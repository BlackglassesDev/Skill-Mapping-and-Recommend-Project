<script>
	/** @type {import('./$types').PageProps} */
	let { data } = $props();
	// ส่วนเชื่อมโยงเส้นทางไปยังหน้าต่าง ๆ ของอาจารย์
	let mappingPage = '/mapping-skills';
	let manageCoursesPage = '/manage-courses';
	let dashboardPage = '/course-dashboard';
</script>

<div
	class="min-h-screen bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] py-16 selection:bg-amber-100"
>
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<!-- Header Section -->
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

		<!-- Menu Cards Grid -->
		<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
			<!-- Menu 1: Mapping ทักษะกับหลักสูตร -->
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

			<!-- Menu 2: เพิ่มหรือลบวิชาเรียน -->
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

			<!-- Menu 3: Dashboard วิเคราะห์ภาพรวมหลักสูตร -->
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
