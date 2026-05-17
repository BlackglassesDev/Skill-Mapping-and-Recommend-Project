import { json } from '@sveltejs/kit';
import { pool } from '$lib/server/db';

export async function POST({ request }) {
	const { otp, email } = await request.json();

	if (!otp) {
		return json({ boxinfo: 'กรุณากรอกข้อมูล' }, { status: 400 });
	}

	try {
		/** @type {[any, any]} */
		const [rows] = await pool.execute(
			`SELECT username FROM users WHERE email = ? AND otp_code = ? AND otp_expires > DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR)`,
			[email, otp]
		);
		if (rows.length === 0) {
			return json({ boxinfo: 'หมายเลข OTP ไม่ถูกต้อง หรือหมดอายุ' }, { status: 400 });
		}

		await pool.execute('UPDATE users SET otp_code = NULL, otp_expires = NULL WHERE email = ?', [
			email
		]);

		return json({ boxinfo: 'รหัส OTP ถูกต้อง✅' }, { status: 200 });
	} catch (error) {
		console.error(error);
		return json({ boxinfo: 'เกิดข้อผิดพลาดจากระบบ😱' }, { status: 500 });
	}
}
