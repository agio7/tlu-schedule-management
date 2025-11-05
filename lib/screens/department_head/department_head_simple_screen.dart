import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:characters/characters.dart';
import '../../providers/hod_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/hod_models.dart';
import '../shared/login_screen.dart';
import '../../scripts/fix_user_department.dart';

// Department Head Dashboard - Full Implementation
class DepartmentHeadSimpleScreen extends StatefulWidget {
  const DepartmentHeadSimpleScreen({super.key});

  @override
  State<DepartmentHeadSimpleScreen> createState() => _DepartmentHeadSimpleScreenState();
}

class _DepartmentHeadSimpleScreenState extends State<DepartmentHeadSimpleScreen> {
  AppState? _appState;
  bool _initialized = false;
  String? _lastDepartmentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();
    final userData = authProvider.userData;
    final departmentId = userData?.departmentId;
    
    print('🔍 DepartmentHeadScreen: userData = ${userData?.fullName}, departmentId = $departmentId');
    
    // Khởi tạo lại nếu departmentId thay đổi hoặc chưa được khởi tạo
    if (departmentId != null && 
        (!_initialized || _lastDepartmentId != departmentId)) {
      print('🔍 DepartmentHeadScreen: Initializing AppState with departmentId: $departmentId');
      _lastDepartmentId = departmentId;
      _initialized = false;
      
      // Dispose AppState cũ nếu có
      _appState?.dispose();
      
      _appState = AppState();
      _appState!.initialize(departmentId)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('❌ DepartmentHeadScreen: Timeout initializing AppState');
              throw TimeoutException('Không thể tải dữ liệu từ Firebase trong 30 giây');
            },
          )
          .then((_) {
            print('✅ DepartmentHeadScreen: AppState initialized successfully');
            if (mounted) {
              setState(() {
                _initialized = true;
              });
            }
          })
          .catchError((error) {
            print('❌ DepartmentHeadScreen: Error initializing AppState: $error');
            print('❌ DepartmentHeadScreen: Stack trace: ${StackTrace.current}');
            if (mounted) {
              setState(() {
                _initialized = false;
              });
            }
          });
    } else if (userData != null && departmentId == null) {
      print('⚠️ DepartmentHeadScreen: User logged in but departmentId is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4));
    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    );

    final authProvider = context.watch<AuthProvider>();
    final userData = authProvider.userData;
    final departmentId = userData?.departmentId;
    
    // Hiển thị thông báo lỗi nếu không có departmentId
    if (userData != null && departmentId == null) {
      return Theme(
        data: theme,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: Không tìm thấy thông tin bộ môn',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tài khoản ${userData.email} không có departmentId trong Firestore.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            // Hiển thị loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text('Đang cập nhật departmentId...'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                            
                            // Gọi script để fix
                            await fixDepartmentForUser(userData.email);
                            
                            // Đóng dialog
                            if (mounted) {
                              Navigator.of(context).pop();
                              
                              // Hot restart để reload data
                              // Hoặc force rebuild
                              setState(() {
                                _initialized = false;
                                _lastDepartmentId = null;
                              });
                            }
                          } catch (e) {
                            // Đóng dialog
                            if (mounted) {
                              Navigator.of(context).pop();
                              
                              // Hiển thị lỗi
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.build),
                        label: const Text('Tự động sửa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          authProvider.signOut();
                        },
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    if (departmentId == null || _appState == null || !_initialized) {
      return Theme(
        data: theme,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Đang tải dữ liệu...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Theme(
      data: theme,
      child: ChangeNotifierProvider.value(
        value: _appState!,
        child: const _DashboardContent(),
      ),
    );
  }

  @override
  void dispose() {
    _appState?.dispose();
    super.dispose();
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
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
          Text(
            'Tổng quan bộ môn',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6750A4),
            ),
          ),
          const SizedBox(height: 16),
          
          // Nút quản lý dữ liệu mẫu
          
          // Các KPI Card (Hiển thị 4 cột trên tablet/desktop, 2 cột trên mobile)
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _KpiCard(
                icon: Icons.group,
                color: Colors.blue,
                title: 'Giảng viên',
                value: state.totalLecturers.toString(),
                style: kpiStyle,
                onTap: () => _jumpTo(context, 4), // Navigate to LecturersScreen (index 4)
              ),
              _KpiCard(
                icon: Icons.menu_book_rounded,
                color: Colors.green,
                title: 'Môn học',
                value: state.totalSubjects.toString(),
                style: kpiStyle,
                onTap: () => _jumpTo(context, 1), // Navigate to ScheduleScreen (index 1)
              ),
              _KpiCard(
                icon: Icons.event_available,
                color: Colors.indigo,
                title: 'Buổi dạy',
                value: state.totalSessions.toString(),
                style: kpiStyle,
                onTap: () => _jumpTo(context, 1), // Navigate to ScheduleScreen (index 1)
              ),
              // KPI Chờ duyệt
              _KpiCard(
                icon: Icons.fact_check,
                color: Colors.amber,
                title: 'Phê duyệt',
                value: pendingRequests.length.toString(),
                style: kpiStyle,
                onTap: () => _jumpTo(context, 2), // Navigate to ApprovalScreen (index 2)
              ),
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
  const _KpiCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.style,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final TextStyle? style;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
    // Chỉ tạo danh sách nếu có dữ liệu giảng viên
    if (state.lecturers.isEmpty) {
      return const SizedBox(height: 220, child: Center(child: Text('Không có dữ liệu tiến độ giảng dạy')));
    }

    // Tính toán tiến độ cho mỗi giảng viên
    final lecturersWithProgress = state.lecturers.map((lecturer) {
      // Tính phần trăm dựa trên hoursActual / hoursPlanned
      final progress = lecturer.hoursPlanned > 0 
          ? (lecturer.hoursActual / lecturer.hoursPlanned * 100).clamp(0, 100).toInt()
          : 0;
      
      return {
        'lecturer': lecturer,
        'progress': progress,
      };
    }).toList();

    return Column(
      children: lecturersWithProgress.map((item) {
        final lecturer = item['lecturer'] as Lecturer;
        final progress = item['progress'] as int;
        
        // Màu sắc dựa trên tiến độ
        Color progressColor;
        if (progress >= 80) {
          progressColor = Colors.green;
        } else if (progress >= 60) {
          progressColor = Colors.blue;
        } else if (progress >= 40) {
          progressColor = Colors.orange;
        } else {
          progressColor = Colors.red;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  lecturer.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progress%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
    
    // Check xem có lecturer filter từ AppState không (khi chuyển từ màn hình giảng viên)
    if (state.selectedLecturerForSchedule != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && state.selectedLecturerForSchedule != null) {
          setState(() {
            lecturer = state.selectedLecturerForSchedule!;
          });
          // Clear filter sau khi đã sử dụng
          state.clearLecturerForSchedule();
        }
      });
    }

    // Tạo danh sách các giá trị duy nhất cho Dropdown
    final allLecturers = ['Tất cả', ...state.lecturers.map((e) => e.name)];
    // Lấy danh sách môn từ chính các lịch đang có để loại các môn không có lịch.
    // Đồng thời gộp các tên trùng nhau theo phân biệt hoa/thường (vd: "Lập trình web" và "Lập trình Web").
    final subjectNameByLower = <String, String>{};
    for (final s in state.schedules) {
      final raw = (s.subject).trim();
      if (raw.isEmpty) continue;
      final key = raw.toLowerCase();
      subjectNameByLower.putIfAbsent(key, () => raw);
    }
    final allSubjects = ['Tất cả', ...subjectNameByLower.values];
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
        // Bộ lọc - Sắp xếp 2 cột (Giảng viên và Môn học ở trên, Trạng thái ở dưới)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng 1: Giảng viên và Môn học
              Row(
                children: [
                  Expanded(
                    child: _Dropdown(
                      label: 'Giảng viên',
                      value: lecturer,
                      values: allLecturers,
                      onChanged: (v) => setState(() => lecturer = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Dropdown(
                      label: 'Môn học',
                      value: subject,
                      values: allSubjects,
                      onChanged: (v) => setState(() => subject = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Hàng 2: Trạng thái
              _Dropdown(
                label: 'Trạng thái',
                value: status,
                values: allStatuses,
                onChanged: (v) => setState(() => status = v!),
              ),
            ],
          ),
        ),
        // Danh sách lịch trình với format mới
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề "Danh sách môn học"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'Danh sách môn học',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6750A4),
                  ),
                ),
              ),
              // Danh sách lịch
              Expanded(
                child: filters.isEmpty
                    ? const Center(child: Text('Không có lịch giảng dạy nào'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filters.length,
                        itemBuilder: (context, i) {
                          final s = filters[i];
                          // Tính toán thời gian kết thúc (15 tuần từ ngày bắt đầu)
                          final endDate = s.date.add(const Duration(days: 15 * 7));
                          // Parse session để lấy thời gian (format: "Sáng (8:00-11:00)" hoặc "7:00 - 9:50")
                          String timeString = s.session;
                          // Nếu session có format "Sáng (8:00-11:00)", lấy phần trong ngoặc và đổi dấu "-" thành " - "
                          if (s.session.contains('(') && s.session.contains(')')) {
                            final match = RegExp(r'\(([^)]+)\)').firstMatch(s.session);
                            if (match != null) {
                              timeString = match.group(1)?.replaceAll('-', ' - ') ?? s.session;
                            }
                          }
                          
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: s.status == SessionStatus.daDay
                                  ? () {
                                      // Chuyển đến màn hình thống kê điểm danh với filter theo lớp và môn học
                                      context.read<AppState>().setAttendanceStatsFilter(s.className, s.subject);
                                      context.read<AppState>().setTab(3);
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title: Tên môn học (bold) và Status chip
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            s.subject,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF6750A4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _StatusChip(status: s.status),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Class ID: Lớp
                                    Text(
                                      'Lớp: ${s.className}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Giảng viên
                                    _ScheduleInfoRow(
                                      icon: Icons.person,
                                      label: s.lecturer,
                                    ),
                                    const SizedBox(height: 8),
                                    // Phòng học
                                    _ScheduleInfoRow(
                                      icon: Icons.location_on,
                                      label: s.room,
                                    ),
                                    const SizedBox(height: 8),
                                    // Lịch học
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${_formatDateVietnamese(s.date)} - ${_formatDateVietnamese(endDate)}',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              Text(
                                                '(15 tuần)',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Thời gian và Điểm danh
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            timeString,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ),
                                        if (s.attendance != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Điểm danh: ${s.attendance}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
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
          child: Consumer<AppState>(
            builder: (context, state, _) {
              final pendingCount = [
                ...state.leaveRequests.where((r) => r.status == RequestStatus.pending),
                ...state.makeups.where((m) => m.status == RequestStatus.pending),
              ].length;
              
              return TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: [
                  Tab(text: 'Chờ duyệt (${pendingCount})'),
                  const Tab(text: 'Đã duyệt'),
                  const Tab(text: 'Từ chối'),
                ],
              );
            },
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

            // Hiển thị thông tin phê duyệt/từ chối nếu đã xử lý
            if (!isPending) ...[
              const SizedBox(height: 12),
              if (request.status == RequestStatus.approved && request.approvedBy != null)
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đã duyệt bởi: ${request.approvedBy}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                )
              else if (request.status == RequestStatus.rejected && request.rejectedBy != null) ...[
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Từ chối bởi: ${request.rejectedBy}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                if (request.rejectionReason != null && request.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Lý do từ chối: ${request.rejectionReason}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ],
            
            // Nút hành động (chỉ hiện khi Pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(children: [
                TextButton(onPressed: () {}, child: const Text('Xem minh chứng')),
                const Spacer(),
                  _ApprovalButtons(
                    onApprove: () => context.read<AppState>().approveLeave(context.read<AppState>().leaveRequests.indexOf(request)),
                    onReject: () => _showRejectDialog(context, request, isMakeup: false),
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
    // Parse session để lấy thời gian
    String timeString = makeup.makeupSession;
    if (makeup.makeupSession.contains('(') && makeup.makeupSession.contains(')')) {
      final match = RegExp(r'\(([^)]+)\)').firstMatch(makeup.makeupSession);
      if (match != null) {
        timeString = match.group(1)?.replaceAll('-', ' - ') ?? makeup.makeupSession;
      }
    }
    
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
                Text(dmy(makeup.submittedAt), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            // Tên giảng viên (bold)
            Text(makeup.lecturer, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            // Thông tin môn học, lớp, phòng
            Text(
              '${makeup.subject} • Lớp ${makeup.className} • Phòng: ${makeup.makeupRoom}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            // Ngày và giờ dạy bù
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(dmy(makeup.makeupDate)),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(timeString),
              ],
            ),
            const SizedBox(height: 8),
            // Lý do
            Text('Lý do: Bù buổi nghỉ ngày ${dmy(makeup.originalDate)}'),
            
            // Hiển thị thông tin phê duyệt/từ chối nếu đã xử lý
            if (!isPending) ...[
              const SizedBox(height: 12),
              if (makeup.status == RequestStatus.approved && makeup.approvedBy != null)
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đã duyệt bởi: ${makeup.approvedBy}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                )
              else if (makeup.status == RequestStatus.rejected && makeup.rejectedBy != null) ...[
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Từ chối bởi: ${makeup.rejectedBy}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                if (makeup.rejectionReason != null && makeup.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Lý do từ chối: ${makeup.rejectionReason}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ],
            
            // Nút hành động (chỉ hiện khi Pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ApprovalButtons(
                    onApprove: () => context.read<AppState>().approveMakeup(context.read<AppState>().makeups.indexOf(makeup)),
                    onReject: () => _showRejectDialog(context, makeup, isMakeup: true),
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
  String selectedCardType = 'Thống kê giờ giảng'; // Default selected card

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check xem có flag để chuyển đến màn hình thống kê điểm danh không
    final appState = context.watch<AppState>();
    if (appState.shouldShowAttendanceStats && selectedCardType != 'Thống kê điểm danh') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedCardType = 'Thống kê điểm danh';
          });
        }
      });
    }
  }

  String _getAppBarTitle() {
    switch (selectedCardType) {
      case 'Thống kê điểm danh':
        return 'Thống kê điểm danh';
      case 'Thống kê nghỉ, dạy bù':
        return 'Thống kê nghỉ, dạy bù';
      case 'Tiến độ giảng dạy':
        return 'Tiến độ giảng dạy';
      default:
        return 'Thống kê giờ giảng';
    }
  }

  Widget _getContentPreview(AppState state) {
    switch (selectedCardType) {
      case 'Thống kê điểm danh':
        return _AttendanceStatisticsPreview(state: state);
      case 'Thống kê nghỉ, dạy bù':
        return _LeaveMakeupStatisticsPreview(state: state);
      case 'Tiến độ giảng dạy':
        return _TeachingProgressPreview(state: state);
      default:
        return _StatisticsPreview(lecturers: state.lecturers);
    }
  }

  String _getReportTypeForExport() {
    switch (selectedCardType) {
      case 'Thống kê điểm danh':
        return 'Báo cáo điểm danh';
      case 'Thống kê nghỉ, dạy bù':
        return 'Báo cáo nghỉ dạy, dạy bù';
      case 'Tiến độ giảng dạy':
        return 'Báo cáo tiến độ';
      default:
        return 'Báo cáo giờ giảng';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: HoDAppBar(title: _getAppBarTitle()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Báo cáo thống kê (4 KPI cards)
            Text('Báo cáo thống kê', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _ReportCard(
                  icon: Icons.bar_chart,
                  color: Colors.indigo,
                  title: 'Thống kê giờ giảng',
                  subtitle: 'Tổng hợp giờ giảng theo giảng viên',
                  isSelected: selectedCardType == 'Thống kê giờ giảng',
                  onTap: () => setState(() => selectedCardType = 'Thống kê giờ giảng'),
                ),
                _ReportCard(
                  icon: Icons.people_alt_outlined,
                  color: Colors.blue,
                  title: 'Thống kê điểm danh',
                  subtitle: 'Tỷ lệ điểm danh theo lớp, môn học',
                  isSelected: selectedCardType == 'Thống kê điểm danh',
                  onTap: () => setState(() => selectedCardType = 'Thống kê điểm danh'),
                ),
                _ReportCard(
                  icon: Icons.access_time_filled,
                  color: Colors.amber,
                  title: 'Thống kê nghỉ, dạy bù',
                  subtitle: 'Tổng hợp tình hình nghỉ và bù giờ',
                  isSelected: selectedCardType == 'Thống kê nghỉ, dạy bù',
                  onTap: () => setState(() => selectedCardType = 'Thống kê nghỉ, dạy bù'),
                ),
                _ReportCard(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  title: 'Tiến độ giảng dạy',
                  subtitle: 'Tỷ lệ hoàn thành theo kế hoạch',
                  isSelected: selectedCardType == 'Tiến độ giảng dạy',
                  onTap: () => setState(() => selectedCardType = 'Tiến độ giảng dạy'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Xem trước báo cáo (Dynamic based on selection)
            _Section(
              title: 'Xem trước báo cáo',
              child: _getContentPreview(state),
            ),
            const SizedBox(height: 20),

            // Xuất báo cáo (Form)
            _Section(
              title: 'Xuất báo cáo',
              child: _ExportReportForm(selectedReportType: _getReportTypeForExport()),
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
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
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

// Widget Thống kê điểm danh
class _AttendanceStatisticsPreview extends StatefulWidget {
  const _AttendanceStatisticsPreview({required this.state});
  final AppState state;

  @override
  State<_AttendanceStatisticsPreview> createState() => _AttendanceStatisticsPreviewState();
}

class _AttendanceStatisticsPreviewState extends State<_AttendanceStatisticsPreview> {
  String? _selectedClass;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    // Khởi tạo selectedClass với lớp đầu tiên
    final allClasses = widget.state.schedules
        .map((s) => s.className)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    if (allClasses.isNotEmpty) {
      _selectedClass = allClasses[0];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check xem có filter từ AppState không (khi chuyển từ màn hình lịch dạy)
    final appState = context.watch<AppState>();
    if (appState.shouldShowAttendanceStats && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && appState.shouldShowAttendanceStats) {
          setState(() {
            _selectedClass = appState.selectedClassForAttendance;
            _selectedSubject = appState.selectedSubjectForAttendance;
          });
          // Clear filter sau khi đã sử dụng
          appState.clearAttendanceStatsFilter();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy tất cả các lớp từ schedules
    final allClasses = widget.state.schedules
        .map((s) => s.className)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    // Lấy các môn học của lớp được chọn
    List<String> availableSubjects = ['Tất cả'];
    if (_selectedClass != null && _selectedClass!.isNotEmpty) {
      final subjects = widget.state.schedules
          .where((s) => s.className == _selectedClass)
          .map((s) => s.subject)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      availableSubjects = ['Tất cả', ...subjects];
    }

    // Nếu chưa có lớp được chọn, sử dụng lớp đầu tiên
    if (_selectedClass == null && allClasses.isNotEmpty) {
      _selectedClass = allClasses[0];
    }

    // Nếu chưa có môn học được chọn hoặc môn học đã chọn không còn trong danh sách (khi đổi lớp), chọn "Tất cả"
    if (_selectedSubject == null || !availableSubjects.contains(_selectedSubject)) {
      _selectedSubject = 'Tất cả';
    }

    // Lọc schedules theo lớp được chọn
    final classSchedules = widget.state.schedules
        .where((s) => s.className == _selectedClass)
        .where((s) => s.status == SessionStatus.daDay)
        .toList();

    // Lọc thêm theo môn học nếu có (và không phải "Tất cả")
    final filteredSchedules = _selectedSubject != null && 
                              _selectedSubject!.isNotEmpty && 
                              _selectedSubject != 'Tất cả'
        ? classSchedules.where((s) => s.subject == _selectedSubject).toList()
        : classSchedules;

    if (filteredSchedules.isEmpty && allClasses.isEmpty) {
      return const Center(child: Text('Không có dữ liệu điểm danh.'));
    }

    // Tính tổng quan điểm danh (giả lập dựa vào số buổi)
    final totalSessions = filteredSchedules.length;
    final presentRate = totalSessions > 0 ? 89.0 : 0.0;
    final excusedRate = totalSessions > 0 ? 8.0 : 0.0;
    final unexcusedRate = totalSessions > 0 ? 3.0 : 0.0;

    // Lấy danh sách các buổi học đã dạy để hiển thị (sắp xếp theo ngày)
    final sortedSchedules = List<ScheduleItem>.from(filteredSchedules)
      ..sort((a, b) => b.date.compareTo(a.date)); // Sắp xếp mới nhất trước

    final sessionData = sortedSchedules.take(5).map((schedule) {
      // Giả lập phần trăm điểm danh cho mỗi buổi (dựa vào ngày)
      final attendancePercent = 85.0 + (schedule.date.day % 15);
      return {'date': schedule.date, 'percent': attendancePercent};
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown Lớp và Môn học
        Row(
          children: [
            Expanded(
              child: _SelectableDropdown(
                label: 'Lớp',
                value: _selectedClass ?? 'Chọn lớp',
                items: allClasses.isEmpty ? ['CNTT01-K15'] : allClasses,
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                    _selectedSubject = null; // Reset môn học khi đổi lớp
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SelectableDropdown(
                label: 'Môn học',
                value: _selectedSubject ?? 'Tất cả',
                items: availableSubjects,
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tổng quan điểm danh
        Text('Tổng quan điểm danh', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _AttendanceCircle(
              icon: Icons.check_circle,
              color: Colors.green,
              percentage: presentRate,
              label: 'Tỷ lệ có mặt',
            ),
            _AttendanceCircle(
              icon: Icons.person_off,
              color: Colors.red,
              percentage: excusedRate,
              label: 'Vắng có phép',
            ),
            _AttendanceCircle(
              icon: Icons.person_remove,
              color: Colors.amber,
              percentage: unexcusedRate,
              label: 'Vắng không phép',
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Progress bar tổng quan
        Row(
          children: [
            Expanded(
              flex: presentRate.toInt(),
              child: Container(height: 8, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4))),
            ),
            Expanded(
              flex: excusedRate.toInt(),
              child: Container(height: 8, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4))),
            ),
            Expanded(
              flex: unexcusedRate.toInt(),
              child: Container(height: 8, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4))),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Điểm danh theo buổi học
        if (sessionData.isNotEmpty) ...[
          Text('Điểm danh theo buổi học', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...sessionData.map((data) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dmy(data['date'] as DateTime), style: Theme.of(context).textTheme.bodyMedium),
                      Text('${(data['percent'] as double).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (data['percent'] as double) / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.green,
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                ],
              ),
            );
          }).toList(),
        ] else ...[
          const SizedBox(height: 12),
          Text('Không có buổi học nào cho lớp này.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ],
      ],
    );
  }
}

// Widget Dropdown có thể chọn được
class _SelectableDropdown extends StatelessWidget {
  const _SelectableDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

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
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Widget vòng tròn điểm danh
class _AttendanceCircle extends StatelessWidget {
  const _AttendanceCircle({
    required this.icon,
    required this.color,
    required this.percentage,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final double percentage;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                color: color,
                backgroundColor: color.withOpacity(0.1),
              ),
            ),
            Icon(icon, color: color, size: 28),
          ],
        ),
        const SizedBox(height: 8),
        Text('${percentage.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// Widget Thống kê nghỉ, dạy bù
class _LeaveMakeupStatisticsPreview extends StatelessWidget {
  const _LeaveMakeupStatisticsPreview({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    // Tính tỷ lệ nghỉ dạy theo giảng viên
    final lecturers = state.lecturers;
    final leaveRequests = state.leaveRequests;
    final makeupRequests = state.makeups;

    // Tính số lần nghỉ và dạy bù cho mỗi giảng viên
    final lecturerStats = <String, Map<String, int>>{};
    
    for (final lecturer in lecturers) {
      final leaveCount = leaveRequests.where((lr) => lr.lecturer == lecturer.name).length;
      final makeupCount = makeupRequests.where((mr) => mr.lecturer == lecturer.name).length;
      final totalSessions = state.schedules.where((s) => s.lecturer == lecturer.name && s.status == SessionStatus.daDay).length;
      
      final totalLeaveRequests = leaveRequests.where((lr) => lr.lecturer == lecturer.name).length;
      final totalSessionsForLecturer = totalSessions + totalLeaveRequests; // Tổng buổi (đã dạy + nghỉ)
      
      lecturerStats[lecturer.name] = {
        'leave': leaveCount,
        'makeup': makeupCount,
        'total': totalSessionsForLecturer > 0 ? totalSessionsForLecturer : 1, // Tránh chia 0
      };
    }

    // Tính phần trăm nghỉ và dạy bù
    final leaveRateData = lecturerStats.entries.map((entry) {
      final leaveRate = (entry.value['leave']! / entry.value['total']!) * 100;
      return {'name': entry.key, 'rate': leaveRate.clamp(0.0, 100.0)};
    }).toList();

    final makeupRateData = lecturerStats.entries.map((entry) {
      final makeupRate = entry.value['total']! > 0 
          ? (entry.value['makeup']! / entry.value['total']!) * 100 
          : 0.0;
      // Giả lập phần trăm dạy bù cao hơn vì đã được phê duyệt
      final approvedMakeups = makeupRequests.where((mr) => mr.lecturer == entry.key && mr.status == RequestStatus.approved).length;
      return {'name': entry.key, 'rate': (approvedMakeups / (entry.value['total']! > 0 ? entry.value['total']! : 1)) * 100 + 85.0};
    }).toList();

    // Sắp xếp và lấy top 4
    leaveRateData.sort((a, b) => (b['rate'] as double).compareTo(a['rate'] as double));
    makeupRateData.sort((a, b) => (b['rate'] as double).compareTo(a['rate'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tỷ lệ nghỉ dạy
        Text('Tỷ lệ nghỉ dạy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...leaveRateData.take(4).map((data) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['name'] as String, style: Theme.of(context).textTheme.bodyMedium),
                    Text('${(data['rate'] as double).toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (data['rate'] as double) / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.amber,
                  backgroundColor: Colors.amber.withOpacity(0.1),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 24),

        // Tỷ lệ dạy bù
        Text('Tỷ lệ dạy bù', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...makeupRateData.take(4).map((data) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['name'] as String, style: Theme.of(context).textTheme.bodyMedium),
                    Text('${(data['rate'] as double).clamp(0.0, 100.0).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (data['rate'] as double).clamp(0.0, 100.0) / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Widget Tiến độ giảng dạy
class _TeachingProgressPreview extends StatelessWidget {
  const _TeachingProgressPreview({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final lecturers = state.lecturers;

    if (lecturers.isEmpty) {
      return const Center(child: Text('Không có dữ liệu giảng viên.'));
    }

    // Tính tiến độ giảng dạy dựa trên giờ giảng
    final progressData = lecturers.map((l) {
      final planned = l.hoursPlanned > 0 ? l.hoursPlanned : 30;
      final actual = l.hoursActual;
      final progress = (actual / planned * 100).clamp(0.0, 100.0);
      return {'name': l.name, 'progress': progress, 'actual': actual, 'planned': planned};
    }).toList();

    // Sắp xếp theo tiến độ
    progressData.sort((a, b) => (b['progress'] as double).compareTo(a['progress'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tiến độ giảng dạy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...progressData.take(4).map((data) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['name'] as String, style: Theme.of(context).textTheme.bodyMedium),
                    Text('${(data['progress'] as double).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (data['progress'] as double) / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
                const SizedBox(height: 2),
                Text('${data['actual']}/${data['planned']} giờ', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
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
  const _ExportReportForm({required this.selectedReportType});
  final String selectedReportType;

  @override
  Widget build(BuildContext context) {
    // Giá trị mặc định cho Dropdown
    const List<String> reportTypes = ['Báo cáo giờ giảng', 'Báo cáo điểm danh', 'Báo cáo nghỉ dạy, dạy bù', 'Báo cáo tiến độ'];
    const List<String> timePeriods = ['Học kỳ hiện tại', 'Học kỳ trước', 'Năm học hiện tại', 'Tùy chọn'];
    const List<String> formats = ['Excel (.xlsx)', 'PDF (.pdf)'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loại báo cáo
        const Text('Loại báo cáo', style: TextStyle(fontWeight: FontWeight.w500)),
        _SimpleDropdown(value: selectedReportType, items: reportTypes),
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

    final allSubjects = ['Tất cả', ...({
      if (state.subjects.isNotEmpty) ...state.subjects else ...state.lecturers.map((e) => e.subject)
    }.toSet())];

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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.email, size: 16), const SizedBox(width: 6), Expanded(child: Text(l.email)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.phone, size: 16), const SizedBox(width: 6), Text(l.phone),
            ]),
            const SizedBox(height: 12),
            Text('Môn giảng dạy: ${l.subject}'),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: percent, minHeight: 8, borderRadius: BorderRadius.circular(8), color: Colors.blue),
            const SizedBox(height: 6),
            Text('Giờ giảng: ${l.hoursActual}/${l.hoursPlanned} giờ ($percentInt%)'),
            const SizedBox(height: 8),
            Row(children: [
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Chuyển sang màn hình lịch dạy với filter theo giảng viên
                  context.read<AppState>().setLecturerForSchedule(l.name);
                  context.read<AppState>().setTab(1);
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Xem lịch'),
              ),
            ]),
          ],
        ),
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

// Widget để hiển thị thông tin lịch với icon
class _ScheduleInfoRow extends StatelessWidget {
  const _ScheduleInfoRow({
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
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
          Expanded(
            child: Text(
            'Xin chào, Trưởng Bộ môn',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.logout),
          color: Colors.white,
          offset: const Offset(0, 40), // Hiển thị menu ngay dưới icon
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onSelected: (value) async {
            if (value == 'logout') {
              // Thực hiện đăng xuất
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              // Chuyển về màn hình đăng nhập
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'logout',
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('Đăng xuất', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ],
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
      // Nút back, chuyển về trang Tổng quan (index 0)
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.read<AppState>().setTab(0),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.logout),
          color: Colors.white,
          offset: const Offset(0, 40), // Hiển thị menu ngay dưới icon
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onSelected: (value) async {
            if (value == 'logout') {
              // Thực hiện đăng xuất
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              // Chuyển về màn hình đăng nhập
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'logout',
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('Đăng xuất', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ],
      elevation: 1,
    );
  }
}

void _jumpTo(BuildContext context, int index) {
  context.read<AppState>().setTab(index);
}

// Dialog để nhập lý do từ chối
void _showRejectDialog(BuildContext context, dynamic request, {required bool isMakeup}) {
  // Lưu reference đến AppState trước khi mở dialog
  final appState = Provider.of<AppState>(context, listen: false);
  
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return _RejectDialogWidget(
        appState: appState,
        request: request,
        isMakeup: isMakeup,
      );
    },
  );
}

// StatefulWidget để quản lý TextEditingController đúng cách
class _RejectDialogWidget extends StatefulWidget {
  const _RejectDialogWidget({
    required this.appState,
    required this.request,
    required this.isMakeup,
  });
  
  final AppState appState;
  final dynamic request;
  final bool isMakeup;

  @override
  State<_RejectDialogWidget> createState() => _RejectDialogWidgetState();
}

class _RejectDialogWidgetState extends State<_RejectDialogWidget> {
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _handleReject() {
    if (_reasonController.text.trim().isNotEmpty) {
      final rejectionReason = _reasonController.text.trim();
      Navigator.of(context).pop();
      
      // Sử dụng reference đã lưu
      if (widget.isMakeup) {
        final index = widget.appState.makeups.indexOf(widget.request as MakeupRegistration);
        if (index >= 0) {
          widget.appState.rejectMakeup(index, rejectionReason);
        }
      } else {
        final index = widget.appState.leaveRequests.indexOf(widget.request as LeaveRequest);
        if (index >= 0) {
          widget.appState.rejectLeave(index, rejectionReason);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Từ chối yêu cầu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối:'),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do từ chối...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _handleReject,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Từ chối'),
        ),
      ],
    );
  }
}

// Helper function để format ngày theo kiểu Việt Nam (Thứ 2, 04/09/2023)
String _formatDateVietnamese(DateTime date) {
  // DateTime.weekday: 1 = Monday, 7 = Sunday
  // Chúng ta cần map: 1->Thứ 2, 2->Thứ 3, ..., 6->Thứ 7, 7->Chủ nhật
  final weekdays = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
  final weekday = weekdays[date.weekday];
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$weekday, $day/$month/$year';
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


