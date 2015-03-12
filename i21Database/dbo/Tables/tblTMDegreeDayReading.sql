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
	CONSTRAINT [UQ_tblTMDegreeDayReading] UNIQUE NONCLUSTERED 
	(
		[intClockID] ASC,
		[dtmDate] ASC
	),
    CONSTRAINT [FK_tblTMDDReading_tblTMClock] FOREIGN KEY ([intClockID]) REFERENCES [dbo].[tblTMClock] ([intClockID]) ON DELETE CASCADE
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'intDegreeDayReadingID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete /not used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'intClockLocationID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reading Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Degree Days',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'intDegreeDays'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accum DD',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'dblAccumulatedDegreeDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete /not used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'strSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete /not used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'intUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete /not used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Clock ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDegreeDayReading',
    @level2type = N'COLUMN',
    @level2name = N'intClockID'