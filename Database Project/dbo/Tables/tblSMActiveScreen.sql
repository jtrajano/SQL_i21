CREATE TABLE [dbo].[tblSMActiveScreen] (
    [intActiveScreenID] INT            IDENTITY (1, 1) NOT NULL,
    [strProcessName]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strMenuName]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strMacAddress]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strMachineName]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strUserName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intProcessID]      INT            NULL,
    CONSTRAINT [PK_ActiveScreen] PRIMARY KEY CLUSTERED ([intActiveScreenID] ASC)
);

