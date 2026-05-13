# Supabase Setup for AyamSegar (Full Reset + Install Ulang)

## Bagian A: HAPUS SEMUA YANG ADA (Reset / Clean Slate)

Jalankan script berikut di **SQL Editor** Supabase untuk menghapus semua tabel, policies, triggers, fungsi, dan data terkait.  
Setelah ini, sistem akan bersih seperti baru.

```sql
-- ============================================
-- 1. Nonaktifkan RLS sementara agar bisa drop policy
-- ============================================
ALTER TABLE IF EXISTS public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.products DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.cart DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notifications DISABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. Hapus semua policy (keamanan baris)
-- ============================================
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
DROP POLICY IF EXISTS "Users can update own data" ON public.users;
DROP POLICY IF EXISTS "Allow insert for authenticated users" ON public.users;

DROP POLICY IF EXISTS "Anyone can view products" ON public.products;
DROP POLICY IF EXISTS "Sellers and admins can insert products" ON public.products;
DROP POLICY IF EXISTS "Sellers and admins can update products" ON public.products;
DROP POLICY IF EXISTS "Sellers and admins can delete products" ON public.products;

DROP POLICY IF EXISTS "Users can view own cart" ON public.cart;
DROP POLICY IF EXISTS "Users can insert own cart" ON public.cart;
DROP POLICY IF EXISTS "Users can update own cart" ON public.cart;
DROP POLICY IF EXISTS "Users can delete own cart" ON public.cart;

DROP POLICY IF EXISTS "Users can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can insert own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can update own orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON public.orders;

DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
DROP POLICY IF EXISTS "System or admin can insert notifications" ON public.notifications;

-- ============================================
-- 3. Hapus semua policy storage
-- ============================================
DROP POLICY IF EXISTS "Users can view own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own avatars" ON storage.objects;

DROP POLICY IF EXISTS "Sellers can upload product images" ON storage.objects;
DROP POLICY IF EXISTS "Sellers can manage own product images" ON storage.objects;

DROP POLICY IF EXISTS "Users can view own payment proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload payment proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own payment proofs" ON storage.objects;

-- ============================================
-- 4. Hapus trigger dan fungsi
-- ============================================
DROP TRIGGER IF EXISTS set_owner_trigger ON storage.objects;
DROP FUNCTION IF EXISTS storage.set_owner();

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- ============================================
-- 5. Hapus tabel (urutan penting karena foreign key)
-- ============================================
DROP TABLE IF EXISTS public.notifications;
DROP TABLE IF EXISTS public.cart;
DROP TABLE IF EXISTS public.orders;
DROP TABLE IF EXISTS public.products;
DROP TABLE IF EXISTS public.users;

-- ============================================
-- 6. Keluarkan tabel dari publikasi realtime (jika ada)
-- ============================================
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS users;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS products;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS cart;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS orders;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS notifications;
```

### Setelah menjalankan SQL di atas, lakukan **pembersihan manual** di Dashboard:

1. **Storage**: Hapus bucket `avatars`, `product_images`, `orders` jika masih ada.  
   (Masuk ke **Storage** > klik 3 titik pada bucket > **Delete bucket**)
2. **Authentication**: Tidak perlu hapus user, biarkan saja. Tabel `auth.users` tidak terpengaruh.

---

## Bagian B: SETUP BARU LENGKAP (Dari Awal)

Setelah membersihkan, jalankan script berikut secara berurutan untuk membangun semuanya dari awal.

### B.1 Buat Tabel

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
  latitude DECIMAL,
  longitude DECIMAL,
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
  "midtransOrderId" TEXT,
  latitude DECIMAL,
  longitude DECIMAL
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

-- Aktifkan Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE products;
ALTER PUBLICATION supabase_realtime ADD TABLE cart;
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
```

### B.2 Buat Storage Bucket (Manual via Dashboard)

1. Buka **Storage** > **Create a new bucket**
2. Buat bucket **`avatars`** → Public ✅
3. Buat bucket **`product_images`** → Public ✅
4. Buat bucket **`orders`** → Public ✅

### B.3 Trigger untuk Owner Storage (WAJIB)

```sql
CREATE OR REPLACE FUNCTION storage.set_owner()
RETURNS TRIGGER AS $$
BEGIN
  NEW.owner = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS set_owner_trigger ON storage.objects;
CREATE TRIGGER set_owner_trigger
  BEFORE INSERT ON storage.objects
  FOR EACH ROW EXECUTE FUNCTION storage.set_owner();
