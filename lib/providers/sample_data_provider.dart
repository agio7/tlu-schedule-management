import '../models/hod_models.dart';

/// Sample data provider for testing without Firebase
class SampleDataProvider {
  /// Load sample lecturers
  static List<Lecturer> getSampleLecturers() {
    return [
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
      Lecturer(
        name: 'Phạm Thị D',
        email: 'phamthid@tlu.edu.vn',
        phone: '0999888777',
        title: 'Thạc sĩ',
        subject: 'Mạng máy tính',
        hoursPlanned: 40,
        hoursActual: 38,
      ),
    ];
  }

  /// Load sample leave requests
  static List<LeaveRequest> getSampleLeaveRequests() {
    return [
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
      LeaveRequest(
        lecturer: 'Trần Thị B',
        subject: 'Cấu trúc dữ liệu',
        className: 'CNTTER02',
        room: 'P302',
        date: DateTime.now().add(const Duration(days: 5)),
        session: 'Chiều (13:00-16:00)',
        reason: 'Có việc gia đình',
        status: RequestStatus.approved,
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        approvedBy: 'Trưởng Bộ môn',
        approvedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LeaveRequest(
        lecturer: 'Lê Văn C',
        subject: 'Hệ điều hành',
        className: 'CNTTER03',
        room: 'P303',
        date: DateTime.now().add(const Duration(days: 7)),
        session: 'Sáng (8:00-11:00)',
        reason: 'Đi họp',
        status: RequestStatus.rejected,
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
        rejectedBy: 'Trưởng Bộ môn',
        rejectionReason: 'Không có lý do chính đáng',
      ),
    ];
  }

  /// Load sample makeup requests
  static List<MakeupRegistration> getSampleMakeupRequests() {
    return [
      MakeupRegistration(
        lecturer: 'Nguyễn Văn A',
        subject: 'Lập trình Python',
        className: 'CNTTER01',
        originalDate: DateTime.now().subtract(const Duration(days: 2)),
        originalSession: 'Sáng',
        makeupDate: DateTime.now().add(const Duration(days: 5)),
        makeupSession: 'Chiều',
        makeupRoom: 'P302',
        status: RequestStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MakeupRegistration(
        lecturer: 'Trần Thị B',
        subject: 'Cấu trúc dữ liệu',
        className: 'CNTTER02',
        originalDate: DateTime.now().subtract(const Duration(days: 5)),
        originalSession: 'Chiều',
        makeupDate: DateTime.now().add(const Duration(days: 3)),
        makeupSession: 'Sáng',
        makeupRoom: 'P301',
        status: RequestStatus.approved,
        approvedBy: 'Trưởng Bộ môn',
        approvedDate: DateTime.now().subtract(const Duration(days: 1)),
        submittedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      MakeupRegistration(
        lecturer: 'Lê Văn C',
        subject: 'Hệ điều hành',
        className: 'CNTTER03',
        originalDate: DateTime.now().subtract(const Duration(days: 4)),
        originalSession: 'Sáng',
        makeupDate: DateTime.now().add(const Duration(days: 6)),
        makeupSession: 'Chiều',
        makeupRoom: 'P303',
        status: RequestStatus.rejected,
        rejectedBy: 'Trưởng Bộ môn',
        rejectionReason: 'Thời gian không phù hợp',
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  /// Load sample schedules
  static List<ScheduleItem> getSampleSchedules() {
    return [
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
      ScheduleItem(
        lecturer: 'Lê Văn C',
        subject: 'Hệ điều hành',
        className: 'CNTTER03',
        date: DateTime.now().subtract(const Duration(days: 1)),
        session: 'Chiều (13:00-16:00)',
        room: 'P303',
        status: SessionStatus.daDay,
        attendance: '29/30',
      ),
      ScheduleItem(
        lecturer: 'Phạm Thị D',
        subject: 'Mạng máy tính',
        className: 'CNTTER04',
        date: DateTime.now().add(const Duration(days: 4)),
        session: 'Sáng (8:00-11:00)',
        room: 'P304',
        status: SessionStatus.chuaDay,
      ),
      ScheduleItem(
        lecturer: 'Trần Thị B',
        subject: 'Cấu trúc dữ liệu',
        className: 'CNTTER02',
        date: DateTime.now().add(const Duration(days: 6)),
        session: 'Chiều (13:00-16:00)',
        room: 'P302',
        status: SessionStatus.chuaDay,
      ),
    ];
  }

  /// Load sample alerts
  static List<AlertItem> getSampleAlerts() {
    return [
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
      AlertItem(
        type: AlertType.delay,
        detail: 'Lê Văn C chậm tiến độ giảng dạy 5 buổi',
        date: DateTime.now().subtract(const Duration(days: 2)),
        priority: 'Thấp',
        state: AlertState.inProgress,
      ),
    ];
  }

  /// Load all sample data
  static Map<String, dynamic> getAllSampleData() {
    return {
      'lecturers': getSampleLecturers(),
      'leaveRequests': getSampleLeaveRequests(),
      'makeups': getSampleMakeupRequests(),
      'schedules': getSampleSchedules(),
      'alerts': getSampleAlerts(),
    };
  }
}

