CREATE TABLE [dbo].[tblTMJulianCalendarDelivery] (
    [intConcurrencyID]            INT      NULL,
    [intJulianCalendarDeliveryID] INT      IDENTITY (1, 1) NOT NULL,
    [dtmDate]                     DATETIME CONSTRAINT [DEF_tblTMJulianCalendarDelivery_dtmDate] DEFAULT ((0)) NOT NULL,
    [intSiteJulianCalendarID]     INT      CONSTRAINT [DEF_tblTMJulianCalendarDelivery_intSiteJulianCalendarID] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMJulianCalendarDelivery] PRIMARY KEY CLUSTERED ([intJulianCalendarDeliveryID] ASC),
    CONSTRAINT [FK_tblTMJulianCalendarDelivery_tblTMSiteJulianCalendar] FOREIGN KEY ([intSiteJulianCalendarID]) REFERENCES [dbo].[tblTMSiteJulianCalendar] ([intSiteJulianCalendarID]) ON DELETE CASCADE
);

