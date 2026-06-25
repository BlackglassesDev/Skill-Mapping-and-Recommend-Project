import { pool } from '$lib/server/db';

export const load = async () => {
    try {
        /** @type {any[]} */
        // 1. นับจำนวนผู้ใช้ทั้งหมด (แกะ rows ออกมาตัวเดียวก่อน)
        const [userRows] = await pool.execute('SELECT COUNT(*) as totalUsers FROM users');
        const totalUsers = userRows[0]?.totalUsers ?? 0;
        
        // 2. นับจำนวนวิชาทั้งหมด
        /** @type {any[]} */
        const [courseRows] = await pool.execute('SELECT COUNT(*) as totalCourses FROM courses');
        const totalCourses = courseRows[0]?.totalCourses ?? 0;
        
        // 3. นับจำนวนหลักสูตร/แผนก
        /** @type {any[]} */
        const [curriculumRows] = await pool.execute('SELECT COUNT(*) as totalCurriculums FROM curriculum');
        const totalCurriculums = curriculumRows[0]?.totalCurriculums ?? 0;
        
        // 4. สรุปผลรวมหน่วยกิตทั้งหมดในระบบ
        /** @type {any[]} */
        const [creditRows] = await pool.execute('SELECT SUM(credits) as totalCredits FROM courses');
        const totalCredits = creditRows[0]?.totalCredits ?? 0;

        // 5. ดึงวิชาล่าสุด 5 วิชามาโชว์ที่ Sidebar
        const [recentCourses] = await pool.execute(
            'SELECT course_code, course_name, credits FROM courses ORDER BY curriculum_id DESC LIMIT 5'
        );

        return {
            stats: {
                totalUsers,
                totalCourses,
                totalCurriculums,
                totalCredits: totalCredits || 0
            },
            recentCourses: recentCourses || []
        };
    } catch (err) {
        console.error('Dashboard Load Error:', err);
        return {
            stats: { totalUsers: 0, totalCourses: 0, totalCurriculums: 0, totalCredits: 0 },
            recentCourses: []
        };
    }
};