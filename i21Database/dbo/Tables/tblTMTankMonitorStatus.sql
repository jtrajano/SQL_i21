CREATE TABLE [dbo].[tblTMTankMonitorStatus]
(
    [intTankMonitorStatusId] INT NOT NULL IDENTITY,
    [intDeviceId] INT NOT NULL,
    [dtmDate] DATETIME NOT NULL,
    [ysnInternetConnectivity] BIT NOT NULL,
    [ysnATGConnectivity] BIT NOT NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblTMTankMonitorStatus] PRIMARY KEY CLUSTERED ([intTankMonitorStatusId] ASC),
    CONSTRAINT [FK_tblTMTankMonitorStatus_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [tblTMDevice]([intDeviceId]) ON DELETE CASCADE,
)