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
    let totalSkills = $derived(data?.stats?.totalSkills ?? 0);
    let totalJobs = $derived(data?.stats?.totalJobs ?? 0);

    // ดึงรายชื่อวิชาล่าสุด หรือ ข้อมูลสถิติย่อยมาโชว์แผงควบคุม
    let recentCourses = $derived(data?.recentCourses ?? []);

    // Path สำหรับย้อนกลับไปหน้า Admin หลัก
    let adminPage = resolve('/adminPage');

    // --- การกระจายระดับทักษะ ฝั่งอาชีพ vs ฝั่งรายวิชา (แยกตามเลเวล 1-6) ---
    let jobSkillDistRaw = $derived(data?.jobSkillDistribution ?? []);
    let courseSkillDistRaw = $derived(data?.courseSkillDistribution ?? []);

    const LEVEL_INFO = [
        { level: 1, name: 'ความเข้าใจเบื้องต้น', bar: 'bg-red-400', text: 'text-red-600' },
        { level: 2, name: 'ประยุกต์ใช้พื้นฐาน', bar: 'bg-orange-400', text: 'text-orange-600' },
        { level: 3, name: 'ปฏิบัติงานได้อิสระ', bar: 'bg-amber-400', text: 'text-amber-600' },
        { level: 4, name: 'แก้ไขปัญหาซับซ้อน', bar: 'bg-lime-500', text: 'text-lime-600' },
        { level: 5, name: 'เชี่ยวชาญเฉพาะทาง', bar: 'bg-emerald-500', text: 'text-emerald-600' },
        { level: 6, name: 'ผู้เชี่ยวชาญ/นวัตกร', bar: 'bg-cyan-500', text: 'text-cyan-600' }
    ];

    function buildDist(rows) {
        const map = new Map();
        for (const r of rows) {
            const lvl = Number(r.level_skill);
            if (lvl >= 1 && lvl <= 6) map.set(lvl, Number(r.count) || 0);
        }
        const total = Array.from(map.values()).reduce((a, b) => a + b, 0);
        return {
            rows: LEVEL_INFO.map((info) => {
                const count = map.get(info.level) || 0;
                const pct = total > 0 ? Math.round((count / total) * 100) : 0;
                return { ...info, count, pct };
            }),
            total
        };
    }

    let jobDist = $derived(buildDist(jobSkillDistRaw));
    let courseDist = $derived(buildDist(courseSkillDistRaw));
</script>

<svelte:head>
    <title>Admin Control</title>
</svelte:head>

<div
    class="min-h-screen bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] py-16 selection:bg-amber-100"
