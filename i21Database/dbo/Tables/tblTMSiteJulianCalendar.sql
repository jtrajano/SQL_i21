CREATE TABLE [dbo].[tblTMSiteJulianCalendar] (
    [intConcurrencyId]        INT            DEFAULT 1 NOT NULL,
    [intSiteJulianCalendarID] INT            IDENTITY (1, 1) NOT NULL,
    [strDescription]          NVARCHAR (200) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmStartDate]            DATETIME       DEFAULT 0 NULL,
    [dtmEndDate]              DATETIME       DEFAULT 0 NULL,
    [ysnAutoRenew]            BIT            DEFAULT 0 NULL,
    [intSiteID]               INT            DEFAULT 0 NOT NULL,
    [intRecurInterval]        INT            DEFAULT 0 NOT NULL,
    [intRecurMonth]           INT            DEFAULT 0 NULL,
    [intRecurPattern]         INT            DEFAULT 0 NOT NULL,
    [ysnSunday]               BIT            DEFAULT 0 NOT NULL,
    [ysnMonday]               BIT            DEFAULT 0 NOT NULL,
    [ysnTuesday]              BIT            DEFAULT 0 NOT NULL,
    [ysnWednesday]            BIT            DEFAULT 0 NOT NULL,
    [ysnThursday]             BIT            DEFAULT 0 NOT NULL,
    [ysnFriday]               BIT            DEFAULT 0 NOT NULL,
    [ysnSaturday]             BIT            DEFAULT 0 NOT NULL,
    [dtmLastLeaseBillingDate] DATETIME       NULL,
    [ysnSingleDateOverride]   BIT            CONSTRAINT [DF_tblTMSiteJulianCalendar_ysnSingleDateOverride] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMSiteJulianCalendar] PRIMARY KEY CLUSTERED ([intSiteJulianCalendarID] ASC),
    CONSTRAINT [FK_tblTMSiteJulianCalendar_tblTMSiteJulianCalendar] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
);

