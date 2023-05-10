import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utills/utills.dart';
import '../auth/login_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance.reference();
  final _picker = ImagePicker();

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF3a5f6f);
  static const Color color3 = Color(0xff89a7b1);
  static const Color color4 = Color(0xFFe8eaf2);

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();

  bool _isEditing = false;

  String? _email;
  String? _fullName;
  File? _image;
  String? _companyName;
  String? _companyAddress;
  String? _contactNumber;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<String?> _uploadImage(File? image) async {
    if (image == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(auth.currentUser!.uid)
        .child('profile.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'userId': auth.currentUser!.uid,
      },
    );

    final uploadTask = ref.putFile(image, metadata);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> _loadUserData() async {
    final user = auth.currentUser;
    if (user != null) {
      final query = database.child('users').child(user.uid);
      query.onValue.listen((event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          final userData =
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
          setState(() {
            _email = userData['email'];
            _fullName = userData['fullName'];
            _companyName = userData['companyName'];
            _companyAddress = userData['companyAddress'];
            _contactNumber = userData['contactNumber'];

          });
        }
      }, onError: (error) {
        Utills().toastMessage(error.toString());
      });
    }
  }

  Future<void> _saveUserData() async {
    final user = auth.currentUser;
    if (user != null) {
      final query = database.child('users').child(user.uid);
      final imageUrl = await _uploadImage(_image);
      await query.update({
        'fullName': _fullNameController.text,
        'companyName': _companyNameController.text,
        'companyAddress': _companyAddressController.text,
        'contactNumber': _contactNumberController.text,
        'imageUrl': imageUrl,
      }).then((value) {
        setState(() {
          _isEditing = false;
          _fullName = _fullNameController.text;
          _companyName = _companyNameController.text;
          _companyAddress = _companyAddressController.text;
          _contactNumber = _contactNumberController.text;
          _image = null;
        });
        Utills().toastMessage('Профиль успешно обновлен');
      }).catchError((error) {
        Utills().toastMessage(error.toString());
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: color1,
        automaticallyImplyLeading: false,
        title: const Text('Жеке кабинет'),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }).onError((error, stackTrace) {
                Utills().toastMessage(error.toString());
              });
            },
            icon: const Icon(Icons.logout_outlined),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          SizedBox(height: 30),
          _buildAvatar(),
          SizedBox(height: 30),
          _buildUserInfo(),
          SizedBox(height: 35),
          _buildCompanyInfo(),
          SizedBox(height: 15),
          Card(
            margin: EdgeInsets.all(20),
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                Center(child: Text("Құрушы туралы ақпарат",style: TextStyle( fontSize: 17,fontWeight: FontWeight.w400))),
                SizedBox(height: 15),
                Container(
                    padding: const EdgeInsets.all(9.0),
                    alignment: Alignment.centerLeft,
                    child: Text("Әзірлеген: Salimbay Beibars",style: TextStyle( fontSize: 15,fontWeight: FontWeight.w400)),
                ),
                Container(
                  padding: const EdgeInsets.all(9.0),
                  alignment: Alignment.centerLeft,
                  child: Text("Байланыс нөмері: 87770552001",style: TextStyle( fontSize: 15,fontWeight: FontWeight.w400)),
                ),
                Container(
                  padding: const EdgeInsets.all(9.0),
                  alignment: Alignment.centerLeft,
                  child: Text("Барлық авторлық құқықтар қорғалған ©",style: TextStyle( fontSize: 15,fontWeight: FontWeight.w400)),
                ),
              ],
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        backgroundColor: color4,
        radius: 60,
        backgroundImage: _image != null ? FileImage(_image!) : null,
        child: _image == null ? Icon(Icons.person, size: 60, color: color1,) : null,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF13588F),
              Color(0xFF13588F),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(1, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.person,  color: Colors.white,),
              title: _isEditing
                  ? TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'Қолданушың аты',
                ),
              )
                  : Text(_fullName ?? 'Қолданушың аты', style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.w600,)),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Colors.white,),
              title: Text(_email ?? 'Email', style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.w600)),
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildCompanyInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDAE6F1),
              Color(0xffc5d9e1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(1, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.business),
              title: _isEditing
                  ? TextField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  hintText: 'Компания аты',
                ),
              )
                  : Text(_companyName ?? 'Компания аты'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.location_on),
              title: _isEditing
                  ? TextField(
                controller: _companyAddressController,
                decoration: const InputDecoration(
                  hintText: 'Компания мекен-жайы',
                ),
              )
                  : Text(_companyAddress ?? 'Компания мекен-жайы'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone),
              title: _isEditing
                  ? TextField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  hintText: 'Байланыс телефон нөмрі',
                ),
              )
                  : Text(_contactNumber ?? 'Байланыс телефон нөмрі'),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isEditing)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        child: Text('Артқа'),
                      ),
                      TextButton(
                        onPressed: () {
                          _saveUserData();
                        },
                        child: Text('Сақтау'),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    label: Text('Өзгертулер еңгізу'),
                    style: ElevatedButton.styleFrom(
                        primary: color1,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },


                  ),

              ],
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );


  }
}