<script>
    import { resolve } from '$app/paths';

    let { data } = $props();

    // 🔔 สถานะสำหรับจำลองการค้นหาและฟิลเตอร์ (พี่เอาไปเชื่อม Logic เพิ่มได้เลย)
    let searchQuery = $state('');
    let selectedRole = $state('all');

    // 🗂️ ก้อนข้อมูลผู้ใช้งานชั่วคราวสำหรับเป็นตัวอย่างเทส UI ครับ
    let users = $state([
        { id: '660610999', name: 'สมชาย สายคอม', role: 'student', email: 'somchai.s@rmutl.ac.th', status: 'active' },
        { id: '660610888', name: 'สมหญิง ยอดขยัน', role: 'student', email: 'somying.y@rmutl.ac.th', status: 'active' },
        { id: 'T001', name: 'ผศ.ดร.ปรีชา มีปัญญา', role: 'teacher', email: 'preecha.m@rmutl.ac.th', status: 'active' },
        { id: 'A002', name: 'อนันต์ ควบคุมระบบ', role: 'admin', email: 'anan.c@rmutl.ac.th', status: 'active' },
        { id: '660610777', name: 'เด็กหลังห้อง แอบแก้เกรด', role: 'student', email: 'badboy.b@rmutl.ac.th', status: 'suspended' }
    ]);

    // ฟังก์ชันคำนวณสถิติตัวเลขด่วนแบบ Reactive
    let totalUsers = $derived(users.length);
    let totalStudents = $derived(users.filter(u => u.role === 'student').length);
    let totalTeachers = $derived(users.filter(u => u.role === 'teacher').length);
</script>

<svelte:head><title>Skill Mapping | ADMIN | ManagerUsers</title></svelte:head>

