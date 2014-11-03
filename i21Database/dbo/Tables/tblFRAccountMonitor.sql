CREATE TABLE [dbo].[tblFRAccountMonitor](
	[cntId]					INT             IDENTITY (1, 1) NOT NULL,
	[intRowId]				INT             NOT NULL,
	[intAccountId]			INT             NOT NULL,
	[strAccountId]			NVARCHAR (70)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strPrimary]			NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription]		NVARCHAR (300)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strAccountGroup]		NVARCHAR (250)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strAccountType]		NVARCHAR (150)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]		INT             NULL,
	[dtmEntered]			DATETIME       CONSTRAINT [DF_tblFRAccountMonitor_dtmEntered] DEFAULT (getdate()) NOT NULL,
 CONSTRAINT [PK_tblFRAccountMonitor] PRIMARY KEY CLUSTERED ([cntId] ASC)
);