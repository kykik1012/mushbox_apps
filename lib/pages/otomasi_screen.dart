import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/otomasi_provider.dart';
import '../providers/dashboard_provider.dart'; // TAMBAHAN: Import Dashboard Provider
import '../theme/app_colors.dart';

class OtomasiScreen extends StatefulWidget {
  const OtomasiScreen({super.key});

  @override
  State<OtomasiScreen> createState() => _OtomasiScreenState();
}

class _OtomasiScreenState extends State<OtomasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OtomasiProvider>(context, listen: false).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tab: Trigger & Jadwal
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Off-white
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Otomasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
              Text('Aturan & penjadwalan otomatis', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(0xFF163832), // Hijau Gelap
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bolt, size: 18), SizedBox(width: 8), Text('Trigger')])),
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.schedule, size: 18), SizedBox(width: 8), Text('Jadwal')])),
                ],
              ),
            ),
          ),
        ),
        body: Consumer<OtomasiProvider>(
          builder: (context, prov, child) {
            if (prov.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF163832)));
            }

            return TabBarView(
              children: [
                // TAB 1: TRIGGER & MANUAL CONTROL
                _buildTriggerList(prov),

                // TAB 2: JADWAL
                const Center(child: Text("Fitur Jadwal akan tampil di sini")),
              ],
            );
          },
        ),
        
        // TOMBOL TAMBAH DI BAWAH
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF163832),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Tambah Trigger', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form Tambah segera menyusul!')));
            },
          ),
        ),
      ),
    );
  }

  // WIDGET PEMBANTU: LIST TRIGGER & MANUAL CONTROL
  Widget _buildTriggerList(OtomasiProvider prov) {
    // Panggil DashboardProvider untuk mengontrol saklar manual
    final dashProv = Provider.of<DashboardProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- BAGIAN 1: KONTROL MANUAL ---
        const Text("Kontrol Manual", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue),
                title: const Text('Pompa Penyemprot', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Switch(
                  value: dashProv.isPompaOnline,
                  activeColor: Colors.blue,
                  onChanged: (val) => dashProv.manualTogglePompa(val),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.mode_fan_off, color: Colors.orange),
                title: const Text('Kipas Ventilasi', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Switch(
                  value: dashProv.isKipasOnline,
                  activeColor: Colors.orange,
                  onChanged: (val) => dashProv.manualToggleKipas(val),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),

        // --- BAGIAN 2: DAFTAR TRIGGER OTOMATIS ---
        const Text("Aturan Otomatis", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        
        // Cek apakah data kosong
        if (prov.triggers.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Belum ada trigger otomasi.", style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          // Looping (Map) data dari Supabase menjadi desain kartu
          ...prov.triggers.map((item) => _buildTriggerItem(item, prov)).toList(),
      ],
    );
  }

  // WIDGET PEMBANTU: DESAIN KARTU TRIGGER
  Widget _buildTriggerItem(dynamic item, OtomasiProvider prov) {
    final bool isActive = item['is_active'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARIS ATAS: Icon, Switch, dan Tombol Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isActive ? const Color(0xFFE8F0ED) : Colors.grey[200],
                    radius: 16,
                    child: Icon(Icons.bolt, color: isActive ? const Color(0xFF163832) : Colors.grey, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: isActive,
                    activeColor: const Color(0xFF163832),
                    onChanged: (val) => prov.toggleTrigger(item['id'], isActive),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => prov.deleteTrigger(item['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // KOTAK JIKA (KONDISI)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Text('JIKA', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8F0ED), borderRadius: BorderRadius.circular(4)),
                  child: Text('${item['sensor']} ${item['operator']} ${item['nilai']}', style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF163832))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // KOTAK MAKA (AKSI)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Text('MAKA', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 16),
                Text('${item['perintah'] == 'ON' ? 'Nyalakan' : 'Matikan'} ${item['aktuator']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}