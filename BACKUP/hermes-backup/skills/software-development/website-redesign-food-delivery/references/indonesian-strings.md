# Indonesian → English UI String Mappings

Common Indonesian strings found in restaurant storefront JS and HTML. Replace after copying source design to target brand.

| Indonesian | English |
|-----------|---------|
| Keranjang kosong | Your cart is empty |
| Pesanan Terkirim! ✅ | Order Placed! ✅ |
| Pesanan diterima! | Order received! |
| Pesanan masih kosong | Your cart is empty |
| Pesanan | Your Cart (drawer title) / Order (context: confirmation) |
| Catatan Pesanan | Order Notes |
| Instruksi khusus... | Special instructions... |
| Kembali | Continue Browsing / Back |
| Kembali Belanja | Continue Shopping |
| Tambah | Add |
| Tambahkan ke keranjang | Add to cart |
| Hapus | Remove |
| Kosongkan | Clear (cart) |
| Kirim Pesanan | Place Order |
| Total Pesanan | Order Total |
| Subtotal | Subtotal |
| Pajak | Tax |
| Diskon | Discount |
| Chat dengan | Chat with |
| Lihat Menu | View Menu / See Menu |
| Lihat Pesanan | View Order |
| Cari menu | Search menu |
| Semua | All |
| Kategori | Category |
| Urutkan | Sort |
| Harga | Price |
| Paling populer | Most popular |
| Terbaru | Newest |
| Tersedia | Available |
| Tidak tersedia | Not available |
| Sedang dimuat | Loading... |
| Stok | Stock |
| Stok habis | Out of stock |
| Stok terbatas | Low stock |
| Stok tidak mencukupi | Stock not sufficient |
| Pilih | Select |
| Mengirim... | Sending... |
| Terkirim! | Sent! |
| Gagal mengirim | Failed to send |
| Batalkan | Cancel |
| Simpan | Save |
| Ubah | Edit |
| Hapus Item | Delete Item |

## How to scan after deployment
```bash
curl -s http://127.0.0.1:7500/<target>/assets/app.js | grep -iE \"Keranjang|Pesanan|Kembali|Tambah|Hapus|Kosongkan|Stok|Catatan|Instruksi|Chat dengan|Lihat|Cari|Kategori|Urutkan|Tersedia|Sedang dimuat|Pilih|Terbaru|Paling populer|Harga|Mengirim|Gagal|Batalkan|Simpan|Ubah|Hapus Item\"
```
