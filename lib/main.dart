import 'package:dart_appwrite/dart_appwrite.dart';

/*
  'req' variable has:
    'headers' - object with request headers
    'payload' - request body data as a string
    'variables' - object with function variables

  'res' variable has:
    'send(text, status: status)' - function to return text response. Status code defaults to 200
    'json(obj, status: status)' - function to return JSON response. Status code defaults to 200
  
  If an error is thrown, a response with code 500 will be returned.
*/

Future<void> start(final req, final res) async {
  final client = Client();

  // Uncomment the services you need, delete the ones you don't
  // final account = Account(client);
  // final avatars = Avatars(client);
  final database = Databases(client);
  // final functions = Functions(client);
  // final health = Health(client);
  // final locale = Locale(client);
  // final storage = Storage(client);
  // final teams = Teams(client);
  // final users = Users(client);

  if (req.variables['APPWRITE_FUNCTION_ENDPOINT'] == null ||
      req.variables['APPWRITE_FUNCTION_API_KEY'] == null) {
    print(
        "Environment variables are not set. Function cannot use Appwrite SDK.");
  } else {
    // Init client
    client
        .setEndpoint(req.variables['APPWRITE_FUNCTION_ENDPOINT'])
        .setProject(req.variables['APPWRITE_FUNCTION_PROJECT_ID'])
        .setKey(req.variables['APPWRITE_FUNCTION_API_KEY'])
        .setSelfSigned(status: true);

    // count = sum of all deleted documents, innercount = paginated documents from appwrite
    int count = 0;
    int innercount = 0;
    // loop until innercount < 0, = database is empty
    do {
      await database
          .listDocuments(
        databaseId: req.variables['DATABASE_ID'],
        collectionId: req.variables['COLLECTION_ID'],
      )
          .then((value) {
        count = count + value.documents.length;
        innercount = value.documents.length;
        value.documents.forEach((element) {
          database.deleteDocument(
              databaseId: req.variables['DATABASE_ID'],
              collectionId: req.variables['COLLECTION_ID'],
              documentId: element.$id);
        });
        // respond occured error message, if happend
      }).onError((error, stackTrace) {
        res.json({'error': error.toString()});
      });
    } while (innercount > 0);
    // respond sum of all deleted documents
    res.json({'total documents deleted': count});
  }
}
