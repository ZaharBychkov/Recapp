import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _avatarPathKey = 'profile_avatar_path';

  final ImagePicker _picker = ImagePicker();
  String username = 'avpetrov';
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_avatarPathKey);

    if (savedPath == null || savedPath.isEmpty) {
      return;
    }

    if (!File(savedPath).existsSync()) {
      await prefs.remove(_avatarPathKey);
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _avatarPath = savedPath;
    });
  }

  Future<void> _saveAvatarPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();

    if (path == null || path.isEmpty) {
      await prefs.remove(_avatarPathKey);
      return;
    }

    await prefs.setString(_avatarPathKey, path);
  }

  Future<void> _pickAvatar(ImageSource source) async {
    Navigator.of(context).pop();

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (pickedFile == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _avatarPath = pickedFile.path;
    });

    await _saveAvatarPath(pickedFile.path);
  }

  Future<void> _removeAvatar() async {
    Navigator.of(context).pop();

    if (!mounted) {
      return;
    }

    setState(() {
      _avatarPath = null;
    });

    await _saveAvatarPath(null);
  }

  void _showAvatarAction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionItem(
                text: 'Сфотографировать',
                onTap: () => _pickAvatar(ImageSource.camera),
              ),
              const Divider(height: 1),
              _actionItem(
                text: 'Выбрать из альбома',
                onTap: () => _pickAvatar(ImageSource.gallery),
              ),
              const Divider(height: 1),
              _actionItem(
                text: 'Удалить',
                textColor: Colors.red,
                onTap: _removeAvatar,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ],
          ),
        );
      },
    );
  }

  Widget _actionItem({
    required String text,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Center(
                child: GestureDetector(
                  onTap: () {
                    _showAvatarAction(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF165932), width: 3.5),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: _avatarPath == null
                          ? Padding(
                              padding: EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/Icons/empty_avatar.png',
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.file(File(_avatarPath!), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              GestureDetector(
                onTap: _openHistory,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFD9D9D9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'История приготовления',
                        style: TextStyle(
                          color: Color(0xff165932),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF2ECC71)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Логин',
                      style: TextStyle(
                        color: Color(0xff165932),
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      username,
                      style: TextStyle(
                        color: Color(0xFF2ECC71),
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9)),
                ),
                child: Center(
                  child: Text(
                    'Выход',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
