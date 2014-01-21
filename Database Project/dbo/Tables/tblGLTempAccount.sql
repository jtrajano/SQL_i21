CREATE TABLE [dbo].[tblGLTempAccount] (
    [cntID]               INT            IDENTITY (1, 1) NOT NULL,
    [strAccountID]        NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strPrimary]          NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strSegment]          NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]      NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strAccountGroup]     NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupID]   INT            NULL,
    [strAccountSegmentID] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intAccountUnitID]	  INT NULL,
	[ysnSystem]			  BIT NULL,
	[ysnActive]			  BIT NULL,
    [intUserID]           INT            NULL,
    [dtmCreated]          DATETIME       CONSTRAINT [DF_tblTempGLAccount_dtmCreated] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblTempGLAccount] PRIMARY KEY CLUSTERED ([cntID] ASC)
);
