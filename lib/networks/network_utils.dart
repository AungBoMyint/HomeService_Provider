import 'dart:convert';
import 'dart:io';

import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/google_places_model.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

Map<String, String> buildHeaderTokens({
  bool isStripePayment = false,
  bool isFlutterWave = false,
  String? flutterWaveSecretKey,
  String? stripeKeyPayment,
  bool isSadadPayment = false,
  String sadadToken = '',
}) {
  Map<String, String> header = {
    HttpHeaders.cacheControlHeader: 'no-cache',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
  };

  if (appStore.isLoggedIn && isStripePayment) {
    header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/x-www-form-urlencoded');
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer $stripeKeyPayment');
  } else if (appStore.isLoggedIn && isFlutterWave) {
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => "Bearer $flutterWaveSecretKey");
  } else if (appStore.isLoggedIn && isSadadPayment) {
    header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json');
    if (sadadToken.validate().isNotEmpty) header.putIfAbsent(HttpHeaders.authorizationHeader, () => sadadToken);
  } else {
    header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json; charset=utf-8');
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer ${appStore.token}');
    header.putIfAbsent(HttpHeaders.acceptHeader, () => 'application/json; charset=utf-8');
  }

  log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);
  if (!endPoint.startsWith('http')) url = Uri.parse('$BASE_URL$endPoint');

  log('URL: ${url.toString()}');

  return url;
}

Future<Response> buildHttpResponse(
  String endPoint, {
  HttpMethod method = HttpMethod.GET,
  Map? request,
  String? flutterWaveSecretKey,
  String? stripeKeyPayment,
  bool isStripePayment = false,
  bool isFlutterWave = false,
  bool isSadadPayment = false,
  String sadadToken = "",
}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens(
      isStripePayment: isStripePayment,
      flutterWaveSecretKey: flutterWaveSecretKey,
      stripeKeyPayment: stripeKeyPayment,
      isFlutterWave: isFlutterWave,
      isSadadPayment: isSadadPayment,
      sadadToken: sadadToken,
    );
    Uri url = buildBaseUrl(endPoint);

    Response response;

    if (method == HttpMethod.POST) {
      log('Request: ${jsonEncode(request)}');
      response = await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethod.DELETE) {
      response = await delete(url, headers: headers);
    } else if (method == HttpMethod.PUT) {
      response = await put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await get(url, headers: headers);
    }

    log('Response (${method.name}) ${response.statusCode}: ${response.body}');

    return response;
  } else {
    throw errorInternetNotAvailable;
  }
}

Future handleResponse(Response response, [bool? avoidTokenError, bool? isSadadPayment]) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }
  if (response.statusCode == 401) {
    if (!avoidTokenError.validate()) LiveStream().emit(LIVESTREAM_TOKEN, true);
    push(SignInScreen(isRegeneratingToken: true), isNewTask: true);
    throw '${languages!.lblTokenExpired}';
  }

  if (response.statusCode.isSuccessful()) {
    return jsonDecode(response.body);
  } else {
    if (isSadadPayment.validate()) {
      try {
        var body = jsonDecode(response.body);
        throw parseHtmlString(body['error']['message']);
      } on Exception catch (e) {
        log(e);
        throw errorSomethingWentWrong;
      }
    } else {
      try {
        var body = jsonDecode(response.body);
        throw parseHtmlString(body['message']);
      } on Exception catch (e) {
        log(e);
        throw errorSomethingWentWrong;
      }
    }
  }
}

Future<MultipartRequest> getMultiPartRequest(String endPoint, {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  return MultipartRequest('POST', Uri.parse(url));
}

Future<void> sendMultiPartRequest(MultipartRequest multiPartRequest, {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  http.Response response = await http.Response.fromStream(await multiPartRequest.send());

  log('response : ${response.body}');

  if (response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      onSuccess?.call(response.body);
    } else {
      onSuccess?.call(response.body);
    }
  } else {
    onError?.call(errorSomethingWentWrong);
  }
}

//region Common
enum HttpMethod { GET, POST, DELETE, PUT }
//endregion

//region Google Maps
Future<List<GooglePlacesModel>> getSuggestion(String input) async {
  String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  String request = '$baseURL?input=$input&key=$GOOGLE_MAPS_API_KEY&sessiontoken=${appStore.token}';

  var response = await buildHttpResponse(request);

  if (response.statusCode == 200) {
    Iterable it = jsonDecode(response.body)['predictions'];
    return it.map((e) => GooglePlacesModel.fromJson(e)).toList().validate();
  } else {
    throw Exception('${languages!.lblFailedToLoadPredictions}');
  }
}
//endregion
