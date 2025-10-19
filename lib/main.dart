import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      // Sử dụng constructor rỗng để khởi tạo trạng thái không có dữ liệu
      create: (_) => AppState(),
      child: const TluApp(),
    ),
  );
}

class TluApp extends StatelessWidget {
  const TluApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4));
    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      // Sử dụng font Inter
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý lịch giảng dạy',
      theme: theme,
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Định nghĩa các trang chính
    final pages = <Widget>[
      const OverviewScreen(),
      const ScheduleScreen(),
      const ApprovalScreen(),
      const ProgressScreen(),
      const LecturersScreen(),
      const AlertsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[state.currentTabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.currentTabIndex,
        onDestinationSelected: (i) => context.read<AppState>().setTab(i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Tổng quan'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), label: 'Lịch dạy'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'Phê duyệt'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Tiến độ'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Giảng viên'),
          NavigationDestination(icon: Icon(Icons.warning_amber_rounded), label: 'Cảnh báo'),
        ],
      ),
    );
  }
}

// --- Screens ---
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final kpiStyle = Theme.of(context).textTheme.titleMedium;

    // Lấy tất cả yêu cầu chờ duyệt (xin nghỉ và dạy bù)
    final pendingRequests = [...state.leaveRequests.where((r) => r.status == RequestStatus.pending), ...state.makeups.where((m) => m.status == RequestStatus.pending)];

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('Tổng quan bộ môn', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          // Các KPI Card (Hiển thị 4 cột trên tablet/desktop, 2 cột trên mobile)
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _KpiCard(icon: Icons.group, color: Colors.blue, title: 'Giảng viên', value: state.totalLecturers.toString(), style: kpiStyle),
              _KpiCard(icon: Icons.menu_book_rounded, color: Colors.green, title: 'Môn học', value: state.totalSubjects.toString(), style: kpiStyle),
              _KpiCard(icon: Icons.event_available, color: Colors.indigo, title: 'Buổi dạy', value: state.totalSessions.toString(), style: kpiStyle),
              // KPI Cảnh báo được thay bằng số lượng yêu cầu chờ duyệt
              _KpiCard(icon: Icons.fact_check, color: Colors.amber, title: 'Chờ duyệt', value: pendingRequests.length.toString(), style: kpiStyle),
            ],
          ),
          const SizedBox(height: 24),
          // Biểu đồ tiến độ (sẽ trống nếu không có dữ liệu)
          _Section(title: 'Tiến độ giảng dạy', child: _OverallLecturerBar()),
          const SizedBox(height: 24),
          // Đã sửa: Thay thế phần Cảnh báo mới nhất bằng Yêu cầu chờ duyệt
          _Section(
            title: 'Yêu cầu chờ duyệt',
            action: TextButton(onPressed: () => _jumpTo(context, 2), child: const Text('Xem phê duyệt')), // Jump to Approval Screen (index 2)
            child: pendingRequests.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('Không có yêu cầu nào chờ duyệt')))
                : Column(
              children: pendingRequests.take(5).map((r) => _PendingRequestTile(request: r)).toList(),
            ),
          ),
        ],
      ),
    );
    // Sử dụng HoDWelcomeAppBar mới cho màn hình Tổng quan
    return Scaffold(appBar: const HoDWelcomeAppBar(), body: body);
  }
}

class _PendingRequestTile extends StatelessWidget {
  const _PendingRequestTile({required this.request});
  final dynamic request; // Có thể là LeaveRequest hoặc MakeupRegistration

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;
    Color color = Colors.amber.shade700;
    String typeLabel;

