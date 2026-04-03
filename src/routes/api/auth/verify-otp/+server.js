import { json } from '@sveltejs/kit';
import { pool } from '$lib/server/db';

export async function POST({ request }) {
	const {otp} = await request.json();

	if(!otp){return json({boxinfo: 'กรุณากรอกข้อมูล'}, {status: 400});}

	try {
		/** @type {[any, any]} */
		const [rows] = await pool.execute('SELECT username FROM users WHERE otp_code = ?', [otp]);
		if (rows.length === 0) {
			return json({ boxinfo: 'หมายเลข OTP ไม่ถูกต้อง' }, { status: 400 });
		}

        return json({boxinfo: 'รหัส OTP ถูกต้อง✅'}, {status: 201});
	} catch (error) {
		console.error(error);
		return json({ boxinfo: 'เกิดข้อผิดพลาดจากระบบ😱' }, { status: 500 });
	}
}
