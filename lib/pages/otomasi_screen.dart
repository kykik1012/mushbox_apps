import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/otomasi_provider.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';
import 'history_automation_screen.dart';

class OtomasiScreen extends StatefulWidget {
  const OtomasiScreen({super.key});

  @override
  State<OtomasiScreen> createState() => _OtomasiScreenState();
}

class _OtomasiScreenState extends State<OtomasiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Mengupdate UI tombol bawah ketika tab digeser/diklik
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OtomasiProvider>(context, listen: false).fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTabTrigger = _tabController.index == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
          // --- TAMBAHAN TOMBOL HISTORY DI SINI ---
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.history, color: Color(0xFF163832), size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryAutomationScreen()),
                  );
                },
              ),
            )
          ],
          bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF163832),
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
            controller: _tabController,
            children: [
              _buildTriggerList(prov),
              _buildJadwalList(prov), // TAB 2 JADWAL WAKTU
            ],
          );
        },
      ),
      
      // TOMBOL BAWAH DINAMIS
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF163832),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            isTabTrigger ? 'Tambah Trigger' : 'Tambah Jadwal Jam', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
          onPressed: () {
            if (isTabTrigger) {
              _showAddTriggerForm();
            } else {
              _showAddJadwalForm(); // Panggil Form Jadwal
            }
          },
        ),
      ),
    );
  }

  // --- WIDGET LIST TRIGGER (KODE SEBELUMNYA) ---
  Widget _buildTriggerList(OtomasiProvider prov) {
    final dashProv = Provider.of<DashboardProvider>(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Kontrol Manual", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue),
                title: const Text('Pompa Penyemprot', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Switch(value: dashProv.isPompaOnline, activeColor: Colors.blue, onChanged: (val) => dashProv.manualTogglePompa(val)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.mode_fan_off, color: Colors.orange),
                title: const Text('Kipas Ventilasi', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Switch(value: dashProv.isKipasOnline, activeColor: Colors.orange, onChanged: (val) => dashProv.manualToggleKipas(val)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text("Aturan Otomatis", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        if (prov.triggers.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Belum ada trigger otomasi.", style: TextStyle(color: Colors.grey))))
        else
          ...prov.triggers.map((item) => _buildTriggerItem(item, prov)).toList(),
      ],
    );
  }

  Widget _buildTriggerItem(dynamic item, OtomasiProvider prov) {
    final bool isActive = item['is_active'];
    final bool hasBatasBawah = item['batas_bawah'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: isActive ? const Color(0xFFE8F0ED) : Colors.grey[200], radius: 16, child: Icon(Icons.bolt, color: isActive ? const Color(0xFF163832) : Colors.grey, size: 18)),
                  const SizedBox(width: 12),
                  Switch(value: isActive, activeColor: const Color(0xFF163832), onChanged: (val) => prov.toggleTrigger(item['id'], isActive)),
                ],
              ),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => prov.deleteTrigger(item['id'])),
                  IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20), onPressed: () {}),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
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
                  child: Text(hasBatasBawah ? '${item['sensor']} \u2265 ${item['nilai']}' : '${item['sensor']} ${item['operator']} ${item['nilai']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF163832))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Text('MAKA', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 16),
                Expanded(child: Text(hasBatasBawah ? '${item['perintah'] == 'ON' ? 'Nyalakan' : 'Matikan'} ${item['aktuator']} hingga < ${item['batas_bawah']}' : '${item['perintah'] == 'ON' ? 'Nyalakan' : 'Matikan'} ${item['aktuator']}', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // --- BARIS BARU: WIDGET PEMBANTU LIST JADWAL JAM ---
  // ====================================================
  Widget _buildJadwalList(OtomasiProvider prov) {
    if (prov.schedules.isEmpty) {
      return const Center(child: Text("Belum ada jadwal penyemprotan rutin.", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prov.schedules.length,
      itemBuilder: (context, index) {
        final item = prov.schedules[index];
        final bool isActive = item['is_active'];
        
        // Supabase mengembalikan format "HH:mm:ss", kita potong menjadi "HH:mm" agar rapi
        final String displayTime = item['waktu'].toString().substring(0, 5);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: isActive ? const Color(0xFFE8F0ED) : Colors.grey[200], radius: 16, child: Icon(Icons.schedule, color: isActive ? const Color(0xFF163832) : Colors.grey, size: 18)),
                      const SizedBox(width: 12),
                      Switch(value: isActive, activeColor: const Color(0xFF163832), onChanged: (val) => prov.toggleJadwal(item['id'], isActive)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () {
                      // Munculkan kotak dialog konfirmasi
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Hapus Jadwal?"),
                            content: const Text("Apakah kamu yakin ingin menghapus jadwal penyemprotan rutin ini?"),
                            actions: [
                              // Tombol Batal
                              TextButton(
                                child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                onPressed: () => Navigator.pop(context),
                              ),
                              // Tombol Hapus Nyata
                              TextButton(
                                child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  Navigator.pop(context); // Tutup popup dialog dulu
                                  
                                  // Eksekusi hapus ke Supabase
                                  await prov.deleteJadwal(item['id']); 
                                  
                                  // Tampilkan notifikasi sukses kecil di bawah layar
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Jadwal berhasil dihapus!'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(displayTime, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF163832))),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Text('AKSI', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 16),
                    Text('${item['perintah'] == 'ON' ? 'Nyalakan' : 'Matikan'} ${item['aktuator']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- FUNGSI POPUP FORM TAMBAH TRIGGER (LAMA) ---
  void _showAddTriggerForm() {
    final prov = Provider.of<OtomasiProvider>(context, listen: false);
    String selectedSensor = 'Suhu'; String selectedOperator = '>'; String selectedAktuator = 'Kipas'; String selectedPerintah = 'ON';
    final TextEditingController nilaiController = TextEditingController(); final TextEditingController batasBawahController = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tambah Aturan Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 24),
            _buildLabel("Pilih Sensor"), DropdownButtonFormField<String>(value: selectedSensor, decoration: _inputDecoration(), items: ['Suhu', 'Kelembaban Tanah', 'Kelembaban Udara', 'Level Air', 'CO2'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) => selectedSensor = val!), const SizedBox(height: 16),
            _buildLabel("Batas Atas (Target Hidup)"), TextField(controller: nilaiController, keyboardType: TextInputType.number, decoration: _inputDecoration(hint: "Contoh: 32")), const SizedBox(height: 16),
            _buildLabel("Batas Bawah (Toleransi Mati) - Opsional"), TextField(controller: batasBawahController, keyboardType: TextInputType.number, decoration: _inputDecoration(hint: "Contoh: 28")), const SizedBox(height: 16),
            _buildLabel("Pilih Aktuator"), DropdownButtonFormField<String>(value: selectedAktuator, decoration: _inputDecoration(), items: ['Kipas', 'Pompa'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) => selectedAktuator = val!), const SizedBox(height: 16),
            _buildLabel("Perintah Awal"), DropdownButtonFormField<String>(value: selectedPerintah, decoration: _inputDecoration(), items: ['ON', 'OFF'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (val) => selectedPerintah = val!), const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF163832), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () async { if (nilaiController.text.isEmpty) return; final Map<String, dynamic> newData = { 'sensor': selectedSensor, 'operator': selectedOperator, 'nilai': double.parse(nilaiController.text), 'batas_bawah': batasBawahController.text.isEmpty ? null : double.parse(batasBawahController.text), 'aktuator': selectedAktuator, 'perintah': selectedPerintah, 'is_active': true, }; await prov.addTrigger(newData); if (mounted) Navigator.pop(context); }, child: const Text('Simpan Aturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  // ====================================================
  // --- PERBAIKAN: POPUP FORM TAMBAH JADWAL JAM ---
  // ====================================================
  void _showAddJadwalForm() {
    final prov = Provider.of<OtomasiProvider>(context, listen: false);
    TimeOfDay selectedTime = const TimeOfDay(hour: 08, minute: 00);
    String selectedAktuator = 'Pompa';
    String selectedPerintah = 'ON';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // TAMBAHAN 1: Mengizinkan form mekar melebihi batas default
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          // TAMBAHAN 2: Memberi jarak aman di bagian bawah layar
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
          child: SingleChildScrollView( // TAMBAHAN 3: Membungkus form agar bisa di-scroll
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tambah Jadwal Waktu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // Tombol untuk memunculkan Android Time Picker asli
                _buildLabel("Pilih Jam & Menit"),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(context: context, initialTime: selectedTime);
                    if (time != null) {
                      setModalState(() => selectedTime = time);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF163832)),
                        ),
                        const Icon(Icons.access_time, color: Color(0xFF163832)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pilih Aktuator
                _buildLabel("Pilih Perangkat"),
                DropdownButtonFormField<String>(
                  value: selectedAktuator,
                  decoration: _inputDecoration(),
                  items: ['Pompa', 'Kipas'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => selectedAktuator = val!,
                ),
                const SizedBox(height: 16),

                // Pilih Perintah
                _buildLabel("Aksi"),
                DropdownButtonFormField<String>(
                  value: selectedPerintah,
                  decoration: _inputDecoration(),
                  items: ['ON', 'OFF'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => selectedPerintah = val!,
                ),
                const SizedBox(height: 32),

                // Tombol Simpan Jadwal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF163832), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      // Konversi format TimeOfDay ke format "HH:mm:00" yang disukai database
                      final String formattedTime = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00";

                      final Map<String, dynamic> newJadwal = {
                        'waktu': formattedTime,
                        'aktuator': selectedAktuator,
                        'perintah': selectedPerintah,
                        'is_active': true,
                      };

                      await prov.addJadwal(newJadwal);
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Simpan Jadwal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)));
  InputDecoration _inputDecoration({String? hint}) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12));
}