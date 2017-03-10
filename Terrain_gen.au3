#cs ----------------------------------------------------------------------------
 AutoIt Version: 3.3.12.0
 Author:         A-maze-ing generator
 Script Function:
    Generates a maze.
      In the $xy[$i][4] is the maze in array form.
      Don't forget to take the size with it, else it's just a string of o's and x's
    It does not generate an entrance or exit!
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>

; Set various variables
; width and height must be odd numbers to have a closed, functioning maze.
Global $height = 27
Global $width = 27

; Check if width & height are an odd number (to get the outer edge an odd number is required)
If mod($height, 2) = 0 Then
   msgbox(0,"","Height is not an odd number!")
   Exit
ElseIf mod($width, 2) = 0 Then
   msgbox(0,"","Width is not an odd number!")
   Exit
EndIf

; Set various variables when script is not exited
Global $grid_size = $height * $width
Global $curpos
Global $backtrack[1]
Global $bt = 0
Local $grid_pixel = 20 ;How many pixels per square

; Initialize main array with all grid data
Global $xy[$grid_size + 1][5]
$xy[0][0] = $grid_size ; first entry is the total number of nodes, rest is set with a header name for easy reference in _ArrayDisplay if needed.
$xy[0][1] = "ID"
$xy[0][2] = "Row"
$xy[0][3] = "Column"
$xy[0][4] = "Type"

; Fill the grid array with 'walls'
For $i = 1 To $xy[0][0]
   $xy[$i][4] = "x"
Next

; Start GUI and create standard buttons
Local $gui = GUICreate("A-maze-ing generator", 200 + $width * $grid_pixel, 100 + $height * $grid_pixel)
GUICtrlCreateLabel("This is a-maze-ing!", 30, 10)
Local $iOKButton = GUICtrlCreateButton("OK", 70, 50, 60)
Local $iExitButton = GUICtrlCreateButton("Exit", 70, 90, 60)

; Create label-grid and fill the xy array with the positions
Local $squarenr = 0
For $i = 0 To ($height * $grid_pixel) - $grid_pixel Step $grid_pixel ; Row
   For $j = 0 To ($width * $grid_pixel) - $grid_pixel Step $grid_pixel ; Column
      $squarenr = $squarenr + 1
      $xy[$squarenr][0] = GUICtrlCreateLabel('x', 150 + $j, 50 + $i, $grid_pixel, $grid_pixel, BitOr($SS_SUNKEN, $SS_CENTER)) ; if you want debugging numbers, replace 'x' with $squarenr
      GUICtrlSetBkColor($xy[$squarenr][0], 0x5E87C9)
      $xy[$squarenr][1] = $squarenr
      $xy[$squarenr][2] = ($i / $grid_pixel) + 1
      $xy[$squarenr][3] = ($j / $grid_pixel) + 1
   Next
Next

; Show GUI
GUISwitch($gui)
GUISetState(@SW_SHOW)

; Start looping and waiting for input
Local $aMsg = 0
While 1
   $aMsg = GUIGetMsg(1)
   Select
      Case $aMsg[0] = $iOKButton
         GUICtrlSetState($iOKButton, $GUI_DISABLE)
         make_maze()

      Case $aMsg[0] = $GUI_EVENT_CLOSE Or $aMsg[0] = $iExitButton
         ExitLoop
  EndSelect
WEnd

Exit

