import { pool } from '$lib/server/db';

/** @type {import('./$types').PageServerLoad} */
export async function load() {
    try {
        const [skillRows] = await pool.execute(
            `SELECT s.skill_id, s.skill_name, s.curriculum_id, c.curriculum_name 
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
        const skill_name = data.get('skill_name')?.toString().trim();
        const curriculum_id = data.get('curriculum_id');

        try {
            if (!skill_name) {
                return { success: false, message: 'กรุณากรอกชื่อทักษะให้ถูกต้อง 📋' };
            }

            // ตรวจสอบชื่อทักษะซ้ำ
            /** @type {[any, any]} */
            const [existing] = await pool.execute(
                'SELECT skill_name FROM skills WHERE skill_name = ?',
                [skill_name]
            );

            if (existing.length > 0) {
                return { success: false, message: 'ทักษะนี้มีอยู่แล้วในระบบ ❌' };
            }

            const dbCurriculumId = curriculum_id && curriculum_id !== '' ? Number(curriculum_id) : null;

            await pool.execute(
                'INSERT INTO skills (skill_name, curriculum_id) VALUES (?, ?)',
                [skill_name, dbCurriculumId]
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
        const skill_name = data.get('skill_name')?.toString().trim();
        const curriculum_id = data.get('curriculum_id');

        try {
            if (!skill_id || !skill_name) {
                return { success: false, message: 'กรุณากรอกข้อมูลให้ครบถ้วน 📋' };
            }

            // ตรวจสอบชื่อทักษะซ้ำที่ไม่ใช่ของตัวเอง
            /** @type {[any, any]} */
            const [existing] = await pool.execute(
                'SELECT skill_id FROM skills WHERE skill_name = ? AND skill_id != ?',
                [skill_name, skill_id]
            );

            if (existing.length > 0) {
                return { success: false, message: 'ชื่อทักษะนี้มีอยู่แล้วในระบบ ❌' };
            }

            const dbCurriculumId = curriculum_id && curriculum_id !== '' ? Number(curriculum_id) : null;

            await pool.execute(
                'UPDATE skills SET skill_name = ?, curriculum_id = ? WHERE skill_id = ?',
                [skill_name, dbCurriculumId, skill_id]
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
