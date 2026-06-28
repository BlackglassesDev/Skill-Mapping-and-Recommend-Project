<script>
    // 1. ตัวแปรสำหรับระบบแจ้งเตือน (Toast Message) ตามต้นแบบ
    let showMessage = false;
    let alertMessage = "";

    function triggerAlert(msg) {
        alertMessage = msg;
        showMessage = true;
        setTimeout(() => { showMessage = false; }, 3000); // หายไปใน 3 วินาที
    }

    // 2. ข้อมูลหลักสูตร (สำหรับตัวเลือก Select)
    let selectedCurriculum = "cpe_67";
    let curriculumList = [
        { curriculum_id: "cpe_67", curriculum_name: "วิศวรรคมคอมพิวเตอร์ (หลักสูตร 2567)" },
        { curriculum_id: "ee_67", curriculum_name: "วิศวกรรมไฟฟ้า (หลักสูตร 2567)" }
    ];

    // 3. คลังข้อมูลรายวิชา (จำลองรองรับข้อมูลจำนวนเยอะเพื่อทดสอบระบบ Pagination)
    let courses = [
        { course_id: 1, course_code: "CPE-101", course_name: "Computer Programming", curriculum_id: "cpe_67" },
        { course_id: 2, course_code: "CPE-221", course_name: "Database Systems", curriculum_id: "cpe_67" },
        { course_id: 3, course_code: "CPE-342", course_name: "Artificial Intelligence", curriculum_id: "cpe_67" },
        { course_id: 4, course_code: "CPE-491", course_name: "Computer Engineering Project I", curriculum_id: "cpe_67" },
        { course_id: 5, course_code: "CPE-212", course_name: "Data Structures and Algorithms", curriculum_id: "cpe_67" },
        { course_id: 6, course_code: "CPE-325", course_name: "Operating Systems", curriculum_id: "cpe_67" },
        { course_id: 7, course_code: "EE-101", course_name: "Electric Circuit Analysis", curriculum_id: "ee_67" }
    ];

    // 4. สเตตัสและตัวแปรค้นหา / แบ่งหน้า
    let searchQuery = "";
    let currentPage = 1;
    const itemsPerPage = 3; // กำหนดให้แสดงหน้าละ 3 แถวตามต้นแบบกรณีข้อมูลเยอะ
    let adminPage = "/adminPage";

    // 5. ⚡️ REACTIVE LOGIC: ระบบกรองค้นหาตามสิทธิ์หลักสูตรและคีย์เวิร์ด (ทำงานจริง)
    $: filteredCourses = courses.filter(course => {
        // กรองด้วยหลักสูตรที่เลือกก่อน
        if (course.curriculum_id !== selectedCurriculum) return false;
        
        // กรองด้วยช่องค้นหา (รหัสวิชา หรือ ชื่อวิชา)
        const query = searchQuery.toLowerCase().trim();
        return (
            course.course_code.toLowerCase().includes(query) ||
            course.course_name.toLowerCase().includes(query)
        );
    });

    // 6. ⚡️ REACTIVE LOGIC: คำนวณระบบแบ่งหน้าถัดไป (Pagination)
    $: totalPages = Math.ceil(filteredCourses.length / itemsPerPage) || 1;
    $: paginatedCourses = filteredCourses.slice(
        (currentPage - 1) * itemsPerPage,
        currentPage * itemsPerPage
    );

    // รีเซ็ตหน้ากลับไปหน้า 1 เสมอเมื่อเปลี่ยนหลักสูตรหรือค้นหาใหม่
    $: if (searchQuery || selectedCurriculum) {
        currentPage = 1;
    }

    // 7. ฟังก์ชันฟังก์ชันปุ่มคำสั่ง (CRUD Actions)
    function openEditModal(course) {
        triggerAlert(`✏️ เปิดหน้าต่างแก้ไขวิชา: ${course.course_code}`);
    }

    function openDeleteModal(course) {
        if (confirm(`🗑️ คุณแน่ใจหรือไม่ที่จะลบวิชา ${course.course_code} ออกจากระบบ?`)) {
            courses = courses.filter(c => c.course_id !== course.course_id);
            triggerAlert(`🗑️ ลบรายวิชาสำเร็จเรียบร้อยแล้ว`);
        }
    }

    function exportCSV() {
        triggerAlert(`📤 กำลังส่งออกไฟล์ CSV ของหลักสูตรที่เลือก...`);
        window.open('/api/export-curriculums', '_blank');
    }
</script>

<div
    class="pointer-events-none fixed top-6 right-0 left-0 z-50 flex justify-center p-4 transition-all duration-500 ease-out"
    class:translate-y-0={showMessage}
    class:-translate-y-20={!showMessage}
    class:opacity-100={showMessage}
    class:opacity-0={!showMessage}
