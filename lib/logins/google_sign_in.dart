import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final _firestore = Firestore.instance;


Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();
  print("User Sign Out");
}
Future<bool> isUserInTheFirestore() async{
  final FirebaseUser currentUser = await _auth.currentUser();
  final uid= currentUser.uid;
  final userSnapShots = await _firestore.collection('users').getDocuments();
  var result = false;
    for (var user in userSnapShots.documents) {
      String userUID = user.data['uid'];
      if (userUID == uid) {
        result = true;
      }
    }
   return result;

}
