//==============================================================================
// Display Mark on your screen
//
// (c) 2003 Michiel 'El Muerte' Hendriks
// $Id: MarkyHud.uc,v 1.2 2003/09/26 20:30:05 elmuerte Exp $
//==============================================================================

class MarkyHud extends Interaction;

var Texture Image;
/** screen location percentages */
var float ImgX, ImgY;
/** scale to screen (1 == 100%) */
var float ImageScale;
/** alpha blending */
var float ImageAlpha;
/** draw the image in the center of the screen */
var bool bCenter;

simulated function PostRender( canvas Canvas )
{
	local float X, Y, LScale;
	if (Image == none) return;
	Canvas.Reset();
	LScale = Canvas.SizeX/float(Image.USize)*ImageScale;

	if (bCenter)
	{		
		X = (Canvas.SizeX/2)-round(ImageScale*float(Image.USize)*2);
		log(X@Canvas.SizeX@ImageScale@Image.USize);		
		Y = (Canvas.SizeY/2)-round(ImageScale*float(Image.VSize)*2);
		log(Y@Canvas.SizeY@ImageScale@Image.VSize);
	}
	else {
		X = Canvas.SizeX*ImgX;
		Y = Canvas.SizeY*ImgY;
	}

  Canvas.Style = 5; //ERenderStyle.STY_Alpha;
	Canvas.SetDrawColor(255,255,255, 255*FMin(ImageAlpha, 1));
	Canvas.SetPos(X, Y);
	LScale = Canvas.SizeX/Image.USize*ImageScale;
  Canvas.DrawIcon(Image, LScale);
}

/** remove ourself */
simulated function NotifyLevelChange ()
{
 	Master.RemoveInteraction(Self);
}

defaultproperties
{
	bActive=false
	bVisible=false
	ImageAlpha=1
}
