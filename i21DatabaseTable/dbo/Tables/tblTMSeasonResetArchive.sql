CREATE TABLE [dbo].[tblTMSeasonResetArchive] (
    [intSeasonResetArchiveID] INT            IDENTITY (1, 1) NOT NULL,
    [dtmDate]                 DATETIME       NOT NULL,
    [intUserID]               INT            NOT NULL,
    [strNewSeason]            NVARCHAR (6)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strCurrentSeason]        NVARCHAR (6)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strSeason]               NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intClockID]              INT            NOT NULL,
    [intConcurrencyId]        INT            DEFAULT 1 NOT NULL, 
    CONSTRAINT [PK_tblTMSeasonResetArchive] PRIMARY KEY ([intSeasonResetArchiveID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intSeasonResetArchiveID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'New Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'strNewSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Current Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'strCurrentSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'strSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Clock ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intClockID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'