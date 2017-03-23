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

AutoItSetOption("MustDeclareVars", 1)

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>

#include <CreateMaze.au3>

; Set various variables
; width and height must be odd numbers to have a closed, functioning maze.
Global $height = 27 ; demo height = 27
Global $width = 43; demo width = 43

; Check if width & height are an odd number (to get the outer edge an odd number is required)
If mod($height, 2) = 0 Or $height < 5 Then
   msgbox(0,"","Height is not an odd number or a minimum of 5 tall !")
   Exit
ElseIf mod($width, 2) = 0 Or $width < 5 Then
   msgbox(0,"","Width is not an odd number of a minimum of 5 wide !")
   Exit
EndIf

; Set various variables when script is not exited
Global $grid_size = $height * $width
Global $numberofsteps = (Ceiling(($height-2) / 2) * (($width-2) - Ceiling(($width-2) / 2))) + (($height-2) - Ceiling(($height-2) / 2)) ; long formula to check the number of steps this maze will take, this is a mathematical given with a fixed number of cells. And yes, I am aware I'm taking a shortcut in this formula. ;)

Global $curpos
Global $backtrack[1]
Global $bt = 0
Local $grid_pixel = 20 ;How many pixels per square

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

; Start GUI and create standard buttons
Local $gui = GUICreate("A-maze-ing generator", 180 + ($width * $grid_pixel), 80 + ($height * $grid_pixel))

; Set the main window to the minimum width (IF) needed for the msgbox
Local $aPos = WinGetPos($gui)
If $aPos[2] < 696 Then
   $aPos[2] = 696
   WinMove($gui, "", $aPos[0], $aPos[1], $aPos[2], $aPos[3])
EndIf

GUICtrlCreateLabel("This is a-maze-ing!", 30, 19)
Global $progress = GUICtrlCreateLabel("Standing by... " & $numberofsteps & " steps to go.", 150, 15, 550, 30)
Local $iOKButton = GUICtrlCreateButton("Start", 45, 50, 60)
Local $iResetButton = GUICtrlCreateButton("Reset", 45, 90, 60)
Local $iExitButton = GUICtrlCreateButton("Exit", 45, 130, 60)

GUICtrlSetFont($progress, 15)
GUICtrlSetColor($progress, 0x00AA00)
GUICtrlSetState($iResetButton, $GUI_DISABLE)

; Create label-grid and fill the xy array with the positions
Local $squarenr = 0
For $i = 0 To ($height * $grid_pixel) - $grid_pixel Step $grid_pixel ; Row
   For $j = 0 To ($width * $grid_pixel) - $grid_pixel Step $grid_pixel ; Column
      $squarenr = $squarenr + 1
      $xy[$squarenr][0] = GUICtrlCreateLabel('x', 150 + $j, 50 + $i, $grid_pixel, $grid_pixel, BitOr($SS_SUNKEN, $SS_CENTER)) ; if you want debugging numbers, replace 'x' with $squarenr
      GUICtrlSetBkColor($xy[$squarenr][0], 0x5E87C9) ; lightblue-ish
      $xy[$squarenr][1] = $squarenr
      $xy[$squarenr][2] = ($i / $grid_pixel) + 1
      $xy[$squarenr][3] = ($j / $grid_pixel) + 1
   Next
Next
$reset_xy = $xy

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
         GUICtrlSetState($iResetButton, $GUI_DISABLE)
         GUICtrlSetState($iExitButton, $GUI_DISABLE)
         GUICtrlSetColor($progress, 0xFF8C00) ; orange
         GUICtrlSetData($progress, "Running - Creating maze. Please stand by... " & $numberofsteps & " steps to go.")
         make_maze()
         GUICtrlSetColor($progress, 0xFF0000) ; red
         GUICtrlSetData($progress, "Maze complete!")
         Sleep(1000) ; Just a small sleep for dramatic effect
         GUICtrlSetColor($progress, 0x00AA00) ; green-ish
         GUICtrlSetData($progress, "Maze completed in " & $numberofsteps & " steps.")
         GUICtrlSetState($iResetButton, $GUI_ENABLE)
         GUICtrlSetState($iExitButton, $GUI_ENABLE)

      Case $aMsg[0] = $iResetButton
         GUICtrlSetData($progress, "Resetting maze...")
         reset_maze()
         GUICtrlSetState($iResetButton, $GUI_DISABLE)
         GUICtrlSetState($iOKButton, $GUI_ENABLE)
         GUICtrlSetData($progress, "Maze reset!")
         Sleep(1000) ; Just a small sleep for dramatic effect
         GUICtrlSetData($progress, "Standing by...")

      Case $aMsg[0] = $GUI_EVENT_CLOSE Or $aMsg[0] = $iExitButton
         ExitLoop
  EndSelect
WEnd

Exit

; Resetting the maze to default state

Func reset_maze()
   $xy = $reset_xy ; Set the $xy array back to it first-run values
   For $i = 1 To $xy[0][0]
      $xy[$i][4] = "x" ; set everything to 'x'
      GUICtrlSetBkColor($xy[$i][0], 0x5E87C9) ; reset the background color
      GUICtrlSetData($xy[$i][0], "x") ; (re)set the label to 'x'
   Next
EndFunc