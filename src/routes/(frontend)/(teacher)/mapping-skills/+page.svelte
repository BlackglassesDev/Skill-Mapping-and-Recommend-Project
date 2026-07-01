<script>
	import { deserialize } from '$app/forms';
	import { invalidateAll } from '$app/navigation';

	// --- 1. สเตตัสและตัวแปรหลัก (Svelte 5 State Runes) ---
	let { data } = $props();

	let showMessage = $state(false);
	let alertMessage = $state('');
	let searchQuery = $state('');

	// เก็บรหัสวิชาที่อาจารย์กำลังเลือกใช้งานอยู่เพื่อทำการแมปสกิล
	let selectedCourseId = $state(1);
	let adminPage = '/adminPage';

	/** @param {string} msg */
	function triggerAlert(msg) {
		alertMessage = msg;
		showMessage = true;
		setTimeout(() => {
			showMessage = false;
		}, 3000);
	}

	// Access data directly from the server using Reactive State variables
	let skillsData = $derived(data.allSkills || []);
	let coursesData = $derived(data.courses || []);
	let mappingsData = $derived(data.mappings || []);

	// --- 2. คลังข้อมูลรายวิชา (ดึงจาก Database และจัดรูปแบบโครงสร้าง) ---
	/** @type {any[]} */
	let courses = $state([]);
	$effect(() => {
		courses = coursesData.map((/** @type {any} */ course) => {
			const courseMappings = mappingsData.filter(
				(/** @type {any} */ m) => m.course_id === course.course_id
			);
			const skills = courseMappings.map((/** @type {any} */ m) => {
				const s = skillsData.find((/** @type {any} */ sk) => sk.skill_id === m.skill_id);
				return {
					name: s ? s.skill_name : 'Unknown Skill',
					level: m.skill_level
				};
			});
			return {
				course_id: course.course_id,
				course_code: course.course_code,
				course_name: course.course_name,
				skills: skills
			};
		});
	});

	$effect(() => {
		if (coursesData.length > 0 && selectedCourseId === 1) {
			selectedCourseId = coursesData[0].course_id;
		}
	});

	// --- 3. ทำเนียบทักษะย่อยมาตรฐานที่เปิดให้กดเลือกแมป ---
	let availableSkills = $derived(
		skillsData.map((/** @type {any} */ skill) => ({
			id: skill.skill_id,
			name: skill.skill_name,
			category: skill.curriculum_name || 'Unspecified course'
		}))
	);

	// ตัวแปรฟอร์มรับค่าสำหรับเพิ่มสกิลใหม่ให้วิชาที่เลือก
	let formSkillName = $state('');
	let formSkillLevel = $state(1);

	$effect(() => {
		if (skillsData.length > 0 && !formSkillName) {
			formSkillName = skillsData[0].skill_name;
		}
	});

	// --- 4. ⚡️ ระบบ Reactive คำนวณกรองรายวิชา (Derived Runes) ---
	let filteredCourses = $derived(
		courses.filter((/** @type {any} */ course) => {
			const query = searchQuery.toLowerCase().trim();
			return (
				course.course_code.toLowerCase().includes(query) ||
				course.course_name.toLowerCase().includes(query)
			);
		})
	);

	// ดึงข้อมูลของวิชาที่เลือกในปัจจุบันออกมากาง
	let currentSelectedCourse = $derived(
		courses.find((/** @type {any} */ c) => c.course_id === selectedCourseId)
	);

	// --- 5. ฟังก์ชันการจัดสรรแมปทักษะ (Skill Mapping Actions) ---
	function addSkillToCourse() {
		if (!currentSelectedCourse) return;

		// ตรวจสอบว่ามีสกิลนี้อยู่แล้วหรือไม่ ถ้ามีให้เปลี่ยนอัปเดตเลเวลแทน ถ้าไม่มีให้เพิ่มใหม่
		let existingSkill = currentSelectedCourse.skills.find(
			(/** @type {any} */ s) => s.name === formSkillName
		);

		if (existingSkill) {
			existingSkill.level = Number(formSkillLevel);
			triggerAlert(`🔄 อัปเดตระดับทักษะ ${formSkillName} เป็นเลเวล ${formSkillLevel}`);
		} else {
			currentSelectedCourse.skills.push({
				name: formSkillName,
				level: Number(formSkillLevel)
			});
			triggerAlert(`✨ แมปทักษะ ${formSkillName} ระดับ ${formSkillLevel} สำเร็จ`);
		}

		// บังคับให้ Svelte อัปเดตรีเฟรชสเตตัสอาร์เรย์ภายใน
		courses = [...courses];
	}

	function exportCSV() {
		const selectedId = coursesData[0]?.curriculum_id || '';
		const selectedName = skillsData[0]?.curriculum_name || 'หลักสูตร';
		triggerAlert(`📤 ส่งออกข้อมูลไฟล์ CSV ของ: ${selectedName}`);
		window.open('/api/export-mapping-skills-csv?curriculum_id=' + selectedId, '_blank');
	}

	/** @param {string} skillName */
	function removeSkillFromCourse(skillName) {
		if (!currentSelectedCourse) return;
		currentSelectedCourse.skills = currentSelectedCourse.skills.filter(
			(/** @type {any} */ s) => s.name !== skillName
		);
		courses = [...courses];
		triggerAlert(`🗑️ ถอดถอนทักษะ ${skillName} ออกแล้ว`);
	}

	async function saveMappingToDatabase() {
		if (!currentSelectedCourse) return;

		const formData = new FormData();
		formData.append('courseId', String(selectedCourseId));
		formData.append('skills', JSON.stringify(currentSelectedCourse.skills));

		try {
			const response = await fetch('?/saveMapping', {
				method: 'POST',
				body: formData
			});

			if (response.ok) {
				const text = await response.text();
				const result = deserialize(text);
				if (result.type === 'success') {
					await invalidateAll();
					triggerAlert(
						'💾 บันทึกโครงสร้างผังทักษะ (Skill Mapping) เข้าสู่ระบบฐานข้อมูลหลักเรียบร้อย!'
					);
				} else {
					//@ts-ignore
					triggerAlert('❌ เกิดข้อผิดพลาดในการบันทึกข้อมูล: ' + (result.data?.error || ''));
				}
			} else {
				triggerAlert('❌ เกิดข้อผิดพลาดในการบันทึกข้อมูล');
			}
		} catch (error) {
			console.error(error);
			triggerAlert('❌ ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
		}
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
		<span
			class="flex h-6 w-6 items-center justify-center rounded-full bg-amber-50 text-base text-[#dca11d]"
			>🔔</span
		>
		<span class="flex-1 font-medium text-gray-600">{alertMessage}</span>
		<button
			onclick={() => (showMessage = false)}
			class="ml-2 p-1 text-xs text-gray-400 transition-colors hover:text-[#443210]">✕</button
		>
	</div>
</div>

<div
	class="min-h-screen bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] py-16 selection:bg-amber-100"
>
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="mb-8 rounded-3xl border border-gray-200 bg-white p-6 shadow-sm sm:p-8">
			<div
				class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left"
			>
				<div
					class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-gray-100 bg-gray-50 text-2xl shadow-sm"
				>
					🗺️
				</div>
				<div class="flex-1 space-y-1">
					<h1 class="text-2xl font-black tracking-tight text-[#443210] sm:text-3xl">
						การจัดทำ<span class="text-[#dca11d]">แผนผังทักษะ (Skill Mapping)</span>
					</h1>
					<p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
						เลือกรายวิชาในหลักสูตรเพื่อระบุและเชื่อมโยงทักษะความรู้ที่นิสิตจะได้รับ
						พร้อมกำหนดระดับระดับความคาดหวัง (เลเวล 1-6) เพื่อใช้วิเคราะห์ Gap ของหลักสูตร
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
						onclick={exportCSV}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d]"
					>
						📤 ส่งออกข้อมูล(CSV)
					</button>
				</div>
			</div>
		</div>

		<div class="grid grid-cols-1 gap-8 lg:grid-cols-3">
			<div class="flex flex-col gap-4 lg:col-span-1">
				<div class="flex flex-col gap-1.5">
					<span class="pl-1 text-xs font-bold text-gray-400">ค้นหารายวิชาในคลังข้อมูล</span>
					<div class="relative">
						<input
							type="text"
							bind:value={searchQuery}
							placeholder="พิมพ์รหัสวิชา หรือชื่อวิชา..."
							class="w-full rounded-xl border border-gray-200 bg-white py-2.5 pr-4 pl-10 text-sm font-medium text-[#443210] shadow-sm transition-all outline-none focus:border-[#dca11d] focus:ring-1 focus:ring-[#dca11d]"
						/>
						<div
							class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 text-gray-400"
						>
							🔍
						</div>
					</div>
				</div>

				<div class="flex max-h-[500px] flex-col gap-3 overflow-y-auto pr-1">
					{#each filteredCourses as course (course.course_id)}
						<button
							type="button"
							onclick={() => (selectedCourseId = course.course_id)}
							class="group relative flex w-full cursor-pointer flex-col gap-2 rounded-2xl border p-4.5 text-left text-sm shadow-sm transition-all
                            {selectedCourseId === course.course_id
								? '-translate-y-0.5 border-[#dca11d] bg-amber-50/40 ring-1 ring-[#dca11d]'
								: 'border-gray-200 bg-white hover:border-gray-300 hover:bg-gray-50/60'}"
						>
							<div class="flex items-center justify-between">
								<span
									class="font-mono font-bold {selectedCourseId === course.course_id
										? 'text-[#dca11d]'
										: 'text-gray-400'}">{course.course_code}</span
								>
								<span
									class="rounded-md border border-gray-100 bg-white px-2 py-0.5 text-[10px] font-bold text-gray-400"
								>
									สกิลที่แมปแล้ว: {course.skills.length}
								</span>
							</div>
							<h3 class="font-black tracking-tight text-[#443210]">{course.course_name}</h3>

							{#if course.skills.length > 0}
								<div class="mt-1 flex flex-wrap gap-1">
									{#each course.skills as s}
										<span
											class="rounded-md border border-gray-100 bg-white px-1.5 py-0.5 text-[9px] font-medium text-[#443210]"
										>
											{s.name} <b class="text-[#dca11d]">L{s.level}</b>
										</span>
									{/each}
								</div>
							{/if}
						</button>
					{:else}
						<div class="text-center py-10 bg-white border border-gray-200 rounded-2xl p-6">
							<span class="text-2xl">💨</span>
							<p class="text-xs text-gray-400 mt-2 font-medium">ไม่พบวิชาเรียนที่ตรงเงื่อนไข</p>
						</div>
					{/each}
				</div>
			</div>

			<div class="flex flex-col gap-6 lg:col-span-2">
				{#if currentSelectedCourse}
					<div
						class="flex flex-col gap-6 rounded-3xl border border-gray-200 bg-white p-6 shadow-sm"
					>
						<div class="border-b border-gray-100 pb-4">
							<span class="font-mono text-xs font-bold tracking-wider text-[#dca11d] uppercase"
								>กำลังจัดการทักษะวิชา :</span
							>
							<h2 class="mt-0.5 text-xl font-black text-[#443210]">
								[{currentSelectedCourse.course_code}] {currentSelectedCourse.course_name}
							</h2>
						</div>

						<div class="grid grid-cols-1 items-end gap-4 md:grid-cols-3">
							<div class="flex flex-col gap-1.5 md:col-span-2">
								<span class="pl-1 text-xs font-bold text-gray-400"
									>1. เลือกองค์ความรู้/ทักษะปลายทาง</span
								>
								<select
									bind:value={formSkillName}
									class="w-full cursor-pointer appearance-none rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm font-black text-[#443210] shadow-sm outline-none focus:border-[#dca11d]"
								>
									{#each availableSkills as skill}
										<option value={skill.name}>[{skill.category}] — {skill.name}</option>
									{/each}
								</select>
							</div>

							<div class="flex flex-col gap-1.5">
								<span class="pl-1 text-xs font-bold text-gray-400"
									>2. ระดับเลเวลคาดหวัง (1 - 6)</span
								>
								<select
									bind:value={formSkillLevel}
									class="w-full cursor-pointer appearance-none rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm font-black text-[#443210] shadow-sm outline-none focus:border-[#dca11d]"
								>
									<option value={1}>เลเวล 1 - ความเข้าใจเบื้องต้น</option>
									<option value={2}>เลเวล 2 - สามารถประยุกต์ใช้พื้นฐาน</option>
									<option value={3}>เลเวล 3 - ปฏิบัติงานได้อิสระ</option>
									<option value={4}>เลเวล 4 - แก้ไขปัญหาซับซ้อนได้</option>
									<option value={5}>เลเวล 5 - เชี่ยวชาญเฉพาะทาง</option>
									<option value={6}>เลเวล 6 - ระดับผู้เชี่ยวชาญ/นวัตกร</option>
								</select>
							</div>
						</div>

						<div class="flex justify-end gap-2 border-t border-gray-100 pt-4">
							<button
								type="button"
								onclick={addSkillToCourse}
								class="inline-flex cursor-pointer items-center justify-center gap-2 rounded-xl bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d]"
							>
								🔗 บันทึกความเชื่อมโยงทักษะนี้
							</button>
						</div>
					</div>

					<div class="rounded-3xl border border-gray-200 bg-white p-6 shadow-sm">
						<div class="mb-4 flex items-center justify-between border-b border-gray-100 pb-3">
							<h3 class="text-sm font-black text-[#443210]">
								📊 ทักษะความสามารถรวมที่จะปรากฏหลังเรียนจบ
							</h3>
							<button
								onclick={saveMappingToDatabase}
								class="text-xs font-black text-[#dca11d] hover:underline"
								>💾 ยืนยันบันทึกโครงสร้างทั้งหมด</button
							>
						</div>

						{#if currentSelectedCourse.skills.length > 0}
							<div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
								{#each currentSelectedCourse.skills as skill}
									<div
										class="flex items-center justify-between gap-3 rounded-xl border border-gray-100 bg-gray-50/70 p-3"
									>
										<div class="flex flex-col gap-0.5">
											<span class="text-xs font-black text-[#443210]">{skill.name}</span>
											<span class="text-[10px] font-medium text-gray-400"
												>ระดับความเชี่ยวชาญคาดหวัง</span
											>
										</div>
										<div class="flex items-center gap-3">
											<span
												class="inline-flex h-7 items-center justify-center rounded-lg bg-[#443210] px-2.5 font-mono text-xs font-black text-white"
											>
												LV: {skill.level}/6
											</span>
											<button
												type="button"
												onclick={() => removeSkillFromCourse(skill.name)}
												class="p-1 text-xs font-bold text-rose-400 transition-colors hover:text-rose-600"
												title="ถอดถอนทักษะนี้"
											>
												✕
											</button>
										</div>
									</div>
								{/each}
							</div>
						{:else}
							<div class="rounded-2xl border-2 border-dashed border-gray-200 py-12 text-center">
								<span class="text-xl">🗺️</span>
								<h4 class="mt-2 text-xs font-bold text-[#443210]">
									ยังไม่มีการระบุสกิลให้แก่วิชานี้
								</h4>
								<p class="mt-0.5 text-[11px] text-gray-400">
									อาจารย์สามารถเลือกชุดสกิลและระบุเลเวลจากฟอร์มด้านบนเพื่อเพิ่มทักษะ
								</p>
							</div>
						{/if}
					</div>
				{:else}
					<div class="rounded-3xl border border-gray-200 bg-white p-12 text-center shadow-sm">
						<span class="text-3xl">👈</span>
						<h3 class="mt-3 text-sm font-bold text-[#443210]">กรุณาเลือกรายวิชาในคลัง</h3>
						<p class="mt-1 text-xs text-gray-400">
							คลิกเลือกการ์ดรายวิชาที่แถบเมนูด้านซ้ายเพื่อเริ่มทำการ Mapping ทักษะ
						</p>
					</div>
				{/if}
			</div>
		</div>
	</div>
</div>
