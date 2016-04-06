﻿CREATE TABLE [dbo].[tblFRAccountMonitor](
	[cntId]					INT             IDENTITY (1, 1) NOT NULL,
	[intRowId]				INT             NULL,
	[intRefNo]				INT             NULL,
	[intAccountId]			INT             NULL,
	[strAccountId]			NVARCHAR (70)	COLLATE Latin1_General_CI_AS NULL,
	[strPrimary]			NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[strDescription]		NVARCHAR (300)  COLLATE Latin1_General_CI_AS NULL,
	[strAccountGroup]		NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
	[strAccountType]		NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
	[dtmEntered]			DATETIME		CONSTRAINT [DF_tblFRAccountMonitor_dtmEntered] DEFAULT (getdate()) NOT NULL,
	[ysnMissing]			BIT             NULL,
	[intConcurrencyId]		INT             NULL	
 CONSTRAINT [PK_tblFRAccountMonitor] PRIMARY KEY CLUSTERED ([cntId] ASC)
);