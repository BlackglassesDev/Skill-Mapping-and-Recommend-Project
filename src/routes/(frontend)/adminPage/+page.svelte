<script>
    import { resolve } from '$app/paths';

    let { data } = $props();

    // 🔔 สถานะควบคุมการแสดงผลของแจ้งเตือน (Notification State)
    let showMessage = $state(false);
    let alertMessage = $state('');

    // 🎯 ใช้ $effect คอยส่องดูว่าถ้าหลังบ้านส่ง data.message มา ให้เริ่มทำงานทันที
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

    // 🔗 1. ประกาศ Path ลิงก์ปลายทางของแต่ละหน้า
    const dashboardPath = resolve('/admin_dashboard');
    const manageUsersPath = resolve('/manage_users');
    const curriculumPath = resolve('/curriculum');
    const manageSkillsPath = resolve('/manage_global_skills');

    // 🗂️ 2. ก้อนข้อมูลการ์ดเมนู เพื่อเอาไปวนลูปแสดงผล
    const adminCards = [
        {
            title: 'ภาพรวมระบบ (Dashboard)',
            description: 'ดูสถิติผู้ใช้งานรายบุคคล สรุปจำนวนอาจารย์ นักศึกษา และกราฟวิเคราะห์ทักษะภาพรวม',
            icon: '📊',
            href: dashboardPath,
            bgHover: 'hover:border-[#dca11d] hover:shadow-lg hover:shadow-[#dca11d]/5'
        },
        {
            title: 'จัดการผู้ใช้งาน',
            description: 'เพิ่ม บล็อก หรือแก้ไขสิทธิ์ผู้ใช้งาน (Student / Teacher / Admin) และระบบ Import Excel',
            icon: '👥',
            href: manageUsersPath,
            bgHover: 'hover:border-[#dca11d] hover:shadow-lg hover:shadow-[#dca11d]/5'
        },
        {
            title: 'ข้อมูลหลักสูตร',
            description: 'จัดการโครงสร้างหลักสูตรวิศวกรรมคอมพิวเตอร์ เพิ่มปีหลักสูตร และหมวดหมู่กลุ่มวิชา',
            icon: '🗺️',
            href: curriculumPath,
            bgHover: 'hover:border-[#dca11d] hover:shadow-lg hover:shadow-[#dca11d]/5'
        },
        {
            title: 'คลังทักษะมาตรฐาน',
            description: 'กำหนดชุดทักษะ (Skill Matrix) กลางของภาควิชา เพื่อให้อาจารย์นำไปจับคู่กับรายวิชา',
            icon: '🎯',
            href: manageSkillsPath,
            bgHover: 'hover:border-[#dca11d] hover:shadow-lg hover:shadow-[#dca11d]/5'
        }
    ];
</script>

<div 
    class="fixed top-20 left-0 right-0 z-50 flex justify-center p-4 transition-all duration-500 ease-out pointer-events-none"
    class:translate-y-0={showMessage}
    class:-translate-y-full={!showMessage}
    class:opacity-100={showMessage}
    class:opacity-0={!showMessage}
>
    <div class="pointer-events-auto flex items-center gap-3 rounded-full bg-[#443210] px-6 py-3 text-sm font-medium text-white shadow-xl border border-[#dca11d]/30">
        <span class="text-base">🔔</span>
        <span>{alertMessage}</span>
        <button 
            onclick={() => showMessage = false} 
            class="ml-3 text-[#dca11d] hover:text-white transition-colors font-bold text-xs"
        >
            ✕
        </button>
    </div>
</div>

<div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
    <div class="mb-8 text-center md:text-left">
        <div class="flex flex-col items-center gap-2 md:flex-row md:gap-4">
            <div
                class="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#443210] text-xl text-[#dca11d] shadow-md"
            >
                🛠️
            </div>
            <div>
                <h1 class="text-3xl font-black text-[#443210] md:text-4xl">
                    แผงควบคุม <span class="text-[#dca11d]">ผู้ดูแลระบบ</span>
                </h1>
                <p class="mt-1 text-sm font-light text-gray-500 md:text-base">
                    CPE Skill Mapping Management Console — เลือกเมนูที่ต้องการเพื่อเริ่มจัดการข้อมูล
                </p>
            </div>
        </div>
    </div>

    <hr class="mb-10 border-gray-200" />

    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {#each adminCards as card (card.title)}
            <a
                href={card.href}
                class="group flex flex-col justify-between rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 {card.bgHover}"
            >
                <div>
                    <div
                        class="flex h-14 w-14 items-center justify-center rounded-2xl bg-[#443210]/5 text-3xl transition-transform duration-300 group-hover:scale-110"
                    >
                        {card.icon}
                    </div>

                    <h3
                        class="mt-5 text-xl font-bold text-[#443210] transition-colors group-hover:text-[#dca11d]"
                    >
                        {card.title}
                    </h3>

                    <p class="mt-2 text-sm leading-relaxed font-light text-gray-500">
                        {card.description}
                    </p>
                </div>

                <div
                    class="mt-8 flex items-center text-sm font-semibold text-[#443210] transition-colors group-hover:text-[#dca11d]"
                >
                    <span>จัดการระบบ</span>
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="ml-1.5 h-4 w-4 transition-transform duration-300 group-hover:translate-x-1.5"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        stroke-width="2.5"
                    >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                    </svg>
                </div>
            </a>
        {/each}
    </div>
</div>