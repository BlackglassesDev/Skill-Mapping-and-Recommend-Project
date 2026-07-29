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
			const trimmedName = String(full_name).trim();
			const nameWords = trimmedName.split(/\s+/).filter(Boolean);
			const isNameValid =
				nameWords.length >= 2 &&
				nameWords.every((w) => /^[A-Za-z\u0E00-\u0E7F]+$/.test(w));

			if (!isNameValid) {
				return fail(401, {
					message: 'กรุณากรอกชื่อและนามสกุลให้ครบ (ภาษาไทยหรืออังกฤษ) เช่น สมชาย ใจดี❌'
				});
			}

			const usernamePolicy = /^[A-Za-z]+_[A-Za-z]{2}[0-9]{2}$/;
			if (!usernamePolicy.test(String(username))) {
				return fail(401, {
					message: 'ชื่อผู้ใช้ต้องเป็นภาษาอังกฤษ รูปแบบ ชื่อ_อักษร2ตัว+ตัวเลข2ตัว เช่น Somchai_Ja67❌'
				});
			}

			const emailPolicy = /^[A-Za-z0-9._%+-]+@live\.rmutl\.ac\.th$/;
			if (!emailPolicy.test(String(email))) {
				return fail(401, {
					message: 'ต้องเป็นอีเมลสถาบันที่ลงท้ายด้วย @live.rmutl.ac.th เท่านั้น❌'
				});
			}

			if (password !== confirmPassword) {
				return fail(401, {
					message: 'รหัสผ่านไม่ตรงกัน❌'
				});
			}

			const passwordPolicy = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/;
			if (!passwordPolicy.test(String(password))) {
				return fail(401, {
					message: 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร รวมตัวเล็ก ตัวใหญ่ ตัวเลข และอักขระพิเศษ❌'
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
