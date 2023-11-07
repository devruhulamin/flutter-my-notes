import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitilize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggenOut());
        } else if (!user.isEmailverified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(authUser: user));
        }
      },
    );

    on<AuthEventLogin>(
      (event, emit) async {
        emit(const AuthStateLoading());
        try {
          final email = event.email;
          final password = event.password;
          final user = await provider.login(email: email, password: password);
          emit(AuthStateLoggedIn(authUser: user));
        } on Exception catch (e) {
          emit(AuthStateLoginFailure(exception: e));
        }
      },
    );
    on<AuthEventLogout>(
      (event, emit) async {
        try {
          emit(const AuthStateLoading());
          await provider.logout();
          emit(const AuthStateLoggenOut());
        } on Exception catch (e) {
          emit(AuthStateLogoutFailure(exception: e));
        }
      },
    );
  }
}
