CREATE TABLE [dbo].[tblTMJulianCalendarDelivery] (
    [intConcurrencyId]            INT      DEFAULT 1 NOT NULL,
    [intJulianCalendarDeliveryID] INT      IDENTITY (1, 1) NOT NULL,
    [dtmDate]                     DATETIME DEFAULT 0 NOT NULL,
    [intSiteJulianCalendarID]     INT      DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMJulianCalendarDelivery] PRIMARY KEY CLUSTERED ([intJulianCalendarDeliveryID] ASC),
    CONSTRAINT [FK_tblTMJulianCalendarDelivery_tblTMSiteJulianCalendar] FOREIGN KEY ([intSiteJulianCalendarID]) REFERENCES [dbo].[tblTMSiteJulianCalendar] ([intSiteJulianCalendarID]) ON DELETE CASCADE
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMJulianCalendarDelivery',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMJulianCalendarDelivery',
    @level2type = N'COLUMN',
    @level2name = N'intJulianCalendarDeliveryID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMJulianCalendarDelivery',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Julian Calendar ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMJulianCalendarDelivery',
    @level2type = N'COLUMN',
    @level2name = N'intSiteJulianCalendarID'