import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_state.dart';
import 'firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
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
      const StatisticsScreen(), // ĐÃ SỬA: Thay ProgressScreen bằng StatisticsScreen
      const LecturersScreen(),
      const AlertsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[state.currentTab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.currentTab,
        onDestinationSelected: (i) => context.read<AppState>().setTab(i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Tổng quan'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), label: 'Lịch dạy'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'Phê duyệt'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Thống kê'), // ĐÃ SỬA: Thay 'Tiến độ' bằng 'Thống kê'
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
          
          // Nút quản lý dữ liệu mẫu
          
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
              // KPI Chờ duyệt
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

// -----------------------------------------------------------------------------
// ĐÃ SỬA: Màn hình Phê duyệt (ApprovalScreen)
// -----------------------------------------------------------------------------
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
    // 3 tabs: Chờ duyệt, Đã duyệt, Từ chối
    _tabController = TabController(length: 3, vsync: this);
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
        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Đã duyệt'),
              Tab(text: 'Từ chối'),
            ],
          ),
        ),
        // TabBarView
        Expanded(child: TabBarView(
            controller: _tabController,
            children: [
              _ApprovalTab(status: RequestStatus.pending), // Tab 1: Chờ duyệt
              _ApprovalTab(status: RequestStatus.approved), // Tab 2: Đã duyệt
              _ApprovalTab(status: RequestStatus.rejected), // Tab 3: Từ chối
            ]
        )),
      ]),
    );
  }
}

// Widget chung cho cả 3 tab Phê duyệt
class _ApprovalTab extends StatelessWidget {
  const _ApprovalTab({required this.status});
  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Lấy tất cả yêu cầu (Xin nghỉ và Dạy bù)
    final allRequests = [
      ...state.leaveRequests.map((r) => {'type': 'leave', 'data': r, 'status': r.status}),
      ...state.makeups.map((m) => {'type': 'makeup', 'data': m, 'status': m.status}),
    ];

    // Lọc theo trạng thái hiện tại của tab
    final filteredItems = allRequests.where((item) => item['status'] == status).toList();

    if (filteredItems.isEmpty) {
      String message = status == RequestStatus.pending
          ? 'Không có yêu cầu nào chờ duyệt.'
          : status == RequestStatus.approved
          ? 'Không có yêu cầu nào đã duyệt.'
          : 'Không có yêu cầu nào bị từ chối.';
      return Center(child: Text(message));
    }

    // Sắp xếp theo thời gian nộp (chỉ định cho LeaveRequest để minh họa)
    filteredItems.sort((a, b) {
      DateTime dateA = a['type'] == 'leave' ? (a['data'] as LeaveRequest).submittedAt : DateTime(2000);
      DateTime dateB = b['type'] == 'leave' ? (b['data'] as LeaveRequest).submittedAt : DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredItems.length,
      itemBuilder: (context, i) {
        final item = filteredItems[i];
        if (item['type'] == 'leave') {
          return _LeaveRequestCard(request: item['data'] as LeaveRequest, isPending: status == RequestStatus.pending);
        } else {
          return _MakeupRequestCard(makeup: item['data'] as MakeupRegistration, isPending: status == RequestStatus.pending);
        }
      },
    );
  }
}

