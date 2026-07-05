<script>
	import './layout.css';
	import { resolve } from '$app/paths';
	import { slide } from 'svelte/transition';
	import { page } from '$app/state';
	import favicon from '$lib/assets/favicon.svg';
	import { goto, invalidateAll } from '$app/navigation';
	import { enhance } from '$app/forms';

	let { children, data } = $props();
	let sid = $derived(data?.user);

	const isPageNoNav = $derived(page.url.pathname === '/login' || page.url.pathname === '/register');

	// ตั้งค่า Path ทั่วไป
	const homePath = resolve('/home');
	const loginPath = resolve('/login');
	const curriculum = resolve('/curriculums_manage');

	// student
	const assess_skills = resolve('/assess_skills');
	// teacher
	// const manage_course = resolve('/manage-courses');
	// const manage_skill = resolve('/mapping-skills');
	// const overview = resolve('/course-dashboard');
	const teacherPage = resolve('/teacherPage');

	// admin
	const adminPage = resolve('/adminPage');

	// Helper check active route
	const isActive = (/** @type {string} */ path) => page.url.pathname === path;

	// Logic สำหรับเมนูมือถือ
	let isMenuOpen = $state(false);
	function toggleMenu() {
		isMenuOpen = !isMenuOpen;
	}
</script>

<svelte:head><link rel="icon" href={favicon} /></svelte:head>

