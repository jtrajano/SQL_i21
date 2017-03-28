CREATE TABLE [dbo].[tblTMLeaseDevice]
(
	[intLeaseDeviceId] INT IDENTITY(1,1) NOT NULL , 
    [intLeaseId] INT NOT NULL, 
    [intDeviceId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblTMLeaseDevice] PRIMARY KEY CLUSTERED ([intLeaseDeviceId] ASC),
	CONSTRAINT [FK_tblTMLeaseDevice_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblTMLeaseDevice_tblTMLease] FOREIGN KEY ([intLeaseId]) REFERENCES [dbo].[tblTMLease] ([intLeaseId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseDevice',
    @level2type = N'COLUMN',
    @level2name = N'intLeaseDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lease Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseDevice',
    @level2type = N'COLUMN',
    @level2name = N'intLeaseId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseDevice',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

CREATE NONCLUSTERED INDEX [IX_tblTMLeaseDevice_intDeviceId_intLeaseId] ON [dbo].[tblTMLeaseDevice]
(
	[intDeviceId] ASC,
	[intLeaseId] ASC
)
INCLUDE ( 	[intLeaseDeviceId],
	[intConcurrencyId]) 