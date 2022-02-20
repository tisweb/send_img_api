import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import 'api.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? pickedImage;
  Uri url = Uri.parse('http://10.0.2.2:5000/verify?Query=103/103_1_1.jpg');
  var data;
  Dio dio = new Dio();
  XFile? _imageFile;
  String state = "";

  String responseDate = "";
  Future _pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.camera);
    if (imageFile == null) {
      return null;
    }

    setState(() {
      pickedImage = File(imageFile.path);
      _imageFile = imageFile;
    });
  }

  upload(File imageFile) async {
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("http://10.0.2.2:5000/upload");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  Future<Map> _avatarSubmit() async {
    List<int> imageBytes = pickedImage!.readAsBytesSync();
    String base64Image = base64.encode(imageBytes);

    var uri = Uri.parse("http://10.0.2.2:5000/upload");
    http.Response response = await http.post(uri, headers: {
      "Accept": "application/json",
      "Content-type": "multipart/form-data",
    }, body: {
      "file": base64Image,
    });
    Map content = json.decode(response.body);
    return content;
  }

  uploadImage(String title, File file) async {
    var request =
        http.MultipartRequest("POST", Uri.parse("http://10.0.2.2:5000/upload"));

    request.fields['title'] = "dummyImage";
    request.headers['Authorization'] = "Client-ID " + "f7........";

    var picture = http.MultipartFile.fromBytes('image',
        (await rootBundle.load('assets/testimage.png')).buffer.asUint8List(),
        filename: 'testimage.png');

    request.files.add(picture);

    var response = await request.send();

    var responseData = await response.stream.toBytes();

    var result = String.fromCharCodes(responseData);

    print(result);
  }

  // _dioUploadImage() async {
  //   var formData = FormData.fromMap({
  //     'file': await MultipartFile.fromFile(basename(_imageFile!.path),
  //         filename: 'file'),
  //   });
  //   var response = await dio
  //       .postUri(url,
  //           data: formData,
  //           options: Options(
  //               method: 'POST',
  //               responseType: ResponseType.json // or ResponseType.JSON
  //               ))
  //       .then((response) => print(response))
  //       .catchError((error) => print(error));
  //   // FormData formData = new FormData();
  //   // formData.files.add("filename": 'testimage.png', new http.MultipartFile(field, stream, length)(imageFile, basename(imageFile!.path)));
  //   // dio
  //   //     .postUri(url,
  //   //         data: formdata,
  //   //         options: Options(
  //   //             method: 'POST',
  //   //             responseType: ResponseType.json // or ResponseType.JSON
  //   //             ))
  //   //     .then((response) => print(response))
  //   //     .catchError((error) => print(error));
  // }

  // Methode for file upload
  // void _uploadFile(filePath) async {
  //   // Get base file name
  //   String fileName = basename(filePath.path);
  //   print("File base name: $fileName");

  //   try {
  //     FormData formData =
  //         new FormData.from({"file": new UploadFileInfo(filePath, fileName)});

  //     Response response =
  //         await Dio().post("http://10.0.2.2:5000/upload", data: formData);
  //     print("File upload response: $response");

  //     // Show the incoming message in snakbar
  //     print(response.data['message']);
  //   } catch (e) {
  //     print("Exception Caught: $e");
  //   }
  // }

  // Method for showing snak bar message
  // void _showSnakBarMsg(String msg) {
  //   _scaffoldstate.currentState
  //       .showSnackBar(new SnackBar(content: new Text(msg)));
  // }

  Future<String?> uploadImage1(filename) async {
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', filename));
    var res = await request.send();
    return res.reasonPhrase;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            OutlinedButton(
              onPressed: () async {
                await _pickImage();
              },
              child: Text("Take a Photo"),
            ),
            if (pickedImage != null)
              Container(
                width: 100,
                height: 100,
                child: Image.file(
                  pickedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () async {
                    data = await getData(url);
                    print("check1");
                    var decodedData = json.decode(data);
                    print("check2");
                    setState(() {
                      responseDate = decodedData['Query'];
                      print(responseDate);
                    });
                  },
                  child: Text("Register Iris"),
                ),
                OutlinedButton(
                  onPressed: () async {
                    // uploadImage1(_imageFile!.path);
                    var res = await uploadImage1(_imageFile!.path);
                    setState(() {
                      state = res!;
                      print(res);
                    });
                    // _avatarSubmit();
                    // _uploadFile(_imageFile);
                  },
                  child: Text("Verify Iris"),
                ),
              ],
            ),
            Text(
              responseDate,
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
