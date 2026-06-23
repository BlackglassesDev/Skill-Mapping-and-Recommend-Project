<script>
	import { enhance } from '$app/forms';
	import { invalidateAll } from '$app/navigation';

	//รับข้อมูลที่ส่งมาจาก +page.server.js ผ่าน data prop
	let { data } = $props();

	//สถานะการค้นหาและตัวกรอง
	let searchQuery = $state('');
	let selectedRole = $state('all');

	//นำข้อมูลจาก DB มาตั้งต้นใน $state (จะอัปเดตอัตโนมัติเมื่อ Server ดึงข้อมูลให้ใหม่)
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

	// โลจิกคำนวณสถิติตัวเลขด่วน
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

	//ฟังก์ชันเปิด Modal พร้อมโหลดข้อมูลผู้ใช้เข้าฟอร์ม
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

<div
	class="min-h-screen bg-gray-50 bg-[linear-gradient(to_right,#80808018_1px,transparent_1px),linear-gradient(to_bottom,#80808018_1px,transparent_1px)] bg-[size:24px_24px] py-12"
>
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div
			class="mb-10 flex flex-col items-center justify-between gap-6 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)] md:flex-row md:items-center"
		>
			<div class="text-center md:text-left">
				<h1 class="text-3xl font-black text-[#443210] md:text-4xl">
					จัดการ<span class="text-[#dca11d]">ผู้ใช้งานระบบ</span>
				</h1>
				<p class="mt-2 text-sm font-medium text-gray-500">
					ข้อมูลผู้ใช้งานจริงจากระบบฐานข้อมูล — สามารถค้นหา คัดกรอง และจำแนกสังกัดแผนกได้ทันที
				</p>
			</div>

			<div class="flex w-full flex-wrap justify-center gap-3 md:w-auto">
				<button
					type="button"
					onclick={() => window.open('/api/export-users', '_blank')}
					class="inline-flex w-full items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white px-5 py-2.5 text-sm font-bold text-[#443210] shadow-sm transition-all hover:-translate-y-0.5 hover:bg-gray-50 sm:w-auto"
				>
					📥 ส่งออกข้อมูล (Export CSV)
				</button>
				<!-- <button
					class="inline-flex w-full items-center justify-center gap-2 rounded-2xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-sm font-bold text-white shadow-[0_4px_12px_rgba(68,50,16,0.2)] transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:bg-[#443210]/90 hover:text-[#dca11d] sm:w-auto"
				>
					➕ เพิ่มผู้ใช้ใหม่
				</button> -->
			</div>
		</div>

		<div class="mb-8 grid grid-cols-1 gap-5 sm:grid-cols-3">
			<div
				class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]"
			>
				<div
					class="flex h-14 w-14 items-center justify-center rounded-2xl border border-blue-200 bg-blue-100 text-2xl text-blue-700"
				>
					👥
				</div>
				<div>
					<p class="text-xs font-bold tracking-wider text-gray-400 uppercase">ผู้ใช้งานทั้งหมด</p>
					<p class="text-2xl font-black text-[#443210]">
						{totalUsers} <span class="text-sm font-normal text-gray-400">คน</span>
					</p>
				</div>
			</div>
			<div
				class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]"
			>
				<div
					class="flex h-14 w-14 items-center justify-center rounded-2xl border border-emerald-200 bg-emerald-100 text-2xl text-emerald-700"
				>
					🎓
				</div>
				<div>
					<p class="text-xs font-bold tracking-wider text-gray-400 uppercase">นักศึกษาในระบบ</p>
					<p class="text-2xl font-black text-[#443210]">
						{totalStudents} <span class="text-sm font-normal text-gray-400">คน</span>
					</p>
				</div>
			</div>
			<div
				class="flex items-center gap-5 rounded-[24px] border-2 border-gray-200/80 bg-white p-6 shadow-[0_8px_24px_rgba(0,0,0,0.04)]"
			>
				<div
					class="flex h-14 w-14 items-center justify-center rounded-2xl border border-amber-200 bg-amber-100 text-2xl text-amber-700"
				>
					👨‍🏫
				</div>
				<div>
					<p class="text-xs font-bold tracking-wider text-gray-400 uppercase">อาจารย์ผู้สอน</p>
					<p class="text-2xl font-black text-[#443210]">
						{totalTeachers} <span class="text-sm font-normal text-gray-400">คน</span>
					</p>
				</div>
			</div>
		</div>

		<div
			class="mb-6 rounded-[24px] border-2 border-gray-200/80 bg-white p-5 shadow-[0_8px_24px_rgba(0,0,0,0.04)]"
		>
			<div class="flex flex-col gap-4 sm:flex-row sm:items-center">
				<div class="relative flex-1">
					<span class="absolute inset-y-0 left-4 flex items-center text-gray-400">🔍</span>
					<input
						type="text"
						bind:value={searchQuery}
						placeholder="ค้นหาด้วย ชื่อ-นามสกุล, รหัสผู้ใช้ หรืออีเมล..."
						class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 py-3 pr-4 pl-11 text-sm font-medium text-gray-700 transition-all outline-none focus:border-[#dca11d] focus:bg-white"
					/>
				</div>
				<div class="w-full sm:w-48">
					<select
						bind:value={selectedRole}
						class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 text-sm font-bold text-[#443210] transition-all outline-none focus:border-[#dca11d] focus:bg-white"
					>
						<option value="all">👥 บทบาททั้งหมด</option>
						<option value="student">🎓 นักศึกษา</option>
						<option value="teacher">👨‍🏫 อาจารย์</option>
						<option value="admin">⚙️ ผู้ดูแลระบบ</option>
					</select>
				</div>
			</div>
		</div>

		<div
			class="overflow-hidden rounded-[28px] border-2 border-gray-200/90 bg-white shadow-[0_12px_36px_rgba(0,0,0,0.06)]"
		>
			<div class="overflow-x-auto">
				<table class="w-full border-collapse text-left">
					<thead>
						<tr
							class="border-b-2 border-gray-200 bg-gray-50/70 text-xs font-extrabold tracking-wider text-[#443210] uppercase"
						>
							<th class="px-6 py-4.5">รหัสผู้ใช้ / email</th>
							<th class="px-6 py-4.5">ชื่อ-นามสกุล</th>
							<th class="px-6 py-4.5">บทบาท</th>
							<th class="px-6 py-4.5">สาขาวิชา / สังกัด</th>
							<th class="px-6 py-4.5 text-center">จัดการ</th>
						</tr>
					</thead>
					<tbody class="divide-y-2 divide-gray-100 text-sm font-medium">
						{#each filteredUsers as user (user.id)}
							<tr class="transition-colors hover:bg-gray-50/60">
								<td class="px-6 py-4 whitespace-nowrap">
									<div class="font-black text-[#443210]">{user.id}</div>
									<div class="mt-0.5 text-xs font-normal text-gray-400">
										{user.email || 'ไม่มีข้อมูลอีเมล'}
									</div>
								</td>
								<td class="px-6 py-4 font-bold whitespace-nowrap text-[#443210]">
									{user.full_name || user.username}
								</td>
								<td class="px-6 py-4 whitespace-nowrap">
									{#if user.role?.toLowerCase() === 'student'}
										<span
											class="inline-flex items-center rounded-xl border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-700"
											>🎓 นักศึกษา</span
										>
									{:else if user.role?.toLowerCase() === 'teacher'}
										<span
											class="inline-flex items-center rounded-xl border border-amber-200 bg-amber-50 px-3 py-1 text-xs font-bold text-amber-700"
											>👨‍🏫 อาจารย์</span
										>
									{:else}
										<span
											class="inline-flex items-center rounded-xl border border-purple-200 bg-purple-50 px-3 py-1 text-xs font-bold text-purple-700"
											>⚙️ แอดมิน</span
										>
									{/if}
								</td>
								<td class="px-6 py-4 whitespace-nowrap">
									{#if user.role?.toLowerCase() === 'student'}
										<span
											class="inline-flex items-center gap-1.5 rounded-xl border border-blue-200 bg-blue-50 px-2.5 py-1 text-xs font-bold text-blue-700 shadow-sm"
										>
											🏢 {user.department || 'ยังไม่ระบุ'}
										</span>
									{:else if user.role?.toLowerCase() === 'teacher'}
										<span
											class="inline-flex items-center gap-1.5 rounded-xl border border-amber-200 bg-amber-50 px-2.5 py-1 text-xs font-bold text-amber-700 shadow-sm"
										>
											👨‍🏫 คณะอาจารย์ผู้สอน
										</span>
									{:else if user.role?.toLowerCase() === 'admin'}
										<span
											class="inline-flex items-center gap-1.5 rounded-xl border border-purple-200 bg-purple-50 px-2.5 py-1 text-xs font-bold text-purple-700 shadow-sm"
										>
											🛠️ ฝ่ายดูแลระบบ
										</span>
									{:else}
										<span
											class="inline-flex items-center gap-1.5 rounded-xl border border-gray-200 bg-gray-100 px-2.5 py-1 text-xs font-bold text-gray-500 shadow-sm"
										>
											ไม่ระบุสังกัด
										</span>
									{/if}
								</td>
								<td class="px-6 py-4 text-center whitespace-nowrap">
									<div class="flex items-center justify-center gap-2">
										<button
											onclick={() => openEditModal(user)}
											class="rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-bold text-gray-600 shadow-sm transition-colors hover:border-[#dca11d] hover:text-[#dca11d]"
										>
											✏️ แก้ไข
										</button>
										<button
											class="rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-bold text-rose-500 shadow-sm transition-colors hover:border-rose-400 hover:bg-rose-50/50"
											onclick={() => openDeleteModal(user)}
										>
											🚫 ลบผู้ใช้งาน
										</button>
									</div>
								</td>
							</tr>
						{:else}
							<tr>
								<td colspan="5" class="px-6 py-12 text-center text-sm font-medium text-gray-400">
									📭 ไม่พบข้อมูลผู้ใช้งานที่ตรงตามเงื่อนไขการค้นหา
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
			<div
				class="flex items-center justify-between border-t-2 border-gray-100 bg-gray-50/50 px-6 py-4 text-xs font-bold text-gray-400"
			>
				<span>แสดงผล {filteredUsers.length} จากทั้งหมด {users.length} รายการ</span>
			</div>
		</div>
	</div>
</div>

{#if isEditModalOpen}
	<div
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 p-4 backdrop-blur-sm"
	>
		<div
			class="w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-200 bg-white shadow-[0_24px_48px_rgba(0,0,0,0.12)]"
		>
			<div
				class="flex items-center justify-between border-b-2 border-gray-100 bg-gray-50/80 px-6 py-5"
			>
				<div>
					<h2 class="text-xl font-black text-[#443210]">แก้ไขข้อมูลผู้ใช้งาน</h2>
					<p class="mt-0.5 text-xs font-bold text-gray-400">รหัสอ้างอิงระบบ: {editingUser.id}</p>
				</div>
				<button
					onclick={() => (isEditModalOpen = false)}
					class="flex h-8 w-8 items-center justify-center rounded-xl bg-gray-200/60 font-bold text-gray-500 hover:bg-gray-200/80"
					>✕</button
				>
			</div>

			<form
				method="POST"
				action="?/updateUser"
				use:enhance={() => {
					return async ({ result }) => {
						if (result.type === 'success') {
							isEditModalOpen = false; // ปิด Modal ทันทีเมื่อบันทึกฝั่ง Server สำเร็จ
							await invalidateAll();
						}
					};
				}}
				class="space-y-4 p-6"
			>
				<input type="hidden" name="id" value={editingUser.id} />

				<div class="grid grid-cols-2 gap-4">
					<div>
						<label class="mb-1.5 block text-xs font-black text-[#443210] uppercase"
							>ชื่อผู้ใช้ (Username)</label
						>
						<input
							type="text"
							name="username"
							bind:value={editingUser.username}
							class="w-full rounded-xl border-2 border-gray-200 bg-gray-50 p-2.5 text-xs font-bold text-gray-700 outline-none focus:border-[#dca11d] focus:bg-white"
							required
						/>
					</div>
					<div>
						<label class="mb-1.5 block text-xs font-black text-[#443210] uppercase"
							>อีเมล (Email)</label
						>
						<input
							type="email"
							name="email"
							bind:value={editingUser.email}
							class="w-full rounded-xl border-2 border-gray-200 bg-gray-50 p-2.5 text-xs font-bold text-gray-700 outline-none focus:border-[#dca11d] focus:bg-white"
							required
						/>
					</div>
				</div>

				<div>
					<label class="mb-1.5 block text-xs font-black text-[#443210] uppercase"
						>ชื่อ-นามสกุลจริง</label
					>
					<input
						type="text"
						name="full_name"
						bind:value={editingUser.full_name}
						class="w-full rounded-xl border-2 border-gray-200 bg-gray-50 p-2.5 text-xs font-bold text-gray-700 outline-none focus:border-[#dca11d] focus:bg-white"
						required
					/>
				</div>

				<div>
					<label class="mb-1.5 block text-xs font-black text-[#443210] uppercase"
						>สิทธิ์การเข้าใช้งาน (Role)</label
					>
					<select
						name="role"
						bind:value={editingUser.role}
						class="w-full rounded-xl border-2 border-gray-200 bg-gray-50 p-2.5 text-xs font-bold text-[#443210] outline-none focus:border-[#dca11d] focus:bg-white"
					>
						<option value="student">🎓 นักศึกษา (Student)</option>
						<option value="teacher">👨‍🏫 อาจารย์ผู้สอน (Teacher)</option>
						<option value="admin">⚙️ ผู้ดูแลระบบ (Admin)</option>
					</select>
				</div>

				<div>
					<label class="mb-1.5 block text-xs font-black text-[#443210] uppercase"
						>สาขาวิชา / สังกัดแผนก</label
					>
					<input
						type="text"
						name="department"
						bind:value={editingUser.department}
						disabled={editingUser.role !== 'student'}
						placeholder={editingUser.role !== 'student'
							? '🔒 ล็อกสิทธิ์ตามตำแหน่งสายงานอัตโนมัติ'
							: 'ไม่จำเป็นต้องกรอก..'}
						class="w-full rounded-xl border-2 border-gray-200 bg-gray-50 p-2.5 text-xs font-bold text-gray-700 outline-none focus:border-[#dca11d] disabled:bg-gray-100 disabled:text-gray-400"
					/>
				</div>

				<div class="flex justify-end gap-3 border-t border-gray-100 pt-4">
					<button
						type="button"
						onclick={() => (isEditModalOpen = false)}
						class="rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-bold text-[#443210] transition-colors hover:bg-gray-50"
						>ยกเลิก</button
					>
					<button
						type="submit"
						class="rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2 text-xs font-bold text-white shadow-sm transition-colors hover:border-[#dca11d] hover:bg-[#443210]/90 hover:text-[#dca11d]"
						>💾 บันทึกการแก้ไข</button
					>
				</div>
			</form>
		</div>
	</div>
{/if}

{#if isDeleteModalOpen}
	<div
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 p-4 backdrop-blur-sm"
	>
		<div
			class="w-full max-w-md overflow-hidden rounded-[28px] border-2 border-rose-200 bg-white shadow-[0_24px_48px_rgba(225,29,72,0.08)]"
		>
			<div class="flex items-center gap-3 border-b-2 border-rose-50 bg-rose-50/50 px-6 py-5">
				<span
					class="flex h-10 w-10 items-center justify-center rounded-xl border border-rose-200 bg-rose-100 text-xl text-rose-600"
					>⚠️</span
				>
				<div>
					<h2 class="text-lg font-black text-rose-700">ยืนยันการลบผู้ใช้งาน</h2>
					<p class="mt-0.5 text-xs font-bold text-rose-400">โปรดตรวจสอบข้อมูลก่อนกดยืนยัน</p>
				</div>
			</div>

			<div class="p-6">
				<div class="space-y-2 rounded-2xl border-2 border-gray-100 bg-gray-50/50 p-4">
					<p class="text-xs font-medium text-gray-400">ผู้ใช้งานที่เลือก:</p>
					<p class="text-sm font-black text-[#443210]">
						รหัสผู้ใช้: <span class="font-mono text-gray-600">{userToDelete.id}</span>
					</p>
					<p class="text-sm font-black text-[#443210]">
						ชื่อ-นามสกุล: <span class="text-gray-600"
							>{userToDelete.full_name || userToDelete.username}</span
						>
					</p>
				</div>
				<p
					class="mt-4 rounded-xl border border-rose-100 bg-rose-50 p-3 text-xs font-bold text-rose-500"
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
							isDeleteModalOpen = false; // ลบสำเร็จฝั่งเซิร์ฟเวอร์ปุ๊บ ปิด Modal ทันที
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
					class="rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-bold text-[#443210] transition-colors hover:bg-gray-50"
				>
					ยกเลิก
				</button>
				<button
					type="submit"
					class="rounded-xl border-2 border-rose-600 bg-rose-600 px-5 py-2 text-xs font-bold text-white shadow-sm transition-colors hover:border-rose-700 hover:bg-rose-700"
				>
					🗑️ ยืนยันลบข้อมูล
				</button>
			</form>
		</div>
	</div>
{/if}