    if (request is LeaveRequest) {
      final r = request as LeaveRequest;
      typeLabel = 'Xin nghỉ';
      title = '${r.lecturer} • Lớp ${r.className}';
      subtitle = 'Nghỉ ${dmy(r.date)} • Lý do: ${r.reason}';
      icon = Icons.person_off_outlined;
    } else if (request is MakeupRegistration) {
      final m = request as MakeupRegistration;
      typeLabel = 'Dạy bù';
      title = '${m.lecturer} • Dạy bù ${dmy(m.makeupDate)}';
      subtitle = 'Buổi nghỉ ${dmy(m.originalDate)} • Phòng: ${m.makeupRoom}';
      icon = Icons.calendar_today_outlined;
    } else {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.amber.shade200)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withAlpha(26), foregroundColor: color, child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: Chip(
          label: Text(typeLabel),
          backgroundColor: Colors.amber.shade100,
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        onTap: () => _jumpTo(context, 2), // Nhấn vào chuyển sang màn hình Phê duyệt
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.icon, required this.color, required this.title, required this.value, required this.style});
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Cấu trúc icon chính xác
            CircleAvatar(backgroundColor: color.withAlpha(26), foregroundColor: color, child: Icon(icon)),
            const SizedBox(width: 12),
            // ĐÃ SỬA: Bọc Column trong Expanded để nó sử dụng không gian còn lại
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: style, maxLines: 1, overflow: TextOverflow.ellipsis,), // Thêm ellipsis để xử lý tràn
                    const SizedBox(height: 6),
                    Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
            if (action != null) action!,
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}

class _OverallLecturerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Chỉ tạo biểu đồ nếu có dữ liệu giảng viên
    if (state.lecturers.isEmpty) {
      return const SizedBox(height: 220, child: Center(child: Text('Không có dữ liệu tiến độ giảng dạy')));
    }

    final names = state.lecturers.map((e) => e.name.split(' ').last).toList();
    // Tạo data trống cho biểu đồ
    final bars = List.generate(names.length, (i) => BarChartGroupData(x: i, barRods: [
      // Taught % (Đã dạy)
      BarChartRodData(toY: 0, color: Colors.blue, width: 14),
      // Leave % (Nghỉ)
      BarChartRodData(toY: 0, color: Colors.red, width: 14),
      // Makeup % (Dạy bù)
      BarChartRodData(toY: 0, color: Colors.teal, width: 14),
      // Remaining % (Còn lại)
      BarChartRodData(toY: 0, color: Colors.grey, width: 14),
    ]));

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: bars,
          titlesData: FlTitlesData(
            // Hiển thị tiêu đề trục Y (Left)
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
            // Hiển thị tên giảng viên ở trục X (Bottom)
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final i = value.toInt();
              return Padding(padding: const EdgeInsets.only(top: 6), child: Text(i >= 0 && i < names.length ? names[i] : ''));
            })),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          groupsSpace: 12,
        ),
      ),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Giá trị lọc mặc định
  String lecturer = 'Tất cả';
  String subject = 'Tất cả';
  String status = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Tạo danh sách các giá trị duy nhất cho Dropdown
    final allLecturers = ['Tất cả', ...state.lecturers.map((e) => e.name)];
    final allSubjects = ['Tất cả', ...state.schedules.map((e) => e.subject).toSet()];
    final allStatuses = ['Tất cả', ...SessionStatus.values.map(statusLabel)];


    final filters = state.schedules.where((s) {
      final okLect = lecturer == 'Tất cả' || s.lecturer == lecturer;
      final okSub = subject == 'Tất cả' || s.subject == subject;
      final okStatus = status == 'Tất cả' || statusLabel(s.status) == status;
      return okLect && okSub && okStatus;
    }).toList();

    return Scaffold(
      // Đã sửa: Thay đổi tiêu đề AppBar từ 'Lịch giảng dạy bộ môn' thành 'Lịch dạy bộ môn'
      appBar: const HoDAppBar(title: 'Lịch dạy bộ môn'),
      body: Column(children: [
        // Bộ lọc
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            // Thay đổi từ Wrap sang Column nếu muốn mỗi Dropdown chiếm 100%
            // Hiện tại dùng Wrap với Dropdown có chiều rộng 90% sẽ tự động nhảy hàng.
            _Dropdown(label: 'Giảng viên', value: lecturer, values: allLecturers, onChanged: (v) => setState(() => lecturer = v!)),
            _Dropdown(label: 'Môn học', value: subject, values: allSubjects, onChanged: (v) => setState(() => subject = v!)),
            _Dropdown(label: 'Trạng thái', value: status, values: allStatuses, onChanged: (v) => setState(() => status = v!)),
          ]),
        ),
        // Danh sách lịch trình
        Expanded(
          child: filters.isEmpty
              ? const Center(child: Text('Không có lịch giảng dạy nào'))
              : ListView.separated(
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = filters[i];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Text('${s.lecturer} • ${s.subject} • Lớp ${s.className}'),
                  subtitle: Text('${dmy(s.date)} • ${s.session} • Phòng ${s.room} — Điểm danh: ${s.attendance ?? '-'}'),
                  trailing: _StatusChip(status: s.status),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});
  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HoDAppBar(title: 'Phê duyệt'),
      body: Column(children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [Tab(text: 'Đơn xin nghỉ'), Tab(text: 'Đăng ký dạy bù')],
          ),
        ),
        Expanded(child: TabBarView(controller: _tabController, children: const [_LeaveTab(), _MakeupTab()])),
      ]),
    );
  }
}

