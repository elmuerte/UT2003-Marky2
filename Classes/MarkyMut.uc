//==============================================================================
// Mutator to load Mark Rein into the game
//
// (c) 2003 Michiel 'El Muerte' Hendriks
// $Id: MarkyMut.uc,v 1.2 2003/09/09 20:42:40 elmuerte Exp $
//==============================================================================

class MarkyMut extends Mutator config exportstructs;

// import Mark Rein
#exec TEXTURE IMPORT NAME=MarkReinFace FILE=TEXTURES\marky.dds ALPHA=1 LODSET=LODSET_Interface
#exec AUDIO IMPORT FILE="Sounds\twoweeks.WAV" NAME="MarkReinSound"
// import CliffyB
#exec TEXTURE IMPORT NAME=CliffyBFace FILE=TEXTURES\cliffyb.dds ALPHA=1 LODSET=LODSET_Interface
//# exec AUDIO IMPORT FILE="Sounds\markrein16.WAV" NAME="MarkReinSound"
// import Dopefish
#exec TEXTURE IMPORT NAME=DopefishFace FILE=TEXTURES\dopefish.dds ALPHA=1 LODSET=LODSET_Interface
#exec AUDIO IMPORT FILE="Sounds\dopefish.WAV" NAME="DopefishSound"

var MarkyActivator MarkAct;

struct FaceRecord
{
	/** the face to show */
	var Texture Face;
	/** the voice to playback */
	var Sound Voice;
	/** at what level to react */
	var int Level;
	/** 
		type of event to be triggered at 
		0: multi kill level (level >=)
		1: number of deaths (level ==)
		2: killing spree level (increase) (0-5)
	*/
	var byte Type;
	/** percentages where to show the image */
	var float fFromX, fFromY, fToX, fToY;
	/** number of stemps to take at the time */
	var int StepSize;
	/** interval between each step */
	var float fShowSpeed;
	/** time to show the picture */
	var float fWaitTime;
	/** Scale the image to the screen */
	var float fImageScale;
	/** don't return to from location */
	var bool bNoReturn;
};
/** 
	Faces to show in diffirent configurations 
	Only one shown at the time!!
*/
var config array<FaceRecord> Faces;

simulated function Mutate(string MutateString, PlayerController Sender)
{
	Super.Mutate(MutateString, Sender);
	if (MarkAct != none) 
	{
		if (InStr(Caps(MutateString), "MARKY") == 0) MarkAct.Mutate(MutateString);
	}
}

simulated function Tick(float DeltaTime)
{
	local PlayerController PC;
	PC = Level.GetLocalPlayerController();	
	if ( PC != None && !PC.PlayerReplicationInfo.bIsSpectator && (MarkAct == none))
	{
		MarkAct = spawn(class'MarkyActivator', PC);
		MarkAct.Faces = Faces;
		MarkAct.LastLevels.length = Faces.length;
	}
}

defaultproperties
{
  RemoteRole=ROLE_SimulatedProxy
  bAlwaysRelevant=true

	Faces(0)=(Face=Texture'Marky2.MarkReinFace',Voice=Sound'Marky2.MarkReinSound',Level=2,Type=0,fFromX=1,fFromY=0.60,fToX=0.70,fToY=0.60,fShowSpeed=0.01,fWaitTime=2,StepSize=5,fImageScale=0.4)
	Faces(1)=(Face=Texture'Marky2.CliffyBFace',Voice=none,Level=2,Type=2,fFromX=1,fFromY=0.60,fToX=0.70,fToY=0.60,fShowSpeed=0.01,fWaitTime=2,StepSize=5,fImageScale=0.35)
	Faces(2)=(Face=Texture'Marky2.DopefishFace',Voice=Sound'Marky2.DopefishSound',Level=5,Type=1,fFromX=1,fFromY=0.40,fToX=-0.1,fToY=0.50,fShowSpeed=0.01,StepSize=4,fImageScale=0.2,bNoReturn=true)

	GroupName="Marky"
	FriendlyName="Marky v2"
	Description="Display Mark Rein's face on special events"
}