; Main function
Func make_maze()
   Local $heading

   $backtrack[0] = 0
   $curpos = $width + 2 ; This is the starting position, second row, second column - aka top-left, one in from the sides.

   open_maze($curpos) ; Set the starter cell to 'open / white'

   ; Main maze generation loop
   While 1
      Do
         $heading = direction($curpos)
      Until $heading <> 0
      If $bt = 1 Then $bt = 0 ; reset backtracking-tracker, else the backtracking array keeps adding the current position

      Sleep(50) ; Slow maze creation down to look at it - relax! (or don't and comment out the sleep)
      If $heading = -1 Then ExitLoop

      ; We got the heading - now which way do we go? After that, set the current position to the last known heading.
      Switch $heading
         Case 1 ; north
            open_maze($curpos - $width)
            open_maze($curpos - ($width * 2))
            $curpos = $curpos - ($width * 2)
         Case 2 ; east
            open_maze($curpos + 1)
            open_maze($curpos + 2)
            $curpos = $curpos + 2
         Case 3 ; south
            open_maze($curpos + $width)
            open_maze($curpos + ($width * 2))
            $curpos = $curpos + ($width * 2)
         Case 4 ; west
            open_maze($curpos - 1)
            open_maze($curpos - 2)
            $curpos = $curpos - 2
         EndSwitch
         ;msgbox(0,"","Turn pause") ; for debugging, click every turn.
   WEnd

   ConsoleWrite("Maze completed.")
   Return
EndFunc

Func open_maze($dest) ; Function set inputted cells to 'open' instead of being an uncool wall.
   $xy[$dest][4] = "o"
   GUICtrlSetData($xy[$dest][0], 'o') ; If you want debugging numbers, replace 'o' with $dest
   GUICtrlSetBkColor($xy[$dest][0], 0xEEEEEE)
EndFunc

Func direction(ByRef $curpos) ; Insert current position, output next heading for path generation.
   Local $nesw
   Local $open_directions[5][2]

   $open_directions[0][0] = 0

   $nesw = $curpos - ($width * 2) ; north side checking
   If $nesw > $width + 1 Then fill_open_dir($nesw, 1, $open_directions)

   $nesw = $curpos + 2 ; east side checking
   If mod($nesw - 1, $width) <> 0 Then fill_open_dir($nesw, 2, $open_directions)

   $nesw = $curpos + ($width * 2) ; south side checking
   If $nesw < $grid_size - $width Then fill_open_dir($nesw, 3, $open_directions)

   $nesw = $curpos - 2 ; west side checking
   If mod($nesw, $width) <> 0 Then fill_open_dir($nesw, 4, $open_directions)

   ; Check which (if any) direction(s) are already opened, if so, discard them from the results-array
   For $i = $open_directions[0][0] To 1 Step -1
      If $xy[$open_directions[$i][1]][4] = "o" Then
         $open_directions[0][0] -= 1
         _ArrayDelete($open_directions, $i)
      EndIf
   Next

   ; If there are any results left...
   If $open_directions[0][0] > 0 Then
      If $open_directions[0][0] = 1 Then
         Return $open_directions[1][0] ; Random does not work with min 1 and max 1 (output = 0), so in this case, return only with the only one result.
      Else
         If $bt = 0 Then ; If there is not backtracking active, add this crossroad to the backtrack-array. This is only needed if there are two or three possible sides.
            $backtrack[0] += 1
            _ArrayAdd($backtrack, $curpos)
         EndIf
         Return $open_directions[Random(1, $open_directions[0][0], 1)][0] ; Random choose between all possible directions and return with the outcome direction.
      EndIf
   ElseIf $backtrack[0] > 0 Then ; If there are no results ánd there are entries in the backtrack list, then visit those entries to see if there still is a path possible.
      $curpos = $backtrack[$backtrack[0]]
      _ArrayDelete($backtrack, $backtrack[0])
      $backtrack[0] -= 1
      $bt = 1
      Return 0 ; Return with a new current direction ($curpos), from the backtrack array.
   Else
      Return -1 ; If there are no paths to explorer, in the pathing, or backtracking, then return with the message that we are finished.
   EndIf
EndFunc

Func fill_open_dir($nesw, $direction, ByRef $open_directions) ; Fill the $open_directions array with a new possible way
   $open_directions[0][0] += 1
   $open_directions[$open_directions[0][0]][1] = $nesw
   $open_directions[$open_directions[0][0]][0] = $direction
   Return
EndFunc