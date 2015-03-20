CREATE TABLE [dbo].[tblTMDDReadingSeasonResetArchive] (
    [intDDReadingSeasonResetArchiveID] INT             IDENTITY (1, 1) NOT NULL,
    [intSeasonResetArchiveID]          INT             NOT NULL,
    [intDDReadingID]                   INT             NOT NULL,
    [dtmDate]                          DATETIME        NOT NULL,
    [intDegreeDays]                    INT             NOT NULL,
    [dblAccumulatedDD]                 NUMERIC (18, 6) NOT NULL,
    [intClockID]                       INT             NOT NULL,
    [intConcurrencyId]                 INT             DEFAULT 1 NOT NULL
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDDReadingSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intDDReadingSeasonResetArchiveID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDDReadingSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Season Reset Archive ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDDReadingSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intSeasonResetArchiveID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Degree Day reading ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDDReadingSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intDDReadingID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reading Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDDReadingSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Degree day reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDDReadingSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intDegreeDays'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accumulated Degree day',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDDReadingSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'dblAccumulatedDD'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Clock Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDDReadingSeasonResetArchive',
    @level2type = N'COLUMN',
    @level2name = N'intClockID'