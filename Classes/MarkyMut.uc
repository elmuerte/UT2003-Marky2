//==============================================================================
// Mutator to load Mark Rein into the game
//
// (c) 2003 Michiel 'El Muerte' Hendriks
// $Id: MarkyMut.uc,v 1.5 2003/09/26 20:30:05 elmuerte Exp $
//==============================================================================

class MarkyMut extends Mutator config exportstructs;

// import Mark Rein
#exec TEXTURE IMPORT NAME=MarkReinFace FILE=TEXTURES\marky.dds ALPHA=1 LODSET=LODSET_Interface
#exec AUDIO IMPORT FILE="Sounds\WHATTHE.WAV" NAME="MarkReinSound"

// import CliffyB
#exec TEXTURE IMPORT NAME=CliffyBFace FILE=TEXTURES\cliffyb.dds ALPHA=1 LODSET=LODSET_Interface
#exec AUDIO IMPORT FILE="Sounds\WhatsUpDoc.wav" NAME="WhatsUpDocSound"

// import Dopefish
#exec TEXTURE IMPORT NAME=DopefishFace FILE=TEXTURES\dopefish.dds ALPHA=1 LODSET=LODSET_Interface
#exec AUDIO IMPORT FILE="Sounds\dopefish.wav" NAME="DopefishSound"

// import Toasty sound, although we don't use it by default
#exec AUDIO IMPORT FILE="Sounds\toasty.wav" NAME="ToastySound"

// import willhaven
#exec TEXTURE IMPORT NAME=WillhavenFace FILE=TEXTURES\willhaven.dds ALPHA=1 LODSET=LODSET_Interface
#exec AUDIO IMPORT FILE="Sounds\nooo.wav" NAME="WillhavenSound"

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
		0: multi kill level (level >= multikill level)
		1: number of deaths (death % level == 0)
		2: killing spree level (increase) (0-5)
		3: number of suicides (suicides % level == 0)
	*/
	var byte Type;
	/** percentages where to show the image */
	var float fFromX, fFromY, fToX, fToY;
	/** number of stemps to take at the time */
	var float StepSize;
	/** interval between each step */
	var float fShowSpeed;
	/** time to show the picture */
	var float fWaitTime;
	/** Scale the image to the screen */
	var float fImageScale;
	/**
		Animation type
		0: move from source to destination and back
				source: fFromX, fFromY
				dest:		fToX, fToY
		1: only move from source to destination
				source: fFromX, fFromY
				dest:		fToX, fToY
		2: zoom in and out
				start size: fFromX,	end size: tToX
				start alpha: fFromY, end alpha fToY
		3: zoom in only

	*/
	var byte Animation;
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

	Faces(0)=(Face=Texture'Marky3.MarkReinFace',Voice=Sound'Marky3.MarkReinSound',Level=2,Type=0,fFromX=1,fFromY=0.60,fToX=0.70,fToY=0.60,fShowSpeed=0.01,fWaitTime=2,StepSize=5,fImageScale=0.4,Animation=0)
	Faces(1)=(Face=Texture'Marky3.CliffyBFace',Voice=Sound'Marky3.WhatsUpDocSound',Level=2,Type=2,fFromX=1,fFromY=0.60,fToX=0.70,fToY=0.60,fShowSpeed=0.01,fWaitTime=2,StepSize=5,fImageScale=0.35,Animation=0)
	Faces(2)=(Face=Texture'Marky3.DopefishFace',Voice=Sound'Marky3.DopefishSound',Level=5,Type=1,fFromX=1,fFromY=0.40,fToX=-0.1,fToY=0.50,fShowSpeed=0.01,StepSize=4,fImageScale=0.2,Animation=1)
	Faces(3)=(Face=Texture'Marky3.WillhavenFace',Voice=Sound'Marky3.WillhavenSound',Level=1,Type=3,fFromX=0.001,fFromY=0,fToX=1,fToY=1,fShowSpeed=0.01,StepSize=3,fImageScale=0.4,Animation=2)

	GroupName="Marky"
	FriendlyName="Marky v3"
	Description="Display Mark Rein's face on special events"
}