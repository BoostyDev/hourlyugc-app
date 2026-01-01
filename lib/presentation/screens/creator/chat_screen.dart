import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'dart:io';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../../data/models/message_model.dart';
import '../../widgets/optimized_image.dart';
import 'chat_attachment_modal.dart';
import 'camera_preview_screen.dart';

/// OPTIMIZED Chat screen - Figma Design with 3 views:
/// 1. Empty Chat State (33:3367)
/// 2. Chat List with Groups (33:3274)
/// 3. Active Chat View (33:3416)
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String _selectedFilter = 'All';
  String? _selectedChatId;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  bool _showEmojiPicker = false;
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _messagesScrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus && _showEmojiPicker) {
        setState(() => _showEmojiPicker = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser.value?.uid;
    final chatsAsync = userId != null ? ref.watch(chatsProvider(userId)) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Search Bar & Notification Bell - Only when NOT in DM
                if (_selectedChatId == null)
                  _SearchBar(
                    controller: _searchController,
                    onChanged: () => setState(() {}),
                  ),
                // Filter Pills - Only when NOT in DM
                if (_selectedChatId == null)
                  _FilterPills(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
                  ),
                // Chats List or Chat View
                Expanded(
                  child: _selectedChatId == null
                      ? _ChatsList(
                          chatsAsync: chatsAsync,
                          userId: userId,
                          selectedFilter: _selectedFilter,
                          searchQuery: _searchController.text,
                          onChatSelected: (chatId) => setState(() => _selectedChatId = chatId),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: _ChatView(
                                chatId: _selectedChatId!,
                                userId: userId ?? '',
                                messageController: _messageController,
                                scrollController: _messagesScrollController,
                                onBack: () => setState(() {
                                  _selectedChatId = null;
                                  _showEmojiPicker = false;
                                }),
                                onSendMessage: _sendMessage,
                                onPickImage: _pickImage,
                                onPickVideo: _pickVideo,
                                onPickAudio: _pickAudio,
                                onPickImageFromCamera: _pickImageFromCameraWithPreview,
                                onShowAttachmentModal: _showAttachmentModal,
                                onShowEmojiPicker: () => _toggleEmojiPicker(),
                                isUploading: _isUploading,
                                showEmojiPicker: _showEmojiPicker,
                                messageFocusNode: _messageFocusNode,
                              ),
                            ),
                            // Emoji Picker
                            if (_showEmojiPicker)
                              SizedBox(
                                height: 280,
                                child: emoji.EmojiPicker(
                                  textEditingController: _messageController,
                                  onEmojiSelected: (category, emojiChar) {
                                    // Emoji already added by textEditingController
                                  },
                                  config: emoji.Config(
                                    checkPlatformCompatibility: true,
                                    emojiViewConfig: emoji.EmojiViewConfig(
                                      columns: 8,
                                      emojiSizeMax: 28,
                                      verticalSpacing: 0,
                                      horizontalSpacing: 0,
                                      gridPadding: EdgeInsets.zero,
                                      backgroundColor: Colors.white,
                                      recentsLimit: 28,
                                      loadingIndicator: const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                      buttonMode: emoji.ButtonMode.MATERIAL,
                                    ),
                                    categoryViewConfig: const emoji.CategoryViewConfig(
                                      initCategory: emoji.Category.RECENT,
                                      indicatorColor: Color(0xFF10B981),
                                      iconColorSelected: Color(0xFF10B981),
                                      iconColor: Color(0xFF94A3B8),
                                      backspaceColor: Color(0xFF10B981),
                                    ),
                                    bottomActionBarConfig: const emoji.BottomActionBarConfig(
                                      showBackspaceButton: true,
                                      showSearchViewButton: true,
                                      backgroundColor: Colors.white,
                                      buttonColor: Color(0xFF10B981),
                                    ),
                                    searchViewConfig: emoji.SearchViewConfig(
                                      backgroundColor: Colors.white,
                                      buttonIconColor: const Color(0xFF10B981),
                                      hintText: 'Search emoji...',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
            // Bottom Navigation - Only when NOT in active chat
            if (_selectedChatId == null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomNavbar(),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      _messageFocusNode.requestFocus();
    } else {
      _messageFocusNode.unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }

  Future<void> _sendMessage(String chatId, String userId, String? receiverId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && !_isUploading) return;

    final chatRepo = ref.read(chatRepositoryProvider);
    await chatRepo.sendMessage(
      chatId: chatId,
      senderId: userId,
      receiverId: receiverId ?? '',
      text: text.isNotEmpty ? text : null,
    );

    _messageController.clear();
    
    // Auto-scroll to newest (position 0 with reverse:true)
    if (_messagesScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messagesScrollController.animateTo(
          0, // With reverse:true, 0 is the newest message (bottom)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickImage(String chatId, String userId, String? receiverId) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Show preview screen for gallery images too
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPreviewScreen(
            imageFile: File(pickedFile.path),
            onSend: (file, caption) async {
              setState(() => _isUploading = true);
              
              final chatRepo = ref.read(chatRepositoryProvider);
              final imageUrl = await chatRepo.uploadChatImage(chatId, file);
              
              if (imageUrl != null && mounted) {
                await chatRepo.sendMessage(
                  chatId: chatId,
                  senderId: userId,
                  receiverId: receiverId ?? '',
                  imageUrl: imageUrl,
                  text: caption,
                );
              }
              
              if (mounted) setState(() => _isUploading = false);
            },
          ),
        ),
      );
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> _pickVideo(String chatId, String userId, String? receiverId) async {
    try {
      final pickedFile = await _imagePicker.pickVideo(source: ImageSource.gallery);

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final chatRepo = ref.read(chatRepositoryProvider);
      final videoUrl = await chatRepo.uploadChatVideo(chatId, File(pickedFile.path));

      if (videoUrl != null && mounted) {
        await chatRepo.sendMessage(
          chatId: chatId,
          senderId: userId,
          receiverId: receiverId ?? '',
          text: 'Video',
          videoUrl: videoUrl,
        );
      }
    } catch (e) {
      // Silent error handling
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAudio(String chatId, String userId, String? receiverId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);

      setState(() => _isUploading = true);

      final chatRepo = ref.read(chatRepositoryProvider);
      final audioUrl = await chatRepo.uploadChatAudio(chatId, file);

      if (audioUrl != null && mounted) {
        await chatRepo.sendMessage(
          chatId: chatId,
          senderId: userId,
          receiverId: receiverId ?? '',
          audioUrl: audioUrl,
        );
      }
    } catch (e) {
      // Silent error handling
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFile(String chatId, String userId, String? receiverId) async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.single.path == null) return;

      setState(() => _isUploading = true);

      final chatRepo = ref.read(chatRepositoryProvider);
      final fileUrl = await chatRepo.uploadChatImage(chatId, File(result.files.single.path!));

      if (fileUrl != null && mounted) {
        await chatRepo.sendMessage(
          chatId: chatId,
          senderId: userId,
          receiverId: receiverId ?? '',
          text: 'File: ${result.files.single.name}',
          imageUrl: fileUrl,
        );
      }
    } catch (e) {
      // Silent error handling
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImageFromCameraWithPreview(String chatId, String userId, String? receiverId) async {
    try {
      if (!mounted) return;
      
      // Use image_picker for camera (more reliable than camera plugin)
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (pickedFile == null || !mounted) return;
      
      // Go to preview screen for editing before sending
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPreviewScreen(
            imageFile: File(pickedFile.path),
            onSend: (file, caption) async {
              setState(() => _isUploading = true);
              
              final chatRepo = ref.read(chatRepositoryProvider);
              final imageUrl = await chatRepo.uploadChatImage(chatId, file);
              
              if (imageUrl != null && mounted) {
                await chatRepo.sendMessage(
                  chatId: chatId,
                  senderId: userId,
                  receiverId: receiverId ?? '',
                  imageUrl: imageUrl,
                  text: caption,
                );
              }
              
              if (mounted) setState(() => _isUploading = false);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _showAttachmentModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Position modal above the plus button
            Positioned(
              bottom: 120, // Fixed position above input bar
              left: 12,
              child: Material(
                color: Colors.transparent,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  alignment: Alignment.bottomLeft,
                  child: AttachmentModal(
                    onCamera: () {
                      final chatId = _selectedChatId;
                      final userId = ref.read(currentUserProvider).value?.uid;
                      if (chatId != null && userId != null) {
                        final receiverId = _getReceiverIdForChat(chatId);
                        _pickImageFromCameraWithPreview(chatId, userId, receiverId);
                      }
                    },
                    onGallery: () {
                      final chatId = _selectedChatId;
                      final userId = ref.read(currentUserProvider).value?.uid;
                      if (chatId != null && userId != null) {
                        final receiverId = _getReceiverIdForChat(chatId);
                        _pickImage(chatId, userId, receiverId);
                      }
                    },
                    onVideo: () {
                      final chatId = _selectedChatId;
                      final userId = ref.read(currentUserProvider).value?.uid;
                      if (chatId != null && userId != null) {
                        final receiverId = _getReceiverIdForChat(chatId);
                        _pickVideo(chatId, userId, receiverId);
                      }
                    },
                    onAudio: () {
                      final chatId = _selectedChatId;
                      final userId = ref.read(currentUserProvider).value?.uid;
                      if (chatId != null && userId != null) {
                        final receiverId = _getReceiverIdForChat(chatId);
                        _pickAudio(chatId, userId, receiverId);
                      }
                    },
                    onFile: () {
                      final chatId = _selectedChatId;
                      final userId = ref.read(currentUserProvider).value?.uid;
                      if (chatId != null && userId != null) {
                        final receiverId = _getReceiverIdForChat(chatId);
                        _pickFile(chatId, userId, receiverId);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _getReceiverIdForChat(String chatId) {
    final chatAsync = ref.read(chatProvider(chatId));
    return chatAsync.when(
      data: (chat) {
        final userId = ref.read(currentUserProvider).value?.uid;
        if (userId == null) return null;
        return chat.participants.firstWhere((id) => id != userId, orElse: () => '');
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Widget _buildBottomNavbar() {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Navigation bar - Figma design
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 362,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(51),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF050514).withOpacity(0.15),
                    blurRadius: 27.6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildNavItem(0, 'assets/icons/Navigation.svg', 'Home', () => context.push('/creator/home')),
                  _buildNavItem(1, 'assets/icons/video.svg', null, () => context.push('/creator/jobs')),
                  _buildNavItem(2, 'assets/icons/Group 13.svg', 'Chat', null, isActive: true),
                  _buildNavItem(3, 'assets/icons/Vector-1.svg', null, () => context.push('/creator/payout')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String svgPath, String? label, VoidCallback? onTap, {bool isActive = false}) {
    return Expanded(
      flex: isActive && label != null ? 2 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const RadialGradient(
                    center: Alignment.bottomCenter,
                    radius: 1.5,
                    colors: [
                      Color(0xFF9FF7C0),
                      Color(0xFF45D27B),
                      Color(0xFF129C8D),
                    ],
                    stops: [0.0, 0.34, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.5),
                      blurRadius: 25.7,
                    ),
                    BoxShadow(
                      color: const Color(0xFF69FFB4).withOpacity(0.18),
                      blurRadius: 39.1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isActive ? const Color(0xFF022C22) : const Color(0xFF64748B),
                  BlendMode.srcIn,
                ),
              ),
              if (isActive && label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF022C22),
                    letterSpacing: -0.18,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF66A384).withOpacity(0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 2.4,
                      ),
                      const Shadow(
                        color: Color(0x80FFFFFF),
                        offset: Offset(0, 0.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// MEMOIZED WIDGETS FOR PERFORMANCE

/// Search bar with bell notification - Figma Node 33:3369
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/icons/chat_search_icon.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF94A3B8),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (_) => onChanged(),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: -0.18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        letterSpacing: -0.18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 35,
                ),
              ],
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/Bell.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF0F172A),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter Pills - Figma Node 33:3385
class _FilterPills extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterPills({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterPill(
              label: 'All',
              isSelected: selectedFilter == 'All',
              onTap: () => onFilterChanged('All'),
            ),
            const SizedBox(width: 6),
            _FilterPill(
              label: 'Unread',
              isSelected: selectedFilter == 'Unread',
              onTap: () => onFilterChanged('Unread'),
            ),
            const SizedBox(width: 6),
            _FilterPill(
              label: 'Archived',
              isSelected: selectedFilter == 'Archived',
              onTap: () => onFilterChanged('Archived'),
            ),
            const SizedBox(width: 6),
            _FilterPill(
              label: 'Muted',
              isSelected: selectedFilter == 'Muted',
              onTap: () => onFilterChanged('Muted'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD3F8DF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981).withOpacity(0.5) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(label == 'All' ? 24 : 48),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF69FFB4).withOpacity(0.18),
                    blurRadius: 39.1,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF475569),
            letterSpacing: -0.18,
          ),
        ),
      ),
    );
  }
}

/// Chats List - handles empty state, groups section, and chat items
class _ChatsList extends ConsumerWidget {
  final AsyncValue<List<ChatModel>>? chatsAsync;
  final String? userId;
  final String selectedFilter;
  final String searchQuery;
  final ValueChanged<String> onChatSelected;

  const _ChatsList({
    required this.chatsAsync,
    required this.userId,
    required this.selectedFilter,
    required this.searchQuery,
    required this.onChatSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return const Center(child: Text('Please log in'));
    }

    return chatsAsync?.when(
          data: (chats) {
            List<ChatModel> filteredChats = chats;
            if (selectedFilter == 'Unread') {
              filteredChats = chats.where((chat) => chat.unreadCount > 0).toList();
            } else if (selectedFilter == 'Archived') {
              filteredChats = chats.where((chat) => chat.isArchived == true).toList();
            } else if (selectedFilter == 'Muted') {
              filteredChats = chats.where((chat) => chat.isMuted == true).toList();
            }

            if (searchQuery.isNotEmpty) {
              final query = searchQuery.toLowerCase();
              filteredChats = filteredChats.where((chat) {
                final otherName = _getOtherParticipantName(chat, userId!);
                return otherName.toLowerCase().contains(query);
              }).toList();
            }

            // Show empty state if no chats - Figma Node 33:3367
            if (filteredChats.isEmpty && searchQuery.isEmpty && selectedFilter == 'All') {
              return _EmptyState();
            }

            if (filteredChats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ChatsCircle.svg',
                      width: 80,
                      height: 80,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF94A3B8).withOpacity(0.5),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No chats found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 120),
              cacheExtent: 500,
              children: [
                // Groups Section - Replacing "Pending requests"
                _GroupsSection(onTap: () {
                  // TODO: Navigate to groups screen
                }),
                // Chat items
                ...filteredChats.map((chat) => _ChatListItem(
                      chat: chat,
                      userId: userId!,
                      onTap: () => onChatSelected(chat.id),
                    )),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
          error: (e, st) => Center(child: Text('Error: $e')),
        ) ??
        const SizedBox.shrink();
  }
}

/// Empty State - Figma Node 33:3367
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chat circles icon - using ChatsCircle.svg from Figma
            SvgPicture.asset(
              'assets/icons/ChatsCircle.svg',
              width: 185,
              height: 180,
            ),
            const SizedBox(height: 29),
            // Title
            Text(
              'No chats yet!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.15,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              'Once you connect with a client, you\'ll be able to chat and collaborate here',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: const Color(0xFF64748B),
                letterSpacing: -0.18,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Groups Section - Replacing "Pending requests" as per requirements
class _GroupsSection extends StatelessWidget {
  final VoidCallback onTap;

  const _GroupsSection({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            // Icon container with chat circles + time
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.65),
                borderRadius: BorderRadius.circular(13.5),
              ),
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/icons/ChatsCircle.svg',
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF64748B),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  // Time indicator badge
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.access_time,
                        size: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            // Text
            Expanded(
              child: Text(
                'Groups',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.18,
                ),
              ),
            ),
            // Arrow
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF475569),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Get the other participant's name from chat - matches Vue web logic
String _getOtherParticipantName(ChatModel chat, String userId) {
  final otherId = chat.participants.firstWhere((id) => id != userId, orElse: () => '');
  
  // Check participantDetails (populated by repository, same as Vue)
  if (chat.participantDetails != null && chat.participantDetails!.containsKey(otherId)) {
    final details = chat.participantDetails![otherId];
    if (details is Map) {
      // Priority order (same as Vue web):
      // fullName > displayName > companyName > name > firstName > email prefix
      final name = details['fullName'] ?? 
                   details['displayName'] ?? 
                   details['companyName'] ??
                   details['name'] ?? 
                   details['firstName'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString();
      }
      // Fallback to email prefix
      final email = details['email'];
      if (email != null && email.toString().contains('@')) {
        return email.toString().split('@')[0];
      }
    }
  }
  
  // Fallback to applicantName (for legacy chats)
  if (chat.applicantName != null && chat.applicantName!.isNotEmpty) {
    return chat.applicantName!;
  }
  
  // Fallback to jobTitle if available
  if (chat.jobTitle != null && chat.jobTitle!.isNotEmpty) {
    return chat.jobTitle!;
  }
  
  return 'User';
}

/// Get the other participant's photo URL - matches Vue web logic
String? _getOtherParticipantPhoto(ChatModel chat, String userId) {
  final otherId = chat.participants.firstWhere((id) => id != userId, orElse: () => '');
  
  if (chat.participantDetails != null && chat.participantDetails!.containsKey(otherId)) {
    final details = chat.participantDetails![otherId];
    if (details is Map) {
      // Vue uses: photoURL || photoUrl (capital URL first, then lowercase)
      return details['photoURL'] ?? details['photoUrl'];
    }
  }
  return null;
}

/// Chat List Item - Figma design with avatar, name, time, message preview
class _ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final String userId;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.chat,
    required this.userId,
    required this.onTap,
  });

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final otherName = _getOtherParticipantName(chat, userId);
    final photoUrl = _getOtherParticipantPhoto(chat, userId);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipOval(
                child: photoUrl != null
                    ? OptimizedImage(
                        imageUrl: photoUrl,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: const Color(0xFFE2E8F0),
                        child: Center(
                          child: Text(
                            otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 15),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Text(
                        otherName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      // Time
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          letterSpacing: -0.16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Message preview
                  Text(
                    chat.lastMessage ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: const Color(0xFF64748B),
                      letterSpacing: -0.18,
                    ),
                  ),
                ],
              ),
            ),
            // Unread badge
            if (chat.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chat View - Active conversation - Figma Node 33:3416
class _ChatView extends ConsumerWidget {
  final String chatId;
  final String userId;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final VoidCallback onBack;
  final Future<void> Function(String, String, String?) onSendMessage;
  final Future<void> Function(String, String, String?) onPickImage;
  final Future<void> Function(String, String, String?) onPickVideo;
  final Future<void> Function(String, String, String?) onPickAudio;
  final Future<void> Function(String, String, String?) onPickImageFromCamera;
  final void Function(BuildContext) onShowAttachmentModal;
  final VoidCallback onShowEmojiPicker;
  final bool isUploading;
  final bool showEmojiPicker;
  final FocusNode messageFocusNode;

  const _ChatView({
    required this.chatId,
    required this.userId,
    required this.messageController,
    required this.scrollController,
    required this.onBack,
    required this.onSendMessage,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onPickAudio,
    required this.onPickImageFromCamera,
    required this.onShowAttachmentModal,
    required this.onShowEmojiPicker,
    required this.isUploading,
    required this.showEmojiPicker,
    required this.messageFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(chatId));
    final chatAsync = ref.watch(chatProvider(chatId));

    return Stack(
      children: [
        Container(color: const Color(0xFFF8FAFC)),
        Column(
          children: [
            // Header - with blur bg
            _ChatHeader(
              chatAsync: chatAsync,
              chatId: chatId,
              userId: userId,
              onBack: onBack,
            ),
            // Messages
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    );
                  }
                  
                  // Scroll to bottom only on first load, not on every rebuild
                  // Remove auto-scroll to allow manual scrolling up

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: messages.length,
                    cacheExtent: 1000,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    reverse: true, // Newest messages at bottom, scroll UP to see old
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == userId;
                      // With reverse:true + descending:true, index 0 = newest (bottom)
                      // Show timestamp when sender changes or time gap > 5min
                      final nextIndex = index + 1;
                      final showTimestamp = nextIndex >= messages.length ||
                          messages[nextIndex].senderId != message.senderId ||
                          message.timestamp.difference(messages[nextIndex].timestamp).inMinutes.abs() > 5;
                      
                      return Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (showTimestamp)
                            _MessageTimestamp(timestamp: message.timestamp),
                          if (showTimestamp) const SizedBox(height: 8),
                          _MessageBubble(
                            message: message,
                            isMe: isMe,
                            chatId: chatId,
                            userId: userId,
                          ),
                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                error: (e, st) => Center(
                  child: Text(
                    'Error loading messages',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ),
            // Input - Figma design with plus, emoji, camera
            _ChatInput(
              messageController: messageController,
              isUploading: isUploading,
              showEmojiPicker: showEmojiPicker,
              messageFocusNode: messageFocusNode,
              onSend: () => onSendMessage(chatId, userId, _getReceiverId(chatAsync.value)),
              onShowAttachmentModal: (context) => onShowAttachmentModal(context),
              onShowEmojiPicker: onShowEmojiPicker,
              onCamera: () => onPickImageFromCamera(chatId, userId, _getReceiverId(chatAsync.value)),
            ),
          ],
        ),
      ],
    );
  }

  String? _getReceiverId(ChatModel? chat) {
    if (chat == null) return null;
    return chat.participants.firstWhere((id) => id != userId, orElse: () => '');
  }
}

/// Chat Header - Figma Node 33:3419
class _ChatHeader extends ConsumerWidget {
  final AsyncValue<ChatModel> chatAsync;
  final String chatId;
  final String userId;
  final VoidCallback onBack;

  const _ChatHeader({
    required this.chatAsync,
    required this.chatId,
    required this.userId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF050514).withValues(alpha: 0.1),
            blurRadius: 35,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF050514).withValues(alpha: 0.1),
                    blurRadius: 35,
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 28,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Profile info
          chatAsync.when(
            data: (chat) {
              final otherName = _getOtherParticipantName(chat, userId);
              final photoUrl = _getOtherParticipantPhoto(chat, userId);
              return Expanded(
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.867),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB48F7A).withOpacity(0.18),
                            blurRadius: 45.617,
                            offset: const Offset(0, 3.5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: photoUrl != null
                            ? OptimizedImage(
                                imageUrl: photoUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFE2E8F0),
                                child: Center(
                                  child: Text(
                                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Name and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF45D27B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Online',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: -0.16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Menu button with clean popup - app design
          PopupMenuButton<String>(
            onSelected: (value) async {
              final chatRepo = ref.read(chatRepositoryProvider);
              final chat = chatAsync.value;
              if (chat == null) return;
              
              switch (value) {
                case 'archive':
                  await chatRepo.archiveChat(chatId, !(chat.isArchived ?? false));
                  break;
                case 'mute':
                  await chatRepo.muteChat(chatId, !(chat.isMuted ?? false));
                  break;
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            position: PopupMenuPosition.under,
            offset: const Offset(-80, 8),
            constraints: const BoxConstraints(minWidth: 140),
            itemBuilder: (context) {
              final chat = chatAsync.value;
              return [
                PopupMenuItem(
                  height: 42,
                  value: 'archive',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        chat?.isArchived == true ? Icons.unarchive_outlined : Icons.archive_outlined,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        chat?.isArchived == true ? 'Unarchive' : 'Archive',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  height: 42,
                  value: 'mute',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        chat?.isMuted == true ? Icons.notifications_outlined : Icons.notifications_off_outlined,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        chat?.isMuted == true ? 'Unmute' : 'Mute',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF050514).withOpacity(0.08),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.more_vert,
                  size: 24,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Message Timestamp - Figma design
class _MessageTimestamp extends StatelessWidget {
  final DateTime timestamp;

  const _MessageTimestamp({required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(48),
        ),
        child: Text(
          _formatTime(timestamp),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
            letterSpacing: -0.16,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

/// Message Bubble - Figma design with gradients and reactions (like Vue web)
class _MessageBubble extends ConsumerStatefulWidget {
  final MessageModel message;
  final bool isMe;
  final String chatId;
  final String userId;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.chatId,
    required this.userId,
  });

  @override
  ConsumerState<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<_MessageBubble> {
  bool _showReactionPicker = false;
  static const List<String> _allReactions = ['👍', '❤️', '😂', '😮', '😢', '🔥', '👏', '🎉'];

  Future<void> _toggleReaction(String emoji) async {
    setState(() => _showReactionPicker = false);
    final chatRepo = ref.read(chatRepositoryProvider);
    await chatRepo.toggleReaction(
      widget.chatId,
      widget.message.id,
      emoji,
      widget.userId,
    );
  }

  Widget _buildMessageContent(MessageModel message) {
    final isNormalText = message.text != null && 
        message.text!.isNotEmpty && 
        message.text != '📷 Image' && 
        message.text != '🎵 Audio' && 
        message.text != '🎥 Video' &&
        message.text != 'Image' &&
        message.text != 'Audio' &&
        message.text != 'Video';
    
    // Image
    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: OptimizedImage(
              imageUrl: message.imageUrl!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          if (isNormalText) ...[
            const SizedBox(height: 8),
            Text(
              message.text!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.18,
              ),
            ),
          ],
        ],
      );
    }
    
    // Video
    if (message.videoUrl != null && message.videoUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_filled, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  'Video',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (isNormalText) ...[
            const SizedBox(height: 8),
            Text(
              message.text!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.18,
              ),
            ),
          ],
        ],
      );
    }
    
    // Audio
    if (message.audioUrl != null && message.audioUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.audiotrack, size: 24, color: Color(0xFF0F172A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Audio',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.play_arrow, size: 24, color: Color(0xFF0F172A)),
              ],
            ),
          ),
        ],
      );
    }
    
    // Text only
    final displayText = message.text?.isNotEmpty == true ? message.text! : 'Message';
    
    return Text(
      displayText,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        color: const Color(0xFF0F172A),
        letterSpacing: -0.18,
        height: 1.375,
      ),
    );
  }

  Widget _buildReactionsDisplay() {
    final reactions = widget.message.reactions;
    if (reactions == null || reactions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: reactions.entries.map((entry) {
          final emoji = entry.key;
          final users = entry.value;
          final hasMyReaction = users.contains(widget.userId);

          return GestureDetector(
            onTap: () => _toggleReaction(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: hasMyReaction
                    ? const Color(0xFFD1FAE5)
                    : (widget.isMe ? Colors.white.withOpacity(0.3) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasMyReaction
                      ? const Color(0xFF10B981)
                      : (widget.isMe ? Colors.white.withOpacity(0.5) : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 2),
                  Text(
                    '${users.length}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: hasMyReaction ? const Color(0xFF059669) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReactionPicker() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _allReactions.map((emoji) => GestureDetector(
          onTap: () => _toggleReaction(emoji),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => _toggleReaction('❤️'),
      onLongPress: () => setState(() => _showReactionPicker = !_showReactionPicker),
      child: Column(
        crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Reaction picker popup
          if (_showReactionPicker)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildReactionPicker(),
            ),
          
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              // Received messages - green gradient from Figma
              gradient: !widget.isMe
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x215DFFAE), // rgba(93,255,174,0.13)
                        Color(0x4269D27B), // rgba(69,210,123,0.26)
                        Color(0x42059669), // rgba(5,150,105,0.26)
                      ],
                      stops: [0.0, 0.48716, 0.96875],
                    )
                  : null,
              // Sent messages - gray
              color: widget.isMe ? const Color(0x52CBD5E1) : null,
              border: Border.all(
                color: widget.isMe ? const Color(0xFFE2E8F0) : const Color(0x1A45D27B),
                width: 0.8,
              ),
              borderRadius: widget.isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMessageContent(widget.message),
                _buildReactionsDisplay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat Input - Figma Node 33:3506
class _ChatInput extends StatelessWidget {
  final TextEditingController messageController;
  final bool isUploading;
  final bool showEmojiPicker;
  final FocusNode messageFocusNode;
  final VoidCallback onSend;
  final void Function(BuildContext) onShowAttachmentModal;
  final VoidCallback onShowEmojiPicker;
  final VoidCallback onCamera;

  const _ChatInput({
    required this.messageController,
    required this.isUploading,
    required this.showEmojiPicker,
    required this.messageFocusNode,
    required this.onSend,
    required this.onShowAttachmentModal,
    required this.onShowEmojiPicker,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Plus button - attachment modal
                GestureDetector(
                  onTap: () => onShowAttachmentModal(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF050514).withOpacity(0.1),
                          blurRadius: 35,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/Plus.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Message Input
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0x42CBD5E1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            focusNode: messageFocusNode,
                            decoration: InputDecoration(
                              hintText: isUploading ? 'Uploading...' : 'Send message',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: -0.18,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              isDense: true,
                            ),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.18,
                            ),
                            cursorColor: const Color(0xFF10B981),
                            enabled: !isUploading,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => onSend(),
                          ),
                        ),
                        // Emoji button
                        GestureDetector(
                          onTap: onShowEmojiPicker,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: showEmojiPicker
                                ? const Icon(Icons.keyboard, size: 24, color: Color(0xFF10B981))
                                : SvgPicture.asset(
                                    'assets/icons/Emoji.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Camera button
                GestureDetector(
                  onTap: isUploading ? null : onCamera,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF050514).withOpacity(0.1),
                          blurRadius: 35,
                        ),
                      ],
                    ),
                    child: isUploading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          )
                        : Center(
                            child: SvgPicture.asset(
                              'assets/icons/Camera.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
