#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <Array.au3>
;#include <GDIPlus.au3> ;_GDIPlus_GraphicsDrawRect ( $hGraphics, $nX, $nY, $nWidth, $nHeight [, $hPen = 0] )

Local $grid_size = 15 ;How many squares in x and y axis
Local $grid_pixel = 20 ;How many pixels per square
Global $grid_max = ($grid_size * $grid_size) + 1
Local $xy[$grid_max][7]
Local $row
Local $col
Global $active = false
Global $heuristic = 1 ; ?? needed ??

Global $estimate
Global $closedList_Str = "_"
Global $openList_Str = "_"
Global $allow_diagonals_Boolean = False ;$GUI_UNCHECKED
Global $data[$grid_size][$grid_size]
;Global $data[5][5] = [["x","x","x","x","x"], _
                    ;["x","s","0","0","x"], _
                    ;["x","x","0","0","x"], _
                    ;["x","x","x","g","x"], _
                    ;["x","x","x","x","x"]]
Global Const $cols = $grid_size
Global Const $rows = $grid_size
Global $map; = $data

For $i = 0 To $grid_size - 1
   For $j = 0 To $grid_size - 1
	  $data[$i][$j] = "x" ;$i * $grid_size + $j
   Next
Next

; Initialize GDI+ library
;_GDIPlus_Startup()

; 150px * (number of squares * 50px) = width
;

Local $gui = GUICreate("Field", 200 + $grid_size * $grid_pixel, 100 + $grid_size * $grid_pixel) ; title, width, height
GUICtrlCreateLabel("Hello world! How are you?", 30, 10)
Local $iOKButton = GUICtrlCreateButton("OK", 70, 50, 60)
Local $iResetButton = GUICtrlCreateButton("Reset", 70, 80, 60)
GUICtrlSetState($iResetButton, $GUI_DISABLE)

;Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($gui) ;create a graphics object from a window handle
;_GDIPlus_GraphicsSetSmoothingMode($hGraphics, $GDIP_SMOOTHINGMODE_HIGHQUALITY) ;sets the graphics object rendering quality (antialiasing)
;Local $hPen = _GDIPlus_PenCreate(0xFF000000, 2) ;color format AARRGGBB (hex)
$xy[0][0] = "width"
$xy[0][1] = "height"
$xy[0][2] = "labelID"
$xy[0][3] = "pathtype"
$xy[0][4] = "column"
$xy[0][5] = "row"

Local $squarenr = 0
For $i = 0 To ($grid_size * $grid_pixel) - $grid_pixel Step $grid_pixel
   For $j = 0 To ($grid_size * $grid_pixel) - $grid_pixel Step $grid_pixel
	  ;_GDIPlus_GraphicsDrawRect($hGraphics, 150 + $j, 50 + $i, 50, 50, $hPen)
	  $xy[$squarenr + 1][2] = GUICtrlCreateLabel("x", 150 + $J, 50 + $i, $grid_pixel, $grid_pixel, $SS_SUNKEN)
	  $xy[$squarenr + 1][3] = $data[Int($i)/$grid_pixel][int($j)/$grid_pixel]
	  GUICtrlSetBkColor(-1, 0xeeeeee) ; GUICtrlSetBkColor(-1, 0x44AA44)
	  $xy[$squarenr + 1][0] = 150 + $j
	  $xy[$squarenr + 1][1] = $grid_pixel + $i
	  $row = Floor($squarenr / $grid_size)
	  ;$col = $squarenr - ($row * $grid_size)
	  $col = Mod($squarenr, $grid_size)
	  $xy[$squarenr + 1][4] = $col
	  $xy[$squarenr + 1][5] = $row
	  $xy[$squarenr + 1][6] = $squarenr + 1
	  $squarenr = $squarenr + 1
   Next
Next

