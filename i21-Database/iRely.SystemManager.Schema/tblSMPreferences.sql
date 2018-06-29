CREATE TABLE [dbo].[tblSMPreferences] (
    [intPreferenceID]  INT            IDENTITY (1, 1) NOT NULL,
    [intUserID]        INT            NOT NULL,
    [strPreference]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strValue]         NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intSort]          INT            NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_SMPreferences_PreferenceID] PRIMARY KEY CLUSTERED ([intUserID] ASC, [strPreference] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPreferences',
    @level2type = N'COLUMN',
    @level2name = N'intPreferenceID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPreferences',
    @level2type = N'COLUMN',
    @level2name = N'intUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Preference Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPreferences',
    @level2type = N'COLUMN',
    @level2name = N'strPreference'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPreferences',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPreferences',
    @level2type = N'COLUMN',
    @level2name = N'strValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPreferences',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPreferences',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'