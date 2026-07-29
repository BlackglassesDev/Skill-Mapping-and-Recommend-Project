import { redirect, fail } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';
import bcrypt from 'bcrypt';
import nodemailer from 'nodemailer';
import { env } from '$env/dynamic/private';

/** @type {import('./$types').PageServerLoad} */
export async function load({ locals }) {
	if (locals.user) {
		throw redirect(302, '/home');
	}
	return {};
}

// ถ้ากรอกเป็นอีเมล ให้ใช้อีเมลนั้นส่ง OTP โดยตรง
// ถ้ากรอกเป็นชื่อผู้ใช้ ให้ค้นหาอีเมลของบัญชีจากชื่อผู้ใช้ แล้วส่ง OTP ไปยังอีเมลนั้นแทน
/** @param {any} identifier */
async function resolveEmail(identifier) {
	const id = String(identifier ?? '').trim();
	if (!id) return null;

	const isEmail = id.includes('@');
	/** @type {[any, any]} */
	const [rows] = await pool.execute(
		isEmail
			? 'SELECT email FROM users WHERE email = ? LIMIT 1'
			: 'SELECT email FROM users WHERE username = ? LIMIT 1',
		[id]
	);
	return rows.length ? rows[0].email : null;
}

/** @type {import('./$types').Actions} */
export const actions = {
	sendotp: async ({ request }) => {
		const data = await request.formData();
		const identifier = data.get('identifier');

		try {
			// หาอีเมลจากอีเมลที่กรอกโดยตรง หรือจากชื่อผู้ใช้
			const email = await resolveEmail(identifier);
			if (!email) {
				return fail(400, { boxinfo: 'ไม่พบบัญชีที่ตรงกับชื่อผู้ใช้หรืออีเมลนี้❌' });
			}

			// ตรวจสอบฝั่งเซิร์ฟเวอร์: หากยังมี OTP ที่ใช้งานได้อยู่ (ยังไม่หมดอายุภายใน 5 นาที)
			// ให้ปฏิเสธคำขอใหม่ เพื่อป้องกันการขอซ้ำ/สแปม (ปลอดภัยกว่าเก็บเวลาที่ฝั่ง client)
			/** @type {[any, any]} */
			const [active] = await pool.execute(
				`SELECT TIMESTAMPDIFF(SECOND, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR), otp_expires) AS remaining
				 FROM users
				 WHERE email = ? AND otp_expires > DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR)
				 LIMIT 1`,
				[email]
			);
			if (active.length > 0) {
				const remaining = Math.max(1, Number(active[0].remaining) || 1);
				return fail(429, {
					boxinfo: `คุณเพิ่งขอรหัส OTP ไป กรุณารออีกประมาณ ${Math.ceil(remaining / 60)} นาทีก่อนขอรหัสใหม่❌`,
					cooldown: remaining
				});
			}

			// สุ่มเลข OTP 6 หลัก แล้วบันทึกลงฐานข้อมูล (หมดอายุใน 5 นาที)
			const otp = Math.floor(100000 + Math.random() * 900000).toString();
			await pool.execute(
				`UPDATE users SET otp_code = ?, otp_expires = DATE_ADD(UTC_TIMESTAMP(), INTERVAL '7:5' HOUR_MINUTE) WHERE email = ?`,
				[otp, email]
			);

			// ส่งอีเมลจริง
			const transporter = nodemailer.createTransport({
				service: 'gmail',
				auth: {
					user: env.MAIL_SKILL_WEB,
					pass: env.PASS_MAIL
				}
			});

			await transporter.sendMail({
				from: `"Skill Mapping Support" <${env.MAIL_SKILL_WEB}>`,
				to: email,
				subject: 'รหัสยืนยันการเปลี่ยนรหัสผ่าน',
				text: `รหัส OTP ของคุณคือ: ${otp} (ใช้งานได้ใน 5 นาที)`
			});

			return { success: true, otpSent: true, resolvedEmail: email, boxinfo: 'ส่งรหัส OTP สำเร็จ✅' };
		} catch (error) {
			console.error('Error in sendotp', error);
			return fail(500, { boxinfo: 'ส่งอีเมลไม่สำเร็จ❌' });
		}
	},

	reset: async ({ request }) => {
		const data = await request.formData();
		const identifier = data.get('identifier');
		const otp = data.get('otp');
		const newPassword = data.get('newPassword');

		try {
			// หาอีเมลจากอีเมลที่กรอกโดยตรง หรือจากชื่อผู้ใช้
			const email = await resolveEmail(identifier);
			if (!email) {
				return fail(400, { boxinfo: 'ไม่พบบัญชีที่ตรงกับชื่อผู้ใช้หรืออีเมลนี้❌' });
			}

			if (!/^\d{6}$/.test(String(otp))) {
				return fail(401, { boxinfo: 'รหัส OTP ต้องเป็นตัวเลข 6 หลัก❌' });
			}

			// ตรวจสอบความถูกต้องของ OTP กับฐานข้อมูลโดยตรง
			/** @type {[any, any]} */
			const [rows] = await pool.execute(
				`SELECT username FROM users WHERE email = ? AND otp_code = ? AND otp_expires > DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR)`,
				[email, String(otp)]
			);
			if (rows.length === 0) {
				return fail(400, { boxinfo: 'หมายเลข OTP ไม่ถูกต้อง หรือหมดอายุ❌' });
			}

			const passwordPolicy = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/;
			if (!passwordPolicy.test(String(newPassword))) {
				return fail(401, {
					boxinfo: 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร รวมตัวเล็ก ตัวใหญ่ ตัวเลข และอักขระพิเศษ❌'
				});
			}

			// เข้ารหัสและบันทึกรหัสผ่านใหม่ พร้อมล้าง OTP
			const hashpass = await bcrypt.hash(String(newPassword), 10);
			await pool.execute(
				'UPDATE users SET password = ?, otp_code = NULL, otp_expires = NULL WHERE email = ?',
				[hashpass, email]
			);

			return { success: true, done: true, boxinfo: 'ตั้งรหัสผ่านใหม่สำเร็จ✅' };
		} catch (error) {
			console.error('Error in reset', error);
			return fail(500, { boxinfo: 'การบันทึกรหัสผ่านผิดพลาด❌' });
		}
	}
};
