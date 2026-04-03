import { redirect } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';

export async function load({ locals }) {
	// 1. เช็คว่าใน locals มี user หรือไม่ (ข้อมูลนี้มาจาก hooks.server.js ที่เราทำไว้)
	if (!locals.user) {
		// 2. ถ้าไม่มี (ไม่ได้ล็อกอิน) ให้เตะกลับไปหน้า login ทันที
		throw redirect(302, '/login');
	}

	let curri_user = null;

	try {
		/** @type {any[]} */
		const [rows] = await pool.execute('SELECT curriculum_id FROM users WHERE username = ?', [
			locals.user.username
		]);
		if (rows && rows.length > 0) {
			curri_user = rows[0].curriculum_id;
		}

		if (curri_user === null || curri_user === undefined) {
			throw redirect(302, '/grade_users');
		}
	} catch (error) {
		if (error && typeof error === 'object' && 'status' in error) {
			if (error.status === 302 || error.status === 307) {
				throw error;
			}
		}
		console.log('Error: Check user in home page', error);
		return { message: 'เกิดปัญหาการดึงข้อมูล' };
	}

	try {
		const [rows] = await pool.execute(
			'SELECT course_id, course_code, course_name FROM courses WHERE curriculum_id = ?',
			[curri_user]
		);

		return {
			user: locals.user,
			courses: rows
		};
	} catch (error) {
		console.log('Error: Check Curriculum', error);
		return { user: locals.user, courses: [] };
	}
}
