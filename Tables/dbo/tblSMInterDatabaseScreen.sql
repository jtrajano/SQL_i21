CREATE TABLE [dbo].[tblSMInterDatabaseScreen] (
    [intScreenId]      INT            IDENTITY (1, 1) NOT NULL,
    [strScreenId]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strScreenName]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPortalName]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strNamespace]     NVARCHAR (150) COLLATE Latin1_General_CI_AS NOT NULL,
    [strModule]        NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTableName]     NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[ysnApproval]	   BIT NULL,
	[ysnActivity]	   BIT NULL,
	[ysnCustomTab]	   BIT NULL,
    [ysnDocumentSource] BIT NULL, 
    [strApprovalMessage]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT CONSTRAINT [DF__tblSMInterDatabaseScreen] DEFAULT ((1)) NOT NULL,
    [ysnAvailable] BIT NOT NULL DEFAULT 1, 
    [strGroupName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSMInterDatabaseScreen] PRIMARY KEY CLUSTERED ([intScreenId] ASC)
);
