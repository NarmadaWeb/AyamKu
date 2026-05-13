# Supabase Setup for AyamSegar

Ikuti langkah-langkah berikut untuk menyiapkan backend Supabase Anda.

## 1. Buat Tabel

Jalankan SQL berikut di SQL Editor Supabase Anda:

```sql
-- Tabel Users
CREATE TABLE public.users (
  uid UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  name TEXT DEFAULT 'User',
  "phoneNumber" TEXT DEFAULT '',
  address TEXT DEFAULT '',
  "photoUrl" TEXT DEFAULT '',
  role TEXT DEFAULT 'user',
  "paymentMethods" JSONB DEFAULT '[]'::jsonb,
  "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Products
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL NOT NULL,
  unit TEXT,
  "imageUrl" TEXT,
  category TEXT,
  "isAvailable" BOOLEAN DEFAULT true,
  weight TEXT
);

-- Tabel Cart
CREATE TABLE public.cart (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID REFERENCES auth.users(id),
  "productId" UUID REFERENCES public.products(id),
  name TEXT,
  price DECIMAL,
  "imageUrl" TEXT,
  quantity INTEGER DEFAULT 1,
  unit TEXT,
  weight TEXT
);

-- Tabel Orders
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID REFERENCES auth.users(id),
  "userName" TEXT,
  "userPhone" TEXT,
  "userAddress" TEXT,
  status TEXT DEFAULT 'Menunggu Konfirmasi',
  "totalPrice" DECIMAL,
  items JSONB,
  "createdAt" TIMESTAMPTZ DEFAULT NOW(),
  "deliveryTimeSlot" TEXT,
  "paymentMethod" TEXT,
  "paymentProofUrl" TEXT
);

-- Tabel Notifications
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID REFERENCES auth.users(id),
  title TEXT,
  body TEXT,
  "createdAt" TIMESTAMPTZ DEFAULT NOW(),
  "isRead" BOOLEAN DEFAULT false,
  type TEXT,
  "relatedId" TEXT
);

-- Aktifkan Realtime untuk tabel-tabel tersebut
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE products;
ALTER PUBLICATION supabase_realtime ADD TABLE cart;
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
```

## 2. Buat Storage Bucket

1. Buka menu **Storage** di Dashboard Supabase.
2. Buat bucket baru bernama `avatars` dan set sebagai **Public**.
3. Buat bucket baru bernama `product_images` dan set sebagai **Public**.
4. Buat bucket baru bernama `orders` dan set sebagai **Public**.

## 3. Konfigurasi RLS (Row Level Security)

### Tabel Users
- `Allow select/update for users based on their uid`

### Tabel Products
- `Allow select for everyone`
- `Allow insert/update/delete for sellers only`

### Storage Policies (avatars & product_images)
Jalankan SQL ini untuk memberikan akses upload:

```sql
-- Kebijakan untuk bucket 'avatars'
DROP POLICY IF EXISTS "Public Access Avatars" ON storage.objects;
CREATE POLICY "Public Access Avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated Upload Avatars" ON storage.objects;
CREATE POLICY "Authenticated Upload Avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated Update Avatars" ON storage.objects;
CREATE POLICY "Authenticated Update Avatars" ON storage.objects FOR UPDATE USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');

-- Kebijakan untuk bucket 'product_images'
DROP POLICY IF EXISTS "Public Access Products" ON storage.objects;
CREATE POLICY "Public Access Products" ON storage.objects FOR SELECT USING (bucket_id = 'product_images');

DROP POLICY IF EXISTS "Authenticated Upload Products" ON storage.objects;
CREATE POLICY "Authenticated Upload Products" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'product_images' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated Update Products" ON storage.objects;
CREATE POLICY "Authenticated Update Products" ON storage.objects FOR UPDATE USING (bucket_id = 'product_images' AND auth.role() = 'authenticated');

-- Kebijakan untuk bucket 'orders' (Bukti Pembayaran)
DROP POLICY IF EXISTS "Public Access Orders" ON storage.objects;
CREATE POLICY "Public Access Orders" ON storage.objects FOR SELECT USING (bucket_id = 'orders');

DROP POLICY IF EXISTS "Authenticated Upload Orders" ON storage.objects;
CREATE POLICY "Authenticated Upload Orders" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'orders' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated Update Orders" ON storage.objects;
CREATE POLICY "Authenticated Update Orders" ON storage.objects FOR UPDATE USING (bucket_id = 'orders' AND auth.role() = 'authenticated');
```
