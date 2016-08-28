#cs ----------------------------------------------------------------------------

 AutoIt Version: 0.1.0
 Author:         Aleksa Ilic

 Script Function:
	Generates an image of your iTunes library

#ce ----------------------------------------------------------------------------

#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <GuiConstants.au3>

Local $pathTemplate=@ScriptDir & "\img"

Msgbox(64,"Info","Please move your mouse so it can't be captured. You have 2 seconds after closing this message box.")
Sleep(2000)

Local $itunes = WinWait("[CLASS:iTunes]")
WinActivate($itunes)
WinWaitActive($itunes)
WinSetState($itunes, "", @SW_MAXIMIZE)
Send("{HOME}")

Local $i = 0
Local $path
Local $prev
While $i <= 100 ;If somehow script failes to recognize duplicate images a limit number is set.
   Sleep(500)
   $path=$pathTemplate & $i & ".jpg"
   _ScreenCapture_Capture($path, 20,92, 1650,980) ;These numbers should be generated from window information, will do that in next version

   If $i>0 Then ;Only check for duplicates once at least 2 images are obtained
	  If checkDuplicate($path,$prev) Then
		 FileDelete($path)
		 ExitLoop
	  EndIf
   EndIf

   $prev=$path

   $i = $i + 1
   Send("{PGDN}") ;Yep, I am really using page down to move through the list.
WEnd

Merge($i)

Func Merge($num)
   Local $MergedImageBackgroundColor = 0xFF000000 ;Adding a background color just for safekeeping

   _GDIPlus_Startup()
   Local $imgArr[$num]

   ;Load images from files
   Local $i=0
   While $i<$num
	  $imgArr[$i]=_GDIPlus_ImageLoadFromFile($pathTemplate & $i & ".jpg")
	  $i=$i+1
   WEnd

   ;As all of them are equal sizewise, just grab info from the first
   Local $width=_GDIPlus_ImageGetWidth($imgArr[0])
   Local $height=_GDIPlus_ImageGetHeight($imgArr[0])

   ; Define the Merged (Composite) image size
   $GuiSizeX = $width
   $GuiSizeY = $height * $num

   ; Initialise the Drawing windows/composite image...
   $hGui = GUICreate("GDIPlus Merger", $GuiSizeX, $GuiSizeY)

   ; Create Double Buffer, so the doesn't need to be repainted on PAINT-Event
   $hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($hGui)                                   ;Draw to this graphics, $hGraphicGUI, to display on GUI
   $hBMPBuff = _GDIPlus_BitmapCreateFromGraphics($GuiSizeX, $GuiSizeY, $hGraphicGUI)       ; $hBMPBuff is a bitmap in memory
   $hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff)

   ; Fill Graphics zone in white color
   _GDIPlus_GraphicsClear($hGraphic, $MergedImageBackgroundColor)

   ;Put Graphics on canvas and merge them
   $i=0
   While $i<$num
	  _GDIPlus_GraphicsDrawImageRectRect($hGraphic, $imgArr[$i], 0, 0, $width, $height, 0, $height * $i , $width, $height)
	  $i=$i+1
   WEnd

   ; Save composite image
   Local $newName = @ScriptDir & "\merged.jpg"
   _GDIPlus_ImageSaveToFile($hBMPBuff, $newName)


   ;Tidy up the mess
   $i=0
   While $i<$num
	  _GDIPlus_ImageDispose($imgArr[$i])
	  $i=$i+1
   WEnd
    _GDIPlus_GraphicsDispose($hGraphic)
    _GDIPlus_GraphicsDispose($hGraphicGUI)
    _WinAPI_DeleteObject($hBMPBuff)
    _GDIPlus_Shutdown()

EndFunc

;This is not a great method for image comparison but it will suffice
Func checkDuplicate($path1, $path2)
   $image1 = FileRead($path1)
   $image2 = FileRead($path2)
   If $image1==$image2 Then
	  Return True
   Else
	  Return False
   EndIf
EndFunc