Local $pathing = StringSplit("16,17,18,21,23,25,31,33,36,38,40,46,48,51,53,55,57,58,61,63,64,65,66,67,68,69,70,71,72,76,87,91,92,93,102,107,111,113,114,115,117,122,123,124,126,128,130,132,137,139,141,143,145,147,152,154,155,156,158,160,162,163,166,167,169,173,175,177,181,184,188,190,191,192,196,199,200,201,202,203,205", ",")
For $i = 1 To UBound($pathing) - 1
   $row = Floor($pathing[$i] / $grid_size)
   ;$col = $pathing[$i] - ($row * $grid_size)
   $col = Mod($pathing[$i], $grid_size)
   $data[$row][$col] = "o"
   $xy[$pathing[$i] + 1][3] = "o"
   GUICtrlSetData($xy[$pathing[$i] + 1][2], "o")
Next

$debug = 1
If $debug = 1 Then
   $data[1][1] = "s"
   $xy[17][3] = "s"
   GUICtrlSetData($xy[17][2], "s")

   $data[11][10] = "g"
   $xy[176][3] = "g"
   GUICtrlSetData($xy[176][2], "g")
   ;_ArrayDisplay($data)
EndIf

;$human1 = GUICtrlCreateLabel("1", 170, 70, 7, 12)

GUISwitch($gui)
GUISetState(@SW_SHOW)

Local $aMsg = 0
While 1
    $aMsg = GUIGetMsg(1)

    Select
	  Case $aMsg[0] = $iOKButton
		 $active = true
		 Global $resetData = $data
		 GUICtrlSetState($iOKButton, $GUI_DISABLE)

		 ;$SLocation = _GetStartingLocation($data, $rows, $cols) ;starting location
		 ;$GLocation = _GetGoalLocation($data, $rows, $cols) ;goal location
		 ;$map = $data
		 ;_CreateMap($data, $cols, $rows) ;replaces data with node objects
		 ;Dim $path = _FindPath($data, $data[$SLocation[1]][$SLocation[0]], $data[$GLocation[1]][$GLocation[0]]) ; !!!!!!!!!!!! Het probleem zit in deze functie! !!!!!!!!!!!!!!!
		 ;;For $i = 0 To _ArraySearch($path, "g") - 2
		 ;For $i = 0 To UBound($path) - 1
		;	GUICtrlSetBkColor($xy[(StringRight($path[$i], StringLen($path[$i]) - StringInStr($path[$i], ",")) * $grid_size) + (StringLeft($path[$i],StringInStr($path[$i], ",") - 1) + 1)][2], 0xccffff)
		; Next
		 For $i = 0 To UBound($xy) - 1
			If $xy[$i][3] = "x" Then
			   GUICtrlSetBkColor($xy[$i][2], 000000)
			EndIf
		 Next

		 startmap()

		 ;GUICtrlSetBkColor($xy[($SLocation[1] * $grid_size) + ($SLocation[0] + 1)][2], 0x44AA44)
		 ;GUICtrlSetBkColor($xy[($GLocation[1] * $grid_size) + ($GLocation[0] + 1)][2], 0xAA4444)
		 GUICtrlSetState($iResetButton, $GUI_ENABLE)
		; If $path <> 0 Then
		;	;msgbox(0,"","Path found!")
		; Else
		;	msgbox(0,"","Path not found...")
		 ;EndIf
		 ;$data = $map

	  Case $aMsg[0] = $iResetButton ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! RESET ISSUE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		 $data = $resetData
		 $path = 0
		 For $i = 0 To UBound($xy) - 1
			GUICtrlSetBkColor($xy[$i][2], 0xeeeeee)
		 Next
		 GUICtrlSetState($iOKButton, $GUI_ENABLE)
		 GUICtrlSetState($iResetButton, $GUI_DISABLE)
		 $active = false

	  Case $aMsg[0] = $GUI_EVENT_CLOSE And $aMsg[1] = $gui
		 ExitLoop

	  Case Else
		 If $active = false Then
			For $i = 1 To UBound($xy) - 1
			   Local $changed = ""
			   If $aMsg[0] = $xy[$i][2] then
				  Switch GUICtrlRead($aMsg[0])
					 Case ""
						GUICtrlSetData($aMsg[0], "s")
						$changed = "s"

					 Case "s"
						GUICtrlSetData($aMsg[0], "g")
						$changed = "g"

					 Case "g"
						GUICtrlSetData($aMsg[0], "o")
						$changed = "o"

					 Case "o"
						GUICtrlSetData($aMsg[0], "x")
						$changed = "x"

					 Case "x"
						GUICtrlSetData($aMsg[0], "s")
						$changed = "s"
				  EndSwitch
				  If $changed <> "" Then
					 $xy[$i][3] = $changed
					 $data[$xy[$i][5]][$xy[$i][4]] = $changed
				  EndIf
			   EndIf
			Next
		 EndIf
		 ;Sleep(20)

	EndSelect
 WEnd

