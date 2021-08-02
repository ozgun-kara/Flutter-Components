import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

const Duration _kExpand = Duration(milliseconds: 200);

///    <https://material.io/guidelines/components/lists-controls.html>.
class ExpansionCard extends StatefulWidget {

 const ExpansionCard({

    Key key,
    this.leading,
    @required this.title,
    this.gif,
	this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.color,
    this.backgroundColor,
	this.initiallyExpanded = false,

  }) : assert(initiallyExpanded != null),
        super(key: key);

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;
  
    final String gif;
  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget leading;

  /// Called when the tile expands or collapses.
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool> onExpansionChanged;

  /// The color to display behind the sublist when expanded.
  final Color backgroundColor;

  /// The widgets that are displayed when the tile expands.
  /// Typically [ListTile] widgets.
  final List<Widget> children;


  /// A widget to display instead of a rotating arrow icon.
  final Widget trailing;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;
  
  /// Color of the title bar and icon in the expanded state.
  final Color color;

  @override
  _ExpansionTileState createState() => _ExpansionTileState();
}

class _ExpansionTileState extends State<ExpansionCard> with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween = CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();


    AnimationController _controller;
    Animation<double> _iconTurns;
    Animation<Color> _iconColor;
	Animation<double> _heightFactor;

  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
	_borderColor = _controller.drive(_borderColorTween.chain(_easeOutTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor = _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded)
      _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted)
            return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged(_isExpanded);
  }


  Widget _buildChildren(BuildContext context, Widget child) {
    final Color borderSideColor =Colors.transparent;// _borderColor.value ??

        return Stack(children: <Widget>[
    
          ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: Align(
              heightFactor: _heightFactor.value<0.5?0.5:_heightFactor.value,
              child: Image.asset(
                widget.gif,fit: BoxFit.cover,
          ),
        ),
      ),
      Container(
		decoration: BoxDecoration(
          color: _backgroundColor.value ?? Colors.transparent,
          border: Border(
            top: BorderSide(color: borderSideColor),
            bottom: BorderSide(color: borderSideColor),
          ),
        ),

		
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTileTheme.merge(
                iconColor: _iconColor.value,
                textColor: _headerColor.value,
                child: Container(margin: EdgeInsets.only(top: 55),
                  child:ListTile(
                    onTap: _handleTap,
                    leading: widget.leading,
                    title: widget.title,
                    trailing: widget.trailing ?? RotationTransition(
                      turns: _iconTurns,
                      child: const Icon(Icons.expand_more),
                    ),
                  ),)
            ),
            ClipRect(
              child: Align(
                heightFactor: _heightFactor.value,
                child: child,
              ),
            ),
          ],
        ),
      )
    ],);
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _borderColorTween
      ..end = theme.dividerColor;
    _headerColorTween
      ..begin = Colors.white
      ..end = widget.color ?? Color(0xff60c9df);
    _iconColorTween
      ..begin = Colors.white
      ..end = widget.color ?? Color(0xff60c9df);
    _backgroundColorTween
      ..end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    
	return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );

  }
}

 
