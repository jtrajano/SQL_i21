CREATE TABLE [dbo].[tblTMSiteDeviceTankMonitor]
(
    [intSiteDeviceTankMonitorId] INT IDENTITY(1,1) NOT NULL,
    [intDeviceTankMonitorId] INT NOT NULL,
    [intSiteId] INT NOT NULL,
    [intConcurrencyId]  INT DEFAULT 1 NOT NULL,
   CONSTRAINT [PK_tblTMSiteDeviceTankMonitor_intSiteDeviceTankMonitorId] PRIMARY KEY CLUSTERED([intSiteDeviceTankMonitorId]),
   CONSTRAINT [FK_tblTMSiteDeviceTankMonitor_tblTMDeviceTankMonitor_intDeviceTankMonitorId] FOREIGN KEY ([intDeviceTankMonitorId]) REFERENCES [dbo].[tblTMDeviceTankMonitor] (intDeviceTankMonitorId),
   CONSTRAINT [FK_tblTMSiteDeviceTankMonitor_tblTMSite_intSiteID] FOREIGN KEY (intSiteId) REFERENCES [dbo].[tblTMSite] (intSiteID),
)

GO

CREATE INDEX [IX_tblTMSiteDeviceTankMonitor_intDeviceTankMonitorId] ON [dbo].[tblTMSiteDeviceTankMonitor] ([intDeviceTankMonitorId])
GO

CREATE INDEX [IX_tblTMSiteDeviceTankMonitor_intSiteId] ON [dbo].[tblTMSiteDeviceTankMonitor] ([intSiteId])
GO






