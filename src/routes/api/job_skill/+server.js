import { json } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';

export async function POST({ request }) {
	const { id } = await request.json();

	if (!id) return json({ boxinfo: 'คุณไม่ได้เลือกอาชีพ' }, { status: 400 });

	try {
        /** @type {[any, any]} */
		const [rows] = await pool.execute(
			`SELECT
                s.skill_id,
                s.skill_name,
                js.level_skill AS required_level,
                c.course_id,
                c.course_code,
                c.course_name,
                cs.skill_level AS course_level
            FROM job_skills js
            JOIN skills s ON js.skill_id = s.skill_id
            LEFT JOIN course_skills cs ON cs.skill_id = s.skill_id
            LEFT JOIN courses c ON cs.course_id = c.course_id
            WHERE js.job_id = ?
            ORDER BY s.skill_id, c.course_id`,
			[id]
		);

        if(rows.length === 0) return json({boxinfo: 'ขณะนี้ยังไม่มีข้อมูล Skills'}, {status: 400});

        // จัดกลุ่มผลลัพธ์: ทักษะหนึ่งอาจถูกสอนโดยหลายวิชา (LEFT JOIN ทำให้มีได้หลายแถวต่อทักษะ)
        const grouped = [];
        const map = new Map();
        for (const r of rows) {
            if (!map.has(r.skill_id)) {
                const entry = {
                    skill_id: r.skill_id,
                    skill_name: r.skill_name,
                    required_level: r.required_level,
                    courses: []
                };
                map.set(r.skill_id, entry);
                grouped.push(entry);
            }
            // มี course_id เฉพาะแถวที่ match กับ course_skills (แถวที่ไม่ match จะเป็น NULL)
            if (r.course_id) {
                map.get(r.skill_id).courses.push({
                    course_id: r.course_id,
                    course_code: r.course_code,
                    course_name: r.course_name,
                    course_level: r.course_level
                });
            }
        }

		return json({ skills: grouped });

	} catch (error) {
		console.error('Error in call job', error);
		return json({ boxinfo: 'เกิดข้อผิดพลาดจากระบบ' }, { status: 500 });
	}
}
