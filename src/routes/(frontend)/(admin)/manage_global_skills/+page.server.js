import { pool } from '$lib/server/db';

/** @type {import('./$types').PageServerLoad} */
export async function load() {
	try {
		const [skillRows] = await pool.execute(
			`SELECT s.skill_id, s.skill_code, s.skill_name, s.standard_skills, s.description, s.curriculum_id, c.curriculum_name 
             FROM skills s 
             LEFT JOIN curriculum c ON s.curriculum_id = c.curriculum_id`
		);

		const [curriculumRows] = await pool.execute(
			`SELECT curriculum_id, curriculum_name FROM curriculum`
		);

		return {
			skills: skillRows,
			curriculums: curriculumRows
		};
	} catch (error) {
		console.error('Error loading global skills:', error);
		return {
			skills: [],
			curriculums: []
		};
	}
}

/** @type {import('./$types').Actions} */
export const actions = {
	createSkill: async ({ request }) => {
		const data = await request.formData();
		const skill_code = data.get('skill_code')?.toString().trim();
		const skill_name = data.get('skill_name')?.toString().trim();
		const skill_keywords = data.get('skill_keywords')?.toString().trim();
		const skill_description = data.get('skill_description')?.toString().trim();
		const curriculum_id = data.get('curriculum_id');

		try {
			if (!skill_name) {
				return { success: false, message: 'กรุณากรอกชื่อทักษะให้ถูกต้อง 📋' };
			}

			const dbCurriculumId = curriculum_id && curriculum_id !== '' ? Number(curriculum_id) : null;

			// ตรวจสอบชื่อทักษะซ้ำ
			/** @type {[any, any]} */
			const [existing] = await pool.execute(
				'SELECT skill_name FROM skills WHERE skill_name = ? AND curriculum_id = ?',
				[skill_name, dbCurriculumId]
			);

			if (existing.length > 0) {
				return { success: false, message: 'ชื่อทักษะนี้มีอยู่แล้วในหลักสูตรนี้แล้ว ❌' };
			}

			await pool.execute(
				//@ts-ignore
				`INSERT INTO skills (skill_code, skill_name, standard_skills, description, curriculum_id) VALUES (?, ?, ?, ?, ?)`,
				[skill_code, skill_name, skill_keywords, skill_description, dbCurriculumId]
			);

			return { success: true, message: 'เพิ่มทักษะเรียนสำเร็จ ✅' };
		} catch (error) {
			console.error('Error in createSkill:', error);
			return { success: false, message: 'เกิดข้อผิดพลาดในการบันทึกข้อมูล' };
		}
	},

	updateSkill: async ({ request }) => {
		const data = await request.formData();
		const skill_id = data.get('skill_id');
		const skill_code = data.get('skill_code')?.toString().trim();
		const skill_name = data.get('skill_name')?.toString().trim();
		const skill_keywords = data.get('skill_keywords')?.toString().trim();
		const skill_description = data.get('skill_description')?.toString().trim();
		const curriculum_id = data.get('curriculum_id');

		try {
			if (!skill_id || !skill_name) {
				return { success: false, message: 'กรุณากรอกข้อมูลให้ครบถ้วน 📋' };
			}

			const dbCurriculumId = curriculum_id && curriculum_id !== '' ? Number(curriculum_id) : null;

			// ตรวจสอบชื่อทักษะซ้ำกับแถวอื่นที่ไม่ใช่ ID ตัวเราเอง
			/** @type {[any, any]} */
			const [existing] = await pool.execute(
				'SELECT skill_id FROM skills WHERE skill_name = ? AND curriculum_id = ? AND skill_id != ?',
				[skill_name, dbCurriculumId, skill_id]
			);

			if (existing.length > 0) {
				return { success: false, message: 'ชื่อทักษะนี้มีอยู่แล้วในหลักสูตรดังกล่าว ❌' };
			}

			// อัปเดตข้อมูลตามปกติ
			await pool.execute(
				//@ts-ignore
				'UPDATE skills SET skill_code = ?, skill_name = ?, standard_skills = ?, description = ?, curriculum_id = ? WHERE skill_id = ?',
				[skill_code, skill_name, skill_keywords, skill_description, dbCurriculumId, skill_id]
			);

			return { success: true, message: 'แก้ไขข้อมูลทักษะสำเร็จ ✅' };
		} catch (error) {
			console.error('Error in updateSkill:', error);
			return { success: false, message: 'เกิดข้อผิดพลาดในการแก้ไขข้อมูล' };
		}
	},

	deleteSkill: async ({ request }) => {
		const data = await request.formData();
		const skill_id = data.get('skill_id');

		try {
			if (!skill_id) {
				return { success: false, message: 'ไม่พบรหัสทักษะที่ต้องการลบ' };
			}

			await pool.execute('DELETE FROM skills WHERE skill_id = ?', [skill_id]);

			return { success: true, message: 'ลบทักษะสำเร็จ ✅' };
		} catch (error) {
			console.error('Error in deleteSkill:', error);
			return { success: false, message: 'เกิดข้อผิดพลาดในการลบข้อมูล' };
		}
	}
};
