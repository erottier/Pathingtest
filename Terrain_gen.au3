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
Global $height = 5
Global $width = 5
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
	  $xy[$squarenr + 1][0] = GUICtrlCreateLabel("x", 150 + $j, 50 + $i, $grid_pixel, $grid_pixel, BitOr($SS_SUNKEN, $SS_CENTER))
	  GUICtrlSetBkColor($xy[$squarenr + 1][0], 0x000000) ; GUICtrlSetBkColor(-1, 0xeeeeee) ; GUICtrlSetBkColor(-1, 0x44AA44)
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
		 make_maze()

	  Case $aMsg[0] = $GUI_EVENT_CLOSE And $aMsg[1] = $gui
		 ExitLoop

   EndSelect
WEnd

Exit

; Main function
Func make_maze()
   Local $heading
   Local $backtrack[1]

   $backtrack[0] = 0
   $curpos = $width + 2

   open_maze($curpos)

   Do
	  $heading = direction($curpos, $backtrack)
	  Switch $heading
		 Case 1 ; north
			open_maze($curpos - $width)
			open_maze($curpos - ($width * 2))
		 Case 2 ; east
			open_maze($curpos + 1)
			open_maze($curpos + 2)
		 Case 3 ; south
			open_maze($curpos + $width)
			open_maze($curpos + ($width * 2))
		 Case 4 ; west
			open_maze($curpos - 1)
			open_maze($curpos - 2)
	  EndSwitch
   Until $backtrack[0] = 0

   Return
EndFunc

Func open_maze($dest)
   $xy[$dest][4] = "o"
   GUICtrlSetData($xy[$dest][0], "o")
   GUICtrlSetBkColor($xy[$dest][0], 0xEEEEEE)
EndFunc

; Get the random _possible_ direction here by inputting your current location ID
Func direction($curpos, ByRef $backtrack)
   Local $dest
   Local $nesw
   Local $rand_result[5]

   Do
	  $rand_result[0] = 0

	  $north = $curpos - ($width * 2)
	  If $north < $width + 2 Then
		 $north = 0
	  ElseIf $xy[$north][4] = "o" Then
		 $north = 0
	  Else
		 $rand_result[0] += 1
		 $rand_result[$rand_result[0]] = 1 ;$north
	  EndIf

	  $east = $curpos + 2
	  If mod($east, $width) = 1 Then
		 $east = 0
	  ElseIf $xy[$east][4] = "o" Then
		 $east = 0
	  Else
		 $rand_result[0] += 1
		 $rand_result[$rand_result[0]] = 2 ;$east
	  EndIf

	  $south = $curpos + ($width * 2)
	  If $south > $grid_size - ($width + 2) Then
		 $south = 0
	  ElseIf $xy[$south][4] = "o" Then
		 $south = 0
	  Else
		 $rand_result[0] += 1
		 $rand_result[$rand_result[0]] = 3 ;$south
	  EndIf

	  $west = $curpos - 2
	  If mod($west, $width) = 0 Then
		 $west = 0
	  ElseIf $xy[$west][4] = "o" Then
		 $west = 0
	  Else
		 $rand_result[0] += 1
		 $rand_result[$rand_result[0]] = 4 ;$west
	  EndIf

	  If $rand_result[0] = 0 Then
		 $nesw = 0
	  ElseIf $rand_result[0] = 1 Then
		 $backtrack[0] += 1
		 _ArrayAdd($backtrack, $curpos)
		 $nesw = $rand_result[$rand_result[0]]
	  Else
		 $backtrack[0] += 1
		 _ArrayAdd($backtrack, $curpos)
		 $nesw = $rand_result[Random(1, $rand_result[0], 1)]
	  EndIf

	  If $nesw = 0 And $backtrack[0] > 0 then
		 $curpos = $backtrack[$backtrack[0]]
		 _ArrayDelete($backtrack, $backtrack[0])
		 $backtrack[0] -= 1
	  EndIf

   Until $nesw <> 0

   Return $nesw
EndFunc

;Func check_dest($dest) ; check destination for searched path, return true for possible way, false for no-go
   ;If $xy[$dest][4] = "x" Then Return True
   ;Return False
;EndFunc