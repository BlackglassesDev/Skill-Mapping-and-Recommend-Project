import mysql from 'mysql2/promise';
import { env } from '$env/dynamic/private';

export const pool = mysql.createPool({
    // ต้องมี env. นำหน้าชื่อตัวแปรที่ตั้งไว้ใน .env
    host: env.DB_HOST,
    port: Number(env.DB_PORT) || 3306,
    user: env.DB_USER,
    password: env.DB_PASS,
    database: env.DB_NAME,
    charset: 'utf8mb4',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});