; Shut down GDI+ library
;_GDIPlus_Shutdown()

Exit

;
; END OF MAIN PROGRAM
;

Func startmap()
   Dim $nodes[$grid_max]
   Global $open[$grid_max][4]
   Global $closed[$grid_max][2]
   Local $start = _ArraySearch($xy, "s", 0, 0, 0, 0, 1, 3) ;$start = (row) 17
   Global $goal = _ArraySearch($xy, "g", 0, 0, 0, 0, 1, 3)
   Local $loc = 1

   $closed[0][0] = 0
   $open[0][0] = 1
   $open[1][0] = Get_H($start, $goal)
   $open[1][1] = $start
   $open[1][2] = 0
   $open[1][3] = 0

   For $i = 1 To 1000
   ;_ArrayDisplay($open)
   If $start = "" Then
	  msgbox(0,"","$start is empty!")
	  Exit
   EndIf
	  AddOpen($start, $loc)
   ;_ArrayDisplay($open)
	  $loc = _ArrayMinIndex($open, 1, 1, $open[0][0])
	  $start = $open[$loc][1]
	  ;msgbox(0,"",$start)
	  UpdateOpen($start)
   Next

_ArrayDisplay($open)
_ArrayDisplay($closed)
exit

	  ;If AddOpen() = 0 Then $goalreached = True
   ;Until $goalreached = True

EndFunc

Func UpdateOpen($start)
   ;Update the whole $open array with new h_cost values
EndFunc

Func AddOpen($start, $loc)
   Local $counter = 1

   $closed[0][0] = $closed[0][0] + 1
   $closed[$closed[0][0]][0] = $start
   $closed[$closed[0][0]][1] = $open[$loc][1]
   GUICtrlSetBkColor($xy[$open[$loc][1]][2], "0xff0000") ; RED col 2 = labelID

   _ArrayDelete($open, $loc)
   $open[0][0] = $open[0][0] - 1

   $process = $start - 15
   ;ConsoleWrite($xy[$process][3] & " <-> " & $start & " <-> " & _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) & " <-> " & _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) & @CRLF)
   If $xy[$process][3] <> "x" Then
	  If $start > 0 And _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) = -1 And _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) = -1 Then
		 $open[$open[0][0]+$counter][0] = Get_H($process, $goal)
		 $open[$open[0][0]+$counter][1] = $process
		 $open[$open[0][0]+$counter][2] = 10
		 $open[$open[0][0]+$counter][3] = Get_H($closed[0][0], $process)
		 $counter = $counter + 1
		 GUICtrlSetBkColor($xy[$process][2], "0x00ff00") ; GREEN
		 If $process = $xy[$goal][6] Then
			msgbox(0,"","You've found the exit!")
			Exit
		 EndIf
		 Sleep(50)
	  EndIf
   EndIf

   $process = $start + 1
   ;ConsoleWrite($xy[$process][3] & " <-> " & $start & " <-> " & _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) & " <-> " & _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) & @CRLF)
   If $xy[$process][3] <> "x" Then
	  If IsInt($start / 15) = 0 And _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) = -1 And _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) = -1 Then
		 $open[$open[0][0]+$counter][0] = Get_H($process, $goal)
		 $open[$open[0][0]+$counter][1] = $process
		 $open[$open[0][0]+$counter][2] = 10
		 $open[$open[0][0]+$counter][3] = Get_H($closed[0][0], $process)
		 $counter = $counter + 1
		 GUICtrlSetBkColor($xy[$process][2], "0x00ff00") ; GREEN
		 If $process = $xy[$goal][6] Then
			msgbox(0,"","You've found the exit!")
			Exit
		 EndIf
		 Sleep(50)
	  EndIf
   EndIf

   $process = $start + 15
   ;ConsoleWrite($xy[$process][3] & " <-> " & $start & " <-> " & _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) & " <-> " & _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) & @CRLF)
   If $xy[$process][3] <> "x" Then
	  If $start < ($grid_max - 15) And _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) = -1 And _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) = -1 Then
		 $open[$open[0][0]+$counter][0] = Get_H($process, $goal)
		 $open[$open[0][0]+$counter][1] = $process
		 $open[$open[0][0]+$counter][2] = 10
		 $open[$open[0][0]+$counter][3] = Get_H($closed[0][0], $process)
		 $counter = $counter + 1
		 GUICtrlSetBkColor($xy[$process][2], "0x00ff00") ; GREEN
		 If $process = $xy[$goal][6] Then
			msgbox(0,"","You've found the exit!")
			Exit
		 EndIf
		 Sleep(50)
	  EndIf
   EndIf

   $process = $start - 1
   ;ConsoleWrite($xy[$process][3] & " <-> " & $start & " <-> " & _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) & " <-> " & _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) & @CRLF)
   If $xy[$process][3] <> "x" Then
	  If IsInt(($start / 15)+1) = 0 And $start <> 1 And _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) = -1 And _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) = -1 Then
		 $open[$open[0][0]+$counter][0] = Get_H($process, $goal)
		 $open[$open[0][0]+$counter][1] = $process
		 $open[$open[0][0]+$counter][2] = 10
		 $open[$open[0][0]+$counter][3] = Get_H($closed[0][0], $process)
		 $counter = $counter + 1
		 GUICtrlSetBkColor($xy[$process][2], "0x00ff00") ; GREEN
		 If $process = $xy[$goal][6] Then
			msgbox(0,"","You've found the exit!")
			Exit
		 EndIf
		 Sleep(50)
	  EndIf
   EndIf

   $open[0][0] = $open[0][0] + ($counter - 1) ; -1 wel goed??
