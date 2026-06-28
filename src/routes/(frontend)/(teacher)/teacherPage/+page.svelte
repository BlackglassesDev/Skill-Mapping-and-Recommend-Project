<script>
//@ts-nocheck
    // 🛠️ แก้จุดที่ 1: ย้าย enhance ไปดึงจาก $app/forms ให้ถูกต้อง
    import { invalidateAll } from "$app/navigation";
    import { enhance } from "$app/forms";

    /** @type {import('./$types').PageProps} */
    let { data } = $props();
    
    // ส่วนเชื่อมโยงเส้นทางไปยังหน้าต่าง ๆ ของอาจารย์
    let mappingPage = '/mapping-skills';
    let manageCoursesPage = '/manage-courses';
    let dashboardPage = '/course-dashboard';

    let showMessage = $state(false);
    let alertMessage = $state('');

    let teachers = $state(data.teachers);
    // 🛠️ แก้จุดที่ 2: เปลี่ยนชื่อตัวแปรให้ตรงกับคำว่า curriculumList ที่ถูกเรียกใช้ด้านล่างในหลูป each
    let curriculumList = $state(Array.isArray(data.curriculums) ? data.curriculums : []);
    let isCheckCurriculumModalOpen = $state(teachers && (teachers.curriculum_id === null || teachers.curriculum_id === undefined || teachers.curriculum_id === ''));

	$effect(() => {
        if (data?.message) {
            alertMessage = data.message;
            showMessage = true;

            // ตั้งเวลานับถอยหลัง 4 วินาที (4000ms) แล้วทำการปิดแถบสไลด์
            const timer = setTimeout(() => {
                showMessage = false;
            }, 4000);

            // คืนค่าฟังก์ชันเพื่อเคลียร์ timeout ป้องกันบั๊กหน่วยความจำซ้อนทับกัน
            return () => clearTimeout(timer);
        }
    });
</script>

<div
    class="pointer-events-none fixed top-6 right-0 left-0 z-50 flex justify-center p-4 transition-all duration-500 ease-out"
    class:translate-y-0={showMessage}
    class:-translate-y-20={!showMessage}
    class:opacity-100={showMessage}
    class:opacity-0={!showMessage}
>
    <div
        class="pointer-events-auto flex max-w-md items-center gap-3 rounded-2xl border-2 border-gray-200 bg-white px-5 py-3.5 text-sm font-semibold text-[#443210] shadow-[0_10px_30px_rgba(0,0,0,0.08)] animate-fade-in"
    >
        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-amber-50 text-xs border border-amber-200">🔔</span>
        <span class="flex-1 font-medium text-gray-700">{alertMessage}</span>
        <button
            onclick={() => (showMessage = false)}
            class="ml-2 p-1 text-xs text-gray-400 transition-colors hover:text-gray-600"
        >
            ✕
        </button>
    </div>
</div>

<div
    class="min-h-screen bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] py-16 selection:bg-amber-100"
>
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="mb-12 rounded-3xl border border-gray-200 bg-white p-6 shadow-sm sm:p-8">
            <div
                class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left"
            >
                <div
                    class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-gray-100 bg-gray-50 text-2xl shadow-sm"
                >
                    👨‍🏫
                </div>
                <div class="flex-1 space-y-1">
                    <h1 class="text-2xl font-black tracking-tight text-[#443210] sm:text-3xl">
                        ระบบควบคุมสำหรับ<span class="text-[#dca11d]">อาจารย์ผู้สอน</span>
                    </h1>
                    <p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
                        ยินดีต้อนรับสู่ห้องทำงานอาจารย์ กรุณาเลือกเมนูด้านล่างเพื่อจัดการโครงสร้างวิชา
                        แผนผังทักษะ หรือดูรายงานวิเคราะห์หลักสูตร
                    </p>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            <a
                href={mappingPage}
                class="group flex flex-col justify-between rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-[#dca11d] hover:shadow-md"
            >
                <div class="space-y-4">
                    <div
                        class="inline-flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner transition-transform duration-300 group-hover:scale-110"
                    >
                        🗺️
                    </div>
                    <div class="space-y-1.5">
                        <h3
                            class="text-lg font-black text-[#443210] transition-colors group-hover:text-[#dca11d]"
                        >
                            Mapping ทักษะกับหลักสูตร
                        </h3>
                        <p class="text-xs leading-relaxed font-medium text-gray-400">
                            เชื่อมโยงและจัดกลุ่มทักษะความเชี่ยวชาญ (Skill Framework)
                            เข้ากับมาตรฐานวิเคราะห์ของหลักสูตรการศึกษา
                        </p>
                    </div>
                </div>
                <div class="mt-auto flex w-full justify-center border-t border-gray-100 pt-3">
                    <span
                        class="flex translate-y-1 transform items-center gap-1 text-xs font-semibold text-amber-700 opacity-0 transition-all group-hover:translate-y-0 group-hover:opacity-100"
                    >
                        เข้าสู่ระบบผัง mapping-skills ➔
                    </span>
                </div>
            </a>

            <a
                href={manageCoursesPage}
                class="group flex flex-col justify-between rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-[#dca11d] hover:shadow-md"
            >
                <div class="space-y-4">
                    <div
                        class="inline-flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner transition-transform duration-300 group-hover:scale-110"
                    >
                        📚
                    </div>
                    <div class="space-y-1.5">
                        <h3
                            class="text-lg font-black text-[#443210] transition-colors group-hover:text-[#dca11d]"
                        >
                            เพิ่มหรือลบวิชาเรียน
                        </h3>
                        <p class="text-xs leading-relaxed font-medium text-gray-400">
                            จัดการคลังรายวิชาในภาคเรียน เปิดรายวิชาใหม่
                            หรือถอดถอนรายวิชาที่ไม่ได้เปิดสอนออกจากฐานข้อมูลหลัก
                        </p>
                    </div>
                </div>
                <div class="mt-auto flex w-full justify-center border-t border-gray-100 pt-3">
                    <span
                        class="flex translate-y-1 transform items-center gap-1 text-xs font-semibold text-amber-700 opacity-0 transition-all group-hover:translate-y-0 group-hover:opacity-100"
                    >
                        จัดการรายวิชา ➔
                    </span>
                </div>
            </a>

            <a
                href={dashboardPage}
                class="group flex flex-col justify-between rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-[#dca11d] hover:shadow-md sm:col-span-2 lg:col-span-1"
            >
                <div class="space-y-4">
                    <div
                        class="inline-flex h-12 w-12 items-center justify-center rounded-xl border border-gray-100 bg-gray-50 text-xl shadow-inner transition-transform duration-300 group-hover:scale-110"
                    >
                        📈
                    </div>
                    <div class="space-y-1.5">
                        <h3
                            class="text-lg font-black text-[#443210] transition-colors group-hover:text-[#dca11d]"
                        >
                            Dashboard ภาพรวมหลักสูตร
                        </h3>
                        <p class="text-xs leading-relaxed font-medium text-gray-400">
                            วิเคราะห์สถิติตัวชี้วัด สัดส่วน Bloom's Taxonomy
                            และการกระจายตัวของหน่วยกิตวิชาผ่านระบบ Visual Report
                        </p>
                    </div>
                </div>
                <div class="mt-auto flex w-full justify-center border-t border-gray-100 pt-3">
                    <span
                        class="flex translate-y-1 transform items-center gap-1 text-xs font-semibold text-amber-700 opacity-0 transition-all group-hover:translate-y-0 group-hover:opacity-100"
                    >
                        เปิดสถิติวิเคราะห์ ➔
                    </span>
                </div>
            </a>
        </div>
    </div>
