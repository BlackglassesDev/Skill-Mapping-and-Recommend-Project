<script>
	//@ts-nocheck
	import { enhance } from '$app/forms';
	import { invalidateAll } from '$app/navigation';
	import { resolve } from '$app/paths';

	// รับข้อมูลที่ส่งมาจาก +page.server.js ผ่าน data prop
	let { data } = $props();

	// สถานะการค้นหาและตัวกรอง
	let searchQuery = $state('');
	let selectedRole = $state('all');

	// ระบบ Pagination State
	let currentPage = $state(1);
	let itemsPerPage = $state(10); // แสดงหน้าละ 10 รายการ

	// นำข้อมูลจาก DB มาตั้งต้นใน $state
	let users = $derived(data?.users ?? []);

	// State สำหรับควบคุม Modal แก้ไขข้อมูล
	let isEditModalOpen = $state(false);
	let editingUser = $state({
		id: '',
		full_name: '',
		username: '',
		email: '',
		role: '',
		department: ''
	});

	let isDeleteModalOpen = $state(false);
	let userToDelete = $state({ id: '', full_name: '', username: '' });

	// ตัวแปร path ย้อนกลับ
	let adminPage = resolve('/adminPage');

	// โลจิกคำนวณสถิติตัวเลขด่วน (คิดจากทั้งหมดในระบบ)
	let totalUsers = $derived(users.length);
	let totalStudents = $derived(users.filter((u) => u.role?.toLowerCase() === 'student').length);
	let totalTeachers = $derived(users.filter((u) => u.role?.toLowerCase() === 'teacher').length);

	// โลจิกสำหรับการกรองข้อมูล (Filter & Search)
	let filteredUsers = $derived(
		users.filter((user) => {
			const matchesRole =
				selectedRole === 'all' || user.role?.toLowerCase() === selectedRole.toLowerCase();
			const searchLower = searchQuery.toLowerCase();
			const matchesSearch =
				searchQuery === '' ||
				user.id?.toString().toLowerCase().includes(searchLower) ||
				user.full_name?.toLowerCase().includes(searchLower) ||
				user.username?.toLowerCase().includes(searchLower) ||
				user.email?.toLowerCase().includes(searchLower);

			return matchesRole && matchesSearch;
		})
	);

	// รีเซ็ตหน้ากลับไปหน้า 1 เสมอเมื่อมีการค้นหาหรือเปลี่ยนตัวกรอง
	$effect(() => {
		searchQuery;
		selectedRole;
		currentPage = 1;
	});

	// คำนวณ Pagination จากข้อมูลที่กรองแล้ว
	let totalPages = $derived(Math.max(1, Math.ceil(filteredUsers.length / itemsPerPage)));

	// ตัดข้อมูลเฉพาะหน้าที่จะแสดงผล
	let paginatedUsers = $derived(
		filteredUsers.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage)
	);

	// ฟังก์ชันเปิด Modal พร้อมโหลดข้อมูลผู้ใช้เข้าฟอร์ม
	function openEditModal(user) {
		editingUser = {
			id: user.id,
			full_name: user.full_name || '',
			username: user.username || '',
			email: user.email || '',
			role: user.role || 'student',
			department: user.department || ''
		};
		isEditModalOpen = true;
	}

	function openDeleteModal(user) {
		userToDelete = {
			id: user.id,
			full_name: user.full_name || '',
			username: user.username || ''
		};
		isDeleteModalOpen = true;
	}
</script>

<svelte:head>
	<title>แผงควบคุมผู้ดูแลระบบ | Skill Mapping</title>
</svelte:head>

<div
	class="min-h-screen bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-size-[16px_16px] py-16 selection:bg-amber-100"
