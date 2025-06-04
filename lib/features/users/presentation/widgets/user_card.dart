// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../domain/entities/user.dart';
// import '../../../../shared/widgets/user_avatar.dart';

// class UserCard extends StatelessWidget {
//   final User user;
//   final VoidCallback? onTap;
//   final bool showPostCount;
//   final bool showProfileButton;
//   final int? postCount;

//   const UserCard({
//     super.key,
//     required this.user,
//     this.onTap,
//     this.showPostCount = false,
//     this.showProfileButton = true,
//     this.postCount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: colorScheme.outline.withOpacity(0.1),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: colorScheme.shadow.withOpacity(0.08),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               // Enhanced User Avatar with Hero Animation
//               Hero(
//                 tag: 'user_avatar_${user.id}',
//                 child: Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         colorScheme.primary.withOpacity(0.1),
//                         colorScheme.secondary.withOpacity(0.1),
//                       ],
//                     ),
//                   ),
//                   padding: const EdgeInsets.all(3),
//                   child: UserAvatar(
//                     imageUrl: user.image,
//                     initials: _getInitials(user.firstName, user.lastName),
//                     size: 64,
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 20),

//               // User Information
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${user.firstName} ${user.lastName}',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.alternate_email,
//                           size: 16,
//                           color: colorScheme.primary,
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           '@${user.username}',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: colorScheme.primary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     if (user.email.isNotEmpty) ...[
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.email_outlined,
//                             size: 14,
//                             color: colorScheme.onSurface.withOpacity(0.6),
//                           ),
//                           const SizedBox(width: 6),
//                           Expanded(
//                             child: Text(
//                               user.email,
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: colorScheme.onSurface.withOpacity(0.7),
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                     ],
//                     if (user.company != null) ...[
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.business,
//                             size: 14,
//                             color: colorScheme.onSurface.withOpacity(0.6),
//                           ),
//                           const SizedBox(width: 6),
//                           Expanded(
//                             child: Text(
//                               '${user.company!.title} at ${user.company!.name}',
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: colorScheme.onSurface.withOpacity(0.7),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                     ],

//                     // Post count badge and profile button row
//                     Row(
//                       children: [
//                         if (showPostCount && postCount != null) ...[
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color:
//                                   colorScheme.primaryContainer.withOpacity(0.3),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.article_outlined,
//                                   size: 12,
//                                   color: colorScheme.onPrimaryContainer,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   '$postCount posts',
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     color: colorScheme.onPrimaryContainer,
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 11,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                         ],

//                         const Spacer(),

//                         // View Profile Button
//                         if (showProfileButton)
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   colorScheme.primary,
//                                   colorScheme.primary.withOpacity(0.8),
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: colorScheme.primary.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 borderRadius: BorderRadius.circular(20),
//                                 onTap: () {
//                                   context.go('/user-profile/${user.id}');
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 10),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         Icons.person_outline,
//                                         size: 16,
//                                         color: colorScheme.onPrimary,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         'View Profile',
//                                         style:
//                                             theme.textTheme.bodySmall?.copyWith(
//                                           color: colorScheme.onPrimary,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _getInitials(String firstName, String lastName) {
//     String initials = '';
//     if (firstName.isNotEmpty) {
//       initials += firstName[0].toUpperCase();
//     }
//     if (lastName.isNotEmpty) {
//       initials += lastName[0].toUpperCase();
//     }
//     return initials.isEmpty ? 'U' : initials;
//   }
// }
