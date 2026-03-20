abstract class CallEvent {}
class JoinRequested extends CallEvent { final String url; JoinRequested(this.url); }
class LeaveRequested extends CallEvent {}
