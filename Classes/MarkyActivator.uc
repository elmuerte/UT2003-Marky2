//==============================================================================
// The class responsible for the actual drawing of a face
//
// (c) 2003 Michiel 'El Muerte' Hendriks
// $Id: MarkyActivator.uc,v 1.4 2003/09/26 20:30:05 elmuerte Exp $
//==============================================================================

class MarkyActivator extends Info dependson(MarkyMut);

var string MHClass;
var MarkyHud MH;

var protected float fModX, fModY;
var protected float fFromX, fFromY, fToX, fToY;
var protected float fShowSpeed;
var protected float fWaitTime;
var protected float fImageScale;
var protected bool bNoReturn;
var protected byte Animation;

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
	if ((i < 0) || (i >= Faces.length))
	{
		log("Warning: no such marky:"@i);
		return;
	}
	ShowMarky(i);
}

event Tick(float delta)
{
	local PlayerController PC;
	local int i, curMKL, curDEATHS, curV, curSUIC;

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
			if (TeamPlayerReplicationInfo(PC.PlayerReplicationInfo) != none)
				curSUIC = TeamPlayerReplicationInfo(PC.PlayerReplicationInfo).Suicides;
				else curSUIC = 0;
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
				else if (Faces[i].Type == 3) // Suicides
				{
					if (LastLevels[i] < curSUIC)
					{
						if (curSUIC % Faces[i].Level == 0) ShowMarky(i);
					}
					LastLevels[i] = curSUIC;
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
		fImageScale = Faces[ActiveFace].fImageScale;
		Animation = Faces[ActiveFace].Animation;

		if (Animation == 0 || Animation == 1)
		{
			MH.bCenter = false;
			MH.ImageAlpha = 1;
			MH.ImgX = fFromX;
			MH.ImgY = fFromY;
			MH.ImageScale = fImageScale;
		}
		if (Animation == 2 || Animation == 3)
		{
			MH.bCenter = true;
			MH.ImageAlpha = fFromY;
			fModX = fModX*fImageScale;
			fFromX = fFromX*fImageScale;
			fToX = fToX*fImageScale;
			MH.ImageScale = fFromX;
		}

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
		if (Animation == 0 || Animation == 1)
		{
			if ((MH.ImgX < fToX && fModX > 0) || (MH.ImgX > fToX && fModX < 0)) MH.ImgX += fModX;
				else f++;
			if ((MH.ImgY < fToY && fModY > 0) || (MH.ImgY > fToY && fModY < 0)) MH.ImgY += fModY;
				else f++;
		}
		else if (Animation == 2 || Animation == 3)
		{
			if ((MH.ImageScale < fToX && fModX > 0) || (MH.ImageScale > fToX && fModX < 0)) MH.ImageScale += fModX;
				else f++;
			if ((MH.ImageAlpha < fToY && fModY > 0) || (MH.ImageAlpha > fToY && fModY < 0)) MH.ImageAlpha += fModY;
				else f++;
		}

		if (f >= 2)
		{			
			ShowState = MSS_Wait;
			SetTimer(FMax(fWaitTime, 0.001), true);			
		}
	}
	else if (ShowState == MSS_Hide)
	{
		if (Animation == 0 || Animation == 1)
		{
			if ((MH.ImgX > fFromX && fModX > 0) || (MH.ImgX < fFromX && fModX < 0)) MH.ImgX -= fModX;
				else f++;
			if ((MH.ImgY > fFromY && fModY > 0) || (MH.ImgY < fFromY && fModY < 0)) MH.ImgY -= fModY;
				else f++;
		}
		else if (Animation == 2 || Animation == 3)
		{
			if ((MH.ImageScale > fFromX && fModX > 0) || (MH.ImageScale < fFromX && fModX < 0)) MH.ImageScale -= fModX;
				else f++;
			if ((MH.ImageAlpha > fFromY && fModY > 0) || (MH.ImageAlpha < fFromY && fModY < 0)) MH.ImageAlpha -= fModY;
				else f++;
		}

		if (f >= 2)
		{	
			MH.bActive = false;
			MH.bVisible = false;
			SetTimer(0.001, false); // stop the timer again
		}
	}
	else if (ShowState == MSS_Wait)
	{				
		if (Animation == 1 || Animation == 3)
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
	MHClass="Marky3.MarkyHud"	
	ShowState=MSS_Hide
}