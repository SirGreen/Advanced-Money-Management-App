import 'package:flutter/material.dart';

class PinInputWidget extends StatefulWidget {
  final Function(String) onCompleted;
  final VoidCallback? onBiometric;
  final bool isCreatePin;

  const PinInputWidget({
    super.key,
    required this.onCompleted,
    this.onBiometric,
    this.isCreatePin = false,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  String _pin = "";

  void _onTap(String value) {
    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {
        widget.onCompleted(_pin);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _pin = "");
        });
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
                color: index < _pin.length
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
            );
          }),
        ),
        if (!widget.isCreatePin) const SizedBox(height: 50),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            ...List.generate(9, (i) => _buildNumberButton('${i + 1}')),
            widget.onBiometric != null
                ? IconButton(
                    icon: const Icon(Icons.fingerprint),
                    iconSize: 36,
                    onPressed: widget.onBiometric,
                    tooltip: "Use Biometrics",
                  )
                : Container(),
            _buildNumberButton('0'),
            IconButton(
              icon: const Icon(Icons.backspace_outlined),
              onPressed: _onBackspace,
              tooltip: "Backspace",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String value) {
    return OutlinedButton(
      onPressed: () => _onTap(value),
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Text(value, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
