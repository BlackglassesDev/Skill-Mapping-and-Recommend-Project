/** @type {import('./$types').PageServerLoad} */
import { pool } from '$lib/server/db';

export async function load() {
    try {
        const [userRows] = await pool.execute(
            `SELECT
                u.id,
                u.full_name,
                u.username,
                u.email,
                u.role,
                u.curriculum_id,
                cl.curriculum_name AS department
            FROM users u
            LEFT JOIN curriculum cl ON u.curriculum_id = cl.curriculum_id` // LEFT JOIN เผื่อกรณีแอดมินไม่มี curriculum_id จะได้ไม่หลุดหายไปจากตาราง
        );

        const [curriculumRows] = await pool.execute(
            `SELECT curriculum_id, curriculum_name FROM curriculum ORDER BY curriculum_name`
        );

        return {
            users: userRows,
            curriculums: curriculumRows
        };
    } catch (error) {
        console.error('fail load information page:', error);
        return {
            users: [],
            curriculums: []
        };
    }
}

/** @type {import('./$types').Actions} */
export const actions = {
    updateUser: async ({ request }) => {
        const formData = await request.formData();
        const id = formData.get('id');
        const username = formData.get('username');
        const email = formData.get('email');
        const full_name = formData.get('full_name');
        const role = formData.get('role');
        const curriculum_id = formData.get('curriculum_id');

        try {
            // ทำการ UPDATE ข้อมูลลงตาราง users บน MySQL
            await pool.execute(
                `UPDATE users
                SET username = ?, email = ?, full_name = ?, role = ?, curriculum_id = ?
                WHERE id = ?`,
                [username, email, full_name, role, role === 'student' ? (curriculum_id || null) : null, id]
            );

            return { success: true };
        } catch (error) {
            console.error('Fail to update user in DB:', error);
            return { success: false, message: 'เกิดข้อผิดพลาดในการบันทึกข้อมูลลงฐานข้อมูล' };
        }
    },

    deleteUser: async ({ request }) => {
        const formData = await request.formData();
        const id = formData.get('id');

        try {
            // สั่ง DELETE ข้อมูลออกจากตาราง users
            await pool.execute(
                `DELETE FROM users WHERE id = ?`,
                [id]
            );

            return { success: true };
        } catch (error) {
            console.error('Fail to delete user from DB:', error);
            return { success: false, message: 'เกิดข้อผิดพลาด ไม่สามารถลบผู้ใช้งานได้' };
        }
    }
};