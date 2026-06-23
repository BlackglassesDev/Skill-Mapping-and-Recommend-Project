<script>
    import { enhance } from '$app/forms';
    import { invalidateAll } from '$app/navigation';
    import { resolve } from '$app/paths';

    // รับข้อมูลรายวิชาจากหลังบ้านเหมือนเดิมทุกประการ
    let { data } = $props();

    // สถานะควบคุมและตัวแปรฟังก์ชันทุกอย่างคงเดิม ไม่มีการเปลี่ยนชื่อ
    let selectedCurriculum = $state('cpe');
    let adminPage = resolve('/adminPage');
</script>

<svelte:head><title>Skill Mapping | Manage Curriculums |</title></svelte:head>

<div class="min-h-screen bg-gray-50 bg-[linear-gradient(to_right,#80808018_1px,transparent_1px),linear-gradient(to_bottom,#80808018_1px,transparent_1px)] bg-[size:24px_24px] py-16">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
        
        <div class="mb-8 rounded-3xl border-2 border-gray-100 bg-white p-6 shadow-sm sm:p-8">
            <div class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left">
                <div class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-amber-100 bg-amber-50 text-2xl text-[#dca11d] shadow-sm">
                    📚
                </div>
                
                <div class="flex-1 space-y-1.5">
                    <h1 class="text-2xl font-extrabold tracking-tight text-[#443210] sm:text-3xl">
                        จัดการ<span class="text-[#dca11d]">หลักสูตรและรายวิชา</span>
                    </h1>
                    <p class="max-w-2xl text-sm font-medium leading-relaxed text-gray-500">
                        Curriculum Management — บริหารจัดการโครงสร้างรายวิชาของแผนก เพื่อนำข้อมูลไปเชื่อมโยงและประเมินผลระดับทักษะ (Skill Mapping)
                    </p>
                    
                    <div class="mt-2 inline-flex items-center gap-1.5 rounded-full border border-red-100 bg-red-50 px-2.5 py-0.5 text-xs font-semibold text-red-600">
                        <span class="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500"></span>
                        Admin Mode Only
                    </div>
                </div>
                
                <div class="shrink-0 pt-2">
                    <a href={adminPage} class="inline-flex items-center gap-2 rounded-2xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-bold text-gray-500 shadow-sm transition-all hover:-translate-y-0.5 hover:bg-gray-50">
                        ← กลับหน้าควบคุม
                    </a>
                </div>
            </div>
        </div>

        <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="flex flex-1 flex-col gap-1.5 sm:max-w-xs">
                <label class="text-xs font-bold tracking-wider text-gray-400 uppercase pl-1">หลักสูตร / ภาควิชาที่เลือก</label>
                <div class="relative">
                    <select 
                        bind:value={selectedCurriculum}
                        class="w-full appearance-none rounded-2xl border-2 border-gray-200 bg-white pl-4 pr-10 py-2.5 text-sm font-bold text-[#443210] outline-none transition-all focus:border-[#dca11d] cursor-pointer shadow-sm"
                    >
                        <option value="cpe">วิศวกรรมคอมพิวเตอร์ (CPE)</option>
                    </select>
                    <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-xs text-gray-400">
                        ▼
                    </div>
                </div>
            </div>

            <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-end">
                
                <button
                    type="button"
                    onclick={() => window.open('/api/export-curriculums', '_blank')}
                    class="inline-flex w-full items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white px-5 py-2.5 text-sm font-bold text-[#443210] shadow-sm transition-all hover:-translate-y-0.5 hover:bg-gray-50 sm:w-auto"
                >
                    📤 ส่งออกหลักสูตร (Export CSV)
                </button>

                <button 
                    type="button"
                    class="inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-[#443210] px-6 py-3 text-sm font-black text-white shadow-[0_4px_12px_rgba(68,50,16,0.15)] transition-all duration-300 hover:-translate-y-1 hover:bg-[#2d210a] hover:shadow-[0_8px_20px_rgba(68,50,16,0.25)] sm:w-auto"
                >
                    ➕ เพิ่มรายวิชาใหม่
                </button>
            </div>
        </div>

        <div class="overflow-hidden rounded-[28px] border-2 border-gray-200/80 bg-white shadow-[0_8px_30px_rgb(0,0,0,0.04)]">
            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left text-sm text-gray-500">
                    <thead class="bg-gray-50/70 text-xs font-black uppercase tracking-wider text-gray-400 border-b-2 border-gray-100">
                        <tr>
                            <th class="px-8 py-5 w-1/4">รหัสวิชา</th>
                            <th class="px-8 py-5 w-1/2">ชื่อรายวิชา (TH / EN)</th>
                            <th class="px-8 py-5 w-1/4">โครงสร้างหลักสูตร</th>
                            <th class="px-8 py-5 text-right">การจัดการ</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 font-medium text-[#443210]">
                        
                        <tr class="odd:bg-white even:bg-gray-50/40 hover:bg-amber-50/30 transition-colors duration-200">
                            <td class="px-8 py-5 font-mono font-black text-gray-500 tracking-wide">
                                CPE-212
                            </td>
                            
                            <td class="px-8 py-5">
                                <div class="space-y-0.5">
                                    <span class="block text-sm font-extrabold text-[#443210]">การเขียนโปรแกรมเชิงวัตถุ</span>
                                    <span class="block text-xs font-semibold text-gray-400 tracking-wide">Object-Oriented Programming</span>
                                </div>
                            </td>
                            
                            <td class="px-8 py-5">
                                <span class="inline-flex items-center rounded-xl bg-amber-50 px-3 py-1 text-xs font-black text-[#dca11d] border border-amber-100/70">
                                    วิศวกรรมคอมพิวเตอร์
                                </span>
                            </td>
                            
                            <td class="px-8 py-5 text-right">
                                <div class="flex justify-end gap-4 text-xs font-bold">
                                    <button class="inline-flex items-center gap-1 text-gray-400 hover:text-[#dca11d] transition-colors">
                                        ✏️ <span class="hover:underline">แก้ไข</span>
                                    </button>
                                    <button class="inline-flex items-center gap-1 text-gray-400 hover:text-red-500 transition-colors">
                                        🗑️ <span class="hover:underline">ลบ</span>
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr class="odd:bg-white even:bg-gray-50/40 hover:bg-amber-50/30 transition-colors duration-200">
                            <td class="px-8 py-5 font-mono font-black text-gray-500 tracking-wide">
                                CPE-491
                            </td>
                            <td class="px-8 py-5">
                                <div class="space-y-0.5">
                                    <span class="block text-sm font-extrabold text-[#443210]">เตรียมโครงงานวิศวกรรมคอมพิวเตอร์</span>
                                    <span class="block text-xs font-semibold text-gray-400 tracking-wide">Computer Engineering Pre-Project</span>
                                </div>
                            </td>
                            <td class="px-8 py-5">
                                <span class="inline-flex items-center rounded-xl bg-amber-50 px-3 py-1 text-xs font-black text-[#dca11d] border border-amber-100/70">
                                    วิศวกรรมคอมพิวเตอร์
                                </span>
                            </td>
                            <td class="px-8 py-5 text-right">
                                <div class="flex justify-end gap-4 text-xs font-bold">
                                    <button class="inline-flex items-center gap-1 text-gray-400 hover:text-[#dca11d] transition-colors">
                                        ✏️ <span class="hover:underline">แก้ไข</span>
                                    </button>
                                    <button class="inline-flex items-center gap-1 text-gray-400 hover:text-red-500 transition-colors">
                                        🗑️ <span class="hover:underline">ลบ</span>
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr>
                            <td colspan="4" class="px-8 py-20">
                                <div class="mx-auto flex max-w-sm flex-col items-center text-center">
                                    <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-50 text-3xl text-gray-400 border border-gray-100 shadow-inner mb-4 animate-pulse">
                                        💨
                                    </div>
                                    <h3 class="text-base font-black text-[#443210]">ไม่พบข้อมูลรายวิชาในขณะนี้</h3>
                                    <p class="mt-2 text-xs leading-relaxed font-medium text-gray-400">
                                        ระบบยังไม่พบฐานข้อมูลรายวิชาในหลักสูตรนี้ พี่สามารถกดปุ่ม <span class="text-[#dca11d] font-bold">"เพิ่มรายวิชาใหม่"</span> ด้านบน เพื่อเริ่มป้อนข้อมูลเข้าสู่ระบบแผนผังทักษะได้เลยครับ
                                    </p>
                                </div>
                            </td>
                        </tr>

                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>