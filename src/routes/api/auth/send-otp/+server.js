import { json } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';
import nodemailer from 'nodemailer';
import {env} from '$env/dynamic/private'

export async function POST({ request }) {
    const { email } = await request.json();

    if(!email){return json({boxinfo: 'กรุณากรอกข้อมูลให้ครบถ้วน'}, {status: 400});}

    // 1. เช็คว่ามีเมลนี้ไหม
    /** @type {[any, any]} */
    const [rows] = await pool.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (rows.length === 0) return json({ boxinfo: 'ไม่พบอีเมลนี้' }, { status: 400 });
    
    // 2. สุ่มเลข 6 หลัก
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expires = new Date(Date.now() + 5 * 60 * 1000); // หมดอายุใน 5 นาที

    // 3. บันทึกลง DB
    await pool.execute('UPDATE users SET otp_code = ?, otp_expires = ? WHERE email = ?', [otp, expires, email]);

    // 4. ส่งอีเมลจริง
    const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: env.MAIL_SKILL_WEB,
            pass: env.PASS_MAIL // รหัสผ่านแอป 16 หลักจาก Google
        }
    });

    try {
        await transporter.sendMail({
            from: `"Skill Mapping Support" <${env.MAIL_SKILL_WEB}>`,
            to: email,
            subject: 'รหัสยืนยันการเปลี่ยนรหัสผ่าน',
            text: `รหัส OTP ของคุณคือ: ${otp} (ใช้งานได้ใน 5 นาที)`
        });
        return json({ boxinfo: 'ส่ง OTP สำเร็จ' });
    } catch (error) {
        console.error(error);
        return json({ boxinfo: 'ส่งอีเมลไม่สำเร็จ' }, { status: 500 });
    }
}