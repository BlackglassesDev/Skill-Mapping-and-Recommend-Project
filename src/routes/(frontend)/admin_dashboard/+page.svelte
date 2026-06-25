<script>
    //@ts-nocheck
    import { resolve } from '$app/paths';

    // รับข้อมูลสถิติมาจาก +page.server.js (เช่น นับจำนวนผู้ใช้, วิชา, แผนก)
    let { data } = $props();

    // นำค่าสถิติต่างๆ มาตั้งต้นเป็น $derived state (ใส่ fallback ป้องกันพังถ้าไม่มีข้อมูล)
    let totalUsers = $derived(data?.stats?.totalUsers ?? 0);
    let totalCourses = $derived(data?.stats?.totalCourses ?? 0);
    let totalCurriculums = $derived(data?.stats?.totalCurriculums ?? 0);
    let totalCredits = $derived(data?.stats?.totalCredits ?? 0);

    // ดึงรายชื่อวิชาล่าสุด หรือ ข้อมูลสถิติย่อยมาโชว์แผงควบคุม
    let recentCourses = $derived(data?.recentCourses ?? []);

    // Path สำหรับย้อนกลับไปหน้า Admin หลัก
    let adminPage = resolve('/adminPage');
</script>

<svelte:head>
    <title>Skill Mapping | ADMIN | Dashboard</title>
</svelte:head>

<div class="min-h-screen bg-gray-50 bg-[linear-gradient(to_right,#80808018_1px,transparent_1px),linear-gradient(to_bottom,#80808018_1px,transparent_1px)] bg-[size:24px_24px] py-16">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div class="mb-8 rounded-3xl border-2 border-gray-100 bg-white p-6 shadow-sm sm:p-8">
            <div class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left">
                <div class="inline-flex h-14 w-14 shrink-0 animate-pulse items-center justify-center rounded-2xl border border-emerald-200 bg-emerald-100 text-2xl text-emerald-700 shadow-sm">
                    📊
                </div>
                <div class="flex-1 space-y-1.5">
                    <h1 class="text-2xl font-extrabold tracking-tight text-[#443210] sm:text-3xl">
                        ภาพรวม<span class="text-[#dca11d]">ระบบควบคุม (Dashboard)</span>
                    </h1>
                    <p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-500">
                        ตรวจสอบผลและสถิติการใช้งานแต่ละภาคเรียน หน่วยกิตภาพรวม และวิเคราะห์โครงสร้างทักษะสะสมจากระบบฐานข้อมูล Skill Mapping
                    </p>
                </div>
                <div class="flex w-full shrink-0 flex-col gap-3 pt-2 md:w-auto md:items-end">
                    <a href={adminPage} class="inline-flex items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-bold text-gray-500 shadow-sm transition-all hover:-translate-y-0.5 hover:bg-gray-50 md:w-full">
                        ← กลับหน้าควบคุมหลัก
                    </a>
                    <button type="button" onclick={() => window.open('/api/export-dashboard', '_blank')} class="inline-flex items-center justify-center gap-2 rounded-2xl border-2 border-emerald-200 bg-emerald-50 px-4 py-2.5 text-xs font-black text-emerald-700 shadow-sm transition-all hover:-translate-y-0.5 hover:bg-emerald-100 md:w-full">
                        📥 ส่งออกรายงานภาพรวม
                    </button>
                </div>
            </div>
        </div>

        <div class="mb-8 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
            <div class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl border border-blue-200 bg-blue-100 text-2xl text-blue-700">👥</div>
                <div>
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">ผู้ใช้งานระบบทั้งหมด</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalUsers} <span class="text-sm font-normal text-gray-400">คน</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl border border-amber-200 bg-amber-100 text-2xl text-amber-700">🏢</div>
                <div>
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">แผนก / หลักสูตร</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalCurriculums} <span class="text-sm font-normal text-gray-400">แผนก</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl border border-purple-200 bg-purple-100 text-2xl text-purple-700">📖</div>
                <div>
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">รายวิชาในระบบ</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalCourses} <span class="text-sm font-normal text-gray-400">วิชา</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl border border-emerald-200 bg-emerald-100 text-2xl text-emerald-700">🎯</div>
                <div>
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">หน่วยกิตสะสมรวม</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalCredits} <span class="text-sm font-normal text-gray-400">หน่วยกิต</span>
                    </p>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <div class="space-y-6 lg:col-span-2">
                <div class="rounded-[28px] border-2 border-gray-200/90 bg-white p-6 shadow-[0_12px_36px_rgba(0,0,0,0.06)]">
                    <h3 class="mb-4 flex items-center gap-2 text-base font-extrabold text-[#443210]">📈 สัดส่วนการกระจายระดับการเรียนรู้ (Bloom's Taxonomy) ของรายวิชาทั้งหมด</h3>
                    <div class="space-y-4 pt-2">
                        <div>
                            <div class="mb-1 flex justify-between text-xs font-bold">
                                <span class="text-red-600">Level 1: ความจำ (Remembering)</span>
                                <span class="text-gray-500">45% ของวิชาทั้งหมด</span>
                            </div>
                            <div class="h-3 w-full overflow-hidden rounded-full bg-gray-100"><div class="h-full rounded-full bg-red-500" style="width: 45%"></div></div>
                        </div>
                        <div>
                            <div class="mb-1 flex justify-between text-xs font-bold">
                                <span class="text-orange-600">Level 2: ความเข้าใจ (Understanding)</span>
                                <span class="text-gray-500">60% ของวิชาทั้งหมด</span>
                            </div>
                            <div class="h-3 w-full overflow-hidden rounded-full bg-gray-100"><div class="h-full rounded-full bg-orange-500" style="width: 60%"></div></div>
                        </div>
                        <div>
                            <div class="mb-1 flex justify-between text-xs font-bold">
                                <span class="text-yellow-600">Level 3: การประยุกต์ใช้ (Applying)</span>
                                <span class="text-gray-500">35% ของวิชาทั้งหมด</span>
                            </div>
                            <div class="h-3 w-full overflow-hidden rounded-full bg-gray-100"><div class="h-full rounded-full bg-yellow-500" style="width: 35%"></div></div>
                        </div>
                        <div>
                            <div class="mb-1 flex justify-between text-xs font-bold">
                                <span class="text-green-600">Level 4-6: การวิเคราะห์และประเมินค่า (Advanced Skill)</span>
                                <span class="text-gray-500">20% ของวิชาทั้งหมด</span>
                            </div>
                            <div class="h-3 w-full overflow-hidden rounded-full bg-gray-100"><div class="h-full rounded-full bg-green-500" style="width: 20%"></div></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="rounded-[28px] border-2 border-gray-200/90 bg-white p-6 shadow-[0_12px_36px_rgba(0,0,0,0.06)]">
                <h3 class="mb-4 flex items-center gap-2 text-base font-extrabold text-[#443210]">✨ รายวิชาที่เพิ่มเข้ามาล่าสุด</h3>
                <div class="divide-y divide-gray-100">
                    {#each recentCourses as course}
                        <div class="flex flex-col gap-1 py-3 text-xs">
                            <span class="font-mono font-black text-[#dca11d]">{course.course_code}</span>
                            <span class="text-sm font-bold text-[#443210]">{course.course_name}</span>
                            <span class="text-gray-400">น้ำหนัก: {course.credits} หน่วยกิต</span>
                        </div>
                    {:else}
                        <div class="py-8 text-center text-gray-400 font-medium">📭 ยังไม่มีข้อมูลรายวิชาใหม่</div>
                    {/each}
                </div>
            </div>
        </div>

    </div>
</div>