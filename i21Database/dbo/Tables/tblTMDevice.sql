CREATE TABLE [dbo].[tblTMDevice] (
    [intConcurrencyId]         INT             DEFAULT 1 NOT NULL,
    [intDeviceId]              INT             IDENTITY (1, 1) NOT NULL,
    [strSerialNumber]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strManufacturerID]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strManufacturerName]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strModelNumber]           NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strBulkPlant]             NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDescription]           NVARCHAR (200)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strOwnership]             NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strAssetNumber]           NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmPurchaseDate]          DATETIME        DEFAULT 0 NULL,
    [dblPurchasePrice]         NUMERIC (18, 6) DEFAULT 0 NULL,
    [dtmManufacturedDate]      DATETIME        DEFAULT 0 NULL,
    [strComment]               NVARCHAR (300)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [ysnUnderground]           BIT             DEFAULT 0 NOT NULL,
    [dblTankSize]              NUMERIC(18, 6)             DEFAULT 0 NOT NULL,
    [dblTankCapacity]          NUMERIC(18, 6)             DEFAULT 0 NOT NULL,
    [dblTankReserve]           NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblEstimatedGalTank]      NUMERIC (18, 6) DEFAULT 0 NULL,
    [intMeterCycle]            INT             DEFAULT 0 NOT NULL,
    [intDeviceTypeId]          INT             DEFAULT 0 NULL,
    [intLeaseId]               INT             DEFAULT 0 NULL,
    [intDeployedStatusID]      INT             DEFAULT 0 NULL,
    [intParentDeviceID]        INT             DEFAULT 0 NULL,
    [intInventoryStatusTypeId] INT             DEFAULT 0 NULL,
    [intTankTypeId]            INT             DEFAULT 0 NULL,
    [intMeterTypeId]           INT             DEFAULT 0 NULL,
    [intRegulatorTypeId]       INT             DEFAULT 0 NULL,
    [intLinkedToTankID]        INT             DEFAULT 0 NULL,
    [strMeterStatus]           NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblMeterReading]          NUMERIC (18, 6) DEFAULT 0 NULL,
    [ysnAppliance]             BIT             DEFAULT 0 NOT NULL,
    [intApplianceTypeID]       INT             DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMDevice] PRIMARY KEY CLUSTERED ([intDeviceId] ASC),
    CONSTRAINT [FK_tblTMDevice_tblTMApplianceType] FOREIGN KEY ([intApplianceTypeID]) REFERENCES [dbo].[tblTMApplianceType] ([intApplianceTypeID]),
    CONSTRAINT [FK_tblTMDevice_tblTMDeployedStatus] FOREIGN KEY ([intDeployedStatusID]) REFERENCES [dbo].[tblTMDeployedStatus] ([intDeployedStatusID]) ON DELETE SET NULL,
    CONSTRAINT [FK_tblTMDevice_tblTMDevice] FOREIGN KEY ([intParentDeviceID]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]),
    CONSTRAINT [FK_tblTMDevice_tblTMDeviceType] FOREIGN KEY ([intDeviceTypeId]) REFERENCES [dbo].[tblTMDeviceType] ([intDeviceTypeId]),
    CONSTRAINT [FK_tblTMDevice_tblTMInventoryStatus] FOREIGN KEY ([intInventoryStatusTypeId]) REFERENCES [dbo].[tblTMInventoryStatusType] ([intInventoryStatusTypeId]),
    CONSTRAINT [FK_tblTMDevice_tblTMLease] FOREIGN KEY ([intLeaseId]) REFERENCES [dbo].[tblTMLease] ([intLeaseId]) ON DELETE SET NULL,
    CONSTRAINT [FK_tblTMDevice_tblTMMeterType] FOREIGN KEY ([intMeterTypeId]) REFERENCES [dbo].[tblTMMeterType] ([intMeterTypeId]),
    CONSTRAINT [FK_tblTMDevice_tblTMRegulatorType] FOREIGN KEY ([intRegulatorTypeId]) REFERENCES [dbo].[tblTMRegulatorType] ([intRegulatorTypeId]),
    CONSTRAINT [FK_tblTMDevice_tblTMTankType] FOREIGN KEY ([intTankTypeId]) REFERENCES [dbo].[tblTMTankType] ([intTankTypeId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Serial Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strSerialNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manufacturer ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strManufacturerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manufacturer Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strManufacturerName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Model Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strModelNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bulk Plant',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strBulkPlant'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ownership',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strOwnership'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Asset Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strAssetNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'dtmPurchaseDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'dblPurchasePrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manufactured Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'dtmManufacturedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Is Underground option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnUnderground'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Size',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'dblTankSize'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Capacity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'dblTankCapacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Reserve',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'dblTankReserve'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estimated Gallons ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'dblEstimatedGalTank'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Cycle ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intMeterCycle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lease ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intLeaseId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deployed Status ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDeployedStatusID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Parent Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intParentDeviceID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Status Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryStatusTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intTankTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intMeterTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Regulator Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intRegulatorTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolet/Unused',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intLinkedToTankID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'strMeterStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'dblMeterReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if an Appliance instead of a Device',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnAppliance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Appliance Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDevice',
    @level2type = N'COLUMN',
    @level2name = N'intApplianceTypeID'