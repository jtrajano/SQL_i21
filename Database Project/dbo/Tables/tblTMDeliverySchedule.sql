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

