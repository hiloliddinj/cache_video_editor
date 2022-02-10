
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'video_editing_files.dart';
const url = 'http://5.181.109.17:8085/video/55c1859ba4c85217f4ad24c4d9b0c82f_20220204-152008_720p2628kbs.mp4';

void main() {
  runApp(const MyApp());
  CacheManager.logLevel = CacheManagerLogLevel.verbose;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoDownloadToCashPage(),
    );
  }
}

class VideoDownloadToCashPage extends StatefulWidget {
  const VideoDownloadToCashPage({Key? key}) : super(key: key);


  @override
  State<VideoDownloadToCashPage> createState() => _VideoDownloadToCashPageState();
}

class _VideoDownloadToCashPageState extends State<VideoDownloadToCashPage> {
  Stream<FileResponse>? fileStream;

  _downloadFile() async {
    setState(() {
      fileStream = DefaultCacheManager().getFileStream(url, withProgress: true);
    });
  }

  _clearCache() {
    DefaultCacheManager().emptyCache();
    setState(() {
      fileStream = null;
    });
  }

  _removeFile() {
    DefaultCacheManager().removeFile(url).then((value) {
      //ignore: avoid_print
      print('File removed');
    }).onError((error, stackTrace) {
      //ignore: avoid_print
      print(error);
    });
    setState(() {
      fileStream = null;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (fileStream == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cache Demo'),
        ),
        body: const Center(
          child: Text('Press button to download...'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _downloadFile();
          },
          tooltip: 'Download',
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cache Demo')),
      body: StreamBuilder<FileResponse>(
        stream: fileStream,
        builder: (context, snapshot) {

          Widget? body;

          var loading = !snapshot.hasData || snapshot.data is DownloadProgress;

          if (snapshot.hasError) {
            body = ListTile(
              title: const Text('Error'),
              subtitle: Text(snapshot.error.toString()),
            );

          } else if (loading) {
            body = Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: (snapshot.data == null) ? null : (snapshot.data as DownloadProgress).progress,
                ),
              ),
            );

          } else {
            FileInfo fileInfo = snapshot.data as FileInfo;
            body = ListView(
              children: [
                ListTile(
                  title: const Text('Original URL'),
                  subtitle: Text(fileInfo.originalUrl),
                ),
                ListTile(
                  title: const Text('Local file path'),
                  subtitle: Text(fileInfo.file.path),
                ),
                ListTile(
                  title: const Text('Loaded from'),
                  subtitle: Text(fileInfo.source.toString()),
                ),
                ListTile(
                  title: const Text('Valid Until'),
                  subtitle: Text(fileInfo.validTill.toIso8601String()),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  // ignore: deprecated_member_use
                  child: RaisedButton(
                    child: const Text('CLEAR CACHE'),
                    onPressed: () {
                      _clearCache();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  // ignore: deprecated_member_use
                  child: RaisedButton(
                    child: const Text('REMOVE FILE'),
                    onPressed: () {
                      _removeFile();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  // ignore: deprecated_member_use
                  child: RaisedButton(
                    child: const Text('GO TO VIDEO EDITING'),
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VideoEditor(file: fileInfo.file)),
                      );

                    },
                  ),
                ),
              ],
            );
          }

          return Scaffold(
            body: body,
          );
        },
      ),
    );
  }
}
