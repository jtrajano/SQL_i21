CREATE TABLE [dbo].[tblTMSyncOutOfRange] (
    [intSyncOutOfRangeID] INT      IDENTITY (1, 1) NOT NULL,
    [intSiteID]           INT      NOT NULL,
    [dtmDateSync]         DATETIME NOT NULL,
    [ysnCommit]           BIT      DEFAULT 0 NOT NULL,
    [intConcurrencyId]    INT      DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMSyncOutOfRange] PRIMARY KEY CLUSTERED ([intSyncOutOfRangeID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncOutOfRange',
    @level2type = N'COLUMN',
    @level2name = N'intSyncOutOfRangeID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncOutOfRange',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sync Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncOutOfRange',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateSync'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inidcates if record is finalized',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncOutOfRange',
    @level2type = N'COLUMN',
    @level2name = N'ysnCommit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSyncOutOfRange',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'