>
    <div
        class="pointer-events-auto flex max-w-md items-center gap-3 rounded-2xl border border-gray-100 bg-white px-5 py-3.5 text-sm font-semibold text-[#443210] shadow-[0_10px_30px_rgba(68,50,16,0.05)]"
    >
        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-amber-50 text-base text-[#dca11d]">🔔</span>
        <span class="flex-1 font-medium text-gray-600">{alertMessage}</span>
        <button
            onclick={() => (showMessage = false)}
            class="ml-2 p-1 text-xs text-gray-400 transition-colors hover:text-[#443210]"
        >
            ✕
        </button>
    </div>
</div>

<div
    class="min-h-screen bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] py-16 selection:bg-amber-100"
>
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div class="mb-8 rounded-3xl border border-gray-200 bg-white p-6 shadow-sm sm:p-8">
            <div class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left">
                <div class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-gray-100 bg-gray-50 text-2xl shadow-sm">
                    📚
                </div>

                <div class="flex-1 space-y-1">
                    <h1 class="text-2xl font-black tracking-tight text-[#443210] sm:text-3xl">
                        ระบบจัดการ<span class="text-[#dca11d]">หลักสูตรและรายวิชา</span>
                    </h1>
                    <p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
                        Curriculum Management — บริหารจัดการโครงสร้างรายวิชาของภาควิชา เพื่อนำข้อมูลไปประมวลผลและการจัดทำแผนผังทักษะ (Skill Mapping)
                    </p>

                    <div class="mt-2 inline-flex items-center gap-1.5 rounded-full border border-red-100 bg-red-50 px-3 py-0.5 text-[10px] font-bold tracking-wider text-red-600 uppercase">
                        <span class="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500"></span>
                        Admin Mode Only
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
                        onclick={exportCSV}
                        class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d]"
                    >
                        📤 ส่งออกข้อมูลรายวิชา (CSV)
                    </button>
                </div>
            </div>
        </div>

        <div class="mb-6 flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
            <div class="grid flex-1 grid-cols-1 gap-4 sm:grid-cols-2 lg:max-w-3xl">
                
                <div class="flex flex-col gap-1.5">
                    <span class="pl-1 text-xs font-medium text-gray-400"> หลักสูตร / ภาควิชาที่เลือก </span>
                    <div class="relative">
                        <select
                            bind:value={selectedCurriculum}
                            class="w-full cursor-pointer appearance-none rounded-xl border border-gray-200 bg-white py-2.5 pr-10 pl-4 text-sm font-black text-[#443210] shadow-sm transition-all outline-none focus:border-[#dca11d] focus:ring-1 focus:ring-[#dca11d]"
                        >
                            {#each curriculumList as item (item.curriculum_id)}
                                <option value={item.curriculum_id}>{item.curriculum_name}</option>
                            {:else}
                                <option value="">❌ ไม่พบข้อมูลหลักสูตรในระบบ</option>
                            {/each}
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[10px] text-gray-400">
                            ▼
                        </div>
                    </div>
                </div>

                <div class="flex flex-col gap-1.5">
                    <span class="pl-1 text-xs font-medium text-gray-400"> ค้นหารายวิชา (กรองสด) </span>
                    <div class="relative">
                        <input
                            type="text"
                            bind:value={searchQuery}
                            placeholder="พิมพ์รหัสวิชา หรือ ชื่อวิชา..."
                            class="w-full rounded-xl border border-gray-200 bg-white py-2.5 pr-4 pl-10 text-sm font-medium text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d] focus:ring-1 focus:ring-[#dca11d]"
                        />
                        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 text-sm text-gray-400">
                            🔍
                        </div>
                        {#if searchQuery}
                            <button
                                type="button"
                                onclick={() => (searchQuery = '')}
                                class="absolute inset-y-0 right-0 flex items-center pr-3 text-xs font-bold text-gray-400 hover:text-gray-600"
                            >
                                ✕ ล้าง
                            </button>
                        {/if}
                    </div>
                </div>
            </div>

            <div class="flex flex-col gap-2.5 sm:flex-row sm:items-center sm:justify-end">
                <button
                    type="button"
                    onclick={() => triggerAlert('➕ เปิด Modal เพิ่มรายวิชาใหม่')}
                    class="inline-flex w-full cursor-pointer items-center justify-center gap-2 rounded-xl bg-[#443210] px-5 py-2.5 text-sm font-bold text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] sm:w-auto"
                >
                    ➕ เพิ่มรายวิชาใหม่
                </button>

                <button
                    type="button"
                    onclick={() => triggerAlert('➕ เปิด Modal เพิ่มหลักสูตรต้นทาง')}
                    class="inline-flex w-full cursor-pointer items-center justify-center gap-2 rounded-xl bg-[#443210] px-5 py-2.5 text-sm font-bold text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] sm:w-auto"
                >
                    ➕ เพิ่มหลักสูตร
                </button>
            </div>
        </div>

        <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left text-sm text-gray-500">
                    <thead class="border-b border-gray-200 bg-gray-50/70 text-xs font-bold tracking-wider text-gray-400 uppercase">
                        <tr>
                            <th class="w-1/4 px-6 py-4 font-bold">รหัสวิชา</th>
                            <th class="w-1/2 px-6 py-4 font-bold">ชื่อรายวิชา (TH / EN)</th>
                            <th class="w-1/4 px-6 py-4 font-bold">โครงสร้างหลักสูตร</th>
                            <th class="px-6 py-4 text-center font-bold">การจัดการ</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 font-medium text-gray-700">
                        {#each paginatedCourses as course (course.course_id)}
                            <tr class="transition-colors duration-150 odd:bg-white even:bg-gray-50/30 hover:bg-gray-50">
                                <td class="px-6 py-4 font-mono font-bold tracking-wide text-[#dca11d]">
                                    {course.course_code}
                                </td>
                                <td class="px-6 py-4">
                                    <span class="block text-sm font-black text-[#443210]">
                                        {course.course_name}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center rounded-lg border border-gray-200 bg-gray-50 px-2.5 py-1 text-xs font-bold text-gray-600">
                                        {curriculumList.find((c) => c.curriculum_id === course.curriculum_id)?.curriculum_name || 'วิศวกรรมคอมพิวเตอร์'}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center whitespace-nowrap">
                                    <div class="flex items-center justify-center gap-2">
                                        <button
                                            onclick={() => openEditModal(course)}
                                            class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-black text-gray-600 shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d]"
                                        >
                                            ✏️ แก้ไขข้อมูล
                                        </button>
                                        <button
                                            onclick={() => openDeleteModal(course)}
                                            class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-black text-rose-500 shadow-sm transition-all hover:border-rose-400 hover:bg-rose-50/50"
                                        >
                                            🗑️ ลบรายวิชา
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        {:else}
                            <tr>
                                <td colspan="4" class="px-6 py-20">
                                    <div class="mx-auto flex max-w-sm flex-col items-center text-center">
                                        <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gray-50 text-xl border border-gray-100 text-gray-400 mb-3">
                                            💨
                                        </div>
                                        <h3 class="text-sm font-bold text-[#443210]">ไม่พบข้อมูลรายวิชา</h3>
                                        <p class="mt-1 text-xs leading-relaxed text-gray-400">
                                            ไม่พบข้อมูลที่ตรงกับเงื่อนไขหลักสูตรหรือคำค้นหาของคุณ <br /> กรุณาลองระบุคำค้นหาใหม่อีกครั้ง หรือเพิ่มรายวิชาเข้าสู่ระบบ
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </div>

            {#if filteredCourses.length > 0}
                <div class="flex flex-col items-center justify-between gap-4 border-t border-gray-200 bg-gray-50/50 px-6 py-4 sm:flex-row">
                    <span class="text-xs font-medium text-gray-400">
                        แสดงข้อมูลหน้า <span class="font-semibold text-gray-700">{currentPage}</span> จากทั้งหมด
                        <span class="font-semibold text-gray-700">{totalPages}</span> หน้า (รวมทั้งสิ้น {filteredCourses.length} รายวิชา)
                    </span>

                    <div class="inline-flex items-center gap-1.5">
                        <button
                            type="button"
                            onclick={() => (currentPage = 1)}
                            disabled={currentPage === 1}
                            class="cursor-pointer rounded-lg border border-gray-200 bg-white p-2 text-xs font-bold text-gray-700 shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                            title="หน้าแรกสุด"
                        >
                            «
                        </button>

                        <button
                            type="button"
                            onclick={() => (currentPage = Math.max(1, currentPage - 1))}
                            disabled={currentPage === 1}
                            class="inline-flex cursor-pointer items-center justify-center gap-1.5 rounded-lg border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-gray-700 shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                        >
                            ◀ ก่อนหน้า
                        </button>

                        <button
                            type="button"
                            onclick={() => (currentPage = Math.min(totalPages, currentPage + 1))}
                            disabled={currentPage === totalPages}
                            class="inline-flex cursor-pointer items-center justify-center gap-1.5 rounded-lg border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-gray-700 shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                        >
                            ถัดไป ▶
                        </button>

                        <button
                            type="button"
                            onclick={() => (currentPage = totalPages)}
                            disabled={currentPage === totalPages}
                            class="cursor-pointer rounded-lg border border-gray-200 bg-white p-2 text-xs font-bold text-gray-700 shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                            title="หน้าสุดท้าย"
                        >
                            »
                        </button>
                    </div>
                </div>
            {/if}
        </div>
    </div>
</div>