# *Your game here*

## godot-game-template

A minimal template for Godot games. Works with 2D and 3D games.

## Features

### Single- und Multilevel Betrieb
Das Template kann über Einstellungen in `Gamemanager` entweder ein einzelnes oder eine Folge von Levels laden. Dabei ist es egal, ob es 2D oder 3D Levels sind, solange sie über ein `win()`-Signal Bescheid geben, wann sie vervollständigt wurden. Wenn man eine Folge an Levels verwendet (wie in Super Mario) können diese hintereinander geladen werden, solange sie eine einheitliche Namenskonvention mit aufsteigenden Levelzahlen haben. Zum Beispiel `level_1.tscn`, `level_2.tscn`, ...

### Settings und Input Remapping
Mithilfe des `Settings`-Autoloads können einfach neue Einstellungen hinzugefügt werden (siehe Setting-Klasse), pro Setting kann ein Callback definiert werden, welches eine Änderung der entsprechenden Einstellung behandelt (z.B. Grafikvoreinstellung geändert -> Update alle Viewports). Das Settings-System hat auch eingebaute Unterstützung für Input-Remapping (2 Slots pro Action). Das Template kommt mit einem Einstellungsmenü, worüber die Zuweisung während der Laufzeit dynamisch geändert werden kann; dabei werden alle Inputs unterstützt, die Godot kennt. Häufig benötigte Einstellungen wie Vollbild-Modus, Lautstärke, etc. sind bereits vorhanden

### Umfangreicher Credit Screen
Die Inhalte des Credit-Screens werden aus `credits.json` eingelesen. Dort kann Name, Beschreibung, Lizenz und URL eines Assets angegeben werden. Standardmäßig sorgt der Credit Screen nicht nur dafür, dass die MIT Lizenz dieses Templates von darauf basierenden eingehalten wird, sondern er erfüllt (nach bestem Wissen) auch die Bedingungen zum crediten von Godot selbst.

### Optionale Tests inklusive GitHub Action
Im `with-tests`-Branch ist GdUnit4 aufgesetzt inclusive eines kleinen Tests, der testet, ob der zentrale Gamemanager gestartet werden kann. Zusätzlich enthält dieser Branch auch eine bereits aufgesetzte GitHub Action, die alle Tests mit jedem Commit ausführt. So wird es schnell ersichtlich, ob die aktuellste Version des Spiels überhaupt ausführbar ist.

### Ingame Debug Panel
Um wichtige Werte immer im Augenwinkel zu haben verfügt das Template über eine Debug Anzeige in der linken oberen Ecke. Über das `DebugGlobal`können Werte zur Debug Anzeige hinzugefügt werden. Die Sichtbarkeit kann über die, in der InputMap bereits definierten, `toggle_debug_label`-Action getoggelt werden.

### Spiel pausieren
Wenn die `pause`-Action der InputMap in einem Level ausgeführt wird, wird ein Pausemenü angezeigt, indem das Level beendet, -fortgeführt, oder Einstellungen angepasst werden. Wenn der `ProcessMode` der Levels auf "Pausable" gesetzt ist, werden die Aktivitäten im Level mitpausiert, solange das Pausemanü angezeigt wird.