>
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div
			class="mb-8 rounded-[28px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] sm:p-8"
		>
			<div
				class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left"
			>
				<div
					class="inline-flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl border border-amber-100 bg-amber-50 text-3xl text-[#dca11d] shadow-[inset_0_2px_4px_rgba(0,0,0,0.02)]"
				>
					<span class="drop-shadow-sm">👥</span>
				</div>

				<div class="flex-1 space-y-1.5">
					<h1 class="text-2xl font-black tracking-tight text-[#443210] sm:text-3xl">
						จัดการ<span class="text-[#dca11d]">ผู้ใช้งานระบบ</span>
					</h1>
					<p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
						User Management — ข้อมูลผู้ใช้งานจริงจากระบบฐานข้อมูล สามารถตรวจสอบ ค้นหา
						และปรับปรุงบทบาทสังกัดของผู้ใช้งานในระบบ Skill Mapping ได้ทันที
					</p>

					<div
						class="mt-2 inline-flex items-center gap-1.5 rounded-full border border-red-100 bg-red-50 px-3 py-0.5 text-[10px] font-bold tracking-wider text-red-600 uppercase"
					>
						<span class="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500"></span>
						Admin Mode Only
					</div>
				</div>

				<div class="flex w-full shrink-0 flex-col gap-3 pt-2 md:w-auto md:items-end">
					<a
						href={adminPage}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-black text-gray-500 shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] md:w-full"
					>
						← กลับหน้าควบคุม
					</a>

					<button
						type="button"
						onclick={() => window.open('/api/export-users-csv', '_blank')}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d]"
					>
						📥 ส่งออกข้อมูล (Export CSV)
					</button>
				</div>
			</div>
		</div>

		<div class="mb-8 grid grid-cols-1 gap-6 sm:grid-cols-3">
			<div
				class="group flex items-center gap-5 rounded-[28px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]"
			>
				<div
					class="flex h-14 w-14 items-center justify-center rounded-2xl border border-blue-100 bg-blue-50 text-2xl text-blue-600 shadow-[inset_0_2px_4px_rgba(0,0,0,0.01)] transition-transform duration-300 group-hover:scale-105"
				>
					<span class="drop-shadow-sm">👥</span>
				</div>
				<div>
					<p
						class="text-[10px] font-bold tracking-wider text-gray-400 uppercase group-hover:text-[#dca11d]/80"
					>
						ผู้ใช้งานทั้งหมด
					</p>
					<p class="text-2xl font-black text-[#443210]">
						{totalUsers} <span class="text-xs font-medium text-gray-400">คน</span>
					</p>
				</div>
			</div>

			<div
				class="group flex items-center gap-5 rounded-[28px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]"
			>
				<div
					class="flex h-14 w-14 items-center justify-center rounded-2xl border border-emerald-100 bg-emerald-50 text-2xl text-emerald-600 shadow-[inset_0_2px_4px_rgba(0,0,0,0.01)] transition-transform duration-300 group-hover:scale-105"
				>
					<span class="drop-shadow-sm">🎓</span>
				</div>
				<div>
					<p
						class="text-[10px] font-bold tracking-wider text-gray-400 uppercase group-hover:text-[#dca11d]/80"
					>
						นักศึกษาในระบบ
					</p>
					<p class="text-2xl font-black text-[#443210]">
						{totalStudents} <span class="text-xs font-medium text-gray-400">คน</span>
					</p>
				</div>
			</div>

			<div
				class="group flex items-center gap-5 rounded-[28px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] transition-all duration-300 hover:-translate-y-1.5 hover:border-[#dca11d]"
			>
				<div
					class="flex h-14 w-14 items-center justify-center rounded-2xl border border-amber-100 bg-amber-50 text-2xl text-amber-600 shadow-[inset_0_2px_4px_rgba(0,0,0,0.01)] transition-transform duration-300 group-hover:scale-105"
				>
					<span class="drop-shadow-sm">👨‍🏫</span>
				</div>
				<div>
					<p
						class="text-[10px] font-bold tracking-wider text-gray-400 uppercase group-hover:text-[#dca11d]/80"
					>
						อาจารย์ผู้สอน
					</p>
					<p class="text-2xl font-black text-[#443210]">
						{totalTeachers} <span class="text-xs font-medium text-gray-400">คน</span>
					</p>
				</div>
			</div>
		</div>

		<div
			class="mb-6 rounded-[24px] border-2 border-gray-200/80 bg-white p-4.5 shadow-[0_8px_30px_rgb(0,0,0,0.04)]"
		>
			<div class="flex flex-col gap-4 sm:flex-row sm:items-center">
				<div class="relative flex-1">
					<span class="absolute inset-y-0 left-4 flex items-center text-base text-gray-400">🔍</span
					>
					<input
						type="text"
						bind:value={searchQuery}
						placeholder="ค้นหาด้วย ชื่อ-นามสกุล, รหัสผู้ใช้ หรืออีเมล..."
						class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 py-3 pr-4 pl-11 text-xs font-bold text-gray-700 transition-all outline-none focus:border-[#dca11d] focus:bg-white"
					/>
				</div>
				<div class="w-full sm:w-56">
					<select
						bind:value={selectedRole}
						class="w-full cursor-pointer rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 text-xs font-black text-[#443210] transition-all outline-none focus:border-[#dca11d] focus:bg-white"
					>
						<option value="all">👥 บทบาททั้งหมดในระบบ</option>
						<option value="student">🎓 นักศึกษา (Student)</option>
						<option value="teacher">👨‍🏫 อาจารย์ (Teacher)</option>
						<option value="admin">⚙️ ผู้ดูแลระบบ (Admin)</option>
					</select>
				</div>
			</div>
		</div>

		<div
			class="overflow-hidden rounded-[28px] border-2 border-gray-200/90 bg-white shadow-[0_12px_36px_rgba(0,0,0,0.04)]"
		>
			<div class="overflow-x-auto">
				<table class="w-full border-collapse text-left">
					<thead>
						<tr
							class="border-b-2 border-gray-200 bg-gray-50/80 text-[11px] font-black tracking-widest text-[#443210] uppercase"
						>
							<th class="px-6 py-4.5">รหัสผู้ใช้ / อีเมล</th>
							<th class="px-6 py-4.5">ชื่อ-นามสกุลจริง</th>
							<th class="px-6 py-4.5">บทบาทระบบ</th>
							<th class="px-6 py-4.5">สาขาวิชา / สังกัดหน่วยงาน</th>
							<th class="px-6 py-4.5 text-center">การจัดการจัดการ</th>
						</tr>
					</thead>
					<tbody class="divide-y-2 divide-gray-100 text-xs font-bold">
						{#each paginatedUsers as user (user.id)}
							<tr class="transition-colors hover:bg-gray-50/50">
								<td class="px-6 py-4.5 whitespace-nowrap">
									<div class="font-mono text-sm font-black text-[#443210]">{user.id}</div>
									<div class="mt-0.5 text-[11px] font-medium text-gray-400">
										{user.email || 'ไม่มีข้อมูลอีเมล'}
									</div>
								</td>
								<td
									class="px-6 py-4.5 font-mono text-sm font-black whitespace-nowrap text-[#443210]"
								>
									{user.full_name || user.username}
								</td>
								<td class="px-6 py-4.5 whitespace-nowrap">
									{#if user.role?.toLowerCase() === 'student'}
										<span
											class="inline-flex items-center gap-1 rounded-xl border border-emerald-100 bg-emerald-50/60 px-2.5 py-1 text-[11px] font-black text-emerald-700"
										>
											<span>🎓</span> นักศึกษา
										</span>
									{:else if user.role?.toLowerCase() === 'teacher'}
										<span
											class="inline-flex items-center gap-1 rounded-xl border border-amber-200 bg-amber-50 px-2.5 py-1 text-[11px] font-black text-amber-700"
										>
											<span>👨‍🏫</span> อาจารย์ผู้สอน
										</span>
									{:else}
										<span
											class="inline-flex items-center gap-1 rounded-xl border border-purple-200 bg-purple-50 px-2.5 py-1 text-[11px] font-black text-purple-700"
										>
											<span>⚙️</span> ผู้ดูแลระบบ
										</span>
									{/if}
								</td>
								<td class="px-6 py-4.5 whitespace-nowrap">
									{#if user.role?.toLowerCase() === 'student'}
										<span
											class="inline-flex items-center gap-1.5 rounded-xl border border-blue-100 bg-blue-50/60 px-2.5 py-1 text-[11px] font-bold text-blue-700 shadow-[inset_0_1px_2px_rgba(0,0,0,0.01)]"
										>
											🏢 {user.department || 'ยังไม่ระบุสังกัด'}
										</span>
									{:else if user.role?.toLowerCase() === 'teacher'}
										<span
											class="inline-flex items-center gap-1.5 rounded-xl border border-amber-100 bg-amber-50/60 px-2.5 py-1 text-[11px] font-bold text-amber-700 shadow-[inset_0_1px_2px_rgba(0,0,0,0.01)]"
										>
											👨‍🏫 คณะอาจารย์สถาบัน
										</span>
									{:else if user.role?.toLowerCase() === 'admin'}
										<span
											class="inline-flex items-center gap-1.5 rounded-xl border border-purple-100 bg-purple-50/60 px-2.5 py-1 text-[11px] font-bold text-purple-700 shadow-[inset_0_1px_2px_rgba(0,0,0,0.01)]"
										>
											🛠️ ศูนย์ควบคุมระบบ
										</span>
									{:else}
										<span
											class="inline-flex items-center gap-1.5 rounded-xl border border-gray-200 bg-gray-100 px-2.5 py-1 text-[11px] font-bold text-gray-500"
										>
											ไม่ระบุสาขาวิชา
										</span>
									{/if}
								</td>
								<td class="px-6 py-4.5 text-center whitespace-nowrap">
									<div class="flex items-center justify-center gap-2.5">
										<button
											type="button"
											onclick={() => openEditModal(user)}
											class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-black text-gray-600 shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d]"
										>
											✏️ แก้ไขข้อมูล
										</button>
										<button
											type="button"
											onclick={() => openDeleteModal(user)}
											class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-black text-rose-500 shadow-sm transition-all hover:border-rose-400 hover:bg-rose-50/50"
										>
											🗑️ ลบผู้ใช้
										</button>
									</div>
								</td>
							</tr>
						{:else}
							<tr>
								<td colspan="5" class="px-6 py-16 text-center text-xs font-bold text-gray-400">
									<div class="text-xl mb-2">📭</div>
									ไม่พบข้อมูลผู้ใช้งานระบบที่ตรงตามเงื่อนไขตารางหรือคำค้นหาที่คุณระบุ
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>

			<div
				class="flex flex-col items-center justify-between gap-4 border-t-2 border-gray-100 bg-gray-50/60 px-6 py-4 text-xs font-bold text-gray-400 sm:flex-row"
			>
				<span class="text-gray-500">
					แสดงข้อมูลหน้า <span class="font-black text-[#443210]">{currentPage}</span>
					จากทั้งหมด <span class="font-black text-[#443210]">{totalPages}</span> หน้า (พบทั้งหมด {filteredUsers.length}
					รายการ)
				</span>

				<div class="flex items-center gap-2">
					<button
						type="button"
						disabled={currentPage === 1}
						onclick={() => (currentPage = 1)}
						class="inline-flex h-9 w-9 cursor-pointer items-center justify-center rounded-xl border border-gray-200 bg-white text-xs font-black text-gray-400 shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d] disabled:opacity-40 disabled:hover:border-gray-200 disabled:hover:text-gray-400"
					>
						«
					</button>

					<button
						type="button"
						disabled={currentPage === 1}
						onclick={() => currentPage--}
						class="inline-flex h-9 cursor-pointer items-center justify-center gap-1.5 rounded-xl border border-gray-200 bg-white px-3 text-xs font-black text-gray-500 shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d] disabled:opacity-40 disabled:hover:border-gray-200 disabled:hover:text-gray-500"
					>
						◀ หน้าก่อน
					</button>

					<button
						type="button"
						disabled={currentPage === totalPages}
						onclick={() => currentPage++}
						class="inline-flex h-9 cursor-pointer items-center justify-center gap-1.5 rounded-xl border border-gray-200 bg-white px-3 text-xs font-black text-[#443210] shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d] disabled:opacity-40 disabled:hover:border-gray-200 disabled:hover:text-[#443210]"
					>
						ถัดไป ▶
					</button>

					<button
						type="button"
						disabled={currentPage === totalPages}
						onclick={() => (currentPage = totalPages)}
						class="inline-flex h-9 w-9 cursor-pointer items-center justify-center rounded-xl border border-gray-200 bg-white text-xs font-black text-gray-400 shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d] disabled:opacity-40 disabled:hover:border-gray-200 disabled:hover:text-gray-400"
					>
						»
					</button>
				</div>
			</div>
		</div>

		{#if isEditModalOpen}
			<div class="fixed inset-0 z-50 flex items-center justify-center p-4">
				<button
					class="fixed inset-0 bg-[#443210]/20 backdrop-blur-sm"
					onclick={() => (isEditModalOpen = false)}>✕</button
				>

				<div
					class="relative w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
				>
					<div class="border-b border-gray-100 px-6 py-4.5">
						<h3 class="text-base font-black text-[#443210]">✏️ แก้ไขข้อมูลสิทธิ์ผู้ใช้งานระบบ</h3>
					</div>

					<form
						method="POST"
						action="?/updateUser"
						use:enhance={() => {
							return async ({ result }) => {
								if (result.type === 'success') {
									isEditModalOpen = false;
									await invalidateAll();
								}
							};
						}}
					>
						<input type="hidden" name="id" value={editingUser.id} />

						<div
							class="max-h-[70vh] space-y-4 overflow-y-auto p-6 text-xs font-bold text-[#443210]"
						>
							<div class="space-y-1.5">
								<label for="userIdDisplay" class="text-gray-400"
									>รหัสประจำตัวผู้ใช้งาน (ไม่สามารถแก้ไขได้)</label
								>
								<input
									id="userIdDisplay"
									type="text"
									value={editingUser.id}
									disabled
									class="w-full rounded-2xl border-2 border-gray-200 bg-gray-100 p-3 font-mono text-gray-500 outline-none"
								/>
							</div>

							<div class="space-y-1.5">
								<label for="username" class="text-gray-400">ชื่อบัญชีผู้ใช้ (Username)</label>
								<input
									id="username"
									type="text"
									name="username"
									bind:value={editingUser.username}
									class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 outline-none focus:border-[#dca11d] focus:bg-white"
									required
								/>
							</div>

							<div class="space-y-1.5">
								<label for="full_name" class="text-gray-400">ชื่อ-นามสกุลจริง</label>
								<input
									id="full_name"
									type="text"
									name="full_name"
									bind:value={editingUser.full_name}
									class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 outline-none focus:border-[#dca11d] focus:bg-white"
									required
								/>
							</div>

							<div class="space-y-1.5">
								<label for="email" class="text-gray-400">ที่อยู่อีเมลสถาบัน (Email)</label>
								<input
									id="email"
									type="email"
									name="email"
									bind:value={editingUser.email}
									class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 outline-none focus:border-[#dca11d] focus:bg-white"
									required
								/>
							</div>

							<div class="space-y-1.5">
								<label for="role" class="text-gray-400">บทบาทสิทธิ์การใช้งาน</label>
								<select
									id="role"
									name="role"
									bind:value={editingUser.role}
									class="w-full cursor-pointer rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-black outline-none focus:border-[#dca11d] focus:bg-white"
								>
									<option value="student">🎓 นักศึกษา (Student)</option>
									<option value="teacher">👨‍🏫 อาจารย์ (Teacher)</option>
									<option value="admin">⚙️ ผู้ดูแลระบบ (Admin)</option>
								</select>
							</div>

							<div class="space-y-1.5">
								<label for="department" class="text-gray-400"
									>สาขาวิชา / ภาควิชาสังกัด (เฉพาะนักศึกษา)</label
								>
								<input
									id="department"
									type="text"
									name="department"
									bind:value={editingUser.department}
									placeholder="เช่น วิศวกรรมคอมพิวเตอร์"
									disabled={editingUser.role !== 'student'}
									class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 outline-none focus:border-[#dca11d] focus:bg-white disabled:border-gray-200 disabled:bg-gray-100 disabled:text-gray-400"
								/>
							</div>
						</div>

						<div class="flex justify-end gap-3 border-t border-gray-100 p-6">
							<button
								type="button"
								onclick={() => (isEditModalOpen = false)}
								class="cursor-pointer rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-xs font-black text-gray-500 shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
							>
								ยกเลิกข้อมูล
							</button>
							<button
								type="submit"
								class="cursor-pointer rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
							>
								💾 บันทึกข้อมูล
							</button>
						</div>
					</form>
				</div>
			</div>
		{/if}

		{#if isDeleteModalOpen}
			<div class="fixed inset-0 z-50 flex items-center justify-center p-4">
				<button
					class="fixed inset-0 bg-[#443210]/20 backdrop-blur-sm"
					onclick={() => (isDeleteModalOpen = false)}>✕</button
				>

				<div
					class="relative w-full max-w-md overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
				>
					<div class="border-b border-gray-100 px-6 py-4.5">
						<h3 class="text-base font-black text-[#443210]">🚫 ยืนยันการลบข้อมูลผู้ใช้งาน</h3>
					</div>

					<div class="p-6">
						<div
							class="flex items-center gap-4 rounded-2xl border border-amber-100 bg-amber-50/60 p-4"
						>
							<span class="text-3xl">⚠️</span>
							<p class="text-xs leading-relaxed font-bold text-[#443210]">
								คุณกำลังทำรายการลบผู้ใช้งานออกจากระบบสารสนเทศ
								โปรดตรวจสอบข้อมูลความถูกต้องก่อนทำการยืนยัน
							</p>
						</div>

						<div class="mt-5 space-y-1.5 rounded-2xl border-2 border-gray-100 bg-gray-50/50 p-4">
							<p class="text-[10px] font-bold text-gray-400 uppercase">
								ผู้ใช้งานที่เลือกทำรายการ:
							</p>
							<p class="text-xs font-black text-[#443210]">
								รหัสผู้ใช้: <span class="font-mono text-gray-600">{userToDelete.id}</span>
							</p>
							<p class="text-xs font-black text-[#443210]">
								ชื่อ-นามสกุล: <span class="text-gray-600"
									>{userToDelete.full_name || userToDelete.username}</span
								>
							</p>
						</div>

						<p
							class="mt-4 rounded-xl border border-rose-100 bg-rose-50 p-3 text-[11px] leading-relaxed font-black text-rose-500"
						>
							คำเตือน: การลบข้อมูลนี้จะเป็นการลบถาวรออกจากระบบฐานข้อมูล ไม่สามารถกู้คืนได้ในภายหลัง
						</p>
					</div>

					<form
						method="POST"
						action="?/deleteUser"
						use:enhance={() => {
							return async ({ result }) => {
								if (result.type === 'success') {
									isDeleteModalOpen = false;
									await invalidateAll();
								}
							};
						}}
						class="flex justify-end gap-3 px-6 pb-6"
					>
						<input type="hidden" name="id" value={userToDelete.id} />
						<button
							type="button"
							onclick={() => (isDeleteModalOpen = false)}
							class="cursor-pointer rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-xs font-black text-gray-500 shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
						>
							ยกเลิก
						</button>
						<button
							type="submit"
							class="cursor-pointer rounded-xl border border-rose-200 bg-rose-500 px-5 py-2.5 text-xs font-black text-white shadow-sm transition-colors hover:bg-rose-600"
						>
							💥 ยืนยันการลบถาวร
						</button>
					</form>
				</div>
			</div>
		{/if}
	</div>
</div>