```

### B.4 Aktifkan RLS dan Buat Policies untuk Tabel

```sql
-- Aktifkan RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- users
CREATE POLICY "Users can view own data" ON public.users
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can update own data" ON public.users
  FOR UPDATE USING (auth.uid() = uid) WITH CHECK (auth.uid() = uid);

CREATE POLICY "Allow insert for authenticated users" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = uid);

-- products
CREATE POLICY "Anyone can view products" ON public.products
  FOR SELECT USING (true);

CREATE POLICY "Sellers and admins can insert products" ON public.products
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

CREATE POLICY "Sellers and admins can update products" ON public.products
  FOR UPDATE USING (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

CREATE POLICY "Sellers and admins can delete products" ON public.products
  FOR DELETE USING (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

-- cart
CREATE POLICY "Users can view own cart" ON public.cart
  FOR SELECT USING (auth.uid() = "userId");

CREATE POLICY "Users can insert own cart" ON public.cart
  FOR INSERT WITH CHECK (auth.uid() = "userId");

CREATE POLICY "Users can update own cart" ON public.cart
  FOR UPDATE USING (auth.uid() = "userId");

CREATE POLICY "Users can delete own cart" ON public.cart
  FOR DELETE USING (auth.uid() = "userId");

-- orders
CREATE POLICY "Users can view own orders" ON public.orders
  FOR SELECT USING (auth.uid() = "userId");

CREATE POLICY "Users can insert own orders" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = "userId");

CREATE POLICY "Users can update own orders" ON public.orders
  FOR UPDATE USING (auth.uid() = "userId");

CREATE POLICY "Sellers and admins can view all orders" ON public.orders
  FOR SELECT USING (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

CREATE POLICY "Sellers and admins can update all orders" ON public.orders
  FOR UPDATE USING (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

-- notifications
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = "userId");

CREATE POLICY "Sellers and admins can view all notifications" ON public.notifications
  FOR SELECT USING (
    auth.uid() IN (SELECT uid FROM public.users WHERE role IN ('seller', 'admin'))
  );

CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = "userId");

CREATE POLICY "Authenticated users can insert notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    auth.role() = 'authenticated'
  );
```

### B.5 Policies untuk Storage

```sql
-- avatars
CREATE POLICY "Users can view own avatars" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload avatars" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update own avatars" ON storage.objects
  FOR UPDATE USING (bucket_id = 'avatars' AND auth.uid() = owner);

CREATE POLICY "Users can delete own avatars" ON storage.objects
  FOR DELETE USING (bucket_id = 'avatars' AND auth.uid() = owner);

-- product_images
CREATE POLICY "Sellers can upload product images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'product_images'
    AND auth.role() = 'authenticated'
    AND EXISTS (SELECT 1 FROM public.users WHERE uid = auth.uid() AND role IN ('seller', 'admin'))
  );

CREATE POLICY "Sellers can manage own product images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'product_images'
    AND auth.uid() = owner
  );

-- orders (bukti pembayaran)
CREATE POLICY "Users can view own payment proofs" ON storage.objects
  FOR SELECT USING (bucket_id = 'orders' AND auth.uid() = owner);

CREATE POLICY "Users can upload payment proofs" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'orders' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update own payment proofs" ON storage.objects
  FOR UPDATE USING (bucket_id = 'orders' AND auth.uid() = owner);
```

### B.6 Sinkronisasi User Otomatis

```sql
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### B.7 Keamanan Tambahan (Opsional)

Aktifkan **Leaked Password Protection** di Dashboard:  
`Authentication` → `Settings` → `Password Protection` → ✅ `Prevent use of leaked passwords`

### B.8 Konfigurasi Authentication untuk Reset Password

Agar link reset password berfungsi dengan benar dan tidak diarahkan ke `localhost:3000`:

1.  Buka **Authentication** > **URL Configuration**
2.  Set **Site URL** ke: `ayamsegar://reset-password`
3.  Tambahkan ke **Redirect URLs**: `ayamsegar://reset-password`
4.  Pastikan di **Providers** > **Email**, `Confirm email` diaktifkan jika diperlukan, namun yang paling penting adalah URL Configuration di atas agar deep link di aplikasi berfungsi.

### B.9 Konfigurasi Google Maps

Untuk menggunakan fitur Maps di Dashboard Penjual, Anda harus menambahkan API Key Google Maps ke file `android/app/src/AndroidManifest.xml`:

```xml
<manifest ...>
    <application ...>
        <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
    </application>
</manifest>
```
