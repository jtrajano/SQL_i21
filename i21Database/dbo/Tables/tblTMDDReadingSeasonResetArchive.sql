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
CREATE INDEX [IX_tblTMDDReadingSeasonResetArchive_intClockID] ON [dbo].[tblTMDDReadingSeasonResetArchive] ([intClockID])

GO

CREATE INDEX [IX_tblTMDDReadingSeasonResetArchive_intSeasonResetArchiveID] ON [dbo].[tblTMDDReadingSeasonResetArchive] ([intSeasonResetArchiveID])

GO

CREATE INDEX [IX_tblTMDDReadingSeasonResetArchive_dtmDate] ON [dbo].[tblTMDDReadingSeasonResetArchive] ([dtmDate])
