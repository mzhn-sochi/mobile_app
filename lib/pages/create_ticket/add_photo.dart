import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/pages/create_ticket/crop_photo.dart';
import 'package:photo_manager/photo_manager.dart';

class AddPhotoPage extends StatefulWidget {
  const AddPhotoPage({super.key});

  @override
  State<AddPhotoPage> createState() => _AddPhotoPageState();
}

class _AddPhotoPageState extends State<AddPhotoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          "Выберите фотографию",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: const SafeArea(
        minimum: EdgeInsets.all(4),
        child: SizedBox(
          width: double.infinity,
          child: Column(children: [
            Flexible(
              child: GalleryScreen(),
            ),
            // TradePointSelector(),
          ]),
        ),
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  final ImagePicker _picker = ImagePicker();

  List<AssetEntity> _mediaList = [];

  @override
  void initState() {
    super.initState();

    initAsync();
  }

  initAsync() async {
    await _initCamera();
    await _loadMedia();
  }

  Future<void> _loadMedia() async {
    final ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // Получаем альбомы
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image, // Фильтр для изображений
      );

      if (albums.isNotEmpty) {
        // Получаем изображения из первого альбома
        List<AssetEntity> media =
            await albums.first.getAssetListPaged(page: 0, size: 100);

        setState(() {
          _mediaList = media;
        });
      }
    } else {
      /*
      PhotoManager
          .openSetting(); // Предлагаем пользователю открыть настройки, если доступ не предоставлен
      */
    }
  }

  Future<void> _takePictureAndNavigate() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _navigateToNextScreen(pickedFile.path);
    }
  }

  void _navigateToNextScreen(String imagePath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConfigurableCrop(imagePath: imagePath),
      ),
    );
  }

  Future<void> _initCamera() async {
    // Получаем список доступных камер
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      // Инициализируем контроллер камеры
      _controller = CameraController(_cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getMediaInfo(AssetEntity asset) async {
    // Получаем миниатюру
    final Uint8List? thumbnailData =
        await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));

    // Получаем файл
    final File? file = await asset.file;

    // Возвращаем и данные миниатюры, и путь к файлу
    return {
      'thumbnailData': thumbnailData,
      'filePath': file?.path,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _mediaList.length + 1, // Увеличиваем на один для камеры
      itemBuilder: (context, index) {
        if (index == 0) {
          // Если это первый элемент, показываем иконку камеры
          return GestureDetector(
            onTap: () {
              _takePictureAndNavigate();
            },
            child: _isCameraInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: CameraPreview(_controller!),
                      ), // Превью камеры, // Превью камеры
                      const Icon(Icons.camera_alt,
                          color: Colors.white), // Иконка камеры
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        } else {
          // Показываем изображения из галереи для остальных элементов
          final assetIndex =
              index - 1; // Уменьшаем индекс на 1, т.к. первый элемент - камера
          return FutureBuilder<Map<String, dynamic>>(
            future: _getMediaInfo(_mediaList[assetIndex]),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                final Uint8List? thumbnailData =
                    snapshot.data!['thumbnailData'];
                final String? filePath = snapshot.data!['filePath'];

                return GestureDetector(
                  onTap: () {
                    // Используем filePath для навигации
                    _navigateToNextScreen(filePath!);
                  },
                  child: thumbnailData != null
                      ? Image.memory(
                          thumbnailData,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey),
                );
              }

              // Placeholder в случае, если миниатюра все еще загружается или не удалось загрузить
              return Container(color: Colors.grey);
            },
          );
        }
      },
    );
  }
}
