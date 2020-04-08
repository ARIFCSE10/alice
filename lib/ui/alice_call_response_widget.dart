import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_base_call_details_widget.dart';

class AliceCallResponseWidget extends StatefulWidget {
  final AliceHttpCall call;

  AliceCallResponseWidget(this.call);

  @override
  State<StatefulWidget> createState() {
    return _AliceCallResponseWidgetState();
  }
}

class _AliceCallResponseWidgetState
    extends AliceBaseCallDetailsWidgetState<AliceCallResponseWidget> {
  static const _kImageContentType = "image";
  static const _kVideoContentType = "video";
  static const _kLargeOutputSize = 100000;
  bool _showLargeBody = false;

  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List();
    if (!_call.loading) {
      rows.addAll(_buildGeneralDataRows());
      rows.addAll(_buildHeadersRows());
      rows.addAll(_buildBodyRows());

      return Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListView(children: rows));
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new CircularProgressIndicator(),
          Text("Awaiting response...")
        ],
      ));
    }
  }


  List<Widget> _buildGeneralDataRows() {
    List<Widget> rows = List();
    rows.add(getListRow("Received:", _call.response.time.toString()));
    rows.add(getListRow("Bytes received:", formatBytes(_call.response.size)));

    var status = _call.response.status;
    var statusText = "$status";
    if (status == -1) {
      statusText = "Error";
    }

    rows.add(getListRow("Status:", statusText));
    return rows;
  }

  List<Widget> _buildHeadersRows() {
    List<Widget> rows = List();
    var headers = _call.response.headers;
    var headersContent = "Headers are empty";
    if (headers != null && headers.length > 0) {
      headersContent = "";
    }
    rows.add(getListRow("Headers: ", headersContent));
    if (_call.response.headers != null) {
      _call.response.headers.forEach((header, value) {
        rows.add(getListRow("   • $header:", value.toString()));
      });
    }
    return rows;
  }

  List<Widget> _buildBodyRows() {
    List<Widget> rows = List();
    if (_isImageResponse()) {
      rows.addAll(_buildImageBodyRows());
    } else if (_isVideoResponse()) {
      rows.addAll(_buildVideoBodyRows());
    } else if (_isLargeResponseBody()) {
      rows.addAll(_buildLargeBodyTextRows());
    } else {
      rows.addAll(_buildTextBodyRows());
    }
    return rows;
  }

  List<Widget> _buildImageBodyRows() {
    List<Widget> rows = List();
    rows.add(
      Column(
        children: [
          Row(
            children: [
              Text(
                "Body: Image",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Image.network(
            _call.uri,
            fit: BoxFit.fill,
            headers: _buildRequestHeaders(),
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
    return rows;
  }

  List<Widget> _buildLargeBodyTextRows() {
    List<Widget> rows = List();
    if (_showLargeBody) {
      return _buildTextBodyRows();
    } else {
      rows.add(getListRow("Body:",
          "Too large to show (${_call.response.body.toString().length} Bytes)"));
      rows.add(
        RaisedButton(
          child: Text("Show body"),
          onPressed: () {
            setState(() {
              _showLargeBody = true;
            });
          },
        ),
      );
      rows.add(Text("Warning! It will take some time to render output."));
    }
    return rows;
  }

  List<Widget> _buildVideoBodyRows() {
    List<Widget> rows = List();
    rows.add(Center(child: Text("Video")));
    return rows;
  }

  List<Widget> _buildTextBodyRows() {
    List<Widget> rows = List();
    var headers = _call.response.headers;
    var bodyContent = formatBody(_call.response.body, getContentType(headers));
    rows.add(getListRow("Body:", bodyContent));
    return rows;
  }

  Map<String, String> _buildRequestHeaders() {
    Map<String, String> requestHeaders = Map();
    if (_call?.request?.headers != null) {
      requestHeaders.addAll(
        _call.request.headers.map(
          (String key, dynamic value) {
            return MapEntry(key, value.toString());
          },
        ),
      );
    }
    return requestHeaders;
  }

  bool _isImageResponse() {
    return _getContentTypeOfResponse()
        .toLowerCase()
        .contains(_kImageContentType);
  }

  bool _isVideoResponse() {
    return _getContentTypeOfResponse()
        .toLowerCase()
        .contains(_kVideoContentType);
  }

  String _getContentTypeOfResponse() {
    return getContentType(_call.response.headers);
  }

  bool _isLargeResponseBody() {
    return _call.response.body != null &&
        _call.response.body.toString().length > _kLargeOutputSize;
  }
}
