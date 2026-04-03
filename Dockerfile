FROM node:22-alpine

WORKDIR /app

# คัดลอกไฟล์จัดการ package ก่อนเพื่อใช้ประโยชน์จาก Docker Cache
COPY package*.json ./
RUN npm install

# คัดลอกโค้ดทั้งหมด
COPY . .

# สร้างไฟล์ Build
RUN npm run build

# --- เพิ่มส่วนนี้เพื่อให้ Caddy มองเห็น App ---
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

EXPOSE 3000

# รันด้วย node โดยตรง (SvelteKit จะสร้างไฟล์ index.js หรือใช้ handler ในโฟลเดอร์ build)
CMD ["node", "build"]