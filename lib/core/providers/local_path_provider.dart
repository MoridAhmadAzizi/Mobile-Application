import 'package:file/file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalPathProvider {
  const LocalPathProvider(
    this.fs,
  );

  static const eventImagesFolder = 'eventImages';
  static const cacheFolder = 'cache';

  final FileSystem fs;

  Future<Directory> getImageStorageFolder() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    return fs.directory(documentDirectory).childDirectory(eventImagesFolder);
  }

  Future<File> getFileFromStorage(String path) async {
    final strippedPath = relativePath(path);
    final storagePath = await getImageStorageFolder();
    return storagePath.childFile(strippedPath);
  }

  String relativePath(String path) {
    final uri = Uri.parse(path);
    final startOfAbsolutePath = path.indexOf(eventImagesFolder);
    if (startOfAbsolutePath > -1) {
      return path.substring(startOfAbsolutePath + eventImagesFolder.length + 1);
    } else if (!uri.hasAbsolutePath) {
      return path;
    } else if (uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https'))) {
      {
        //Parse regular file on server
        final fileIndex = path.lastIndexOf('/');
        if (fileIndex >= 5) {
          final folderIndex = path.lastIndexOf('/', fileIndex - 1);
          if (folderIndex > -1 && (fileIndex - folderIndex) > 1) {
            final strippedPath = path.substring(folderIndex + 1);
            if (strippedPath.length >= 7 /* a/a.png */) return strippedPath;
          }
        }
      }
    }
    throw PathException('Unsupported relative path! $path');
  }
}