>
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div class="mb-8 rounded-3xl border border-gray-200 bg-white p-6 shadow-sm sm:p-8">
            <div class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left">
                <div class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-gray-100 bg-gray-50 text-2xl shadow-sm">
                    📊
                </div>
                <div class="flex-1 space-y-1">
                    <h1 class="text-2xl font-black tracking-tight text-[#443210] sm:text-3xl">
                        ภาพรวมระบบ<span class="text-[#dca11d]">(Dashboard)</span>
                    </h1>
                    <p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
                        ตรวจสอบสถิติการใช้งาน จำนวนหลักสูตร/วิชา/ทักษะ/อาชีพและหน่วยกิตทั้งหมดในระบบ อัตราการกระจายทักษะของอาชีพและวิชาเรียน และการเพิ่มรายวิชาล่าสุด
                    </p>
                    <div
                        class="mt-2 inline-flex items-center gap-1.5 rounded-full border border-red-100 bg-red-50/60 px-2.5 py-0.5 text-[10px] font-bold text-red-600 uppercase tracking-wider"
                    >
                        <span class="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500"></span>
                        Admin Privileges Only
                    </div>
                </div>
                <div class="flex w-full shrink-0 flex-col gap-2.5 pt-2 md:w-auto md:items-end">
					<a
						href={adminPage}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-black text-gray-500 shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] md:w-full"
					>
						← กลับหน้าควบคุม
					</a>

					<button
						type="button"
						onclick={() => window.open('/api/export-dashboard-csv', '_blank')}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d]"
					>
						📤 ส่งออกข้อมูล(CSV)
					</button>
				</div>
            </div>
        </div>

        <div class="mb-8 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">👥</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">จำนวนผู้ใช้ในระบบ</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalUsers} <span class="text-xs font-medium text-gray-400">คน</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">🏢</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">จำนวนแผนกและหลักสูตร</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalCurriculums} <span class="text-xs font-medium text-gray-400">แผนก</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">📖</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">จำนวนวิชาในระบบ</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalCourses} <span class="text-xs font-medium text-gray-400">วิชา</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">🗄️</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">จำนวนทักษะในระบบ</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalSkills} <span class="text-xs font-medium text-gray-400">ทักษะ</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">💼</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">จำนวนอาชีพในระบบ</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalJobs} <span class="text-xs font-medium text-gray-400">อาชีพ</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">🎯</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">หน่วยกิตสะสมรวม</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalCredits} <span class="text-xs font-medium text-gray-400">หน่วยกิต</span>
                    </p>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <div class="space-y-6 lg:col-span-2">
                <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                    <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                        <h3 class="mb-1 flex items-center gap-2 text-sm font-black text-[#443210]">
                            💼 การกระจายทักษะที่อาชีพเรียกร้อง
                        </h3>
                        <p class="mb-4 text-[11px] font-medium text-gray-400">
                            รวม {jobDist.total} รายการ · สัดส่วนตามเลเวลที่ต้องการ (Occupational Skills)
                        </p>
                        {#if jobDist.total > 0}
                            <div class="space-y-3">
                                {#each jobDist.rows as row (row.level)}
                                    <div>
                                        <div class="mb-1 flex justify-between text-[11px] font-bold">
                                            <span class={row.text}>Level {row.level}: {row.name}</span>
                                            <span class="text-gray-400 font-medium">{row.count} ({row.pct}%)</span>
                                        </div>
                                        <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                                            <div class="h-full rounded-full transition-all duration-500 {row.bar}" style="width: {row.pct}%"></div>
                                        </div>
                                    </div>
                                {/each}
                            </div>
                        {:else}
                            <p class="py-8 text-center text-xs text-gray-400 italic">ยังไม่มีข้อมูลทักษะที่อาชีพเรียกร้อง</p>
                        {/if}
                    </div>

                    <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                        <h3 class="mb-1 flex items-center gap-2 text-sm font-black text-[#443210]">
                            📚 การกระจายทักษะที่รายวิชาสอน
                        </h3>
                        <p class="mb-4 text-[11px] font-medium text-gray-400">
                            รวม {courseDist.total} รายการ · สัดส่วนตามเลเวลที่สอน (Academic Subjects)
                        </p>
                        {#if courseDist.total > 0}
                            <div class="space-y-3">
                                {#each courseDist.rows as row (row.level)}
                                    <div>
                                        <div class="mb-1 flex justify-between text-[11px] font-bold">
                                            <span class={row.text}>Level {row.level}: {row.name}</span>
                                            <span class="text-gray-400 font-medium">{row.count} ({row.pct}%)</span>
                                        </div>
                                        <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                                            <div class="h-full rounded-full transition-all duration-500 {row.bar}" style="width: {row.pct}%"></div>
                                        </div>
                                    </div>
                                {/each}
                            </div>
                        {:else}
                            <p class="py-8 text-center text-xs text-gray-400 italic">ยังไม่มีข้อมูลทักษะที่รายวิชาสอน</p>
                        {/if}
                    </div>
                </div>
            </div>

            <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h3 class="mb-3 flex items-center gap-2 text-sm font-black text-[#443210]">
                    ✨ รายวิชาที่เพิ่มเข้ามาล่าสุด
                </h3>
                <div class="divide-y divide-gray-100">
                    {#each recentCourses as course}
                        <div class="flex flex-col gap-0.5 py-3 text-xs transition-colors hover:bg-gray-50/50 rounded-lg px-1">
                            <span class="font-mono font-black text-[#dca11d]">{course.course_code}</span>
                            <span class="text-sm font-bold text-[#443210]">{course.course_name}</span>
                            <span class="text-gray-400 font-medium">น้ำหนัก: {course.credits} หน่วยกิต</span>
                        </div>
                    {:else}
                        <div class="py-12 text-center text-gray-400 font-medium text-xs">
                            <span class="block text-lg mb-1">📭</span> ยังไม่มีข้อมูลรายวิชาใหม่
                        </div>
                    {/each}
                </div>
            </div>
        </div>

    </div>
</div>