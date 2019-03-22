﻿CREATE TABLE [dbo].[tblSMScreen] (
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
	[ysnSearch]			BIT NULL DEFAULT ((0)),
    [strApprovalMessage]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT CONSTRAINT [DF__tblSMScreen] DEFAULT ((1)) NOT NULL,
    [ysnAvailable] BIT NOT NULL DEFAULT 1, 
    [strGroupName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSMScreen] PRIMARY KEY CLUSTERED ([intScreenId] ASC)
);



GO

CREATE INDEX [IX_tblSMScreen_strScreenName] ON [dbo].[tblSMScreen] ([strScreenName])

GO

CREATE INDEX [IX_tblSMScreen_strModule] ON [dbo].[tblSMScreen] ([strModule])

GO

CREATE INDEX [IX_tblSMScreen_strScreenId] ON [dbo].[tblSMScreen] ([strScreenId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreen',
    @level2type = N'COLUMN',
    @level2name = N'intScreenId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Screen Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreen',
    @level2type = N'COLUMN',
    @level2name = N'strScreenId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Screen Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreen',
    @level2type = N'COLUMN',
    @level2name = N'strScreenName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Namespace of the Screen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreen',
    @level2type = N'COLUMN',
    @level2name = N'strNamespace'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Module Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreen',
    @level2type = N'COLUMN',
    @level2name = N'strModule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Table Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreen',
    @level2type = N'COLUMN',
    @level2name = N'strTableName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreen',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'