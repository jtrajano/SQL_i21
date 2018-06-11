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
    [ysnSeasonStart] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblTMDDReading] PRIMARY KEY CLUSTERED ([intDegreeDayReadingID] ASC),
	CONSTRAINT [UQ_tblTMDegreeDayReading] UNIQUE NONCLUSTERED 
	(
		[intClockID] ASC,
		[dtmDate] ASC
	),
    CONSTRAINT [FK_tblTMDDReading_tblTMClock] FOREIGN KEY ([intClockID]) REFERENCES [dbo].[tblTMClock] ([intClockID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_tblTMDegreeDayReading_intClockID_dtmDate] ON [dbo].[tblTMDegreeDayReading]
(
	[intClockID] ASC,
	[dtmDate] ASC
)
INCLUDE ([intDegreeDays])
GO

CREATE NONCLUSTERED INDEX [IX_tblTMDegreeDayReading_dtmDate_intClockID_intDegreeDayReadingID] ON [dbo].[tblTMDegreeDayReading]
(
	[dtmDate] ASC,
	[intClockID] ASC,
	[intDegreeDayReadingID] ASC
)
INCLUDE ([intConcurrencyId],
	[intClockLocationID],
	[intDegreeDays],
	[dblAccumulatedDegreeDay],
	[strSeason],
	[intUserID],
	[dtmLastUpdated],
	[ysnSeasonStart])
GO
