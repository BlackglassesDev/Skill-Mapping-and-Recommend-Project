<script>
	import { resolve } from '$app/paths';

	// 🎯 รับ Props ตามมาตรฐาน Svelte 5 Rune
	let { data } = $props();

    let login = resolve('/login');
    let home = resolve('/home');

	// 🎯 สถานะการควบคุม (State Runes)
	let selectedCareer = $state('Full-Stack Developer');
	let authModalOpen = $state(!data.user); // ถ้าไม่ได้ Login ตัว Modal เตือนจะเด้งขึ้นมาทันที

	// จำลองทักษะที่ต้องศึกษาเพิ่มอ้างอิงตามอาชีพที่เลือก
	let skillsToLearn = $derived(
		selectedCareer === 'Full-Stack Developer' ? 'Node Backend, SQL DB' : 'Python, AI Framework'
	);
</script>

<div class="min-h-screen bg-[#FAF9F6] text-[#443210] antialiased">
	<main class="container mx-auto max-w-7xl space-y-10 px-4 py-8 md:px-8">
		<section class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
			<div
				class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-[#FAF9F6] p-6 shadow-sm transition-all hover:shadow-md"
			>
				<div
					class="flex h-16 w-16 shrink-0 items-center justify-center rounded-full border-2 border-[#DCA11D] bg-[#DCA11D] text-3xl font-bold text-white shadow-md md:h-20 md:w-20 md:text-4xl"
				>
					{data.summary.passedCoursesCount || '0'}
				</div>
				<div>
					<h4 class="text-sm font-medium tracking-wider text-gray-500 uppercase">
						รายวิชาที่ผ่านแล้ว
					</h4>
					<p class="mt-0.5 text-xl font-bold text-[#443210]">วิชา</p>
				</div>
			</div>

			<div
				class="flex items-center gap-5 rounded-2xl border border-gray-200 bg-[#FAF9F6] p-6 shadow-sm transition-all hover:shadow-md"
			>
				<div
					class="flex h-16 w-16 shrink-0 items-center justify-center rounded-full border-2 border-[#DCA11D] bg-[#DCA11D] text-3xl font-bold text-white shadow-md md:h-20 md:w-20 md:text-4xl"
				>
					{data.summary.accumulatedSkillsCount || '3'}
				</div>
				<div>
					<h4 class="text-sm font-medium tracking-wider text-gray-500 uppercase">
						ทักษะที่สะสมได้
					</h4>
					<p class="mt-0.5 text-xl font-bold text-[#443210]">ทักษะ</p>
				</div>
			</div>

			<div
				class="flex flex-col justify-center rounded-2xl border border-gray-200 bg-[#FAF9F6] p-6 shadow-sm transition-all hover:shadow-md sm:col-span-2 lg:col-span-1"
			>
				<div class="space-y-3">
					<div class="flex items-start gap-2">
						<span class="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-[#DCA11D]"></span>
						<p class="text-sm font-medium text-[#443210]/80">
							ทักษะที่โดดเด่นที่สุด: <strong class="block text-lg font-bold text-[#443210]"
								>{data.summary.topSkill}</strong
							>
						</p>
					</div>
					<div class="flex items-start gap-2 border-t border-gray-200/60 pt-2">
						<span class="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-[#443210]/50"></span>
						<p class="text-sm font-medium text-[#443210]/70">
							ทักษะที่เป็นรอง: <strong class="block text-base font-bold text-[#443210]/90"
								>{data.summary.secondarySkill}</strong
							>
						</p>
					</div>
				</div>
			</div>
		</section>

		<section class="grid grid-cols-1 items-start gap-8 lg:grid-cols-12">
			<div class="space-y-6 lg:col-span-7">
				<h2 class="text-2xl font-bold tracking-tight text-[#443210]">สำรวจทักษะของคุณ</h2>

				<div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:gap-4">
					<label for="career-dropdown" class="shrink-0 text-base font-bold text-[#443210]/90">
						เปรียบเทียบทักษะกับตำแหน่ง:
					</label>
					<div class="relative max-w-xs flex-1">
						<select
							id="career-dropdown"
							bind:value={selectedCareer}
							class="w-full appearance-none rounded-xl border border-gray-300 bg-[#FAF9F6] py-3 pr-10 pl-4 text-sm font-bold text-[#443210] shadow-sm transition-all focus:border-[#DCA11D] focus:ring-1 focus:ring-[#DCA11D] focus:outline-none"
						>
							<option value="Full-Stack Developer">Full-Stack Developer</option>
							<option value="Data Scientist">Data Scientist</option>
							<option value="Network Engineer">Network Engineer</option>
						</select>
						<div
							class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 text-gray-500"
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								fill="none"
								viewBox="0 0 24 24"
								stroke-width="2.5"
								stroke="currentColor"
								class="h-4 w-4"
							>
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									d="m19.5 8.25-7.5 7.5-7.5-7.5"
								/>
							</svg>
						</div>
					</div>
				</div>

				<div class="rounded-2xl border border-gray-200 bg-[#FAF9F6] p-6 shadow-sm">
					<h3 class="text-sm font-bold tracking-wider text-gray-400 uppercase">
						ทักษะที่ต้องศึกษาเพิ่ม
					</h3>
					<p class="mt-2 text-xl font-bold tracking-tight text-[#DCA11D] md:text-2xl">
						{skillsToLearn}
					</p>
				</div>
			</div>

			<div
				class="flex flex-col items-center rounded-3xl border border-gray-100 bg-white p-6 shadow-md lg:col-span-5"
			>
				<h3 class="mb-4 text-base font-bold text-[#443210]/90">กราฟวิเคราะห์ทักษะ (Radar Chart)</h3>

				<div
					class="flex h-64 w-full items-center justify-center rounded-xl border-2 border-dashed border-gray-200 bg-[#FAF9F6]"
				>
					<p class="text-sm font-medium text-gray-400 italic">
						[ ส่วนสำหรับเรนเดอร์ Radar Chart Canvas ]
					</p>
				</div>

				<div class="mt-5 flex gap-6 text-xs font-semibold">
					<div class="flex items-center gap-2">
						<span class="h-3 w-3 rounded-full bg-[#DCA11D]"></span>
						<span class="text-gray-600">ทักษะของคุณ</span>
					</div>
					<div class="flex items-center gap-2">
						<span class="h-3 w-3 rounded-full bg-[#443210]"></span>
						<span class="text-gray-600">ทักษะของอาชีพ</span>
					</div>
				</div>
			</div>
		</section>

		<section class="space-y-6">
			<h2 class="text-xl font-bold text-[#443210] md:text-2xl">แนะนำวิชาเลือก</h2>

			<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
				{#each data.recommendedCourses as course (course.id)}
					<div
						class="group flex flex-col justify-between rounded-2xl border border-gray-200 bg-[#FAF9F6] p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-[#DCA11D]/60 hover:bg-white hover:shadow-md"
					>
						<div>
							<div
								class="flex h-12 w-12 items-center justify-center rounded-full border border-[#DCA11D]/30 bg-[#DCA11D]/10 text-sm font-bold text-[#DCA11D] shadow-inner"
							>
								{course.group}
							</div>
							<h4 class="mt-4 text-xs font-bold tracking-wider text-gray-400 uppercase">
								{course.code}
							</h4>
							<h3
								class="mt-1 text-base leading-tight font-bold text-[#443210] group-hover:text-amber-950"
							>
								{course.name}
							</h3>
						</div>

						<div class="mt-6 border-t border-gray-100 pt-3">
							<span class="text-[10px] font-bold tracking-wider text-gray-400 uppercase"
								>ทักษะที่เกี่ยวข้อง:</span
							>
							<div class="mt-2 flex flex-wrap gap-1.5">
								{#each course.skills as skill}
									<span
										class="rounded-lg bg-[#443210]/5 px-2.5 py-1 text-xs font-semibold text-[#443210]/80 transition-colors group-hover:bg-[#DCA11D]/10 group-hover:text-[#DCA11D]"
									>
										{skill}
									</span>
								{/each}
							</div>
						</div>
					</div>
				{/each}
			</div>

			<div class="flex justify-end pt-2">
				<button
					type="button"
					class="cursor-pointer rounded-xl bg-[#443210] px-6 py-3 text-sm font-bold text-[#DCA11D] shadow-md transition-all hover:bg-[#543f15] hover:shadow-lg focus:outline-none"
				>
					แนะนำสายงานที่ถนัด
				</button>
			</div>
		</section>
	</main>
</div>

{#if authModalOpen}
	<div class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-sm">
		<div class="w-full max-w-sm rounded-[24px] bg-[#E3E1DF] p-6 text-center shadow-2xl sm:max-w-md">
			<div
				class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-amber-100 text-[#DCA11D]"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					fill="none"
					viewBox="0 0 24 24"
					stroke-width="2"
					stroke="currentColor"
					class="h-8 w-8"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z"
					/>
				</svg>
			</div>
			<h3 class="text-xl font-bold text-[#443210]">กรุณาเข้าสู่ระบบ</h3>
			<p class="mt-2 text-sm leading-relaxed text-gray-600">
				คุณจำเป็นต้องเข้าสู่ระบบก่อน เพื่อทำการวิเคราะห์ เปรียบเทียบ
				และตรวจสอบช่องว่างทักษะตามรายวิชาเลือก
			</p>
			<div class="mt-6 flex flex-col gap-2">
				<a
					href={login}
					class="flex w-full items-center justify-center rounded-xl bg-[#443210] py-3 text-sm font-bold text-[#DCA11D] shadow-md transition-all hover:bg-[#543f15]"
				>
					เข้าสู่ระบบตอนนี้
				</a>
				<a
					href={home}
					class="py-2 text-xs font-semibold text-gray-500 hover:text-gray-800 hover:underline"
				>
					กลับหน้าหลัก
				</a>
			</div>
		</div>
	</div>
{/if}
