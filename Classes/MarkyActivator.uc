//==============================================================================
// The class responsible for the actual drawing of a face
//
// (c) 2003 Michiel 'El Muerte' Hendriks
// $Id: MarkyActivator.uc,v 1.3 2003/09/10 09:00:25 elmuerte Exp $
//==============================================================================

class MarkyActivator extends Info dependson(MarkyMut);

var string MHClass;
var MarkyHud MH;

var protected float fModX, fModY;
var protected float fFromX, fFromY, fToX, fToY;
var protected float fShowSpeed;
var protected float fWaitTime;
var protected bool bNoReturn;

var array< MarkyMut.FaceRecord > Faces;
var array<int> LastLevels;

var enum MarkShowState
{
	MSS_Show,
	MSS_Hide,
	MSS_Wait,
} ShowState;

event PreBeginPlay()
{
	Log("Warning: Mark Rein loaded into your game...");
}

function Mutate(string MutateString)
{
	local int i;
	i = int(Mid(MutateString, InStr(MutateString, " ")+1));
	if ((i < 0) || (i >= Faces.length)) return;
	ShowMarky(i);
}

event Tick(float delta)
{
	local PlayerController PC;
	local int i, curMKL, curDEATHS, curV;

	PC = Level.GetLocalPlayerController();	
	if ( PC != None && !PC.PlayerReplicationInfo.bIsSpectator)
	{
		if (MH == none)
		{
			MH = MarkyHud(PC.Player.InteractionMaster.AddInteraction(MHClass, PC.Player));
		}
		else {
			curMKL = UnrealPlayer(PC).MultiKillLevel;
			curDEATHS = PC.PlayerReplicationInfo.Deaths;
			for (i = 0; i < Faces.length; i++)
			{
				if (Faces[i].Type == 0) // multi kill
				{
					if (LastLevels[i] < curMKL)
					{
						if (curMKL >= Faces[i].Level) ShowMarky(i);
					}
					LastLevels[i] = curMKL;
				}
				else if (Faces[i].Type == 1) // deaths
				{
					if (LastLevels[i] < curDEATHS)
					{
						if (curDEATHS % Faces[i].Level == 0) ShowMarky(i);
					}
					LastLevels[i] = curDEATHS;
				}
				else if (Faces[i].Type == 2) // killing spree
				{
					if (TeamPlayerReplicationInfo(PC.PlayerReplicationInfo) != none)
					{
						curV = TeamPlayerReplicationInfo(PC.PlayerReplicationInfo).Spree[Faces[i].Level];
						if (LastLevels[i] < curV)
						{
							ShowMarky(i);
						}
						LastLevels[i] = curV;
					}
				}
			}
		}
	}
}

function ShowMarky(int ActiveFace)
{
	local PlayerController PC;

	if (MH == none) return;
	if (ShowState == MSS_Show) return; // already showing	

	if (Faces[ActiveFace].Face != none)
	{
		if (Faces[ActiveFace].fFromX < Faces[ActiveFace].fToX) fModX = 0.01*Faces[ActiveFace].StepSize;
			else fModX = -0.01*Faces[ActiveFace].StepSize;
		if (Faces[ActiveFace].fFromY < Faces[ActiveFace].fToY) fModY = 0.01*Faces[ActiveFace].StepSize;
			else fModY = -0.01*Faces[ActiveFace].StepSize;

		fFromX = Faces[ActiveFace].fFromX;
		fFromY = Faces[ActiveFace].fFromY;
		fToX = Faces[ActiveFace].fToX;
		fToY = Faces[ActiveFace].fToY;
		fShowSpeed = Faces[ActiveFace].fShowSpeed;
		fWaitTime = Faces[ActiveFace].fWaitTime;
		bNoReturn = Faces[ActiveFace].bNoReturn;

		MH.ImgX = Faces[ActiveFace].fFromX;
		MH.ImgY = Faces[ActiveFace].fFromY;
		MH.ImageScale = Faces[ActiveFace].fImageScale;
		MH.bActive = true;
		MH.bVisible = true;
		MH.Image = Faces[ActiveFace].Face;
		ShowState = MSS_Show;
		SetTimer(FMax(fShowSpeed, 0.001), true);
	}

	PC = Level.GetLocalPlayerController();	
	if (Faces[ActiveFace].Voice != none && PC != none)
	{
		PC.ClientPlaySound(Faces[ActiveFace].Voice);
	}
}

function Timer()
{
	local int f;
	f = 0;
	if (ShowState == MSS_Show)
	{
		if ((MH.ImgX < fToX && fModX > 0) || (MH.ImgX > fToX && fModX < 0)) MH.ImgX += fModX;
			else f++;
		if ((MH.ImgY < fToY && fModY > 0) || (MH.ImgY > fToY && fModY < 0)) MH.ImgY += fModY;
			else f++;
		if (f >= 2)
		{			
			ShowState = MSS_Wait;
			SetTimer(FMax(fWaitTime, 0.001), true);			
		}
	}
	else if (ShowState == MSS_Hide)
	{
		if ((MH.ImgX > fFromX && fModX > 0) || (MH.ImgX < fFromX && fModX < 0)) MH.ImgX -= fModX;
			else f++;
		if ((MH.ImgY > fFromY && fModY > 0) || (MH.ImgY < fFromY && fModY < 0)) MH.ImgY -= fModY;
			else f++;

		if (f >= 2)
		{	
			MH.bActive = false;
			MH.bVisible = false;
			SetTimer(0.001, false); // stop the timer again
		}
	}
	else if (ShowState == MSS_Wait)
	{				
		if (bNoReturn)
		{
			MH.bActive = false;
			MH.bVisible = false;
			ShowState = MSS_Hide;
			SetTimer(0.001, false); // stop the timer again
		}
		else {
			ShowState = MSS_Hide;
			SetTimer(FMax(fShowSpeed, 0.001), true);		
		}
	}
}

defaultproperties
{
  RemoteRole=ROLE_None
  bAlwaysTick=true
	MHClass="Marky2.MarkyHud"	
	ShowState=MSS_Hide
}