#cs ----------------------------------------------------------------------------
 AutoIt Version: 3.3.12.0
 Author:         myName
 Script Function:
	Template AutoIt script.
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <Array.au3>
;#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>

; Set various variables
Global $height = 11
Global $width = 11
Global $grid_size = $height * $width
Local $grid_pixel = 40 ;How many pixels per square


; Check if width & height are an odd number (to get the outer edge an odd number is required)
If mod($height, 2) = 0 Then
   msgbox(0,"","Height is not an odd number!")
   Exit
EndIf

If mod($width, 2) = 0 Then
   msgbox(0,"","Width is not an odd number!")
   Exit
EndIf

; Initialize the grid-array
;Local $grid[$grid_size + 1]
;$grid[0] = $grid_size

; Initialize grid coords, contains: 0=GUI-id, 1=row, 2=column
Global $xy[$grid_size + 1][5]
$xy[0][0] = $grid_size ; the rest of the rows contain the GUI-ID
$xy[0][1] = "ID"
$xy[0][2] = "Row"
$xy[0][3] = "Column"
$xy[0][4] = "Type"

; Fill the grid array with 'walls'
For $i = 1 To $xy[0][0]
   $xy[$i][4] = "x"
Next

; Start GUI and create standard buttons
Local $gui = GUICreate("Field", 200 + $width * $grid_pixel, 100 + $height * $grid_pixel) ; title, width, height
GUICtrlCreateLabel("This is a-maze-ing!", 30, 10)
Local $iOKButton = GUICtrlCreateButton("OK", 70, 50, 60)
;Local $iResetButton = GUICtrlCreateButton("Reset", 70, 80, 60)
;GUICtrlSetState($iResetButton, $GUI_DISABLE)

; Create label-grid and fill the xy array with the positions
Local $squarenr = 0
For $i = 0 To ($height * $grid_pixel) - $grid_pixel Step $grid_pixel ; Row
   For $j = 0 To ($width * $grid_pixel) - $grid_pixel Step $grid_pixel ; Column
	  $xy[$squarenr + 1][0] = GUICtrlCreateLabel($squarenr+1, 150 + $j, 50 + $i, $grid_pixel, $grid_pixel, BitOr($SS_SUNKEN, $SS_CENTER))
	  GUICtrlSetBkColor($xy[$squarenr + 1][0], 0x5E87C9) ; GUICtrlSetBkColor(-1, 0xeeeeee) ; GUICtrlSetBkColor(-1, 0x44AA44)
	  $xy[$squarenr + 1][1] = $squarenr + 1
	  $xy[$squarenr + 1][2] = ($i / $grid_pixel) + 1
	  $xy[$squarenr + 1][3] = ($j / $grid_pixel) + 1
	  $squarenr = $squarenr + 1
   Next
Next

; Show GUI
GUISwitch($gui)
GUISetState(@SW_SHOW)
; End GUI

; Start looping and waiting for input
Local $aMsg = 0
While 1
   $aMsg = GUIGetMsg(1)
   Select
	  Case $aMsg[0] = $iOKButton
		 GUICtrlSetState($iOKButton, $GUI_DISABLE)
		 make_maze()

	  Case $aMsg[0] = $GUI_EVENT_CLOSE And $aMsg[1] = $gui
		 ExitLoop

   EndSelect
WEnd

Exit

; Main function
Func make_maze()
   Global $curpos
   global $backtrack[1]
   Local $heading

   $backtrack[0] = 0
   $curpos = $width + 2

   open_maze($curpos)

   While 1
	  $heading = direction($curpos, 0)
	  If $heading = -1 Then ExitLoop

	  Switch $heading
		 Case 1 ; north
		 ConsoleWrite("Curpos 1: " & $curpos&@CRLF)
			open_maze($curpos - $width)
			open_maze($curpos - ($width * 2))
			$curpos = $curpos - ($width * 2)
		 Case 2 ; east
			ConsoleWrite("Curpos 2: " & $curpos&@CRLF)
			open_maze($curpos + 1)
			open_maze($curpos + 2)
			$curpos = $curpos + 2
		 Case 3 ; south
			ConsoleWrite("Curpos 3: " & $curpos&@CRLF)
			open_maze($curpos + $width)
			open_maze($curpos + ($width * 2))
			$curpos = $curpos + ($width * 2)
		 Case 4 ; west
			ConsoleWrite("Curpos 4: " & $curpos&@CRLF)
			open_maze($curpos - 1)
			open_maze($curpos - 2)
			$curpos = $curpos - 2
		 EndSwitch
		 msgbox(0,"","pause")
   WEnd ;Until $backtrack[0] = -1

   ConsoleWrite("Ending")
   Return
EndFunc

Func open_maze($dest)
   $xy[$dest][4] = "o"
   GUICtrlSetData($xy[$dest][0], $dest) ;
   GUICtrlSetBkColor($xy[$dest][0], 0xEEEEEE)
EndFunc

Func direction(ByRef $curpos, $bt) ;$bt = backtrack-tracking; 1=backtrack entry, 0=normal entry
   Local $tempbt
   Local $nesw
   Local $rand_result[5][2]

   $rand_result[0][0] = 0

   $nesw = $curpos - ($width * 2) ; north
   If $nesw > $width + 1 Then fill_rand_result($nesw, 1, $rand_result)

   $nesw = $curpos + 2 ; east
   If mod($nesw - 1, $width) <> 0 Then fill_rand_result($nesw, 2, $rand_result)

   $nesw = $curpos + ($width * 2) ; south
   If $nesw < $grid_size - $width Then fill_rand_result($nesw, 3, $rand_result)

   $nesw = $curpos - 2 ; west
   If mod($nesw, $width) <> 0 Then fill_rand_result($nesw, 4, $rand_result)

   For $i = $rand_result[0][0] To 1 Step -1
	  If $xy[$rand_result[$i][1]][4] = "o" Then
		 $rand_result[0][0] -= 1
		 _ArrayDelete($rand_result, $i)
	  EndIf
   Next

   If $rand_result[0][0] >= 2 Then
	  $backtrack[0] += 1
	  _ArrayAdd($backtrack, $curpos)
	  Return $rand_result[Random(1, $rand_result[0][0], 1)][0]
   ElseIf $rand_result[0][0] = 1 Then
	  consolewrite("one result: "& $rand_result[1][0]& " curpos: " & $curpos & @CRLF)
	  Return $rand_result[1][0]
   EndIf

   If $backtrack[0] > 0 Then
	  $tempbt = $backtrack[$backtrack[0]]
	  _ArrayDelete($backtrack, $backtrack[0])
	  $backtrack[0] -= 1
	  ConsoleWrite("tempBT: " & $tempbt&@CRLF)
	  $debug = direction($tempbt, 1)
	  ConsoleWrite("Debug: " &$debug&", curpos: "&$curpos &@CRLF)
	  Return $debug
   Else
	  Return -1
   EndIf
EndFunc

Func fill_rand_result($nesw, $direction, ByRef $rand_result)
   $rand_result[0][0] += 1
   $rand_result[$rand_result[0][0]][1] = $nesw
   $rand_result[$rand_result[0][0]][0] = $direction
   Return
EndFunc