CREATE TABLE [dbo].[tblTMTankMeasurement] (
    [intConcurrencyId]     INT             DEFAULT 1 NOT NULL,
    [intTankMeasurementID] INT             IDENTITY (1, 1) NOT NULL,
    [intSiteDeviceID]      INT             DEFAULT 0 NOT NULL,
    [dblTankSize]          NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblTankCapacity]      NUMERIC (18, 6) DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMTankMeasurement] PRIMARY KEY CLUSTERED ([intTankMeasurementID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intTankMeasurementID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intSiteDeviceID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Size',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'dblTankSize'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Capacity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'dblTankCapacity'