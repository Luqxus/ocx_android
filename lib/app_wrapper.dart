import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offconnectx/service/authentication/bloc.dart';
import 'package:offconnectx/service/authentication/state.dart';
import 'package:offconnectx/utils/authenticate.dart';
import 'package:offconnectx/view/authentication/create_account_view.dart';
import 'package:offconnectx/view/authentication/unlock_account_view.dart';
import 'package:offconnectx/view/common/loading_view.dart';
import 'package:offconnectx/view/home/home_view.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationUnauthenticatedState) {
          if (state.type == AuthenticationType.UnlockAccount) {
            return const UnlockAccountView();
          }

          return const CreateAccountView();
        } else if (state is AuthenticationAuthenticatedState) {
          return const HomeView();
        }

        return const LoadingView();
      },
    );
  }
}
