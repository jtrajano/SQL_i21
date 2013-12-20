CREATE TABLE [dbo].[tblTMDegreeDayReading] (
    [intConcurrencyID]        INT             CONSTRAINT [DEF_tblTMDDReading_intConcurrencyID] DEFAULT ((0)) NULL,
    [intDegreeDayReadingID]   INT             IDENTITY (1, 1) NOT NULL,
    [intClockLocationID]      INT             CONSTRAINT [DEF_tblTMDDReading_intDDClockLocationID] DEFAULT ((0)) NOT NULL,
    [dtmDate]                 DATETIME        CONSTRAINT [DEF_tblTMDDReading_dtmDate] DEFAULT ((0)) NULL,
    [intDegreeDays]           INT             CONSTRAINT [DEF_tblTMDDReading_intDegreeDays] DEFAULT ((0)) NULL,
    [dblAccumulatedDegreeDay] NUMERIC (18, 6) CONSTRAINT [DEF_tblTMDDReading_dblAccumulatedDD] DEFAULT ((0)) NULL,
    [strSeason]               NVARCHAR (20)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMDDReading_strSeason] DEFAULT ('') NULL,
    [intUserID]               INT             CONSTRAINT [DEF_tblTMDDReading_intUserID] DEFAULT ((0)) NULL,
    [dtmLastUpdated]          DATETIME        CONSTRAINT [DEF_tblTMDDReading_dtmLastUpdated] DEFAULT ((0)) NULL,
    [intClockID]              INT             CONSTRAINT [DEF_tblTMDDReading_intClockID] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMDDReading] PRIMARY KEY CLUSTERED ([intDegreeDayReadingID] ASC),
    CONSTRAINT [FK_tblTMDDReading_tblTMClock] FOREIGN KEY ([intClockID]) REFERENCES [dbo].[tblTMClock] ([intClockID]) ON DELETE CASCADE
);

