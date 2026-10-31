require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');

const app = express();
const prisma = new PrismaClient();

// Middleware
app.use(cors());
app.use(express.json());

// ====== USER ROUTES ======

// Регистрация
app.post('/api/register', async (req, res) => {
  try {
    const { name, login, password, phone } = req.body;
    
    // Проверяем, есть ли уже такой логин
    const existingUser = await prisma.user.findUnique({ where: { login } });
    if (existingUser) {
      return res.status(400).json({ message: 'Пользователь с таким логином уже существует' });
    }
    
    // Создаём пользователя (пароль пока храним без шифрования для простоты)
    const user = await prisma.user.create({
      data: {
        name,
        login,
        password,
        phone: phone || null,
      }
    });
    
    res.json({ id: user.id, name: user.name, login: user.login, phone: user.phone });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'Ошибка сервера' });
  }
});

// Авторизация
app.post('/api/login', async (req, res) => {
  try {
    const { login, password } = req.body;
    
    const user = await prisma.user.findUnique({ where: { login } });
    if (!user || user.password !== password) {
      return res.status(401).json({ message: 'Неверный логин или пароль' });
    }
    
    res.json({ id: user.id, name: user.name, login: user.login, phone: user.phone });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Ошибка сервера' });
  }
});

// Профиль пользователя
app.get('/api/profile/:id', async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: parseInt(req.params.id) },
      include: { rentals: true }
    });
    
    if (!user) {
      return res.status(404).json({ message: 'Пользователь не найден' });
    }
    
    res.json(user);
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ message: 'Ошибка сервера' });
  }
});

// ====== TERMINAL ROUTES ======

// Получить все терминалы
app.get('/api/terminals', async (req, res) => {
  try {
    const terminals = await prisma.terminal.findMany();
    res.json(terminals);
  } catch (error) {
    console.error('Terminals error:', error);
    res.status(500).json({ message: 'Ошибка сервера' });
  }
});

// ====== RENTAL ROUTES ======

// Создать аренду
app.post('/api/rentals', async (req, res) => {
  try {
    const { userId, terminalId } = req.body;
    
    // Проверяем, есть ли активная аренда у пользователя
    const activeRental = await prisma.rental.findFirst({
      where: { userId, isActive: true }
    });
    
    if (activeRental) {
      return res.status(400).json({ message: 'У вас уже есть активная аренда' });
    }
    
    // Проверяем, есть ли зонт в терминале
    const terminal = await prisma.terminal.findUnique({
      where: { id: terminalId }
    });
    
    if (!terminal || terminal.availableUmbrellas <= 0) {
      return res.status(400).json({ message: 'Зонты в этом терминале закончились' });
    }
    
    // Создаём аренду и уменьшаем количество зонтов
    const rental = await prisma.rental.create({
      data: {
        userId,
        terminalId,
      }
    });
    
    await prisma.terminal.update({
      where: { id: terminalId },
      data: { availableUmbrellas: { decrement: 1 } }
    });
    
    res.json(rental);
  } catch (error) {
    console.error('Rental error:', error);
    res.status(500).json({ message: 'Ошибка сервера' });
  }
});

// Завершить аренду
app.post('/api/rentals/:id/end', async (req, res) => {
  try {
    const rental = await prisma.rental.update({
      where: { id: parseInt(req.params.id) },
      data: {
        isActive: false,
        endedAt: new Date(),
      }
    });
    
    // Возвращаем зонт в терминал
    await prisma.terminal.update({
      where: { id: rental.terminalId },
      data: { availableUmbrellas: { increment: 1 } }
    });
    
    res.json(rental);
  } catch (error) {
    console.error('End rental error:', error);
    res.status(500).json({ message: 'Ошибка сервера' });
  }
});

// Получить активную аренду пользователя
app.get('/api/rentals/active/:userId', async (req, res) => {
  try {
    const rental = await prisma.rental.findFirst({
      where: {
        userId: parseInt(req.params.userId),
        isActive: true,
      },
      include: { terminal: true }
    });
    
    res.json(rental || null);
  } catch (error) {
    console.error('Active rental error:', error);
    res.status(500).json({ message: 'Ошибка сервера' });
  }
});

// Получить историю аренд пользователя
app.get('/api/rentals/history/:userId', async (req, res) => {
  try {
    const rentals = await prisma.rental.findMany({
      where: {
        userId: parseInt(req.params.userId),
        isActive: false,
      },
      include: { terminal: true },
      orderBy: { startedAt: 'desc' }
    });
    
    res.json(rentals);
  } catch (error) {
    console.error('History error:', error);
    res.status(500).json({ message: 'Ошибка сервера' });
  }
});

// Запуск сервера
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
