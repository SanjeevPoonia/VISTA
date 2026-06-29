
class AppConstant
{
  static String appBaseURL='https://libas.checklistree.com/api/';
  static String productionBaseUrl='https://retailanalytics.qdegrees.com/api/';
  static String clientInfoUrl="https://checklistree.com/api/";
  static int apiSuccess=1;
  static int apiErrorCode=0;

  // Checklist
  static String NOTI_CHECKLIST_ASSIGNED      = 'checklist_assigned';
  static String NOTI_CHECKLIST_UPDATED       = 'checklist_updated';
  static String NOTI_CHECKLIST_COMPLETED     = 'checklist_completed';
  static String NOTI_CHECKLIST_REOPENED      = 'checklist_reopened';
  static String NOTI_CHECKLIST_ESCALATE      = 'checklist_escalate';
  static String NOTI_CHECKLIST_OVERDUE       = 'checklist_overdue';
  static String NOTI_CHECKLIST_DUE_REMINDER  = 'checklist_due_reminder';

  // Incident / Ticket
  static String NOTI_TICKET_CREATED          = 'ticket_created';
  static String NOTI_TICKET_ASSIGNED         = 'ticket_assigned';
  static String NOTI_TICKET_UPDATED          = 'ticket_updated';
  static String NOTI_TICKET_RESOLVED         = 'ticket_resolved';
  static String NOTI_TICKET_CLOSED           = 'ticket_closed';
  static String NOTI_TICKET_ESCALATED        = 'ticket_escalated';


  // Leave Management
  static String NOTI_LEAVE_APPLIED           = 'leave_applied';
  static String NOTI_LEAVE_APPROVED          = 'leave_approved';
  static String NOTI_LEAVE_REJECTED          = 'leave_rejected';
  static String NOTI_LEAVE_CANCELLED         = 'leave_cancelled';

  // Attendance
  static String NOTI_ATTENDANCE_MISSED       = 'attendance_missed';
  static String NOTI_ATTENDANCE_APPROVED     = 'attendance_approved';

  // General
  static String NOTI_REMINDER                = 'reminder';
  static String NOTI_SYSTEM_ALERT            = 'system_alert';

  static String NOTI_ARL_ALERT = 'checklist_arl_alert';
  static String NOTI_TL_ALERT = 'checklist_tl_alert';

}