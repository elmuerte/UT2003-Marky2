//==============================================================================
// Display Mark on your screen
//
// (c) 2003 Michiel 'El Muerte' Hendriks
// $Id: MarkyHud.uc,v 1.1 2003/09/09 10:56:50 elmuerte Exp $
//==============================================================================

class MarkyHud extends Interaction;

var Texture Image;
/** screen location percentages */
var float ImgX, ImgY;
/** scale to screen (1 == 100%) */
var float ImageScale;

simulated function PostRender( canvas Canvas )
{
	local float X, Y, LScale;
	if (Image == none) return;
	X = Canvas.SizeX*ImgX;
	Y = Canvas.SizeY*ImgY;

  Canvas.Reset();
  Canvas.Style = 5; //ERenderStyle.STY_Alpha;
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
}