class _LeaveTab extends StatelessWidget {
  const _LeaveTab();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.leaveRequests.where((e) => e.status == RequestStatus.pending).toList();
    if (items.isEmpty) {
      return const Center(child: Text('Chưa có đơn xin nghỉ nào chờ duyệt'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final r = items[i];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${r.lecturer} • ${r.subject} • Lớp ${r.className}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Ngày: ${dmy(r.date)}  •  ${r.session}  •  Phòng: ${r.room}'),
              Text('Nộp lúc: ${dmy(r.submittedAt)}'),
              const SizedBox(height: 8),
              Text('Lý do: ${r.reason}'),
              const SizedBox(height: 8),
              Row(children: [
                TextButton(onPressed: () {}, child: const Text('Xem minh chứng đính kèm')),
                const Spacer(),
                _ApproveRejectButtons(onApprove: () => context.read<AppState>().approveLeave(r, true), onReject: () => context.read<AppState>().approveLeave(r, false)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _MakeupTab extends StatelessWidget {
  const _MakeupTab();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.makeups.where((e) => e.status == RequestStatus.pending).toList();
    if (items.isEmpty) {
      return const Center(child: Text('Chưa có đăng ký dạy bù nào chờ duyệt'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _InfoBox(title: 'Buổi nghỉ', lines: ['${dmy(m.originalDate)}', m.originalSession])),
              const SizedBox(width: 8),
              // Buổi dạy bù được highlight màu xanh nhạt
              Expanded(child: _InfoBox(title: 'Buổi dạy bù', highlight: true, lines: ['${dmy(m.makeupDate)}', m.makeupSession, 'Phòng ${m.makeupRoom}'])),
              const SizedBox(width: 8),
              _ApproveRejectButtons(onApprove: () => context.read<AppState>().approveMakeup(m, true), onReject: () => context.read<AppState>().approveMakeup(m, false)),
            ]),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// ĐÃ SỬA: Thêm chức năng tìm kiếm và lọc cho ProgressScreen
// -----------------------------------------------------------------------------
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String searchText = '';
  String subjectFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Nếu không có giảng viên, hiển thị thông báo trống
    if (state.lecturers.isEmpty) {
      return const Scaffold(appBar: HoDAppBar(title: 'Tiến độ'), body: Center(child: Text('Không có dữ liệu giảng viên để theo dõi tiến độ')));
    }

    final allSubjects = ['Tất cả', ...state.lecturers.map((e) => e.subject).toSet()];

    // Logic lọc và tìm kiếm
    final filteredProgress = state.lecturers.where((l) {
      // Đảm bảo tìm kiếm theo tên/email hoạt động
      final matchesSearch = searchText.isEmpty || l.name.toLowerCase().contains(searchText.toLowerCase()) || l.email.toLowerCase().contains(searchText.toLowerCase());
      final matchesSubject = subjectFilter == 'Tất cả' || l.subject == subjectFilter;
      return matchesSearch && matchesSubject;
    }).toList();

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          Text('Tiến độ giảng dạy', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          FilledButton.tonal(onPressed: () {}, child: const Text('Xuất báo cáo')),
        ]),
        const SizedBox(height: 12),
        // Bộ lọc và tìm kiếm
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ĐÃ SỬA: Bọc SearchField trong Column để nó chiếm full width (đã có)
              _SearchField(
                hintText: 'Tìm kiếm theo tên giảng viên, email...',
                onChanged: (value) => setState(() => searchText = value),
              ),
              const SizedBox(height: 8),
              // Wrap Dropdown để nó cũng chiếm full width trên mobile
              _Dropdown(label: 'Môn học', value: subjectFilter, values: allSubjects, onChanged: (v) => setState(() => subjectFilter = v!)),
            ],
          ),
        ),

        // Biểu đồ tổng quan
        Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(12), child: _OverallLecturerBar())),
        const SizedBox(height: 12),
        // Danh sách tiến độ chi tiết
        if (filteredProgress.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('Không tìm thấy giảng viên nào')))
        else
          ...filteredProgress.map((l) => _ProgressRow(l: l)).toList(),
      ]),
    );
    return Scaffold(appBar: const HoDAppBar(title: 'Tiến độ'), body: body);
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.l});
  final Lecturer l;
  @override
  Widget build(BuildContext context) {
    // Tính toán phần trăm (sẽ là 0% nếu hoursPlanned = 0)
    final percent = l.hoursPlanned == 0 ? 0 : (l.hoursActual / l.hoursPlanned * 100).round();
    final progressValue = l.hoursPlanned == 0 ? 0.0 : l.hoursActual / l.hoursPlanned;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('${l.name} • ${l.subject}', style: Theme.of(context).textTheme.titleMedium)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(14)), child: Text('$percent%')),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progressValue, minHeight: 8, borderRadius: BorderRadius.circular(8), color: Colors.blue),
          const SizedBox(height: 4),
          Text('Giờ giảng: ${l.hoursActual}/${l.hoursPlanned} giờ'),
          const SizedBox(height: 8),
          // KPI chi tiết sẽ hiển thị '-' vì không có dữ liệu buổi cụ thể
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
            _KpiSmall(title: 'Tổng số buổi', value: '-'),
            _KpiSmall(title: 'Đã dạy', value: '-'),
            _KpiSmall(title: 'Đã nghỉ', value: '-'),
            _KpiSmall(title: 'Đã dạy bù', value: '-'),
          ]),
          const SizedBox(height: 8),
          const Row(children: [Icon(Icons.info_outline, color: Colors.grey, size: 18), SizedBox(width: 6), Text('Chưa có dữ liệu chi tiết')]),
        ]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ĐÃ SỬA: Thêm chức năng tìm kiếm và lọc cho LecturersScreen
