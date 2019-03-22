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


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cocurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'intSiteJulianCalendarID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Start Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'dtmStartDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Auto Renew Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnAutoRenew'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Frequency for Interval Pattern',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'intRecurInterval'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recurrency Month for Yearly Pattern (Obsolete)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'intRecurMonth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recurrence Pattern',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'intRecurPattern'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sunday Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnSunday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Monday Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnMonday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tuesday Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnTuesday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Wednesday Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnWednesday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Thursday Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnThursday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Friday Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnFriday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Saturday Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnSaturday'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete/Unused',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastLeaseBillingDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Single Date Override Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMSiteJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'ysnSingleDateOverride'