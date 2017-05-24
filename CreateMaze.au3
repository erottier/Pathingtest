#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>

; Script Start - Add your code below here

; Initialize required maze variables and grid array. Returns 1 when an error occurred and 0 when all's good.
Func init_maze()
   Global $GUIenabled = False

   ; width and height must be odd numbers to have a closed, functioning maze.
   Global $height = 27 ; demo height = 27
   Global $width = 43; demo width = 43

   ; Check if width & height are an odd number (to get the outer edge an odd number is required)
   If mod($height, 2) = 0 Or $height < 5 Then
	  ;msgbox(0,"","Height is not an odd number or a minimum of 5 tall !")
	  Return 1
	  ;Exit
   ElseIf mod($width, 2) = 0 Or $width < 5 Then
	  ;msgbox(0,"","Width is not an odd number of a minimum of 5 wide !")
	  Return 1
	  ;Exit
   EndIf

   Global $grid_size = $height * $width
   Global $numberofsteps = (Ceiling(($height-2) / 2) * (($width-2) - Ceiling(($width-2) / 2))) + (($height-2) - Ceiling(($height-2) / 2)) ; long formula to check the number of steps this maze will take, this is a mathematical given with a fixed number of cells. And yes, I am aware I'm taking a shortcut in this formula. ;)

   Global $curpos
   Global $backtrack[1]
   Global $bt = 0

   ; Initialize main array with all grid data
   Global $xy[$grid_size + 1][5]
   Global $reset_xy = $xy ; set the reset array
   $xy[0][0] = $grid_size ; first entry is the total number of nodes, rest is set with a header name for easy reference in _ArrayDisplay if needed.
   $xy[0][1] = "ID"
   $xy[0][2] = "Row"
   $xy[0][3] = "Column"
   $xy[0][4] = "Type"

   ; Fill the grid array with 'walls'
   For $i = 1 To $xy[0][0]
	  $xy[$i][4] = "x"
   Next

   Return 0
EndFunc

; Main function - set if GUI used true or false
Func make_maze($GUIenabled)
   Local $heading
   Local $stepcount = $numberofsteps ; Reset the step counter.
   Local $timed = TimerInit() ; Start the timer to see how long the maze generation took.

   $backtrack[0] = 0
   $curpos = $width + 2 ; This is the starting position, second row, second column - aka top-left, one in from the sides.

   open_maze($curpos) ; Set the starter cell to 'open / white'

   ; Main maze generation loop
   While 1
      Do
         $heading = direction($curpos)
      Until $heading <> 0
      If $bt = 1 Then $bt = 0 ; reset backtracking-tracker, else the backtracking array keeps adding the current position

      If $GUIenabled = True Then GUICtrlSetData($progress, "Running - Creating maze. Please stand by... " & $stepcount & " steps to go.")
      ;Sleep(50) ; Slow maze creation down to look at it - relax! (or don't and comment out the sleep)
      If $heading = -1 Then ExitLoop
      $stepcount -= 1 ; Count down the steps to finish.

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

   ConsoleWrite("Maze completed in " & Round(TimerDiff($timed) / 1000, 1) & " seconds." & @CRLF) ; Show the generation time in seconds, rounded up with one decimal
   Return
EndFunc

; If needed, set the selected 'cell' to 'open' in the array, set the letter 'o' visual and set the background color to grey.
Func open_maze($dest) ; Function set inputted cells to 'open' instead of being an uncool wall.
   $xy[$dest][4] = "o"
   msgbox(0,"",$GUIenabled)
   If $GUIenabled = True Then GUICtrlSetData($xy[$dest][0], 'o') ; If you want debugging numbers, replace 'o' with $dest.
   If $GUIenabled = True Then GUICtrlSetBkColor($xy[$dest][0], 0xEEEEEE)
EndFunc

; Insert current position, output next heading for path generation.
Func direction(ByRef $curpos)
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

; Fill the $open_directions array with a new possible way
Func fill_open_dir($nesw, $direction, ByRef $open_directions)
   $open_directions[0][0] += 1
   $open_directions[$open_directions[0][0]][1] = $nesw
   $open_directions[$open_directions[0][0]][0] = $direction
   Return
EndFunc

;init_maze()
;make_maze(False)
;_ArrayDisplay($xy)