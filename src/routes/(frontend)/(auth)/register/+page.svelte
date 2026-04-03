<script>
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';

	let full_name = $state('');
	let username = $state('');
	let email = $state('');
	let password = $state('');
	let confirmPassword = $state('');
	let message = $state('');

	const login_page = resolve('/login');

	/** @param {any} e */
	const handleRegister = async (e) => {

		e.preventDefault();
		
		if (password !== confirmPassword) {
			message = 'รหัสผ่านไม่ตรงกัน❌';
			return;
		}

		const res = await fetch('/api/auth/register', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({
				full_name: full_name,
				username: username,
				email: email,
				password: password
			})
			//ส่งไปเก็บที่บอดี้ให้แบคเอนรู้
		});

		const data = await res.json();

		if (res.ok) {
			message = data.message;
			setTimeout(() => {
				goto(login_page);
			}, 1500);
		} else {
			message = data.error || 'เกิดข้อผิดพลาด😱';
		}
	};
</script>

<svelte:head><title>ลงทะเบียน</title></svelte:head>

<article class="flex min-h-screen items-center justify-center p-4">
	<article
		class="w-full max-w-lg overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-xl"
	>

		<header class="bgcolor-uni flex items-baseline justify-between gap-3 p-6 text-2xl">
			<h1 class="font-bold text-amber-400">Skill Mapping</h1>
			<span class="font-bold text-white">ลงทะเบียน</span>
		</header>

		{#if message}
					<h1 class="text-center m-2 rounded-2xl font-bold p-2 bg-amber-200 border border-amber-800">{message}</h1>
			{/if}

		<form onsubmit={handleRegister}>
			<section class="grid grid-cols-2 gap-3 p-3">
				<div class="flex flex-col gap-0.5">
					<label for="fullname" class="text-md font-semibold text-slate-700">ชื่อ - นามสกุล</label>
					<input
						id="fullname"
						type="text"
						placeholder="เรียนดี มีชัย"
						bind:value={full_name}
						required
						class="w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
					/>
				</div>

				<div class="flex flex-col gap-0.5">
					<label for="username" class="text-md font-semibold text-slate-700">ชื่อผู้ใช้งาน</label>
					<input
						id="username"
						type="text"
						placeholder="StudentRmutl"
						bind:value={username}
						required
						class="w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
					/>
				</div>

				<div class="col-span-2 flex flex-col gap-0.5">
					<label for="mail" class="text-md font-semibold text-slate-700">อีเมล</label>
					<input
						id="mail"
						type="email"
						placeholder="StudentRmutl@live.rmutl.ac.th"
						bind:value={email}
						required
						class="w-full rounded-lg border border-slate-500 p-2.5 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
					/>
				</div>

				<div class="col-span-2 flex flex-col gap-0.5">
					<label for="pass" class="text-md font-semibold text-slate-700">รหัสผ่าน</label>
					<input
						id="pass"
						type="password"
						placeholder="รหัสผ่านอย่างน้อย 8 ตัว"
						bind:value={password}
						required
						class="w-full rounded-lg border border-slate-500 p-2.5 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
					/>
				</div>

				<div class="col-span-2 flex flex-col gap-0.5">
					<label for="conpass" class="text-md font-semibold text-slate-700">ยืนยันรหัสผ่าน</label>
					<input
						id="conpass"
						type="password"
						placeholder="รหัสผ่านอย่างน้อย 8 ตัว"
						bind:value={confirmPassword}
						required
						class="w-full rounded-lg border border-slate-500 p-2.5 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
					/>
				</div>

				<div class="col-span-2">
					<button
						class="btn-submit bgcolor-uni w-full cursor-pointer rounded-lg py-3 font-bold text-amber-400 shadow-md transition-all hover:bg-amber-800 active:scale-[0.98]"
					>
						ลงทะเบียน
					</button>
				</div>

				<div class="text-md col-span-2 pt-2 text-center text-amber-950">
					<span>มีบัญชีผู้ใช้งานแล้ว ?</span>
					<a href={login_page} class="text-amber-400">เข้าสู่ระบบ</a>
				</div>
			</section>
		</form>
	</article>
</article>

<style>
	.bgcolor-uni {
		background-color: #443210;
	}
	.btn-submit:hover {
		/* background-color: rgb(81, 44, 1); */
		box-shadow: 2px 3px 6px rgba(129, 64, 0, 0.765);
	}
</style>
