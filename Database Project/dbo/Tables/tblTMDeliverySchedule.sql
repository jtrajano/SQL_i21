CREATE TABLE [dbo].[tblTMDeliverySchedule] (
    [intConcurrencyID]      INT           CONSTRAINT [DEF_tblTMDeliverySchedule_intConcurrencyID] DEFAULT ((0)) NULL,
    [intDeliveryScheduleID] INT           IDENTITY (1, 1) NOT NULL,
    [dtmStartDate]          DATETIME      CONSTRAINT [DEF_tblTMDeliverySchedule_dtmStartDate] DEFAULT ((0)) NOT NULL,
    [dtmEndDate]            DATETIME      CONSTRAINT [DEF_tblTMDeliverySchedule_dtmEndDate] DEFAULT ((0)) NOT NULL,
    [intInterval]           INT           CONSTRAINT [DEF_tblTMDeliverySchedule_intInterval] DEFAULT ((0)) NULL,
    [ysnOnWeekDay]          BIT           CONSTRAINT [DEF_tblTMDeliverySchedule_ysnOnWeekDay] DEFAULT ((0)) NULL,
    [strRecurrencePattern]  NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMDeliverySchedule_strRecurrencePattern] DEFAULT ('') NULL,
    [intSiteID]             INT           CONSTRAINT [DEF_tblTMDeliverySchedule_intSiteID] DEFAULT ((0)) NOT NULL,
    [ysnSunday]             BIT           CONSTRAINT [DEF_tblTMDeliverySchedule_ysnSunday] DEFAULT ((0)) NULL,
    [ysnMonday]             BIT           CONSTRAINT [DEF_tblTMDeliverySchedule_ysnMonday] DEFAULT ((0)) NULL,
    [ysnTuesday]            BIT           CONSTRAINT [DEF_tblTMDeliverySchedule_ysnTuesday] DEFAULT ((0)) NULL,
    [ysnWednesday]          BIT           CONSTRAINT [DEF_tblTMDeliverySchedule_ysnWednesday] DEFAULT ((0)) NULL,
    [ysnThursday]           BIT           CONSTRAINT [DEF_tblTMDeliverySchedule_ysnThursday] DEFAULT ((0)) NULL,
    [ysnFriday]             BIT           CONSTRAINT [DEF_tblTMDeliverySchedule_ysnFriday] DEFAULT ((0)) NULL,
    [ysnSaturday]           BIT           CONSTRAINT [DEF_tblTMDeliverySchedule_ysnSaturday] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMDeliverySchedule] PRIMARY KEY CLUSTERED ([intDeliveryScheduleID] ASC),
    CONSTRAINT [FK_tblTMDeliverySchedule_tblTMDeliverySchedule] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
);

