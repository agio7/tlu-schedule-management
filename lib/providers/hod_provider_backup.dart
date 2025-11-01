import 'package:flutter/material.dart';
import '../models/hod_models.dart';

class AppState extends ChangeNotifier {
  int currentTab = 0;

  // Sample data - In production, this would come from Firebase
  List<Lecturer> _lecturers = [];
  List<LeaveRequest> _leaveRequests = [];
  List<MakeupRegistration> _makeups = [];
  List<ScheduleItem> _schedules = [];
  List<AlertItem> _alerts = [];

  List<Lecturer> get lecturers => _lecturers;
  List<LeaveRequest> get leaveRequests => _leaveRequests;
  List<MakeupRegistration> get makeups => _makeups;
  List<ScheduleItem> get schedules => _schedules;
  List<AlertItem> get alerts => _alerts;

  // KPI values
  int get totalLecturers => _lecturers.length;
  int get totalSubjects => _schedules.map((s) => s.subject).toSet().length;
  int get totalSessions => _schedules.length;

  void setTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  // Approval methods
  void approveLeave(int index) {
    if (index >= 0 && index < _leaveRequests.length) {
      _leaveRequests[index] = LeaveRequest(
        lecturer: _leaveRequests[index].lecturer,
        subject: _leaveRequests[index].subject,
        className: _leaveRequests[index].className,
        room: _leaveRequests[index].room,
        date: _leaveRequests[index].date,
        session: _leaveRequests[index].session,
        reason: _leaveRequests[index].reason,
        status: RequestStatus.approved,
        submittedAt: _leaveRequests[index].submittedAt,
      );
      notifyListeners();
    }
  }

  void rejectLeave(int index) {
    if (index >= 0 && index < _leaveRequests.length) {
      _leaveRequests[index] = LeaveRequest(
        lecturer: _leaveRequests[index].lecturer,
        subject: _leaveRequests[index].subject,
        className: _leaveRequests[index].className,
        room: _leaveRequests[index].room,
        date: _leaveRequests[index].date,
        session: _leaveRequests[index].session,
        reason: _leaveRequests[index].reason,
        status: RequestStatus.rejected,
        submittedAt: _leaveRequests[index].submittedAt,
      );
      notifyListeners();
    }
  }

  void approveMakeup(int index) {
    if (index >= 0 && index < _makeups.length) {
      _makeups[index] = MakeupRegistration(
        lecturer: _makeups[index].lecturer,
        originalDate: _makeups[index].originalDate,
        originalSession: _makeups[index].originalSession,
        makeupDate: _makeups[index].makeupDate,
        makeupSession: _makeups[index].makeupSession,
        makeupRoom: _makeups[index].makeupRoom,
        status: RequestStatus.approved,
      );
      notifyListeners();
    }
  }

  void rejectMakeup(int index) {
    if (index >= 0 && index < _makeups.length) {
      _makeups[index] = MakeupRegistration(
        lecturer: _makeups[index].lecturer,
        originalDate: _makeups[index].originalDate,
        originalSession: _makeups[index].originalSession,
        makeupDate: _makeups[index].makeupDate,
        makeupSession: _makeups[index].makeupSession,
        makeupRoom: _makeups[index].makeupRoom,
        status: RequestStatus.rejected,
      );
      notifyListeners();
    }
  }

  void updateAlertState(int index, AlertState state) {
    if (index >= 0 && index < _alerts.length) {
      _alerts[index] = AlertItem(
        type: _alerts[index].type,
        detail: _alerts[index].detail,
        date: _alerts[index].date,
        priority: _alerts[index].priority,
        state: state,
      );
      notifyListeners();
    }
  }

  // Load sample data
  void loadSampleData() {
    _lecturers = [
      Lecturer(
        name: 'Nguyễn Văn A',
        email: 'nguyenvana@tlu.edu.vn',
        phone: '0123456789',
        title: 'Tiến sĩ',
        subject: 'Lập trình Python',
        hoursPlanned: 30,
        hoursActual: 25,
      ),
      Lecturer(
        name: 'Trần Thị B',
        email: 'tranthib@tlu.edu.vn',
        phone: '0987654321',
        title: 'Thạc sĩ',
        subject: 'Cấu trúc dữ liệu',
        hoursPlanned: 45,
        hoursActual: 40,
      ),
      Lecturer(
        name: 'Lê Văn C',
        email: 'levanc@tlu.edu.vn',
        phone: '0111222333',
        title: 'Tiến sĩ',
        subject: 'Hệ điều hành',
        hoursPlanned: 35,
        hoursActual: 30,
      ),
    ];

    _leaveRequests = [
      LeaveRequest(
        lecturer: 'Nguyễn Văn A',
        subject: 'Lập trình Python',
        className: 'CNTTER01',
        room: 'P301',
        date: DateTime.now().add(const Duration(days: 3)),
        session: 'Sáng (8:00-11:00)',
        reason: 'Bị ốm',
        status: RequestStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _makeups = [
      MakeupRegistration(
        lecturer: 'Nguyễn Văn A',
        originalDate: DateTime.now().subtract(const Duration(days: 2)),
        originalSession: 'Sáng',
        makeupDate: DateTime.now().add(const Duration(days: 5)),
        makeupSession: 'Chiều',
        makeupRoom: 'P302',
        status: RequestStatus.pending,
      ),
    ];

    _schedules = [
      ScheduleItem(
        lecturer: 'Nguyễn Văn A',
        subject: 'Lập trình Python',
        className: 'CNTTER01',
        date: DateTime.now().subtract(const Duration(days: 5)),
        session: 'Sáng (8:00-11:00)',
        room: 'P301',
        status: SessionStatus.daDay,
        attendance: '28/30',
      ),
      ScheduleItem(
        lecturer: 'Trần Thị B',
        subject: 'Cấu trúc dữ liệu',
        className: 'CNTTER02',
        date: DateTime.now().subtract(const Duration(days: 3)),
        session: 'Chiều (13:00-16:00)',
        room: 'P302',
        status: SessionStatus.daDay,
        attendance: '30/30',
      ),
      ScheduleItem(
        lecturer: 'Nguyễn Văn A',
        subject: 'Lập trình Python',
        className: 'CNTTER01',
        date: DateTime.now().add(const Duration(days: 2)),
        session: 'Sáng (8:00-11:00)',
        room: 'P301',
        status: SessionStatus.chuaDay,
      ),
    ];

    _alerts = [
      AlertItem(
        type: AlertType.conflict,
        detail: 'Xung đột lịch: Nguyễn Văn A bị trùng thời gian',
        date: DateTime.now(),
        priority: 'Cao',
        state: AlertState.unresolved,
      ),
      AlertItem(
        type: AlertType.noMakeup,
        detail: 'Chưa có lịch dạy bù cho buổi nghỉ ngày 15/01',
        date: DateTime.now().subtract(const Duration(days: 1)),
        priority: 'Trung bình',
        state: AlertState.unresolved,
      ),
    ];

    notifyListeners();
  }

  // Constructor
  AppState() {
    loadSampleData();
  }
}

