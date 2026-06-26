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
    <title>แผงควบคุมผู้ดูแลระบบ | Skill Mapping</title>
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
                        ภาพรวม<span class="text-[#dca11d]">ระบบควบคุม (Dashboard)</span>
                    </h1>
                    <p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
                        ตรวจสอบผลและสถิติการใช้งานแต่ละภาคเรียน หน่วยกิตภาพรวม และวิเคราะห์โครงสร้างทักษะสะสมจากระบบฐานข้อมูล Skill Mapping
                    </p>
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
						📤 ส่งออกข้อมูลรายวิชา (CSV)
					</button>
				</div>
            </div>
        </div>

        <div class="mb-8 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">👥</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">ผู้ใช้งานระบบทั้งหมด</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalUsers} <span class="text-xs font-medium text-gray-400">คน</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">🏢</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">แผนก / หลักสูตร</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalCurriculums} <span class="text-xs font-medium text-gray-400">แผนก</span>
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner">📖</div>
                <div class="space-y-0.5">
                    <p class="text-xs font-bold tracking-wider text-gray-400 uppercase">รายวิชาในระบบ</p>
                    <p class="text-2xl font-black text-[#443210]">
                        {totalCourses} <span class="text-xs font-medium text-gray-400">วิชา</span>
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
                <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                    <h3 class="mb-5 flex items-center gap-2 text-sm font-black text-[#443210]">
                        📈 สัดส่วนการกระจายระดับการเรียนรู้ (Bloom's Taxonomy)
                    </h3>
                    <div class="space-y-4 pt-1">
                        <div>
                            <div class="mb-1.5 flex justify-between text-xs font-bold">
                                <span class="text-red-600">Level 1: ความจำ (Remembering)</span>
                                <span class="text-gray-400 font-medium">45% ของวิชาทั้งหมด</span>
                            </div>
                            <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                                <div class="h-full rounded-full bg-red-500 transition-all duration-500" style="width: 45%"></div>
                            </div>
                        </div>
                        <div>
                            <div class="mb-1.5 flex justify-between text-xs font-bold">
                                <span class="text-orange-600">Level 2: ความเข้าใจ (Understanding)</span>
                                <span class="text-gray-400 font-medium">60% ของวิชาทั้งหมด</span>
                            </div>
                            <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                                <div class="h-full rounded-full bg-orange-500 transition-all duration-500" style="width: 60%"></div>
                            </div>
                        </div>
                        <div>
                            <div class="mb-1.5 flex justify-between text-xs font-bold">
                                <span class="text-amber-600">Level 3: การประยุกต์ใช้ (Applying)</span>
                                <span class="text-gray-400 font-medium">35% ของวิชาทั้งหมด</span>
                            </div>
                            <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                                <div class="h-full rounded-full bg-amber-500 transition-all duration-500" style="width: 35%"></div>
                            </div>
                        </div>
                        <div>
                            <div class="mb-1.5 flex justify-between text-xs font-bold">
                                <span class="text-emerald-600">Level 4-6: การวิเคราะห์และประเมินค่า (Advanced Skill)</span>
                                <span class="text-gray-400 font-medium">20% ของวิชาทั้งหมด</span>
                            </div>
                            <div class="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                                <div class="h-full rounded-full bg-emerald-500 transition-all duration-500" style="width: 20%"></div>
                            </div>
                        </div>
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