// -----------------------------------------------------------------------------
class LecturersScreen extends StatefulWidget {
  const LecturersScreen({super.key});
  @override
  State<LecturersScreen> createState() => _LecturersScreenState();
}

class _LecturersScreenState extends State<LecturersScreen> {
  String searchText = '';
  String subjectFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final allSubjects = ['Tất cả', ...state.lecturers.map((e) => e.subject).toSet()];

    // Logic lọc và tìm kiếm
    final filteredLecturers = state.lecturers.where((l) {
      final matchesSearch = searchText.isEmpty ||
          l.name.toLowerCase().contains(searchText.toLowerCase()) ||
          l.email.toLowerCase().contains(searchText.toLowerCase());
      final matchesSubject = subjectFilter == 'Tất cả' || l.subject == subjectFilter;
      return matchesSearch && matchesSubject;
    }).toList();

    return Scaffold(
      appBar: const HoDAppBar(title: 'Quản lý giảng viên'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchField(
                  hintText: 'Tìm kiếm theo tên, email...',
                  onChanged: (value) => setState(() => searchText = value),
                ),
                const SizedBox(height: 8),
                _Dropdown(label: 'Môn học', value: subjectFilter, values: allSubjects, onChanged: (v) => setState(() => subjectFilter = v!)),
              ],
            ),
          ),
          Expanded(
            child: filteredLecturers.isEmpty
                ? const Center(child: Text('Không tìm thấy giảng viên nào'))
                : GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 2 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: filteredLecturers.map((l) => _LecturerCard(l: l)).toList(),
            ),
          ),
        ],
      ),
      // Giữ nút thêm giảng viên
      // floatingActionButton: FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Thêm giảng viên')),
    );
  }
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Trạng thái lọc mặc định
  String type = 'Tất cả';
  String level = 'Tất cả';
  String status = 'Tất cả';
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Lấy danh sách các lựa chọn cho Dropdown
    final allAlertTypes = ['Tất cả', ...AlertType.values.map(alertTypeLabel)];
    final allAlertStatuses = ['Tất cả', ...AlertState.values.map(alertStateLabel)];

    // Logic lọc (vẫn giữ nguyên để minh họa)
    final filtered = state.alerts.where((a) {
      final okType = type == 'Tất cả' || alertTypeLabel(a.type) == type;
      final okLevel = level == 'Tất cả' || a.priority == level;
      final okStatus = status == 'Tất cả' || alertStateLabel(a.state) == status;
      return okType && okLevel && okStatus;
    }).toList();

    return Scaffold(
      appBar: const HoDAppBar(title: 'Quản lý cảnh báo'),
      body: Column(children: [
        // Bộ lọc
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            _Dropdown(label: 'Loại cảnh báo', value: type, values: allAlertTypes, onChanged: (v) => setState(() => type = v!)),
            _Dropdown(label: 'Mức độ', value: level, values: const ['Tất cả', 'Cao', 'Trung bình', 'Thấp'], onChanged: (v) => setState(() => level = v!)),
            _Dropdown(label: 'Trạng thái', value: status, values: allAlertStatuses, onChanged: (v) => setState(() => status = v!)),
          ]),
        ),
        // Danh sách cảnh báo
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Không có cảnh báo nào cần xử lý'))
              : ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _AlertTile(alert: filtered[i], actions: true),
          ),
        ),
      ]),
    );
  }
}

