import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'addpost_text.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

@override
class _AddPostScreenState extends State<AddPostScreen> {
  final List<Widget> _mediaList = [];
  final List<File> path = [];
  // ignore: unused_field
  File? _file;
  int currentPage = 0;
  int? lastPage;

  _fetchNewMedia() async {
    lastPage = currentPage;
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> album =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      List<AssetEntity> media =
          await album[0].getAssetListPaged(page: currentPage, size: 60);

      for (var asset in media) {
        if (asset.type == AssetType.image) {
          final file = await asset.file;
          if (file != null) {
            path.add(File(file.path));
            _file = path[0];
          }
        }
      }
      List<Widget> temp = [];
      for (var asset in media) {
        temp.add(
          FutureBuilder(
            future: asset.thumbnailDataWithSize(const ThumbnailSize(640, 640)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  height: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        );
      }
      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  int indexx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 375,
                child: GridView.builder(
                  itemCount: _mediaList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                  ),
                  itemBuilder: (context, index) {
                    return _mediaList[indexx];
                  },
                ),
              ),
              Container(
                width: double.infinity,
                height: 40,
                color: Colors.white,
                child: const Row(
                  children: [
                    Text(
                      'Recent',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _mediaList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          indexx = index;
                          _file = path[index];
                        });
                      },
                      child: _mediaList[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'New Post',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddPostTextScreen(_file!),
                ));
              },
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 15, color: Colors.blue),
              ),
            ),
          ),
        )
      ],
    );
  }
}
