import { json } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken'; // 1. นำเข้า JWT
import { env } from '$env/dynamic/private'; // 2. ดึง Secret Key จาก .env

export async function POST({ request, cookies }) {
    try {
        const { username, password } = await request.json();

        // เช็คข้อมูลว่างเหมือนเดิม
        if (!username || !password) {
            return json({ message: 'กรุณากรอกข้อมูลให้ครบ📋' }, { status: 400 });
        }

        /** @type {any[]} */
        const [rows] = await pool.execute('SELECT * FROM users WHERE username = ?', [username]);
        const user = rows[0];

        // เช็คว่ามี User หรือไม่
        if (!user) {
            return json({ message: 'ชื่อผู้ใช้ไม่ถูกต้องหรือรหัสผ่านไม่ถูกต้อง!❌' }, { status: 401 });
        }

        // ตรวจสอบรหัสผ่านด้วย bcrypt
        const verifyPass = await bcrypt.compare(password, user.password);
        if (!verifyPass) {
            return json({ message: 'ชื่อผู้ใช้ไม่ถูกต้องหรือรหัสผ่านไม่ถูกต้อง!❌' }, { status: 401 });
        }

        // --- เริ่มส่วน JWT ---
        
        // 3. สร้าง Payload (ข้อมูลที่เราต้องการเก็บไว้ใน Token)
        const payload = {
            username: user.username,
            role: user.role,
        };

        // 4. สร้าง Token และเซ็นลายเซ็นดิจิทัล
        const token = jwt.sign(payload, env.APP_SECRET, { expiresIn: '1d' });

        // 5. ส่ง Token ลง Cookie แทน username ตรงๆ
        cookies.set('session', token, {
            path: '/',
            httpOnly: true, // ป้องกัน XSS (Script แอบอ่านไม่ได้)
            sameSite: 'strict',
            secure: process.env.NODE_ENV === 'production', // ใช้ Secure เฉพาะตอนขึ้น Server จริง
            maxAge: 60 * 60 * 24 // อยู่ได้ 1 วัน
        });

        return json({ message: 'เข้าสู่ระบบสำเร็จ✅' }, { status: 200 });

    } catch (error) {
        console.error('LOGIN API ERROR:', error);
        return json({ error: 'เกิดข้อผิดพลาดที่ระบบ' }, { status: 500 });
    }
}