import { json } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';

export async function POST({ request }) {
	const { id } = await request.json();

	if (!id) return json({ boxinfo: 'คุณไม่ได้เลือกอาชีพ' }, { status: 400 });

	try {
        /** @type {[any, any]} */
		const [rows] = await pool.execute(
			'SELECT s.skill_name, js.level_skill FROM job_skills js JOIN skills s ON js.skill_id = s.skill_id WHERE js.job_id = ?',
			[id]
		);

        if(rows.length === 0) return json({boxinfo: 'ขณะนี้ยังไม่มีข้อมูล Skills'}, {status: 400});

		return json({ skills: rows });
        
	} catch (error) {
		console.error('Error in call job', error);
		return json({ boxinfo: 'เกิดข้อผิดพลาดจากระบบ' }, { status: 500 });
	}
}
