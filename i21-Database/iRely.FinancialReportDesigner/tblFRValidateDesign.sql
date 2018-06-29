CREATE TABLE [dbo].[tblFRValidateDesign](
	[cntId]				INT				IDENTITY (1, 1) NOT NULL,
	[intDesign]			INT				NULL,
	[intType]			INT				NULL,
	[strType]			NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[strName]			NVARCHAR (255)	COLLATE Latin1_General_CI_AS NULL,
	[strDescription]	NVARCHAR (150)	COLLATE Latin1_General_CI_AS NULL,
	[intUserId]			INT				NULL,
	[dtmEntered]		DATETIME		CONSTRAINT [DF_tblFRValidateDesign_dtmEntered] DEFAULT (getdate()) NOT NULL,
	CONSTRAINT [PK_tblFRValidateDesign] PRIMARY KEY CLUSTERED ([cntId] ASC)
);