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
	const curriculumPath = resolve('/curriculums_manage');
	const manageSkillsPath = resolve('/manage_global_skills');

	// 🗂️ 2. ก้อนข้อมูลการ์ดเมนูสไตล์ 3D นุ่มละมุน (ปรับคู่สีไอคอนให้เข้มคมชัดขึ้น)
	const adminCards = [
		{
			title: 'ภาพรวมระบบ',
			subTitle: 'Dashboard',
			description:
				'ตรวจสอบผลและสถิติการใช้งานแต่ละภาคเรียน หน่วยกิตภาพรวม และกราฟวิเคราะห์ทักษะสะสมรายบุคคล',
			icon: '📊',
			href: dashboardPath,
			iconBg: 'bg-emerald-100 text-emerald-700 border border-emerald-200 animate-pulse'
		},
		{
			title: 'จัดการผู้ใช้งาน',
			subTitle: 'User Management',
			description:
				'ระบบจัดการบัญชีผู้ใช้งาน ค้นหาประวัติ ตรวจสอบชั่วโมง และเครื่องมือนำเข้าข้อมูลผ่าน Excel',
			icon: '👥',
			href: manageUsersPath,
			iconBg: 'bg-blue-100 text-blue-700 border border-blue-200 animate-pulse'
		},
		{
			title: 'ข้อมูลหลักสูตร',
			subTitle: 'Curriculum Management',
			description: 'กำหนดการและโครงสร้างวิศวกรรมคอมพิวเตอร์ จัดหมวดหมู่รายวิชาบังคับและวิชาเลือก',
			icon: '🗺️',
			href: curriculumPath,
			iconBg: 'bg-amber-100 text-amber-700 border border-amber-200 animate-pulse'
		},
		{
			title: 'คลังทักษะมาตรฐาน',
			description: 'กำหนดเกณฑ์และชุดทักษะความเชี่ยวชาญกลาง เพื่อใช้เทียบโยงและประเมินผลระดับคณะ',
			subTitle: 'Skill Framework',
			icon: '🎯',
			href: manageSkillsPath,
			iconBg: 'bg-rose-100 text-rose-700 border border-rose-200 animate-pulse'
		}
	];
</script>

<svelte:head><title>Skill Mapping | ADMIN |</title></svelte:head>

<div
	class="pointer-events-none fixed top-6 right-0 left-0 z-50 flex justify-center p-4 transition-all duration-500 ease-out"
	class:translate-y-0={showMessage}
	class:-translate-y-20={!showMessage}
	class:opacity-100={showMessage}
	class:opacity-0={!showMessage}
>
	<div
		class="pointer-events-auto flex max-w-md items-center gap-3 rounded-2xl border border-gray-200 bg-white px-5 py-3.5 text-sm font-semibold text-[#443210] shadow-2xl"
	>
		<span class="flex h-6 w-6 items-center justify-center rounded-full bg-[#dca11d]/10 text-base"
			>🔔</span
		>
		<span class="flex-1 text-gray-700">{alertMessage}</span>
		<button
			onclick={() => (showMessage = false)}
			class="ml-2 p-1 text-xs text-gray-400 transition-colors hover:text-gray-600"
		>
			✕
		</button>
	</div>
</div>

<div
	class="min-h-screen bg-gray-50 bg-[linear-gradient(to_right,#80808018_1px,transparent_1px),linear-gradient(to_bottom,#80808018_1px,transparent_1px)] bg-[size:24px_24px] py-16"
>
	<div class="mx-auto max-w-7xl px-6 lg:px-8">
		<div class="mb-8 rounded-3xl border-2 border-gray-100 bg-white p-6 shadow-sm sm:p-8">
			<div
				class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left"
			>
				<div
					class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-amber-100 bg-amber-50 text-2xl text-[#dca11d] shadow-sm"
				>
					⚙️
				</div>

				<div class="flex-1 space-y-1.5">
					<h1 class="text-2xl font-extrabold tracking-tight text-[#443210] sm:text-3xl">
						แผงควบคุม<span class="text-[#dca11d]">ผู้ดูแลระบบ</span>
					</h1>
					<p class="max-w-2xl text-sm leading-relaxed font-normal text-gray-500">
						CPE Skill Mapping Console — แหล่งรวมระบบทางลัดสำหรับจัดการข้อมูลหลักสูตรและสมาชิก
					</p>

					<div
						class="mt-2 inline-flex items-center gap-1.5 rounded-full border border-red-100 bg-red-50 px-2.5 py-0.5 text-xs font-semibold text-red-600"
					>
						<span class="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500"></span>
						Admin Mode Only
					</div>
				</div>
			</div>
		</div>

		<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
			{#each adminCards as card (card.title)}
				<a
					href={card.href}
					class="group relative flex flex-col items-center rounded-[28px] border-2 border-gray-200/80 bg-white p-8 text-center shadow-[0_8px_30px_rgb(0,0,0,0.06)] transition-all duration-300 hover:-translate-y-2 hover:border-[#dca11d] hover:shadow-[0_20px_40px_rgba(68,50,16,0.12)]"
				>
					<div
						class="flex h-24 w-24 items-center justify-center rounded-full text-4xl shadow-[inset_0_2px_4px_rgba(0,0,0,0.04)] transition-transform duration-500 ease-out group-hover:scale-110 {card.iconBg}"
					>
						<span class="drop-shadow-md">{card.icon}</span>
					</div>

					<h3
						class="mt-6 text-lg font-black tracking-tight text-[#443210] transition-colors group-hover:text-[#dca11d]"
					>
						{card.title}
					</h3>

					{#if card.subTitle}
						<span
							class="mt-0.5 text-[11px] font-bold tracking-widest text-gray-400 uppercase group-hover:text-[#dca11d]/70"
							>{card.subTitle}</span
						>
					{/if}

					<p class="mt-3 text-xs leading-relaxed font-medium text-gray-500">
						{card.description}
					</p>

					<div
						class="mt-auto pt-6 text-[11px] font-bold tracking-wider text-gray-400 uppercase transition-colors group-hover:text-[#dca11d]"
					>
						Click to manage →
					</div>
				</a>
			{/each}
		</div>
	</div>
</div>
