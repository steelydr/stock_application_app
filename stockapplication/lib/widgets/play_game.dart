import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayGame extends StatefulWidget {
  final String symbol;
  final Map<String, dynamic>? userData;

  const PlayGame({
    Key? key,
    required this.symbol,
    this.userData,
  }) : super(key: key);

  @override
  _PlayGameState createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayGame> with SingleTickerProviderStateMixin {
  final TextEditingController _predictionController = TextEditingController();
  bool _isGameStarted = false;
  bool _isGamePlayed = false;
  String? _message;
  bool _isLoading = false;
  late SharedPreferences _prefs;

  double _initialOpacity = 0.0;
  double _messageOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _initialOpacity = 1.0;
      });
    });
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadGameState();
  }

  void _loadGameState() {
    final String gameKey = _getGameKey();
    setState(() {
      _isGamePlayed = _prefs.getBool('${gameKey}_played') ?? false;
      _isGameStarted = _prefs.getBool('${gameKey}_started') ?? false;
      final savedPrediction = _prefs.getString('${gameKey}_prediction');
      if (savedPrediction != null) {
        _predictionController.text = savedPrediction;
      }
      _message = _prefs.getString('${gameKey}_message');
      _messageOpacity = _message != null ? 1.0 : 0.0;
    });
  }

  String _getGameKey() {
    final email = widget.userData?['email'] ?? 'Guest';
    return '${email}_${widget.symbol}_${DateTime.now().toIso8601String().split('T')[0]}';
  }

  Future<void> _saveGameState({
    bool? isPlayed,
    bool? isStarted,
    String? prediction,
    String? message,
  }) async {
    final String gameKey = _getGameKey();

    if (isPlayed != null) {
      await _prefs.setBool('${gameKey}_played', isPlayed);
    }
    if (isStarted != null) {
      await _prefs.setBool('${gameKey}_started', isStarted);
    }
    if (prediction != null) {
      await _prefs.setString('${gameKey}_prediction', prediction);
    }
    if (message != null) {
      await _prefs.setString('${gameKey}_message', message);
    }
  }

  @override
  void dispose() {
    _predictionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
      _messageOpacity = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _messageOpacity = 1.0;
      });
    });
    _saveGameState(message: message);
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
    });
    _saveGameState(isStarted: true);
  }

  void submitPrediction() async {
    if (_predictionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a prediction'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
      _messageOpacity = 0.0;
    });

    // Save the prediction immediately when submitted
    await _saveGameState(prediction: _predictionController.text);

    final email = widget.userData?['email'] ?? 'Guest';
    final symbol = widget.symbol;
    final userPrediction = _predictionController.text;

    final mutation = """
      mutation RecordGame(\$email: String!, \$symbol: String!, \$userPrediction: String!) {
        recordGame(email: \$email, symbol: \$symbol, userPrediction: \$userPrediction) {
          won
          coinsEarned
        }
      }
    """;

    final client = GraphQLProvider.of(context).value;
    client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'email': email,
          'symbol': symbol,
          'userPrediction': userPrediction,
        },
        onCompleted: (dynamic resultData) async {
          if (resultData != null) {
            final response = resultData['recordGame'];
            String message;
            if (response['won'] == false && response['coinsEarned'] == 0) {
              message = 'Results are not yet released.';
            } else if (response['coinsEarned'] == 200) {
              message = '🏆 Excellent! You beat the AI!';
            } else if (response['coinsEarned'] == 100) {
              message = '🎯 Great job! You matched the AI!';
            } else if (response['coinsEarned'] == -10) {
              message = '📊 Keep trying! The AI won this round.';
            } else {
              message = 'Unexpected result.';
            }
            _showMessage(message);
          } else {
            _showMessage('Failed to fetch results.');
          }

          setState(() {
            _isLoading = false;
            _isGamePlayed = true;
            _isGameStarted = false;
          });

          await _saveGameState(
            isPlayed: true,
            isStarted: false,
          );
        },
        onError: (error) {
          _showMessage('An error occurred: ${error.toString()}');
          setState(() {
            _isLoading = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.05),
              Colors.purple.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              color: Colors.grey[900],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isGamePlayed)
                        if (!_isGameStarted)
                          AnimatedOpacity(
                            opacity: _initialOpacity,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 48,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Predict ${widget.symbol}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Challenge the AI and predict the next market move!',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _startGame,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: const [Colors.blue, Colors.purpleAccent],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Start Predicting',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              Text(
                                widget.symbol,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _predictionController,
                                decoration: InputDecoration(
                                  labelText: 'Your Prediction',
                                  labelStyle: TextStyle(color: Colors.grey[300]),
                                  hintText: 'Enter a number',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: Icon(Icons.analytics, color: Colors.grey[300]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : submitPrediction,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: const [Colors.blue, Colors.purpleAccent],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Submit Prediction',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      if (_isGamePlayed && !_isLoading)
                        Column(
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              'You have already played this game.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      if (_message != null) ...[
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          opacity: _messageOpacity,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey[700]!),
                            ),
                            child: Text(
                              _message!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}