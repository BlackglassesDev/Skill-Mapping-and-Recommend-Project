import { redirect, fail } from '@sveltejs/kit';

export async function load({ locals }) {
	if (locals.user) {
		throw redirect(302, '/home');
	}
	return {};
}

export const actions = {
	regis: async ({ request, fetch }) => {
		const data = await request.formData();
		const full_name = data.get('full_name');
		const username = data.get('username');
		const email = data.get('email');
		const password = data.get('password');
		const confirmPassword = data.get('confirmPassword');

		try {
			if (password !== confirmPassword) {
				return fail(401, {
					message: 'รหัสผ่านไม่ตรงกัน❌'
				});
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

			const result = await res.json();
			if (!res.ok) {
				return fail(res.status, {
					success: false,
					message: result.error || 'เกิดขอผิดพลาดในระบบ'
				});
			}
            const reslogin = await fetch('/api/auth/login', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({
					username: username,
					password: password
				})
			});

			const resultlogin = await reslogin.json();
			if (!reslogin.ok) {
				return fail(reslogin.status, {
					success: false,
					message: resultlogin.message
				});
			}
            
			return { success: true, message: result.message || 'สำเร็จ' };
		} catch (error) {
			console.error('Error in regis', error);
            return fail(500,{
                success: false,
                message: 'การเชื่อมต่อขัดข้อง'
            });
		}
	}
};
