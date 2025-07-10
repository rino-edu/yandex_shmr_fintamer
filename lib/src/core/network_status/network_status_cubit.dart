import 'package:flutter_bloc/flutter_bloc.dart';

enum NetworkStatus { online, offline }

class NetworkStatusCubit extends Cubit<NetworkStatus> {
  NetworkStatusCubit() : super(NetworkStatus.online);

  void setOnline() => emit(NetworkStatus.online);
  void setOffline() => emit(NetworkStatus.offline);
}
