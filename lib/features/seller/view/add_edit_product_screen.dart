import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../product/repository/product_repository.dart';
import '../../product/model/product_model.dart';

class AddEditProductScreen extends HookConsumerWidget {
  final String? productId;
  const AddEditProductScreen({super.key, this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      data: (products) {
        final product = productId != null
            ? products.where((p) => p.id == productId).firstOrNull
            : null;

        return _AddEditProductForm(product: product);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _AddEditProductForm extends HookConsumerWidget {
  final ProductModel? product;
  const _AddEditProductForm({this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: product?.name);
    final priceController = useTextEditingController(text: product?.price.toString());
    final stockController = useTextEditingController(text: product?.stock.toString() ?? '0');
    final descController = useTextEditingController(text: product?.description);
    final weightController = useTextEditingController(text: product?.weight);
    final unitController = useTextEditingController(text: product?.unit ?? '/pack');
    final categoryController = useTextEditingController(text: product?.category ?? 'Ayam');
    final imageUrl = useState(product?.imageUrl ?? '');
    final isUploading = useState(false);

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        final file = File(image.path);
        final bytes = await file.length();

        if (bytes > 2 * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran gambar terlalu besar (Maksimal 2MB)'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
          return;
        }

        isUploading.value = true;
        try {
          final url = await ref.read(productRepositoryProvider).uploadProductImage(file);
          imageUrl.value = url;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal upload gambar: $e'), backgroundColor: AppTheme.error),
            );
          }
        } finally {
          isUploading.value = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: isUploading.value ? null : pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outlineVariant),
                  image: imageUrl.value.isNotEmpty
                      ? DecorationImage(image: NetworkImage(imageUrl.value), fit: BoxFit.cover)
                      : null,
                ),
                child: isUploading.value
                    ? const Center(child: CircularProgressIndicator())
                    : imageUrl.value.isEmpty
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 48, color: AppTheme.onSurfaceVariant),
                              SizedBox(height: 12),
                              Text('Upload Gambar Produk'),
                              Text('(Maksimal 2MB)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          )
                        : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: 'Berat (misal: 500g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit (misal: /pack)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isUploading.value ? null : () async {
                  if (nameController.text.isEmpty || priceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nama dan Harga wajib diisi')),
                    );
                    return;
                  }
                  if (imageUrl.value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Silakan upload gambar produk terlebih dahulu')),
                    );
                    return;
                  }

                  final newProduct = ProductModel(
                    id: product?.id ?? '',
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    description: descController.text,
                    weight: weightController.text,
                    imageUrl: imageUrl.value,
                    unit: unitController.text,
                    category: categoryController.text,
                    isAvailable: true,
                    stock: int.tryParse(stockController.text) ?? 0,
                  );

                  try {
                    if (product == null) {
                      await ref.read(productRepositoryProvider).addProduct(newProduct);
                    } else {
                      await ref.read(productRepositoryProvider).updateProduct(newProduct);
                    }
                    if (context.mounted) {
                      context.pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan produk: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Simpan Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
