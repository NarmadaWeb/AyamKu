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
  weight TEXT,
  stock INTEGER DEFAULT 0
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
  "paymentProofUrl" TEXT,
  "paymentStatus" TEXT DEFAULT 'pending',
  "snapToken" TEXT,
  "midtransOrderId" TEXT
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

## 3. Konfigurasi Row Level Security (RLS)

Aktifkan RLS pada semua tabel dan buat kebijakan (policies) sesuai kebutuhan.

```sql
-- Aktifkan RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ==================== POLICIES untuk users ====================
-- Setiap user hanya bisa melihat dan mengupdate data dirinya sendiri
-- Insert diizinkan hanya jika uid sesuai dengan user yang login (biasanya untuk signup via trigger)
CREATE POLICY "Users can view own data" ON public.users
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can update own data" ON public.users
  FOR UPDATE USING (auth.uid() = uid) WITH CHECK (auth.uid() = uid);

CREATE POLICY "Allow insert for authenticated users" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = uid);

-- ==================== POLICIES untuk products ====================
-- Semua orang (tanpa login) bisa melihat produk
CREATE POLICY "Anyone can view products" ON public.products
  FOR SELECT USING (true);

-- Hanya user dengan role 'seller' atau 'admin' yang bisa menambah, mengubah, menghapus produk
CREATE POLICY "Sellers and admins can insert products" ON public.products
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

CREATE POLICY "Sellers and admins can update products" ON public.products
  FOR UPDATE USING (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  ) WITH CHECK (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

CREATE POLICY "Sellers and admins can delete products" ON public.products
  FOR DELETE USING (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

-- ==================== POLICIES untuk cart ====================
-- User hanya bisa melihat, menambah, mengubah, menghapus item cart miliknya sendiri
CREATE POLICY "Users can view own cart" ON public.cart
  FOR SELECT USING (auth.uid() = "userId");

CREATE POLICY "Users can insert own cart" ON public.cart
  FOR INSERT WITH CHECK (auth.uid() = "userId");

CREATE POLICY "Users can update own cart" ON public.cart
  FOR UPDATE USING (auth.uid() = "userId") WITH CHECK (auth.uid() = "userId");

CREATE POLICY "Users can delete own cart" ON public.cart
  FOR DELETE USING (auth.uid() = "userId");

-- ==================== POLICIES untuk orders ====================
-- User bisa melihat pesanan mereka sendiri
CREATE POLICY "Users can view own orders" ON public.orders
  FOR SELECT USING (auth.uid() = "userId");

-- User bisa membuat pesanan baru (userId harus sesuai)
CREATE POLICY "Users can insert own orders" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = "userId");

-- User bisa mengupdate pesanan mereka sendiri (misal: upload bukti bayar)
-- Batasi hanya kolom tertentu jika perlu, di sini diizinkan semua kolom
CREATE POLICY "Users can update own orders" ON public.orders
  FOR UPDATE USING (auth.uid() = "userId") WITH CHECK (auth.uid() = "userId");

-- (Opsional) Admin/seller bisa melihat semua pesanan
CREATE POLICY "Admins can view all orders" ON public.orders
  FOR SELECT USING (
    auth.uid() IN (SELECT uid FROM public.users WHERE role = 'admin')
  );

-- ==================== POLICIES untuk notifications ====================
-- User hanya bisa melihat notifikasi mereka sendiri
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = "userId");

-- User bisa mengupdate notifikasi sendiri (misal: menandai sudah dibaca)
CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = "userId") WITH CHECK (auth.uid() = "userId");

-- Insert notifikasi biasanya dilakukan oleh sistem atau admin, maka izinkan dari role tertentu
CREATE POLICY "System or admin can insert notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    auth.uid() IS NULL OR -- untuk sistem (trigger)
    auth.uid() IN (SELECT uid FROM public.users WHERE role = 'admin')
  );
```

## 4. Kebijakan Storage (Buckets)

Jalankan SQL berikut untuk memberikan akses upload file ke bucket yang sudah dibuat.  
> **Catatan:** Policy `SELECT` sengaja tidak dibuat agar tidak bisa melakukan listing file, namun file tetap dapat diakses via public URL karena bucket diset sebagai **Public**.

```sql
-- ==================== Bucket 'avatars' ====================
DROP POLICY IF EXISTS "Authenticated Upload Avatars" ON storage.objects;
CREATE POLICY "Authenticated Upload Avatars" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated Update Avatars" ON storage.objects;
CREATE POLICY "Authenticated Update Avatars" ON storage.objects
  FOR UPDATE USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');

-- ==================== Bucket 'product_images' ====================
DROP POLICY IF EXISTS "Authenticated Upload Products" ON storage.objects;
CREATE POLICY "Authenticated Upload Products" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'product_images' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated Update Products" ON storage.objects;
CREATE POLICY "Authenticated Update Products" ON storage.objects
  FOR UPDATE USING (bucket_id = 'product_images' AND auth.role() = 'authenticated');

-- ==================== Bucket 'orders' (Bukti Pembayaran) ====================
DROP POLICY IF EXISTS "Authenticated Upload Orders" ON storage.objects;
CREATE POLICY "Authenticated Upload Orders" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'orders' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated Update Orders" ON storage.objects;
CREATE POLICY "Authenticated Update Orders" ON storage.objects
  FOR UPDATE USING (bucket_id = 'orders' AND auth.role() = 'authenticated');
```

## 5. Keamanan Autentikasi

Untuk meningkatkan keamanan akun pengguna, sangat disarankan untuk mengaktifkan fitur **"Leaked Password Protection"** di Dashboard Supabase:
1. Pergi ke **Authentication** > **Settings**.
2. Cari bagian **Password Protection**.
3. Aktifkan **"Prevent use of leaked passwords"**.

## 6. Sinkronisasi User (Otomatis)

Gunakan trigger PostgreSQL untuk secara otomatis membuat data di `public.users` saat user baru mendaftar di `auth.users`. Ini lebih handal daripada menyimpannya dari sisi client.

Jalankan SQL berikut:

```sql
-- Fungsi untuk menangani user baru
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (uid, email, name, role)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'name', 'User'),
    'user'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger setelah user baru dibuat di auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```
