#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <Array.au3>
;#include <GDIPlus.au3> ;_GDIPlus_GraphicsDrawRect ( $hGraphics, $nX, $nY, $nWidth, $nHeight [, $hPen = 0] )

Local $grid_size = 15 ;How many squares in x and y axis  !! mag niet groter worden dan 4000 !!!
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
   Global $open[$grid_max][5]
   Global $closed[$grid_max][3]
   Global $start = _ArraySearch($xy, "s", 0, 0, 0, 0, 1, 3) ;$start = (row) 17
   Global $goal = _ArraySearch($xy, "g", 0, 0, 0, 0, 1, 3)
   Local $loc = 1

   $closed[0][0] = 0
   $closed[0][1] = "ParentID"
   $closed[0][2] = "F-cost"
   $open[0][0] = 1 ; = G-Cost
   $open[0][1] = "ID"
   $open[0][2] = "H-cost"
   $open[0][3] = "F-cost"
   $open[0][4] = "ParentID"
   $open[1][0] = 0 ; Get_Distance($start, $goal)
   $open[1][1] = $start
   $open[1][2] = 0
   $open[1][3] = 0
   $open[1][4] = 0

   ;For $i = 1 To 1000 ; safeguard for testing
   Do ; Main loop
	  If $start = "" Then
		 msgbox(0,"","$start is empty!")
		 ExitLoop
	  EndIf
		 Checkpath($start, $loc)
		 $loc = _ArrayMinIndex($open, 1, 1, $open[0][0], 3)
		 $start = $open[$loc][1]
	  ;Next
   Until $open[$open[0][0]][3] = 0
EndFunc

Func UpdateOpen($process, $start) ; Update given open-cell with the new low cost AND parent
   msgbox(0,"","Found this open tile again.")
EndFunc

Func Checkpath($start, $loc)
   Local $counter = 1
   $closed[0][0] = $closed[0][0] + 1
   $closed[$closed[0][0]][0] = $start
   $closed[$closed[0][0]][1] = $open[$loc][4]
   $closed[$closed[0][0]][2] = $open[$loc][0] ; $open[$loc][3]
   GUICtrlSetBkColor($xy[$open[$loc][1]][2], "0xff0000") ; RED col 2 = labelID

   _ArrayDelete($open, $loc)
   $open[0][0] = $open[0][0] - 1

   $process = $start - 15
   If $xy[$process][3] <> "x" Then
	  If _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) <> -1 Then
		 UpdateOpen($process, $start)
	  ElseIf $start > 0 And _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) = -1 Then
		Add_open($start, $closed[0][0], $counter, $process)
	  EndIf
   EndIf

   $process = $start + 1
   If $xy[$process][3] <> "x" Then
	  If _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) <> -1 Then
		 UpdateOpen($process, $start)
	  ElseIf IsInt($start / 15) = 0 And _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) = -1 Then
		 Add_open($start, $closed[0][0], $counter, $process)
	  EndIf
   EndIf

   $process = $start + 15
   If $xy[$process][3] <> "x" Then
	  If _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) <> -1 Then
		 UpdateOpen($process, $start)
	  ElseIf $start < ($grid_max - 15) And _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) = -1 Then
		 Add_open($start, $closed[0][0], $counter, $process)
	  EndIf
   EndIf

   $process = $start - 1
   If $xy[$process][3] <> "x" Then
	  If _ArraySearch($open, $process, 1, $open[0][0], 0, 0, 1, 1) <> -1 Then
		 UpdateOpen($process, $start)
	  ElseIf IsInt(($start / 15)+1) = 0 And $start <> 1 And _ArraySearch($closed, $process, 1, $closed[0][0], 0, 0, 1, 0) = -1 Then
		 Add_open($start, $closed[0][0], $counter, $process)
	  EndIf
   EndIf

   $open[0][0] = $open[0][0] + ($counter - 1)
EndFunc

Func Add_open($parentid, $startid, ByRef $counter, $process)
   ;msgbox(0,"",$closed[$startid][2])
   _ArrayDisplay($open)
   ;_ArrayDisplay($closed)
   $open[$open[0][0]+$counter][0] = $closed[$startid][2] ;Get_Distance($closed[1][0], $process) ; $start = vorige node, $closed[1][0] = start node - vandaar de closed ipv start...
   ;_ArrayDisplay($open)
   $open[$open[0][0]+$counter][1] = $process
   $open[$open[0][0]+$counter][2] = Get_Distance($process, $goal)
   $open[$open[0][0]+$counter][3] = $open[$open[0][0]+$counter][0] + $open[$open[0][0]+$counter][2]
   $open[$open[0][0]+$counter][4] = $parentid
   ;_ArrayDisplay($open)
   ;_ArrayDisplay($closed)
   $counter = $counter + 1
   GUICtrlSetBkColor($xy[$process][2], "0x00ff00") ; GREEN
   If $process = $xy[$goal][6] Then
	  _ArrayDisplay($open)
	  msgbox(0,"","You've found the exit!")
	  Exit
   EndIf
   Sleep(50)
EndFunc

Func Get_Distance($start, $goal)
   Local $ydiff = 0
   Local $xdiff = 0
   Local $diag = 0
   Local $hori = 0
   Local $goalheight = $xy[$goal][5] ; 5 = row
   Local $startheight = $xy[$start][5]
   Local $goalwidth = $xy[$goal][4] ; 4 = column
   Local $startwidth = $xy[$start][4]

   $ydiff = Abs($goalheight - $startheight)
   $xdiff = Abs($goalwidth - $startwidth)

   If $xdiff > $ydiff Then
	  $diag = $ydiff
	  $hori = $xdiff - $ydiff
   Else
	  $diag = $xdiff
	  $hori = $ydiff - $xdiff
   EndIf

   Return (14 * $diag) + (10 * $hori)
EndFunc