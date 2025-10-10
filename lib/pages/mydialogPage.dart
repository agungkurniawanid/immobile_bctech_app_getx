import 'package:lottie/lottie.dart';

class MyDialogAnimation extends StatefulWidget {
  final String type;

  MyDialogAnimation(this.type);

  @override
  _MyDialogAnimationState createState() => _MyDialogAnimationState();
}

class _MyDialogAnimationState extends State<MyDialogAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Delay the execution of _showDialogAnimation until after initState completes.
    Future.delayed(Duration.zero, () {
      _showDialogAnimation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDialogAnimation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: AlertDialog(
            content: Lottie.asset(
              widget.type == "reject"
                  ? 'data/images/reject_animation.json'
                  : 'data/images/success_animation.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                _controller.forward();

                _controller.addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    });
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // You can return any placeholder widget here
  }
}
