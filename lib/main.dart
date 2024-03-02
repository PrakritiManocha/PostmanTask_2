import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);
const messageLimit = 30;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    print(e);
    print(st);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final DateFormat formatter = DateFormat('MM/dd HH:mm:SS');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Enter a new message',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 16),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: ElevatedButton(
                  onPressed: _handleSignIn,
                  child: Text('Sign in with Google'),
                ),
              ),
              const SizedBox(height: 16),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your message and hit Enter',
                  ),
                  onSubmitted: (String value) {
                    FirebaseFirestore.instance.collection('chat').add(
                      {
                        'message': value,
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat')
                      .orderBy('timestamp', descending: true)
                      .limit(messageLimit)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    var docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          leading: DefaultTextStyle.merge(
                            style: const TextStyle(color: Colors.indigo),
                            child: Text(formatter.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                docs[i]['timestamp'],
                              ),
                            )),
                          ),
                          title: Text('${docs[i]['message']}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        print('Google sign-in failed');
      }
    } catch (error) {
      print('Google sign-in error: $error');
    }
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
        apiKey: "AIzaSyAhE5iTdU1MflQxb4_M_uHiXJR9EC_mE_I",
        authDomain: "nanochat.firebaseapp.com",
        projectId: "firebase-nanochat",
        messagingSenderId: '137230848633',
        appId: '1:137230848633:web:89e9b54f881fa0b843baa8');
  }
}
