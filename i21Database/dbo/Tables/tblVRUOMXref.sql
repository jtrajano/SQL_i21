﻿CREATE TABLE [dbo].[tblVRUOMXref] (
   [intUOMXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intVendorSetupId] [int] NOT NULL,
	[intUnitMeasureId] [int] NOT NULL,
	[strVendorUOM] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strEquipmentType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRUOMXref_intConcurrencyId]  DEFAULT ((0)),
	[intRowNumber] INT NULL,
	[guiApiUniqueId] UNIQUEIDENTIFIER NULL,
	CONSTRAINT [PK_tblVRUOMXref] PRIMARY KEY CLUSTERED ([intUOMXrefId] ASC),
	CONSTRAINT [UQ_tblVRUOMXref_strVendorUOM_intEntityId] UNIQUE NONCLUSTERED ([strVendorUOM] ASC, [intUnitMeasureId], [intVendorSetupId] ASC),
	CONSTRAINT [FK_tblVRUOMXref_tblVRVendorSetup] FOREIGN KEY([intVendorSetupId])REFERENCES [dbo].[tblVRVendorSetup] ([intVendorSetupId]) ON DELETE CASCADE
);
GO