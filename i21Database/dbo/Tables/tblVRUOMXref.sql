CREATE TABLE [dbo].[tblVRUOMXref] (
   [intUOMXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intUnitMeasureId] [int] NOT NULL,
	[strVendorUOM] [nvarchar](50) NOT NULL,
	[strEquipmentType] [nvarchar](50) NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRUOMXref_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRUOMXref] PRIMARY KEY CLUSTERED ([intUOMXrefId] ASC),
	CONSTRAINT [UQ_tblVRUOMXref_intUnitMeasureId_intVendorId] UNIQUE NONCLUSTERED ([intUnitMeasureId] ASC,[intEntityId] ASC)
);