{#if isPageNoNav}
	<div
		class="bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] selection:bg-amber-100"
	>
		{@render children()}
	</div>
{:else if sid}
	<nav class="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-gray-100 p-4 text-[#443210] shadow-sm transition-all duration-300">
		<div class="mx-auto flex max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
			<a href={homePath} class="flex items-center gap-2">
				<span class="text-xl font-black text-[#443210] md:text-2xl tracking-tight">
					RMUTL <span class="text-[#dca11d] font-black">- Skill Mapping</span>
				</span>
			</a>

			<div class="hidden items-center gap-8 md:flex">
				<div class="flex items-center gap-6 text-xs font-bold uppercase tracking-wider">
					{#if sid.role === 'student'}
						<a href={homePath} class="transition-all duration-300 py-1.5 border-b-2 {isActive('/home') ? 'border-[#dca11d] text-[#dca11d]' : 'border-transparent text-[#443210] hover:text-[#dca11d]'}">หน้าหลัก</a>
						<a href={assess_skills} class="transition-all duration-300 py-1.5 border-b-2 {isActive('/assess_skills') ? 'border-[#dca11d] text-[#dca11d]' : 'border-transparent text-[#443210] hover:text-[#dca11d]'}">ประเมินทักษะ</a>
					{/if}

					{#if sid.role === 'teacher'}
						<a href={teacherPage} class="transition-colors hover:text-[#dca11d] {isActive('/teacherPage') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>หน้าหลัก</a>
						<a href={curriculum} class="transition-colors hover:text-[#dca11d] {isActive('/curriculums_manage') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>ข้อมูลหลักสูตร</a>
					{/if}

					{#if sid.role === 'admin'}
						<a href={adminPage} class="transition-all duration-300 py-1.5 border-b-2 {isActive('/adminPage') ? 'border-[#dca11d] text-[#dca11d]' : 'border-transparent text-[#443210] hover:text-[#dca11d]'}">แผงควบคุมหลัก</a>
						<a href={curriculum} class="transition-all duration-300 py-1.5 border-b-2 {isActive('/curriculums_manage') ? 'border-[#dca11d] text-[#dca11d]' : 'border-transparent text-[#443210] hover:text-[#dca11d]'}">ข้อมูลหลักสูตร</a>
					{/if}
				</div>

				<div class="flex items-center gap-4">
					<div class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-[#443210]/5 border border-[#443210]/10">
						<div class="h-6 w-6 rounded-full bg-[#443210] text-[#dca11d] flex items-center justify-center text-[10px] font-black">
							{sid.username.substring(0, 2).toUpperCase()}
						</div>
						<span class="text-xs font-black text-[#443210]">{sid.username}</span>
					</div>

					<form
						method="POST"
						action="/api/auth/logout"
						use:enhance={() => {
							return async ({ result }) => {
								// @ts-ignore
								if (result && result.success === true) {
									await invalidateAll();
									goto(homePath);
								}
							};
						}}
					>
						<button
							type="submit"
							class="flex items-center gap-1.5 text-xs font-black text-rose-600 hover:text-rose-700 transition-all duration-300 py-1.5 px-3.5 rounded-xl border border-rose-100 hover:bg-rose-50"
							aria-label="ออกจากระบบ"
							title="ออกจากระบบ"
						>
							<span>ออกจากระบบ</span>
							<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-3.5 h-3.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75" />
							</svg>
						</button>
					</form>
				</div>
			</div>

			<button class="p-2 text-[#443210] md:hidden" onclick={toggleMenu} aria-label="Toggle Menu">
				<svg
					xmlns="http://www.w3.org/2000/svg"
					class="h-7 w-7"
					fill="none"
					viewBox="0 0 24 24"
					stroke="currentColor"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2.5"
						d={isMenuOpen ? 'M6 18L18 6M6 6l12 12' : 'M4 6h16M4 12h16M4 18h16'}
					/>
				</svg>
			</button>
		</div>

		{#if isMenuOpen}
			<div
				transition:slide
				class="space-y-4 border-t border-gray-100 bg-white/95 backdrop-blur-md px-6 py-4 md:hidden text-[#443210]"
			>
				<div class="flex flex-col gap-3 font-bold text-sm">
					{#if sid.role === 'student'}
						<a href={homePath} class="transition-colors hover:text-[#dca11d] {isActive('/home') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>หน้าหลัก</a>
						<a href={assess_skills} class="transition-colors hover:text-[#dca11d] {isActive('/assess_skills') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>ประเมินทักษะ</a>
					{/if}

					{#if sid.role === 'teacher'}
						<a href={teacherPage} class="transition-colors hover:text-[#dca11d] {isActive('/teacherPage') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>หน้าหลัก</a>
						<a href={curriculum} class="transition-colors hover:text-[#dca11d] {isActive('/curriculums_manage') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>ข้อมูลหลักสูตร</a>
					{/if}

					{#if sid.role === 'admin'}
						<a href={adminPage} class="transition-colors hover:text-[#dca11d] {isActive('/adminPage') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>หน้าหลัก</a>
						<a href={curriculum} class="transition-colors hover:text-[#dca11d] {isActive('/curriculums_manage') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>ข้อมูลหลักสูตร</a>
					{/if}
				</div>

				<div class="border-t border-gray-100 pt-3 flex flex-col gap-3">
					<div class="flex items-center gap-2">
						<div class="h-6 w-6 rounded-full bg-[#443210] text-[#dca11d] flex items-center justify-center text-[10px] font-black">
							{sid.username.substring(0, 2).toUpperCase()}
						</div>
						<span class="text-xs font-black text-[#443210]">{sid.username}</span>
					</div>

					<form
						method="POST"
						action="/api/auth/logout"
						use:enhance={() => {
							return async ({ result }) => {
								// @ts-ignore
								if (result && result.success === true) {
									await invalidateAll();
									goto(homePath);
								}
							};
						}}
					>
						<button
							type="submit"
							class="flex w-full items-center gap-1.5 text-xs font-black text-rose-600 hover:text-rose-700 transition-all duration-300 py-2.5 px-3.5 rounded-xl border border-rose-100 hover:bg-rose-50"
							onclick={toggleMenu}
						>
							<span>ออกจากระบบ</span>
							<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-3.5 h-3.5">
								<path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75" />
							</svg>
						</button>
					</form>
				</div>
			</div>
		{/if}
	</nav>

	<main class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8 bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] selection:bg-amber-100 transition-all duration-300">
		{@render children()}
	</main>

	<footer class="bg-[#443210] text-white border-t border-[#dca11d]/20 py-12 mt-16 transition-all duration-300">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="grid grid-cols-1 md:grid-cols-3 gap-8 border-b border-white/10 pb-8">
				<div>
					<h4 class="text-sm font-black text-[#dca11d] uppercase tracking-wider mb-3">CPE Skill Mapping System</h4>
					<p class="text-xs text-gray-300 leading-relaxed font-medium">
						ระบบการจัดการหลักสูตรและวิเคราะห์ทักษะความเชี่ยวชาญ ค้นหาจุดเด่นและช่องว่างการเรียนรู้ของหลักสูตรเพื่อการพัฒนาที่ยั่งยืน
					</p>
				</div>
				<div>
					<h4 class="text-sm font-black text-[#dca11d] uppercase tracking-wider mb-3">ฝ่ายพัฒนาหลักสูตร</h4>
					<p class="text-xs text-gray-300 leading-relaxed font-medium">
						สาขาวิศวกรรมคอมพิวเตอร์ คณะวิศวกรรมศาสตร์<br/>
						มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา
					</p>
				</div>
				<div>
					<h4 class="text-sm font-black text-[#dca11d] uppercase tracking-wider mb-3">ช่วยเหลือและติดต่อ</h4>
					<div class="flex flex-col gap-2 text-xs text-gray-300 font-medium">
						<a href="/about" class="hover:text-[#dca11d] transition-colors">เกี่ยวกับระบบ</a>
						<a href="/contact" class="hover:text-[#dca11d] transition-colors">ติดต่อผู้จัดทำ</a>
					</div>
				</div>
			</div>
			<div class="pt-8 flex flex-col sm:flex-row justify-between items-center gap-4 text-[10px] font-semibold uppercase tracking-wider text-gray-400">
				<span>© 2026 CPE RMUTL. All Rights Reserved.</span>
				<span>Created by 3 Smart Developers</span>
			</div>
		</div>
	</footer>
{:else}
	<nav class="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-gray-100 p-4 text-[#443210] shadow-sm transition-all duration-300">
		<div class="mx-auto flex max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
			<a href={homePath} class="flex items-center gap-2">
				<span class="text-xl font-black text-[#443210] md:text-2xl tracking-tight">
					RMUTL <span class="text-[#dca11d] font-black">- Skill Mapping</span>
				</span>
			</a>

			<div class="hidden items-center gap-8 md:flex">
				<div class="flex items-center gap-6 text-xs font-bold uppercase tracking-wider">
					<a href={homePath} class="transition-all duration-300 py-1.5 border-b-2 {isActive('/home') ? 'border-[#dca11d] text-[#dca11d]' : 'border-transparent text-[#443210] hover:text-[#dca11d]'}">หน้าหลัก</a>
					<a href={assess_skills} class="transition-all duration-300 py-1.5 border-b-2 {isActive('/assess_skills') ? 'border-[#dca11d] text-[#dca11d]' : 'border-transparent text-[#443210] hover:text-[#dca11d]'}">ประเมินทักษะ</a>
					<a href={curriculum} class="transition-all duration-300 py-1.5 border-b-2 {isActive('/curriculums_manage') ? 'border-[#dca11d] text-[#dca11d]' : 'border-transparent text-[#443210] hover:text-[#dca11d]'}">ข้อมูลหลักสูตร</a>
				</div>
				<a
					href={loginPath}
					class="rounded-xl bg-[#443210] px-5 py-2 text-xs font-black text-white hover:bg-[#dca11d] hover:text-[#443210] transition-all duration-300 shadow-sm"
				>
					เข้าสู่ระบบ
				</a>
			</div>

			<button class="p-2 text-[#443210] md:hidden" onclick={toggleMenu} aria-label="Toggle Menu">
				<svg
					xmlns="http://www.w3.org/2000/svg"
					class="h-7 w-7"
					fill="none"
					viewBox="0 0 24 24"
					stroke="currentColor"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2.5"
						d={isMenuOpen ? 'M6 18L18 6M6 6l12 12' : 'M4 6h16M4 12h16M4 18h16'}
					/>
				</svg>
			</button>
		</div>

		{#if isMenuOpen}
			<div
				transition:slide
				class="space-y-4 border-t border-gray-100 bg-white/95 backdrop-blur-md px-6 py-4 md:hidden text-[#443210]"
			>
				<div class="flex flex-col gap-3 font-bold text-sm">
					<a href={homePath} class="transition-colors hover:text-[#dca11d] {isActive('/home') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>หน้าหลัก</a>
					<a href={assess_skills} class="transition-colors hover:text-[#dca11d] {isActive('/assess_skills') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>ประเมินทักษะ</a>
					<a href={curriculum} class="transition-colors hover:text-[#dca11d] {isActive('/curriculums_manage') ? 'text-[#dca11d]' : ''}" onclick={toggleMenu}>ข้อมูลหลักสูตร</a>
				</div>
				<a
					href={loginPath}
					class="block rounded-lg bg-[#443210] py-2 text-center text-xs font-black text-white hover:bg-[#dca11d] hover:text-[#443210] transition-colors"
					onclick={toggleMenu}>เข้าสู่ระบบ</a
				>
			</div>
		{/if}
	</nav>

	<main class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8 bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] selection:bg-amber-100 transition-all duration-300">
		{@render children()}
	</main>

	<footer class="bg-[#443210] text-white border-t border-[#dca11d]/20 py-12 mt-16 transition-all duration-300">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="grid grid-cols-1 md:grid-cols-3 gap-8 border-b border-white/10 pb-8">
				<div>
					<h4 class="text-sm font-black text-[#dca11d] uppercase tracking-wider mb-3">CPE Skill Mapping System</h4>
					<p class="text-xs text-gray-300 leading-relaxed font-medium">
						ระบบการจัดการหลักสูตรและวิเคราะห์ทักษะความเชี่ยวชาญ ค้นหาจุดเด่นและช่องว่างการเรียนรู้ของหลักสูตรเพื่อการพัฒนาที่ยั่งยืน
					</p>
				</div>
				<div>
					<h4 class="text-sm font-black text-[#dca11d] uppercase tracking-wider mb-3">ฝ่ายพัฒนาหลักสูตร</h4>
					<p class="text-xs text-gray-300 leading-relaxed font-medium">
						สาขาวิศวกรรมคอมพิวเตอร์ คณะวิศวกรรมศาสตร์<br/>
						มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา
					</p>
				</div>
				<div>
					<h4 class="text-sm font-black text-[#dca11d] uppercase tracking-wider mb-3">ช่วยเหลือและติดต่อ</h4>
					<div class="flex flex-col gap-2 text-xs text-gray-300 font-medium">
						<a href="/about" class="hover:text-[#dca11d] transition-colors">เกี่ยวกับระบบ</a>
						<a href="/contact" class="hover:text-[#dca11d] transition-colors">ติดต่อคณะผู้จัดทำ</a>
					</div>
				</div>
			</div>
			<div class="pt-8 flex flex-col sm:flex-row justify-between items-center gap-4 text-[10px] font-semibold uppercase tracking-wider text-gray-400">
				<span>© 2026 CPE RMUTL. All Rights Reserved.</span>
				<span>Created by 3 Smart Developers</span>
			</div>
		</div>
	</footer>
{/if}
