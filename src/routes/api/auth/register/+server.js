import { json } from '@sveltejs/kit';
import bcrypt from 'bcrypt'; //เรียกใช้ฟังก์ชันเข้ารหัส
import { pool } from '$lib/server/db.js'; // ตัวนี้คือ $conn ใน PHP ของคุณ
// import { error } from 'console';

export async function POST({request}) {
    try{
        const {full_name,username,email,password} = await request.json();
        //รับค่าเหมือน $username = $_POST['username'];

        if(!full_name || !username || !email || !password){
            return json({ error: 'กรุณากรอกข้อมูลให้ครบ📋' }, { status: 400 });
            //เหมือน echo
        }

        if(password.length<8){
            return json({ error: 'กรุณากรอกรหัสผ่าน 8 ตัวขึ้นไป'}, {status: 401});
        }

        /** @type {[any, any]} */
        const [rows] = await pool.query(
            'SELECT * FROM users WHERE username = ? OR email = ?',
            [username, email]
        ); //เหมือนเรียกดูข้อมูลใน php | await pool.query(sql, [params])

        if(rows.length>0){ //เหมือน $result->num_rows
            return json({error: 'ชื่อผู้ใช้หรืออีเมลนี้มีการใช้งานอยู่แล้ว!🤔'},{status: 400});
        }

        //เข้ารหัสแบบ $hash = password_hash($pass, PASSWORD_DEFUALT)
        const hashedPassword = await bcrypt.hash(password, 10);

        // บันทึกข้อมูล (เหมือน SQL INSERT ใน PHP) ---
        await pool.query(
            'INSERT INTO users (full_name,username, email, password) VALUES (?, ?, ?, ?)',
            [full_name,username, email, hashedPassword]
        );

        return json({message: 'ลงทะเบียนสำเร็จ✅'},{status: 201});
    }catch (error){
        console.error(error);
        return json({ error: 'เกิดข้อผิดพลาดที่ระบบ' }, { status: 500 });
    }
}