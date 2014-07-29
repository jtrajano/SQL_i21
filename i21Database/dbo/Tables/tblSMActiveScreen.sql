CREATE TABLE [dbo].[tblSMActiveScreen] (
    [intActiveScreenID] INT            IDENTITY (1, 1) NOT NULL,
    [strProcessName]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strMenuName]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strMacAddress]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strMachineName]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strUserName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intProcessID]      INT            NULL,
    [intConcurrencyId]  INT            DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_ActiveScreen] PRIMARY KEY CLUSTERED ([intActiveScreenID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMActiveScreen',
    @level2type = N'COLUMN',
    @level2name = N'intActiveScreenID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Process Name of the executing application',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMActiveScreen',
    @level2type = N'COLUMN',
    @level2name = N'strProcessName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Menu Name that will appear on the Active Screens panel',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMActiveScreen',
    @level2type = N'COLUMN',
    @level2name = N'strMenuName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'MAC Address of the client machine where the screen is currently running',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMActiveScreen',
    @level2type = N'COLUMN',
    @level2name = N'strMacAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Machine name of the client where the screen is currently running',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMActiveScreen',
    @level2type = N'COLUMN',
    @level2name = N'strMachineName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User ID of the curretly logged user running the screen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMActiveScreen',
    @level2type = N'COLUMN',
    @level2name = N'strUserName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Process Id of the client process running the active screen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMActiveScreen',
    @level2type = N'COLUMN',
    @level2name = N'intProcessID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMActiveScreen',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'

GO
