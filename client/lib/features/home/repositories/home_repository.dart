import 'dart:io';

import 'package:client/core/constants/server_constant.dart';
import 'package:http/http.dart' as http;

class HomeRepository {
  Future<void> uploadSong(File selectedImage, File selectedAudio) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ServerConstant.baseUrl}/song/upload'),
    );

    request
      ..files.addAll([
        await http.MultipartFile.fromPath('song', selectedAudio.path),
        await http.MultipartFile.fromPath('thumbnail', selectedImage.path),
      ])
      ..fields.addAll({
        'artist': 'Mihoyo',
        'song_name': 'Devaline hymn',
        'hex_code': 'FFFFFF',
      })
      ..headers.addAll({
        'x-auth-token':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjJkNWMwYzk3LWQ3YmEtNDEwYS1hNzdjLTA5NDY5NzIyZjc0MSJ9.2keb9ktHm0ejN1VPrqAtLD_MgtciqRr_JaKnghV9P34',
      });

    final res = await request.send();
    print(res);
  }
}
