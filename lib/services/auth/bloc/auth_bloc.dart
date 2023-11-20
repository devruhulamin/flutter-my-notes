import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateInitilizing()) {
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );
    on<AuthEventRegisterUser>(
      (event, emit) async {
        try {
          final email = event.email;
          final password = event.password;
          await provider.createUser(email: email, password: password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification());
        } on Exception catch (e) {
          emit(AuthStateRegistering(exception: e));
        }
      },
    );
    on<AuthEventLogin>(
      (event, emit) async {
        emit(const AuthStateLoggenOut(exception: null, isLoading: true));
        try {
          final user = await provider.login(
              email: event.email, password: event.password);
          if (!user.isEmailverified) {
            emit(const AuthStateLoggenOut(exception: null, isLoading: false));
            emit(const AuthStateNeedsVerification());
          } else {
            emit(const AuthStateLoggenOut(exception: null, isLoading: false));
            emit(AuthStateLoggedIn(authUser: user));
          }
        } on Exception catch (e) {
          emit(AuthStateLoggenOut(exception: e, isLoading: false));
        }
      },
    );
    on<AuthEventInitilize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(
            const AuthStateLoggenOut(exception: null, isLoading: false),
          );
        } else if (!user.isEmailverified) {
          emit(const AuthStateNeedsVerification());
          await provider.sendEmailVerification();
        } else {
          emit(AuthStateLoggedIn(authUser: user));
        }
      },
    );

    on<AuthEventLogout>(
      (event, emit) async {
        try {
          emit(const AuthStateLoggenOut(exception: null, isLoading: false));
          await provider.logout();
        } on Exception catch (e) {
          emit(AuthStateLoggenOut(exception: e, isLoading: false));
        }
      },
    );
  }
}