// Card cho Đơn Xin Nghỉ (chỉ hiển thị nút Duyệt/Từ chối nếu đang ở trạng thái Pending)
class _LeaveRequestCard extends StatelessWidget {
  const _LeaveRequestCard({required this.request, required this.isPending});
  final LeaveRequest request;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Nghỉ dạy Chip và Ngày nộp)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RequestTypeChip(label: 'Nghỉ dạy', color: Colors.amber),
                Text(dmy(request.submittedAt), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            // Nội dung chính
            Text(request.lecturer, style: Theme.of(context).textTheme.titleMedium),
            Text('${request.subject} • Lớp ${request.className} • Phòng: ${request.room}'),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(dmy(request.date)),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(request.session),
              ],
            ),
            const SizedBox(height: 8),
            Text('Lý do: ${request.reason}'),

            // Nút hành động (chỉ hiện khi Pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(children: [
                TextButton(onPressed: () {}, child: const Text('Xem minh chứng')),
                const Spacer(),
                  _ApprovalButtons(
                    onApprove: () => context.read<AppState>().approveLeave(context.read<AppState>().leaveRequests.indexOf(request)),
                    onReject: () => context.read<AppState>().approveLeave(context.read<AppState>().leaveRequests.indexOf(request)),
                  ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

// Card cho Đăng Ký Dạy Bù
class _MakeupRequestCard extends StatelessWidget {
  const _MakeupRequestCard({required this.makeup, required this.isPending});
  final MakeupRegistration makeup;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Dạy bù Chip và Ngày nộp)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RequestTypeChip(label: 'Dạy bù', color: Colors.blue),
                Text(dmy(makeup.originalDate), style: Theme.of(context).textTheme.bodySmall), // Giả sử dùng ngày nghỉ ban đầu làm ngày tham chiếu
              ],
            ),
            const SizedBox(height: 8),
            // Nội dung chính
            Text(makeup.lecturer, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thông tin Buổi nghỉ
                Expanded(child: _InfoBox(title: 'Buổi nghỉ', lines: ['${dmy(makeup.originalDate)}', makeup.originalSession])),
                const SizedBox(width: 8),
                // Thông tin Dạy bù
                Expanded(child: _InfoBox(title: 'Buổi dạy bù', highlight: true, lines: ['${dmy(makeup.makeupDate)}', makeup.makeupSession, 'Phòng ${makeup.makeupRoom}'])),
              ],
            ),
            // Nút hành động (chỉ hiện khi Pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ApprovalButtons(
                    onApprove: () => context.read<AppState>().approveMakeup(context.read<AppState>().makeups.indexOf(makeup)),
                    onReject: () => context.read<AppState>().approveMakeup(context.read<AppState>().makeups.indexOf(makeup)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget chip nhỏ hiển thị loại yêu cầu
class _RequestTypeChip extends StatelessWidget {
  const _RequestTypeChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// ĐÃ SỬA: Màn hình Thống kê (StatisticsScreen) - Thay thế ProgressScreen
// -----------------------------------------------------------------------------
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Thay đổi tiêu đề AppBar
    return Scaffold(
      appBar: const HoDAppBar(title: 'Thống kê giờ giảng'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm
            _SearchField(
              hintText: 'Tìm kiếm theo giảng viên...',
              onChanged: (value) => setState(() => searchText = value),
            ),
            const SizedBox(height: 20),

            // Báo cáo thống kê (4 KPI cards)
            Text('Báo cáo thống kê', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _ReportCard(
                  icon: Icons.bar_chart,
                  color: Colors.indigo,
                  title: 'Thống kê giờ giảng',
                  subtitle: 'Tổng hợp giờ giảng theo giảng viên',
                ),
                _ReportCard(
                  icon: Icons.people_alt_outlined,
                  color: Colors.blue,
                  title: 'Thống kê điểm danh',
                  subtitle: 'Tỷ lệ điểm danh theo lớp, môn học',
                ),
                _ReportCard(
                  icon: Icons.access_time_filled,
                  color: Colors.amber,
                  title: 'Thống kê nghỉ, dạy bù',
                  subtitle: 'Tổng hợp tình hình nghỉ và bù giờ',
                ),
                _ReportCard(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  title: 'Tiến độ giảng dạy',
                  subtitle: 'Tỷ lệ hoàn thành theo kế hoạch',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Xem trước báo cáo (Giờ giảng)
            _Section(
              title: 'Xem trước báo cáo',
              child: _StatisticsPreview(lecturers: state.lecturers),
            ),
            const SizedBox(height: 20),

            // Xuất báo cáo (Form)
            _Section(
              title: 'Xuất báo cáo',
              child: _ExportReportForm(),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Card Báo cáo cho StatisticsScreen
class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Xem trước thống kê
class _StatisticsPreview extends StatelessWidget {
  const _StatisticsPreview({required this.lecturers});
  final List<Lecturer> lecturers;

  @override
  Widget build(BuildContext context) {
    if (lecturers.isEmpty) {
      return const Center(child: Text('Không có dữ liệu giảng viên để xem trước.'));
    }

    // Giả lập dữ liệu xem trước giờ giảng (chỉ lấy 4 giảng viên đầu)
    final previewData = lecturers.take(4).map((l) {
      // Giả lập giờ giảng (đã sử dụng hoursActual và hoursPlanned)
      final actual = l.hoursActual == 0 ? 25 : l.hoursActual;
      final planned = l.hoursPlanned == 0 ? 30 : l.hoursPlanned;
      final percent = actual / planned;
      return {'name': l.name, 'actual': actual, 'planned': planned, 'percent': percent};
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giờ giảng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...previewData.map((data) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['name'] as String, style: Theme.of(context).textTheme.bodyMedium),
                    Text('${data['actual']} giờ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: data['percent'] as double,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Widget Form Xuất báo cáo
class _ExportReportForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Giá trị mặc định cho Dropdown
    const List<String> reportTypes = ['Báo cáo giờ giảng', 'Báo cáo điểm danh', 'Báo cáo nghỉ/bù', 'Báo cáo tiến độ'];
    const List<String> timePeriods = ['Học kỳ hiện tại', 'Học kỳ trước', 'Năm học hiện tại', 'Tùy chọn'];
    const List<String> formats = ['Excel (.xlsx)', 'PDF (.pdf)'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loại báo cáo
        const Text('Loại báo cáo', style: TextStyle(fontWeight: FontWeight.w500)),
        _SimpleDropdown(value: reportTypes[0], items: reportTypes),
        const SizedBox(height: 12),

        // Thời gian
        const Text('Thời gian', style: TextStyle(fontWeight: FontWeight.w500)),
        _SimpleDropdown(value: timePeriods[0], items: timePeriods),
        const SizedBox(height: 12),

        // Định dạng
        const Text('Định dạng', style: TextStyle(fontWeight: FontWeight.w500)),
        _SimpleDropdown(value: formats[0], items: formats),
        const SizedBox(height: 20),

        // Nút Xuất báo cáo
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('Xuất báo cáo'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

// Dropdown đơn giản cho Export Form
class _SimpleDropdown extends StatelessWidget {
  const _SimpleDropdown({required this.value, required this.items});
  final String value;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // Logic xử lý thay đổi (Chỉ là placeholder cho khung front-end)
          },
        ),
      ),
    );
  }
}


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
          onSelected: (s) => context.read<AppState>().updateAlertState(context.read<AppState>().alerts.indexOf(alert), s),
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

    // Đặt chiều rộng tối đa là 90% màn hình trên mobile
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

// ĐÃ SỬA: Thay đổi widget nút Duyệt/Từ chối thành một widget ApprovalButtons chung
class _ApprovalButtons extends StatelessWidget {
  const _ApprovalButtons({required this.onApprove, required this.onReject});
  final VoidCallback onApprove;
  final VoidCallback onReject;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ElevatedButton(
        onPressed: onApprove,
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16)
        ),
        child: const Text('Phê duyệt'),
      ),
      const SizedBox(width: 8),
      TextButton(
        onPressed: onReject,
        style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 8)
        ),
        child: const Text('Từ chối'),
      ),
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
              fontWeight: FontWeight.w600,
            ),
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

// Helper functions for labels
String statusLabel(SessionStatus status) {
  switch (status) {
    case SessionStatus.chuaDay:
      return 'Chưa dạy';
    case SessionStatus.daDay:
      return 'Đã dạy';
    case SessionStatus.nghi:
      return 'Nghỉ';
    case SessionStatus.dayBu:
      return 'Dạy bù';
  }
}

String alertTypeLabel(AlertType type) {
  switch (type) {
    case AlertType.conflict:
      return 'Xung đột lịch';
    case AlertType.noMakeup:
      return 'Chưa dạy bù';
    case AlertType.delay:
      return 'Chậm tiến độ';
  }
}

String alertStateLabel(AlertState state) {
  switch (state) {
    case AlertState.unresolved:
      return 'Chưa giải quyết';
    case AlertState.inProgress:
      return 'Đang xử lý';
    case AlertState.resolved:
      return 'Đã giải quyết';
  }
}



