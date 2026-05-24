import { error } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';

export async function load({ locals }) {
	// ระบบป้องกัน: ถ้ายังไม่ Login ข้อมูล user จะส่งไปเป็น null (ฝั่ง Svelte จะเปิด Modal เตือน)

	if (locals.user) {
		try {
			const [rows] = await pool.execute('SELECT curriculum_id FROM users WHERE username = ?', [
				locals.user?.username
			]);

            // @ts-ignore
			return { hasCurriculum: !!rows[0]?.curriculum_id };
		} catch (error) {
			console.error('Error checking curriculum_id:', error);
			return { hasCurriculum: false };
		}
	}
	return {
		// user: locals.user || null,
		// // ตัวอย่างโครงสร้างข้อมูลจำลองเพื่อเอาไปเรนเดอร์สไตล์เป๊ะๆ
		// summary: {
		//     passedCoursesCount: 7,
		//     accumulatedSkillsCount: 5,
		//     topSkill: "Frontend",
		//     secondarySkill: "Node Backend"
		// },
		// recommendedCourses: [
		//     { id: 1, code: 'ENGCE312', name: 'การพัฒนาเว็บแอปพลิเคชัน', group: 'ENG', skills: ['Frontend', 'Node Backend'] },
		//     { id: 2, code: 'ENGCE205', name: 'ระบบฐานข้อมูล', group: 'ENG', skills: ['SQL DB', 'NoSQL DB'] }
		// ]
	};
}
