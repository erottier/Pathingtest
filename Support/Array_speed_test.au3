#INCLUDE <ARRAY.AU3>
;_ArrayReadTest1()
;_ArrayReadTest2()

Global $testtimes = 10

Local $iTime1 = 0
Local $iTime2 = 0
For $iZ = 1 to $testtimes
    $iValue1 = Random(1000,10000,1)
    $iValue2 = Random(10,100,1)

    $iTime1 += _ArrayReadTest1($iValue1,$iValue2, $iZ)
    $iTime2 += _ArrayReadTest2($iValue1,$iValue2, $iZ)
Next

$iTime1 = $iTime1 / $testtimes
$iTime2 = $iTime2 / $testtimes

ConsoleWrite("Array Read Test Average Time: " & $iTime1 & @CRLF)
ConsoleWrite("Variable Read Test Average Time: " & $iTime2 & @CRLF)

Func _ArrayReadTest1($iArrayDimension1,$iArrayDimension2,$runs)
    ConsoleWrite("ArrayReadTest1" & @CRLF)
    ;Create Array for Testing
    Local $aData[$iArrayDimension1][$iArrayDimension2]
    For $iX = 0 to $iArrayDimension1-1
        For $iY = 0 to $iArrayDimension2-1
            $aData[$iX][$iY] = "456"
        Next
    Next
    Local $iDim1 = Random(0,$iArrayDimension1-1,1)
    Local $iDim2 = Random(0,$iArrayDimension2-1,1)
    ;Time Measurement
    Local $hTimer = TimerInit()
    ConsoleWrite($aData[$iDim1][$iDim2] & @TAB)
    ConsoleWrite($aData[$iDim1][$iDim2] & @TAB)
    ConsoleWrite($aData[$iDim1][$iDim2] & @CRLF)
    Local $iTime = TimerDiff($hTimer)
    ConsoleWrite($runs & " <- Duration: " & $iTime & @CRLF & @CRLF)
    $hTimer = 0
   If $runs = $testtimes Then _ArrayDisplay($aData)
    Return $iTime
EndFunc

Func _ArrayReadTest2($iArrayDimension1,$iArrayDimension2,$runs)
    ConsoleWrite("ArrayReadTest2" & @CRLF)
    ;Create Array for Testing
    Local $aData[$iArrayDimension1][$iArrayDimension2]
    For $iX = 0 to $iArrayDimension1-1
        For $iY = 0 to $iArrayDimension2-1
            $aData[$iX][$iY] = "456"
        Next
    Next
    Local $iDim1 = Random(0,$iArrayDimension1-1,1)
    Local $iDim2 = Random(0,$iArrayDimension2-1,1)
	Local $iValue = $aData[$iDim1][$iDim2]
    ;Time Measurement
    Local $hTimer = TimerInit()
    ConsoleWrite($iValue & @TAB)
    ConsoleWrite($iValue & @TAB)
    ConsoleWrite($iValue & @CRLF)
    Local $iTime = TimerDiff($hTimer)
    ConsoleWrite("Duration: " & $iTime & @CRLF & @CRLF)
    $hTimer = 0
    Return $iTime
EndFunc