import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateInitilizing(loading: true)) {
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );
    on<AuthEventShouldRegister>(
      (event, emit) {
        emit(const AuthStateRegistering(exception: null, loading: false));
      },
    );
    on<AuthEventRegisterUser>(
      (event, emit) async {
        try {
          final email = event.email;
          final password = event.password;
          await provider.createUser(email: email, password: password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(loading: false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(exception: e, loading: false));
        }
      },
    );
    on<AuthEventLogin>(
      (event, emit) async {
        emit(const AuthStateLoggenOut(
            exception: null,
            loading: true,
            loadingText: 'Please Wait for Login'));
        try {
          final user = await provider.login(
              email: event.email, password: event.password);
          if (!user.isEmailverified) {
            emit(const AuthStateLoggenOut(
              exception: null,
              loading: false,
            ));
            emit(const AuthStateNeedsVerification(loading: false));
          } else {
            emit(const AuthStateLoggenOut(exception: null, loading: false));
            emit(AuthStateLoggedIn(authUser: user, loading: false));
          }
        } on Exception catch (e) {
          emit(AuthStateLoggenOut(exception: e, loading: false));
        }
      },
    );
    on<AuthEventInitilize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(
            const AuthStateLoggenOut(exception: null, loading: false),
          );
        } else if (!user.isEmailverified) {
          emit(const AuthStateNeedsVerification(loading: false));
          await provider.sendEmailVerification();
        } else {
          emit(AuthStateLoggedIn(authUser: user, loading: false));
        }
      },
    );

    on<AuthEventLogout>(
      (event, emit) async {
        try {
          emit(const AuthStateLoggenOut(exception: null, loading: false));
          await provider.logout();
        } on Exception catch (e) {
          emit(AuthStateLoggenOut(exception: e, loading: false));
        }
      },
    );

    on<AuthEventResetPassword>(
      (event, emit) async {
        emit(const AuthStateResetPassword(
          loading: false,
          exception: null,
          hasSentEmail: false,
        ));

        final email = event.email;

        if (email == null) {
          return;
        }

        emit(const AuthStateResetPassword(
          loading: true,
          exception: null,
          hasSentEmail: false,
        ));
        bool? isSendEmail;
        Exception? exception;
        try {
          await provider.sendEmailVerification();
          isSendEmail = true;
          exception = null;
        } on Exception catch (e) {
          isSendEmail = true;
          exception = e;
        }

        emit(AuthStateResetPassword(
          loading: false,
          exception: exception,
          hasSentEmail: isSendEmail,
        ));
      },
    );
  }
}
