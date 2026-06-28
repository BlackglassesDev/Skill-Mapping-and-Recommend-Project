//@ts-nocheck
import { pool } from '$lib/server/db';
import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').PageServerLoad} */
export async function load({ locals }) {
    if (!locals.user) throw redirect(302, '/');

    try {
        const [teacherRows] = await pool.execute(
            `SELECT u.curriculum_id, c.curriculum_name 
             FROM users u
             LEFT JOIN curriculum c ON u.curriculum_id = c.curriculum_id
             WHERE u.username = ? AND u.role = 'teacher'`,
            [locals.user.username]
        );

        const [curriculumsRows] = await pool.execute(
            `SELECT curriculum_id, curriculum_name FROM curriculum`
        );
        
        /** @type {any} */
        const finalTeacher = teacherRows;
        const teacherData = finalTeacher[0] || null;

        let welcomeMessage = '';
        if (teacherData && teacherData.curriculum_id) {
            const curriculumDisplay = teacherData.curriculum_name || teacherData.curriculum_id;
            welcomeMessage = `ยินดีต้อนรับสู่หน้าจัดการหลักสูตร ${curriculumDisplay}`;
        }

        return {
            teachers: teacherData,
            curriculums: curriculumsRows,
            message: welcomeMessage
        };
    } catch (error) {
        console.error('Failed to load teacher page data:', error);
        return {
            teachers: null,
            curriculums: [],
            message: ''
        };
    }
}

/** @type {import('./$types').Actions} */
export const actions = {
    updateTeacherCurriculum: async ({ request, locals }) => {
        if (!locals.user) {
            return { success: false, message: 'กรุณาล็อกอินเข้าสู่ระบบ' };
        }
        
        const formData = await request.formData();
        const curriculumId = formData.get('curriculum_id');

        try {
            const [updateRows] = await pool.execute(
                `UPDATE users SET curriculum_id = ? WHERE username = ? AND role = 'teacher'`,
                [curriculumId, locals.user.username]
            );

            const [curriculumNameRows] = await pool.execute(
                `SELECT curriculum_name FROM curriculum WHERE curriculum_id = ?`,
                [curriculumId]
            );

            const curriculumDisplay = curriculumNameRows[0].curriculum_name;

            return { success: true, message: `ยินดีต้อนรับสู่หน้าจัดการหลักสูตร ${curriculumDisplay}` };
        } catch (error) {
            console.error('Failed to update teacher curriculum:', error);
            return { success: false, message: 'เกิดข้อผิดพลาดในการบันทึกข้อมูลหลักสูตร' };
        }
    }
};