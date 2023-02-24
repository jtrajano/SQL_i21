CREATE TABLE [dbo].[tblTMDeviceTankMonitor]
(
    [intDeviceTankMonitorId] INT IDENTITY(1,1) NOT NULL,
    [intDeviceId] INT NOT NULL,
    [intConcurrencyId]  INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMDeviceTankMonitor_intDeviceTankMonitorId] PRIMARY KEY CLUSTERED (intDeviceTankMonitorId ASC),
    CONSTRAINT [FK_tblTMDeviceTankMonitor_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId])
)

GO
CREATE INDEX [IX_tblTMDeviceTankMonitor_intDeviceId] ON [dbo].[tblTMDeviceTankMonitor] ([intDeviceId])
GO