// --- Widgets ---
class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, this.actions = false});
  final AlertItem alert;
  final bool actions;
  @override
  Widget build(BuildContext context) {
    final icon = {
      AlertType.conflict: Icons.calendar_month,
      AlertType.noMakeup: Icons.timelapse,
      AlertType.delay: Icons.bar_chart,
      AlertType.highLeave: Icons.person_off,
    }[alert.type]!;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, child: Icon(icon)),
        title: Text(alert.detail),
        subtitle: Text(dmy(alert.date)),
        trailing: actions
            ? PopupMenuButton<AlertState>(
          initialValue: alert.state,
          onSelected: (s) => context.read<AppState>().updateAlertState(alert, s),
          itemBuilder: (_) => AlertState.values
              .map((e) => PopupMenuItem(value: e, child: Text(alertStateLabel(e))))
              .toList(),
          child: Chip(label: Text(alertStateLabel(alert.state)), backgroundColor: alert.state == AlertState.unresolved ? Colors.red.shade100 : Colors.green.shade100,),
        )
            : Chip(label: Text(alert.priority)),
      ),
    );
  }
}

class _LecturerCard extends StatelessWidget {
  const _LecturerCard({required this.l});
  final Lecturer l;
  @override
  Widget build(BuildContext context) {
    final percent = l.hoursPlanned == 0 ? 0.0 : (l.hoursActual / l.hoursPlanned).clamp(0.0, 1.0);
    final percentInt = (percent * 100).round();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Sử dụng chữ cái đầu tiên của tên lót để làm avatar placeholder
            CircleAvatar(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, child: Text(l.name.split(' ').last.characters.first)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.name, style: Theme.of(context).textTheme.titleMedium),
              Text(l.title, style: Theme.of(context).textTheme.bodySmall),
            ])),
            Chip(label: const Text('Đang dạy', style: TextStyle(color: Colors.green)), backgroundColor: Colors.green.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.email, size: 16), const SizedBox(width: 6), Text(l.email),
          ]),
          Row(children: [
            const Icon(Icons.phone, size: 16), const SizedBox(width: 6), Text(l.phone),
          ]),
          const SizedBox(height: 8),
          Text('Môn giảng dạy: ${l.subject}'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: percent, minHeight: 8, borderRadius: BorderRadius.circular(8), color: Colors.blue),
          const SizedBox(height: 4),
          Text('Giờ giảng: ${l.hoursActual}/${l.hoursPlanned} giờ ($percentInt%)'),
          const SizedBox(height: 8),
          Row(children: [
            // Các nút hành động
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined), tooltip: 'Chỉnh sửa'),
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: Colors.red), tooltip: 'Xóa'),
            const Spacer(),
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_month), label: const Text('Xem lịch')),
          ]),
        ]),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.values, required this.onChanged});
  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình
    final screenWidth = MediaQuery.of(context).size.width;

    // ĐIỂM ĐÃ CHỈNH SỬA: Đặt chiều rộng tối đa là 90% màn hình trên mobile
    // và giới hạn tối đa là 300 pixels (thay vì 250) trên màn hình desktop/tablet.
    final dropdownWidth = screenWidth > 600 ? 300.0 : screenWidth * 0.9;

    return SizedBox(
      width: dropdownWidth,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: values.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: onChanged,
            alignment: AlignmentDirectional.centerStart,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NEW WIDGET: Search Field
// -----------------------------------------------------------------------------
class _SearchField extends StatelessWidget {
  const _SearchField({required this.hintText, required this.onChanged});
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final SessionStatus status;
  @override
  Widget build(BuildContext context) {
    final map = {
      SessionStatus.daDay: {'color': Colors.green, 'label': 'Đã dạy'},
      SessionStatus.nghi: {'color': Colors.red, 'label': 'Nghỉ'},
      SessionStatus.dayBu: {'color': Colors.blue, 'label': 'Dạy bù'},
      SessionStatus.chuaDay: {'color': Colors.grey, 'label': 'Chưa dạy'},
    }[status]!;
    final color = map['color'] as Color;
    final label = map['label'] as String;

    return Chip(label: Text(label), backgroundColor: color.withAlpha(26), labelStyle: TextStyle(color: color), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)));
  }
}