EndFunc




Func Get_H($start, $goal)
   ; H(euristic) Cost = Number of squares = Length + Width – (1 of HFC/GCD)
If $start <= 0 Then _ArrayDisplay($open)
   Local $width2
   Local $length2
   Local $xygoallength = $xy[$goal][5]
   Local $xystartlength = $xy[$start][5]
   Local $xygoalwidth = $xy[$goal][4]
   Local $xystartwidth = $xy[$start][4]

   If $xygoallength > $xystartlength Then
	  $length2 = $xygoallength - $xystartlength
   Elseif $xystartlength > $xygoallength Then
	  $length2 = $xystartlength - $xygoallength
   Else
	  $length2 = 1
   EndIf

   If $xygoalwidth > $xystartwidth Then
	  $width2 = $xygoalwidth - $xystartwidth
   Elseif $xystartwidth > $xygoalwidth Then
	  $width2 = $xystartwidth - $xygoalwidth
   Else
	  $width2 = 1
   EndIf
   ;$width2 = $xygoalwidth - $xystartwidth

   ; !!! ToDo: Insert logic hier als de de goal niet rechtsonder de start ligt? !!!
   ;$length = $xy[$goal][5] - $xy[$start][5]
   ;$width = $xy[$goal][4] - $xy[$start][4]
   ;msgbox(0,"",$length & " + " & $width & " - " & _GCD($length, $width))
   If $width2 = $length2 Then
	  Return $length2 + $width2 - 1
   Else
	  ;msgbox(0,"",$length & " + " & $width & " - " & _GCD($length, $width))
	  Return $length2 + $width2 - _GCD($length2, $width2)
   EndIf
EndFunc

; Source: https://rosettacode.org/wiki/Greatest_common_divisor#AutoIt
Func _GCD($ia, $ib)
	;Local $ret = "GCD of " & $ia & " : " & $ib & " = "
	Local $imod
	While True
		$imod = Mod($ia, $ib)
		If $imod = 0 Then Return $ib ;ConsoleWrite($ret & $ib & @CRLF)
		$ia = $ib
		$ib = $imod
	WEnd
EndFunc   ;==>_GCD