CREATE TABLE [dbo].[tblTMDegreeDayReading] (
    [intConcurrencyId]        INT             DEFAULT 1 NOT NULL,
    [intDegreeDayReadingID]   INT             IDENTITY (1, 1) NOT NULL,
    [intClockLocationID]      INT             DEFAULT 0 NOT NULL,
    [dtmDate]                 DATETIME        DEFAULT 0 NULL,
    [intDegreeDays]           INT             DEFAULT 0 NULL,
    [dblAccumulatedDegreeDay] NUMERIC (18, 6) DEFAULT 0 NULL,
    [strSeason]               NVARCHAR (20)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intUserID]               INT             DEFAULT 0 NULL,
    [dtmLastUpdated]          DATETIME        DEFAULT 0 NULL,
    [intClockID]              INT             DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMDDReading] PRIMARY KEY CLUSTERED ([intDegreeDayReadingID] ASC),
    CONSTRAINT [FK_tblTMDDReading_tblTMClock] FOREIGN KEY ([intClockID]) REFERENCES [dbo].[tblTMClock] ([intClockID]) ON DELETE CASCADE
);

