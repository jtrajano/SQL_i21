CREATE TABLE [dbo].[tblGLTempAccount] (
    [cntId]               INT            IDENTITY (1, 1) NOT NULL,
    [strAccountId]        NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strPrimary]          NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strSegment]          NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]      NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strAccountGroup]     NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupId]   INT            NULL,
    [strAccountSegmentId] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intAccountUnitId]    INT            NULL,
    [ysnSystem]           BIT            NULL,
    [ysnActive]           BIT            NULL,
    [intUserId]           INT            NULL,
    [dtmCreated]          DATETIME       CONSTRAINT [DF_tblTempGLAccount_dtmCreated] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblTempGLAccount] PRIMARY KEY CLUSTERED ([cntId] ASC)
);

