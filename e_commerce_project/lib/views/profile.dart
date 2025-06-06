import 'package:flutter/material.dart';
import 'package:e_commerce_project/data/local/shared_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_commerce_project/views/loginPage.dart';
import 'package:e_commerce_project/core/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  // Modern bottom sheet ile uyarı ve yönlendirme
  static Future<void> showSellerAccessDenied(BuildContext context, void Function()? onOk) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: AppColors.primaryColor),
            const SizedBox(height: 16),
            const Text(
              'Erişim Engellendi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu sayfaya erişmek için satıcı kaydı yaptırmalısınız.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOk != null) onOk();
              },
              child: const Text('Profilime Git'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String?>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await SharedPrefs.getUserData();
    setState(() {
      userData = data;
      loading = false;
    });
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
     
      body: userData == null
          ? const Center(child: Text('Kullanıcı verisi bulunamadı.'))
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Arka plan
                 
                    // Avatar
                    Transform.translate(
                      offset: const Offset(0, -56),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 52,
                          backgroundImage: (userData!['photoUrl'] != null && userData!['photoUrl']!.isNotEmpty)
                              ? NetworkImage(userData!['photoUrl']!)
                              : null,
                          child: (userData!['photoUrl'] == null || userData!['photoUrl']!.isEmpty)
                              ? Icon(Icons.person, size: 52, color: AppColors.primaryColor)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Kart
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                          child: Column(
                            children: [
                              Text(
                                userData!['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userData!['email'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Rol: ${userData!['role'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.errorColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: _signOut,
                                  icon: const Icon(Icons.logout),
                                  label: const Text(
                                    'Çıkış Yap',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              // Satıcı kaydı butonu sadece müşteri ise göster
                              if ((userData!['role'] ?? '').toLowerCase() == 'customer') ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.store_mall_directory),
                                    label: const Text('Satıcı Kaydı Oluştur'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () {
                                      // Satıcı kaydı oluşturma işlemi burada yapılabilir
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Satıcı kaydı oluşturma ekranı açılacak!')),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
