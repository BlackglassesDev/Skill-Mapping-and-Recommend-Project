import { pool } from '$lib/server/db.js';
import { json } from '@sveltejs/kit';
import bcrypt from 'bcrypt';

/** @type {import('./$types').RequestHandler} */
export async function POST({request}) {
    const {newPassword, email, otp} = await request.json();

    /** @type {[any, any]} */
		const [rows] = await pool.execute(
			`SELECT username FROM users WHERE email = ? AND otp_code = ? AND otp_expires > DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR)`,
			[email, otp]
		);
		if (rows.length === 0) {
			return json({ boxinfo: 'ขั้นตอนดำเนินการไม่ถูกต้อง' }, { status: 400 });
		}

    if(newPassword.length < 8){
            return json({boxinfo: 'กรุณากรอกรหัสผ่าน 8 ตัวขึ้นไป'}, {status: 400});
    }

    if(!newPassword){return json({boxinfo: 'กรุณากรอกรหัสใหม่'},{status: 400});}

    try{
        
        const hashpass = await bcrypt.hash(newPassword,10);
        
        await pool.execute('UPDATE users SET password = ? WHERE email = ?', [hashpass,email]);
        return json({ boxinfo: 'บันทึกรหัสผ่านสำเร็จ✅'}, {status: 200});

    }catch(error){
        console.error('บันทึกรหัสผ่านไม่สำเร็จ❌',error);
        return json({ boxinfo: 'การบันทึกรหัสผ่านผิดพลาด!'}, {status: 500});
    }
}