</div>

{#if isCheckCurriculumModalOpen}
    <div class="fixed inset-0 z-30 flex items-center justify-center p-4 bg-black/50 p-4 backdrop-blur-sm">
        <div
            class="relative w-full max-w-md overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
        >
            <div class="border-b border-gray-100 px-6 py-4.5">
                <h3 class="text-base font-black text-[#443210]">🎓 ระบุข้อมูลหลักสูตรประจำตัว</h3>
            </div>

            <form
                method="POST"
                action="?/updateTeacherCurriculum"
                use:enhance={() => {
                    return async ({ result }) => {
                        // 🛠️ แก้จุดที่ 3: ปรับโครงสร้างรับผลลัพธ์ของ SvelteKit Form Action ให้สมบูรณ์
                        if (result.type === 'success' && result.data) {
                            alertMessage = result.data.message ?? 'บันทึกข้อมูลหลักสูตรสำเร็จ!';
                            showMessage = true;

                            setTimeout(() => {
                                showMessage = false;
                            }, 4000);

                            if (result.data.success === true) {
                                isCheckCurriculumModalOpen = false;
                                await invalidateAll(); // ดึงข้อมูลโครงสร้างล่าสุดจาก Server ใหม่
                            }
                        } else if (result.type === 'failure' && result.data) {
                            alertMessage = result.data.message ?? 'เกิดข้อผิดพลาด';
                            showMessage = true;
                            setTimeout(() => showMessage = false, 4000);
                        }
                    };
                }}
                class="space-y-4 p-6 text-xs font-bold text-[#443210]"
            >
                <div class="flex items-center gap-4 rounded-2xl border border-amber-100 bg-amber-50/60 p-4">
                    <span class="text-3xl">⚠️</span>
                    <p class="text-xs leading-relaxed font-bold text-[#443210]">
                        ระบบตรวจพบว่า บัญชีอาจารย์ของคุณยังไม่ได้ผูกเข้ากับหลักสูตรวิชาใด ๆ 
                        โปรดระบุหลักสูตร/ภาควิชาต้นสังกัดก่อนเริ่มดำเนินการจัดการ Skill Mapping
                    </p>
                </div>

                <div class="space-y-1.5 pt-2">
                    <label for="teacherCurriculumId" class="text-gray-400 uppercase tracking-wider">
                        เลือกหลักสูตร / ภาควิชาสังกัดของคุณ <span class="text-rose-500">*</span>
                    </label>
                    <div class="relative">
                        <select
                            id="teacherCurriculumId"
                            name="curriculum_id"
                            required
                            class="w-full cursor-pointer appearance-none rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-black outline-none transition-all focus:border-[#dca11d] focus:bg-white"
                        >
                            <option value="" disabled selected>-- โปรดเลือกหลักสูตรของคุณ --</option>
                            {#each curriculumList as item (item.curriculum_id)}
                                <option value={item.curriculum_id}>{item.curriculum_name}</option>
                            {/each}
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[10px] text-gray-400">
                            ▼
                        </div>
                    </div>
                </div>

                <div class="flex justify-end gap-3 border-t border-gray-100 pt-5">
                    <button
                        type="submit"
                        class="cursor-pointer rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
                    >
                        💾 บันทึกข้อมูลหลักสูตร
                    </button>
                </div>
            </form>
        </div>
    </div>
{/if}