<div class="min-h-screen bg-gray-50 bg-[linear-gradient(to_right,#80808018_1px,transparent_1px),linear-gradient(to_bottom,#80808018_1px,transparent_1px)] bg-[size:24px_24px] py-12">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div class="mb-10 flex flex-col items-center justify-between gap-4 border-b border-gray-200 pb-6 md:flex-row md:items-end">
            <div class="text-center md:text-left">
                <h1 class="text-3xl font-black text-[#443210] md:text-4xl">
                    จัดการ<span class="text-[#dca11d]">ผู้ใช้งานระบบ</span>
                </h1>
                <p class="mt-2 text-sm font-medium text-gray-500">
                    เพิ่ม บล็อกสิทธิ์ หรือจัดการบทบาทและสิทธิ์การเข้าถึงระบบของนักศึกษาและอาจารย์
                </p>
            </div>
            
            <div class="flex flex-wrap gap-3">
                <button class="inline-flex items-center gap-2 rounded-2xl border-2 border-[#443210] bg-white px-5 py-2.5 text-sm font-bold text-[#443210] shadow-[0_4px_12px_rgba(0,0,0,0.05)] transition-all hover:-translate-y-0.5 hover:bg-gray-50">
                    📥 Import Excel
                </button>
                <button class="inline-flex items-center gap-2 rounded-2xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-sm font-bold text-white shadow-[0_4px_12px_rgba(68,50,16,0.2)] transition-all hover:-translate-y-0.5 hover:bg-[#443210]/90 hover:border-[#dca11d] hover:text-[#dca11d]">
                    ➕ เพิ่มผู้ใช้ใหม่
                </button>
            </div>
        </div>

        <div class="mb-8 grid grid-cols-1 gap-5 sm:grid-cols-3">
            <div class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-100 text-2xl text-blue-700 border border-blue-200">👥</div>
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-400">ผู้ใช้งานทั้งหมด</p>
                    <p class="text-2xl font-black text-[#443210]">{totalUsers} <span class="text-sm font-normal text-gray-400">คน</span></p>
                </div>
            </div>
            <div class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-100 text-2xl text-emerald-700 border border-emerald-200">🎓</div>
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-400">นักศึกษาในระบบ</p>
                    <p class="text-2xl font-black text-[#443210]">{totalStudents} <span class="text-sm font-normal text-gray-400">คน</span></p>
                </div>
            </div>
            <div class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-100 text-2xl text-amber-700 border border-amber-200">👨‍🏫</div>
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-400">อาจารย์ผู้สอน</p>
                    <p class="text-2xl font-black text-[#443210]">{totalTeachers} <span class="text-sm font-normal text-gray-400">คน</span></p>
                </div>
            </div>
        </div>

        <div class="mb-6 rounded-[24px] border-2 border-gray-200/80 bg-white p-5 shadow-[0_8px_24px_rgba(0,0,0,0.04)]">
            <div class="flex flex-col gap-4 sm:flex-row sm:items-center">
                <div class="relative flex-1">
                    <span class="absolute inset-y-0 left-4 flex items-center text-gray-400">🔍</span>
                    <input 
                        type="text" 
                        bind:value={searchQuery}
                        placeholder="ค้นหาด้วย ชื่อ, รหัสนักศึกษา หรืออีเมล..." 
                        class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 py-3 pl-11 pr-4 text-sm font-medium text-gray-700 outline-none transition-all focus:border-[#dca11d] focus:bg-white"
                    />
                </div>
                <div class="w-full sm:w-48">
                    <select 
                        bind:value={selectedRole}
                        class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 text-sm font-bold text-[#443210] outline-none transition-all focus:border-[#dca11d] focus:bg-white"
                    >
                        <option value="all">👥 บทบาททั้งหมด</option>
                        <option value="student">🎓 นักศึกษา</option>
                        <option value="teacher">👨‍🏫 อาจารย์</option>
                        <option value="admin">⚙️ ผู้ดูแลระบบ</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="overflow-hidden rounded-[28px] border-2 border-gray-200/90 bg-white shadow-[0_12px_36px_rgba(0,0,0,0.06)]">
            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left">
                    <thead>
                        <tr class="border-b-2 border-gray-200 bg-gray-50/70 text-xs font-extrabold uppercase tracking-wider text-[#443210]">
                            <th class="px-6 py-4.5">รหัสผู้ใช้ / อีเมล</th>
                            <th class="px-6 py-4.5">ชื่อ-นามสกุล</th>
                            <th class="px-6 py-4.5">บทบาท</th>
                            <th class="px-6 py-4.5">สถานะ</th>
                            <th class="px-6 py-4.5 text-center">จัดการ</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y-2 divide-gray-100 text-sm font-medium">
                        {#each users as user (user.id)}
                            <tr class="transition-colors hover:bg-gray-50/60">
                                <td class="whitespace-nowrap px-6 py-4">
                                    <div class="font-black text-[#443210]">{user.id}</div>
                                    <div class="text-xs font-normal text-gray-400 mt-0.5">{user.email}</div>
                                </td>
                                <td class="whitespace-nowrap px-6 py-4 text-[#443210] font-bold">
                                    {user.name}
                                </td>
                                <td class="whitespace-nowrap px-6 py-4">
                                    {#if user.role === 'student'}
                                        <span class="inline-flex items-center rounded-xl bg-emerald-50 border border-emerald-200 px-3 py-1 text-xs font-bold text-emerald-700">🎓 นักศึกษา</span>
                                    {:else if user.role === 'teacher'}
                                        <span class="inline-flex items-center rounded-xl bg-amber-50 border border-amber-200 px-3 py-1 text-xs font-bold text-amber-700">👨‍🏫 อาจารย์</span>
                                    {:else}
                                        <span class="inline-flex items-center rounded-xl bg-purple-50 border border-purple-200 px-3 py-1 text-xs font-bold text-purple-700">⚙️ แอดมิน</span>
                                    {/if}
                                </td>
                                <td class="whitespace-nowrap px-6 py-4">
                                    {#if user.status === 'active'}
                                        <span class="inline-flex items-center gap-1 text-xs font-bold text-emerald-600">
                                            <span class="h-2 w-2 rounded-full bg-emerald-500 animate-pulse"></span> ใช้งานปกติ
                                        </span>
                                    {:else}
                                        <span class="inline-flex items-center gap-1 text-xs font-bold text-rose-500">
                                            <span class="h-2 w-2 rounded-full bg-rose-500"></span> ถูกระงับสิทธิ์
                                        </span>
                                    {/if}
                                </td>
                                <td class="whitespace-nowrap px-6 py-4 text-center">
                                    <div class="flex items-center justify-center gap-2">
                                        <button class="rounded-xl border border-gray-200 bg-white p-2 text-gray-500 shadow-sm transition-colors hover:border-[#dca11d] hover:text-[#dca11d]">
                                            ✏️ แก้ไข
                                        </button>
                                        {#if user.status === 'active'}
                                            <button class="rounded-xl border border-gray-200 bg-white p-2 text-rose-500 shadow-sm transition-colors hover:border-rose-400 hover:bg-rose-50/50">
                                                🚫 บล็อก
                                            </button>
                                        {:else}
                                            <button class="rounded-xl border border-gray-200 bg-white p-2 text-emerald-600 shadow-sm transition-colors hover:border-emerald-400 hover:bg-emerald-50/50">
                                                ✅ ปลดบล็อก
                                            </button>
                                        {/if}
                                    </div>
                                </td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </div>
            
            <div class="flex items-center justify-between border-t-2 border-gray-100 bg-gray-50/50 px-6 py-4 text-xs font-bold text-gray-400">
                <span>แสดงผล 1 ถึง {users.length} จากทั้งหมด {users.length} รายการ</span>
                <div class="flex gap-1">
                    <button class="rounded-lg border border-gray-200 bg-white px-3 py-1.5 transition-colors hover:bg-gray-50">ก่อนหน้า</button>
                    <button class="rounded-lg border border-gray-200 bg-[#443210] px-3 py-1.5 text-white">1</button>
                    <button class="rounded-lg border border-gray-200 bg-white px-3 py-1.5 transition-colors hover:bg-gray-50">ถัดไป</button>
                </div>
            </div>
        </div>

    </div>
</div>