class _ApproveRejectButtons extends StatelessWidget {
  const _ApproveRejectButtons({required this.onApprove, required this.onReject});
  final VoidCallback onApprove;
  final VoidCallback onReject;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      FilledButton.icon(onPressed: onApprove, icon: const Icon(Icons.check), label: const Text('Duyệt'), style: FilledButton.styleFrom(backgroundColor: Colors.green)),
      const SizedBox(width: 8),
      FilledButton.tonalIcon(onPressed: onReject, icon: const Icon(Icons.close), label: const Text('Từ chối'), style: FilledButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red)),
    ]);
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.title, required this.lines, this.highlight = false});
  final String title;
  final List<String> lines;
  final bool highlight;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: highlight ? Colors.blue.shade50 : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        ...lines.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 8, color: highlight ? Theme.of(context).primaryColor : Colors.grey),
              const SizedBox(width: 6),
              Flexible(child: Text(e)),
            ],
          ),
        )).toList(),
      ]),
    );
  }
}

class _KpiSmall extends StatelessWidget {
  const _KpiSmall({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(title, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
    ]);
  }
}

// -----------------------------------------------------------------------------
// NEW WIDGET: Custom AppBar for Overview Screen
// -----------------------------------------------------------------------------

class HoDWelcomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HoDWelcomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false, // Loại bỏ nút back
      title: Row(
        children: [
          // Avatar minh họa (sử dụng icon người dùng làm placeholder)
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF6750A4)), // Màu tím đậm
          ),
          const SizedBox(width: 12),
          // Tiêu đề
          Text(
            'Xin chào, Trưởng Bộ môn',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600            ),
          ),
        ],
      ),
      elevation: 1,
    );
  }
}

// -----------------------------------------------------------------------------
// EXISTING WIDGET: General AppBar for other Screens
// -----------------------------------------------------------------------------
class HoDAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HoDAppBar({super.key, required this.title});
  final String title;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      title: Text(title),
      // Giả lập nút back/home, chuyển về trang Tổng quan (index 0)
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.read<AppState>().setTab(0)),
      elevation: 1,
    );
  }
}

void _jumpTo(BuildContext context, int index) {
  context.read<AppState>().setTab(index);
}
