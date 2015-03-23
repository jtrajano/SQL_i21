CREATE TABLE [dbo].[tblTMDeliverySchedule] (
    [intConcurrencyId]      INT           DEFAULT 1 NOT NULL,
    [intDeliveryScheduleID] INT           IDENTITY (1, 1) NOT NULL,
    [dtmStartDate]          DATETIME      DEFAULT 0 NOT NULL,
    [dtmEndDate]            DATETIME      DEFAULT 0 NOT NULL,
    [intInterval]           INT           DEFAULT 0 NULL,
    [ysnOnWeekDay]          BIT           DEFAULT 0 NULL,
    [strRecurrencePattern]  NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intSiteID]             INT           DEFAULT 0 NOT NULL,
    [ysnSunday]             BIT           DEFAULT 0 NULL,
    [ysnMonday]             BIT           DEFAULT 0 NULL,
    [ysnTuesday]            BIT           DEFAULT 0 NULL,
    [ysnWednesday]          BIT           DEFAULT 0 NULL,
    [ysnThursday]           BIT           DEFAULT 0 NULL,
    [ysnFriday]             BIT           DEFAULT 0 NULL,
    [ysnSaturday]           BIT           DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMDeliverySchedule] PRIMARY KEY CLUSTERED ([intDeliveryScheduleID] ASC),
    CONSTRAINT [FK_tblTMDeliverySchedule_tblTMDeliverySchedule] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'intDeliveryScheduleID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Start Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'dtmStartDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Days Interval ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'intInterval'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'On Week Day',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'ysnOnWeekDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recurrence Pattern',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'strRecurrencePattern'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deliver on Sunday ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'ysnSunday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deliver on Monday',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'ysnMonday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deliver on Tuesday',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'ysnTuesday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deliver on Wednesday',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'ysnWednesday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deliver on Thursday',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'ysnThursday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deliver on Friday',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'ysnFriday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deliver on Saturday',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliverySchedule',
    @level2type = N'COLUMN',
    @level2name = N'ysnSaturday'