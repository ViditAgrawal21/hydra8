import 'dart:math';

import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class Progress extends StatefulWidget {
  final int intakeAmount;
  final int todaysAmount;
  final int prevAmount;
  final int prevIntake;
  final String activeUnit;

  const Progress(
      {required this.prevIntake,
      required this.activeUnit,
      required this.intakeAmount,
      required this.todaysAmount,
      required this.prevAmount,
      super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Tween<double> valueTween;
  late Animation<double> curve;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    valueTween = Tween<double>(
      begin: 0,
      end: widget.todaysAmount / widget.intakeAmount,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(Progress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.todaysAmount / widget.intakeAmount !=
        oldWidget.todaysAmount / oldWidget.intakeAmount) {
      // Try to start with the previous tween's end value. This ensures that we
      // have a smooth transition from where the previous animation reached.
      double beginValue = valueTween.evaluate(curve);

      // Update the value tween.
      valueTween = Tween<double>(
        begin: beginValue,
        end: widget.todaysAmount / widget.intakeAmount,
      );

      _animationController
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    int usePrevIntake =
        widget.prevIntake > 0 ? widget.prevIntake : widget.intakeAmount;
    return AnimatedBuilder(
      animation: curve,
      builder: (BuildContext context, _) {
        return Container(
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.07),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(0, 10))
            ], borderRadius: BorderRadius.circular(1000)),
            margin: const EdgeInsets.all(30.0),
            child: LiquidCircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              /* borderColor: Colors.black12,
              borderWidth: 1, */
              backgroundColor: isDarkTheme
                  ? Theme.of(context).colorScheme.surface
                  : Colors.white,
              value: valueTween.evaluate(curve),
              center: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 85,
                        child: Countup(
                          begin:
                              min(widget.prevAmount / usePrevIntake * 100, 100),
                          end: min(
                              widget.todaysAmount / widget.intakeAmount * 100,
                              100),
                          duration: const Duration(milliseconds: 800),
                          style: TextStyle(
                              color: widget.todaysAmount >=
                                          widget.intakeAmount ||
                                      isDarkTheme
                                  ? Colors.white
                                  : const Color.fromARGB(255, 152, 224, 255),
                              fontSize: 64,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "%",
                        style: TextStyle(
                            fontSize: 30,
                            color: widget.todaysAmount >= widget.intakeAmount ||
                                    isDarkTheme
                                ? Colors.white
                                : const Color.fromARGB(255, 152, 224, 255),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.todaysAmount.toString(),
                        style: TextStyle(
                            color:
                                isDarkTheme ? Colors.white54 : Colors.black26,
                            fontSize: 17),
                      ),
                      Text(
                        ' / ${widget.intakeAmount.toString()}${widget.activeUnit}',
                        style: TextStyle(
                            fontSize: 17,
                            color:
                                isDarkTheme ? Colors.white54 : Colors.black26),
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }
}
