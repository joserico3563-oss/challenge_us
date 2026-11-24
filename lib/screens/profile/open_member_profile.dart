import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import 'member_profile_screen.dart';

void openMemberProfile(BuildContext context, String memberId) {
  final state = AppScope.of(context);

  if (memberId == state.user.id) {
    Navigator.of(context).pushNamed(AppRoutes.profile);
    return;
  }

  GroupMember? selected;

  for (final member in state.members) {
    if (member.id == memberId) {
      selected = member;
      break;
    }
  }

  if (selected == null) return;

  final member = selected;

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MemberProfileScreen(member: member),
    ),
  );
}
