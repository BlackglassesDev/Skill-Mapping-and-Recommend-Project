<script>
	/** @type {{ data: { courses: any[], user: any } }} */
    let { data } = $props();
    
    // บังคับให้เป็น Array เสมอเพื่อป้องกัน Error .length
    let courses = $derived(Array.isArray(data.courses) ? data.courses : []);
    // let user = $derived(data.user);

	// ข้อมูลจำลองสำหรับวนลูป
	const steps = [
		{ icon: '🎯', text: 'รู้จักตัวเอง' },
		{ icon: '🔍', text: 'วิเคราะห์ช่องว่าง' },
		{ icon: '💡', text: 'แนะนำรายวิชา' }
	];

	const jobs = [
		{ id: 1, name: 'วิศวกรปัญญาประดิษฐ์และข้อมูล' },
		{ id: 2, name: 'วิศวกรสมองกลฝังตัวและไอโอที' },
		{ id: 3, name: 'ผู้ดูแลระบบเครือข่ายและคลาวด์' },
		{ id: 4, name: 'นักพัฒนาซอฟต์แวร์' },
		{ id: 5, name: 'วิศวกรรมคอมพิวเตอร์' }
	];
</script>

<svelte:head><title>Skill Mapping | RMUTL | Home</title></svelte:head>

<div class="mx-auto max-w-6xl space-y-20 px-4 py-10 md:py-16">
	<section class="space-y-4 text-center">
		<h1 class="text-2xl font-bold text-[#443210] md:text-4xl">
			เตรียมความพร้อมทักษะ <br> และเส้นทางอาชีพของคุณ
		</h1>
		<p class="text-sm text-gray-600 md:text-base">
			สำรวจอาชีพในสายงาน และประเมินช่องว่างทักษะของคุณ อ้างอิงตามหลักสูตร มทร.ล้านนา
		</p>

		<div class="flex flex-wrap justify-center gap-6 pt-10 md:gap-16">
			{#each steps as step (step.text)}
				<div class="flex flex-col items-center gap-3">
					<div
						class="flex h-24 w-24 items-center justify-center rounded-full border-4 border-[#443210] bg-white shadow-lg md:h-32 md:w-32"
					>
						<span class="text-3xl md:text-4xl">{step.icon}</span>
					</div>
					<span class="text-sm font-bold text-[#443210] md:text-base">{step.text}</span>
				</div>
			{/each}
		</div>
	</section>

	<section class="space-y-8">
		<h2 class="text-xl font-bold text-[#443210] md:text-2xl">เรียนจบแล้วเป็นอะไรได้บ้าง ?</h2>
		<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
			{#each jobs as job (job.id)}
				<div class="group flex items-center gap-3">
					<div
						class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-[#443210] font-bold text-[#dca11d] shadow-md"
					>
						{job.id}
					</div>
					<div
						class="flex-1 cursor-default rounded-lg bg-[#dca11d] px-5 py-3 font-bold text-[#443210] shadow transition-transform hover:translate-x-1"
					>
						{job.name}
					</div>
				</div>
			{/each}
			<div class="flex items-center justify-end">
				<a href="#" class="text-sm font-bold text-[#443210] hover:underline">ดูเพิ่มเติม</a>
			</div>
		</div>
	</section>

	<section class="space-y-8">
		<h2 class="flex items-center gap-2 text-xl font-bold text-[#443210] md:text-2xl">
			รายวิชาในหลักสูตร 📖
		</h2>
		<div class="grid grid-cols-2 gap-4 sm:grid-cols-2 md:grid-cols-4">
		<!-- ถ้าไม่มีรายวิชา -->
		{#if courses.length == 0}
			<div class="text-center p-10 bg-gray-100 rounded-xl border-2 border-dashed">
                <p class="text-gray-500">ไม่พบรายวิชาในหลักสูตรของคุณ</p>
            </div>
		{/if}

			{#each courses as course (course.course_id)}
				<div
					class="rounded-xl border border-[#c58f1a] bg-[#dca11d] p-5 shadow-md transition-shadow hover:shadow-lg"
				>
					<div class="mb-3">
						<h3 class="text-lg leading-tight font-bold text-[#443210]">{course.course_code}</h3>
						<p class="h-10 overflow-hidden text-sm leading-tight font-medium text-[#443210]">
							{course.course_name}
						</p>
					</div>
					<div class="border-t border-[#443210]/20 pt-2">
						<span class="text-[10px] font-bold text-[#ffff]/70 uppercase">Skills</span>
						<p class="text-xs leading-tight font-light text-[#ffff] italic">111111</p>
					</div>
				</div>
			{/each}
		</div>
	</section>
</div>
