import 'package:flutter/material.dart';
import 'package:dental_app/style/default_layouts.dart';
import 'package:dental_app/services/messaging_servic.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, String>> _chatMessages = [];
  late AnimationController _animationController;
  String _typingIndicator = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    )..addListener(() {
        setState(() {
          int step = (_animationController.value * 3).floor() % 3;
          _typingIndicator = '.' * (step + 1); // ".", "..", "..."
        });
      });

    _animationController.repeat();
  }

  void _sendMessage(String message) async {
    setState(() {
      _chatMessages.add({"role": "user", "content": message});
      _isLoading = true;
    });

    FocusScope.of(context).requestFocus(FocusNode());

    _scrollToBottom();

    setState(() {
      _chatMessages.add({"role": "assistant", "content": "typing"});
    });

    try {
      var response = await sendMessageAndGetResponse(message, _chatMessages);
      print('API Response: $response');

      setState(() {
        _chatMessages[_chatMessages.length - 1] = {
          "role": "assistant",
          "content": response
        };
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (error) {
      setState(() {
        _chatMessages
            .add({"role": "assistant", "content": "Error occurred: $error"});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI asszisztens'),
        backgroundColor: titleColor,
        titleTextStyle: titleText,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDAE2F8), Color(0xFF9D50BB)],
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatMessages.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isUserMessage = _chatMessages[index]["role"] == "user";
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color:
                              isUserMessage ? Colors.blueAccent : Colors.purple,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(10),
                        child: isUserMessage
                            ? Text(
                                _chatMessages[index]["content"]!,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )
                            : _chatMessages[index]["content"] == "typing"
                                ? Text(
                                    _typingIndicator,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  )
                                : Text(
                                    _chatMessages[index]["content"]!,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Írjon be egy üzenetet...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    iconSize: 30.0,
                    onPressed: () {
                      String message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        _sendMessage(message);
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
