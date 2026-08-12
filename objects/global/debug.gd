extends Node


enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
}

enum Verbosity {
	BRIEF,
	CALLER,
	STACK,
}

const LEVEL := Level.DEBUG


func debug(message: String, verbosity := Verbosity.BRIEF) -> void:
	if Debug.LEVEL <= Level.DEBUG:
		_print_message(message, verbosity, 'DEBUG', Color.CORNFLOWER_BLUE, Color.CORNFLOWER_BLUE.lightened(0.4))


func info(message: String, verbosity := Verbosity.BRIEF) -> void:
	if Debug.LEVEL <= Level.INFO:
		_print_message(message, verbosity, 'INFO', Color.PALE_GREEN, Color.PALE_GREEN.lightened(0.4))


func warning(message: String, verbosity := Verbosity.BRIEF) -> void:
	if Debug.LEVEL <= Level.WARNING:
		_print_message(message, verbosity, 'WARNING', Color.ORANGE, Color.ORANGE.lightened(0.4))


func error(message: String, verbosity := Verbosity.BRIEF) -> void:
	if Debug.LEVEL <= Level.ERROR:
		_print_message(message, verbosity, 'ERROR', Color.ORANGE_RED, Color.ORANGE_RED.lightened(0.2))


func _print_message(message: String, verbosity := Verbosity.BRIEF, tag: String = 'DEBUG', message_color := Color.WHITE, trace_color := Color.WHITE) -> void:
	print_rich('[color=%s][b]• [%s][/b] %s[/color]' % [message_color.to_html(false), tag, message])
	_attach_stack_trace(verbosity, trace_color)


func _attach_stack_trace(verbosity := Verbosity.BRIEF, color := Color.WHITE) -> void:
	var stack: Array[Dictionary] = get_stack()
	stack.reverse()
	
	match verbosity:
		Verbosity.CALLER:
			print_rich('  [color=%s][i]from[/i] [b]%s[/b]:[i]%d[/i]  (%s)[/color]' % [
				color.to_html(false), stack[0]['function'], stack[0]['line'], stack[0]['source'].split('/')[-1]
			])
		
		Verbosity.STACK:
			for caller: Dictionary in stack:
				print_rich('  [color=%s][i]from[/i] [b]%s[/b]:[i]%d[/i]  (%s)[/color]' % [
					color.to_html(false), caller['function'], caller['line'], caller['source'].split('/')[-1]
				])
