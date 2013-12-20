CREATE TABLE [dbo].[tblTMDDReadingSeasonResetArchive] (
    [intDDReadingSeasonResetArchiveID] INT             IDENTITY (1, 1) NOT NULL,
    [intSeasonResetArchiveID]          INT             NOT NULL,
    [intDDReadingID]                   INT             NOT NULL,
    [dtmDate]                          DATETIME        NOT NULL,
    [intDegreeDays]                    INT             NOT NULL,
    [dblAccumulatedDD]                 NUMERIC (18, 6) NOT NULL,
    [intClockID]                       INT             NOT NULL,
    [intConcurrencyID]                 INT             NULL
);

