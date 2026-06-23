<div class="mb-8 rounded-3xl border-2 border-gray-100 bg-white p-6 shadow-sm sm:p-8">
    <div class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left">
        <div class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-amber-50 text-2xl border border-amber-100 text-[#dca11d] shadow-sm">
            📚
        </div>
        
        <div class="flex-1 space-y-1.5">
            <h1 class="text-2xl font-extrabold tracking-tight text-[#443210] sm:text-3xl">
                จัดการ<span class="text-[#dca11d]">หลักสูตรและรายวิชา</span>
            </h1>
            <p class="max-w-2xl text-sm font-normal leading-relaxed text-gray-500">
                Curriculum Management — บริหารจัดการรายวิชาในหลักสูตรวิศวกรรมคอมพิวเตอร์ เพื่อใช้เป็นฐานข้อมูลในการทำ Skill Mapping
            </p>
        </div>
    </div>
</div>

<div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
    <div class="flex flex-1 flex-col gap-1.5 sm:max-w-xs">
        <label class="text-xs font-bold text-gray-500 uppercase tracking-wider">หลักสูตร / แผนกวิชา</label>
        <select class="w-full rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-bold text-[#443210] outline-none transition-all focus:border-[#dca11d]">
            <option value="cpe">วิศวกรรมคอมพิวเตอร์ (CPE)</option>
        </select>
    </div>

    <div class="flex items-end">
        <button 
            type="button"
            class="inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-[#443210] px-5 py-2.5 text-sm font-bold text-white shadow-sm transition-all hover:-translate-y-0.5 hover:bg-[#2d210a] sm:w-auto"
        >
            ➕ เพิ่มรายวิชาใหม่
        </button>
    </div>
</div>

<div class="overflow-hidden rounded-3xl border-2 border-gray-100 bg-white shadow-sm">
    <div class="overflow-x-auto">
        <table class="w-full border-collapse text-left text-sm text-gray-500">
            <thead class="bg-gray-50 text-xs font-bold uppercase tracking-wider text-gray-600 border-b border-gray-100">
                <tr>
                    <th class="px-6 py-4">รหัสวิชา</th>
                    <th class="px-6 py-4">ชื่อรายวิชา (ไทย / อังกฤษ)</th>
                    <th class="px-6 py-4">หลักสูตรที่สังกัด</th>
                    <th class="px-6 py-4 text-right">การจัดการ</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 font-medium text-[#443210]">
                <tr class="hover:bg-gray-50/70 transition-colors">
                    <td class="px-6 py-4 font-mono font-bold text-gray-600">
                        CPE-212
                    </td>
                    
                    <td class="px-6 py-4">
                        <div class="flex flex-col">
                            <span class="text-sm font-bold text-[#443210]">การเขียนโปรแกรมเชิงวัตถุ</span>
                            <span class="text-xs font-normal text-gray-400">Object-Oriented Programming</span>
                        </div>
                    </td>
                    
                    <td class="px-6 py-4">
                        <span class="inline-flex items-center rounded-xl bg-amber-50 px-2.5 py-1 text-xs font-bold text-[#dca11d] border border-amber-100/70">
                            วิศวกรรมคอมพิวเตอร์
                        </span>
                    </td>
                    
                    <td class="px-6 py-4 text-right">
                        <div class="flex justify-end gap-3">
                            <button class="text-xs font-bold text-gray-400 hover:text-[#dca11d] transition-colors">
                                ✏️ 编辑
                            </button>
                            <button class="text-xs font-bold text-gray-400 hover:text-red-500 transition-colors">
                                🗑️ ลบ
                            </button>
                        </div>
                    </td>
                </tr>
                </tbody>
        </table>
    </div>
</div>