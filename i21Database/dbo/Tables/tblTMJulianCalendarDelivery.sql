CREATE TABLE [dbo].[tblTMJulianCalendarDelivery] (
    [intConcurrencyId]            INT      DEFAULT 1 NOT NULL,
    [intJulianCalendarDeliveryID] INT      IDENTITY (1, 1) NOT NULL,
    [dtmDate]                     DATETIME DEFAULT 0 NOT NULL,
    [intSiteJulianCalendarID]     INT      DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMJulianCalendarDelivery] PRIMARY KEY CLUSTERED ([intJulianCalendarDeliveryID] ASC),
    CONSTRAINT [FK_tblTMJulianCalendarDelivery_tblTMSiteJulianCalendar] FOREIGN KEY ([intSiteJulianCalendarID]) REFERENCES [dbo].[tblTMSiteJulianCalendar] ([intSiteJulianCalendarID]) ON DELETE CASCADE
);

