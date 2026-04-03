import { pool } from '$lib/server/db.js';
import { json } from '@sveltejs/kit';
import bcrypt from 'bcrypt';

export async function POST({request}) {
    const {newpass, email} = await request.json();

    if(!newpass){return json({boxinfo: 'กรุณากรอกรหัสใหม่'},{status: 400});}

    try{
        if(newpass.length < 8){
            return json({boxinfo: 'กรุณากรอกรหัสผ่าน 8 ตัวขึ้นไป'}, {status: 400});
        }

        const hashpass = await bcrypt.hash(newpass,10);
        
        await pool.execute('UPDATE users SET password = ? WHERE email = ?', [hashpass,email]);
        return json({ boxinfo: 'บันทึกรหัสผ่านสำเร็จ✅'}, {status: 201});

    }catch(error){
        console.error('บันทึกรหัสผ่านไม่สำเร็จ❌',error);
        return json({ boxinfo: 'การบันทึกรหัสผ่านผิดพลาด!'}, {status: 500});
    }
}