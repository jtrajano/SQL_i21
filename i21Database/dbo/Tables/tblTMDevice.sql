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
    [dblTankCapacity]          NUMERIC(18, 6)             DEFAULT 0 NOT NULL,
    [dblTankReserve]           NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblEstimatedGalTank]      NUMERIC (18, 6) DEFAULT 0 NULL,
    [intMeterCycle]            INT             DEFAULT 0 NOT NULL,
    [intDeviceTypeId]          INT              NULL,
    [intLeaseId]               INT              NULL,
    [intDeployedStatusID]      INT              NULL,
    [intParentDeviceID]        INT              NULL,
    [intInventoryStatusTypeId] INT              NULL,
    [intTankTypeId]            INT              NULL,
    [intMeterTypeId]           INT              NULL,
    [intRegulatorTypeId]       INT              NULL,
    [intLinkedToTankID]        INT              NULL,
    [strMeterStatus]           NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblMeterReading]          NUMERIC (18, 6) DEFAULT 0 NULL,
    [ysnAppliance]             BIT             DEFAULT 0 NOT NULL,
    [intApplianceTypeID]       INT              NULL,
    [intLocationId] INT NULL, 
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

CREATE INDEX [IX_tblTMDevice_strSerialNumber] ON [dbo].[tblTMDevice] ([strSerialNumber])
GO

CREATE NONCLUSTERED INDEX [IX_tblTMDevice_intDeviceTypeId] ON [dbo].[tblTMDevice]
(
	[intDeviceTypeId] ASC
)
GO

CREATE NONCLUSTERED INDEX [IX_tblTMDevice_ysnAppliance_intDeviceId_intDeviceTypeId] ON [dbo].[tblTMDevice]
(
	[ysnAppliance] ASC,
	[intDeviceId] ASC,
	[intDeviceTypeId] ASC
)
GO

