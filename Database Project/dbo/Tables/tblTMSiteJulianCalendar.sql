CREATE TABLE [dbo].[tblTMSiteJulianCalendar] (
    [intConcurrencyID]        INT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_intConcurrencyID] DEFAULT ((0)) NULL,
    [intSiteJulianCalendarID] INT            IDENTITY (1, 1) NOT NULL,
    [strDescription]          NVARCHAR (200) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMSiteJulianCalendar_strDescription] DEFAULT ('') NULL,
    [dtmStartDate]            DATETIME       CONSTRAINT [DEF_tblTMSiteJulianCalendar_dtmStartDate] DEFAULT ((0)) NULL,
    [dtmEndDate]              DATETIME       CONSTRAINT [DEF_tblTMSiteJulianCalendar_dtmEndDate] DEFAULT ((0)) NULL,
    [ysnAutoRenew]            BIT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnAutoRenew] DEFAULT ((0)) NULL,
    [intSiteID]               INT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_intSiteID] DEFAULT ((0)) NOT NULL,
    [intRecurInterval]        INT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_intRecurInterval] DEFAULT ((1)) NOT NULL,
    [intRecurMonth]           INT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_intRecurMonth] DEFAULT ((0)) NULL,
    [intRecurPattern]         INT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_intRecurPattern] DEFAULT ((0)) NOT NULL,
    [ysnSunday]               BIT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnSunday] DEFAULT ((0)) NOT NULL,
    [ysnMonday]               BIT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnMonday] DEFAULT ((0)) NOT NULL,
    [ysnTuesday]              BIT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnTuesday] DEFAULT ((0)) NOT NULL,
    [ysnWednesday]            BIT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnWednesday] DEFAULT ((0)) NOT NULL,
    [ysnThursday]             BIT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnThursday] DEFAULT ((0)) NOT NULL,
    [ysnFriday]               BIT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnFriday] DEFAULT ((0)) NOT NULL,
    [ysnSaturday]             BIT            CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnSaturday] DEFAULT ((0)) NOT NULL,
    [dtmLastLeaseBillingDate] DATETIME       NULL,
    [ysnSingleDateOverride]   BIT            CONSTRAINT [DF_tblTMSiteJulianCalendar_ysnSingleDateOverride] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMSiteJulianCalendar] PRIMARY KEY CLUSTERED ([intSiteJulianCalendarID] ASC),
    CONSTRAINT [FK_tblTMSiteJulianCalendar_tblTMSiteJulianCalendar] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
);

