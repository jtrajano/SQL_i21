﻿CREATE TABLE [dbo].[tblTMDevice] (
    [intConcurrencyId]         INT             DEFAULT 1 NOT NULL,
    [intDeviceID]              INT             IDENTITY (1, 1) NOT NULL,
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
    [intTankSize]              INT             DEFAULT 0 NOT NULL,
    [intTankCapacity]          INT             DEFAULT 0 NOT NULL,
    [dblTankReserve]           NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblEstimatedGalTank]      NUMERIC (18, 6) DEFAULT 0 NULL,
    [intMeterCycle]            INT             DEFAULT 0 NOT NULL,
    [intDeviceTypeId]          INT             DEFAULT 0 NULL,
    [intLeaseID]               INT             DEFAULT 0 NULL,
    [intDeployedStatusID]      INT             DEFAULT 0 NULL,
    [intParentDeviceID]        INT             DEFAULT 0 NULL,
    [intInventoryStatusTypeId] INT             DEFAULT 0 NULL,
    [intTankTypeId]            INT             DEFAULT 0 NULL,
    [intMeterTypeId]           INT             DEFAULT 0 NULL,
    [intRegulatorTypeID]       INT             DEFAULT 0 NULL,
    [intLinkedToTankID]        INT             DEFAULT 0 NULL,
    [strMeterStatus]           NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblMeterReading]          NUMERIC (18, 6) DEFAULT 0 NULL,
    [ysnAppliance]             BIT             DEFAULT 0 NOT NULL,
    [intApplianceTypeID]       INT             DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMDevice] PRIMARY KEY CLUSTERED ([intDeviceID] ASC),
    CONSTRAINT [FK_tblTMDevice_tblTMApplianceType] FOREIGN KEY ([intApplianceTypeID]) REFERENCES [dbo].[tblTMApplianceType] ([intApplianceTypeID]),
    CONSTRAINT [FK_tblTMDevice_tblTMDeployedStatus] FOREIGN KEY ([intDeployedStatusID]) REFERENCES [dbo].[tblTMDeployedStatus] ([intDeployedStatusID]) ON DELETE SET NULL,
    CONSTRAINT [FK_tblTMDevice_tblTMDevice] FOREIGN KEY ([intParentDeviceID]) REFERENCES [dbo].[tblTMDevice] ([intDeviceID]),
    CONSTRAINT [FK_tblTMDevice_tblTMDeviceType] FOREIGN KEY ([intDeviceTypeId]) REFERENCES [dbo].[tblTMDeviceType] ([intDeviceTypeId]),
    CONSTRAINT [FK_tblTMDevice_tblTMInventoryStatus] FOREIGN KEY ([intInventoryStatusTypeId]) REFERENCES [dbo].[tblTMInventoryStatusType] ([intInventoryStatusTypeId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_tblTMDevice_tblTMLease] FOREIGN KEY ([intLeaseID]) REFERENCES [dbo].[tblTMLease] ([intLeaseID]) ON DELETE SET NULL,
    CONSTRAINT [FK_tblTMDevice_tblTMMeterType] FOREIGN KEY ([intMeterTypeId]) REFERENCES [dbo].[tblTMMeterType] ([intMeterTypeId]),
    CONSTRAINT [FK_tblTMDevice_tblTMRegulatorType] FOREIGN KEY ([intRegulatorTypeID]) REFERENCES [dbo].[tblTMRegulatorType] ([intRegulatorTypeID]),
    CONSTRAINT [FK_tblTMDevice_tblTMTankType] FOREIGN KEY ([intTankTypeId]) REFERENCES [dbo].[tblTMTankType] ([intTankTypeId])
);

