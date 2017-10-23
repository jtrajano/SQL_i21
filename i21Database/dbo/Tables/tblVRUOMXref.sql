CREATE TABLE [dbo].[tblVRUOMXref] (
   [intUOMXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intUnitMeasureId] [int] NOT NULL,
	[strVendorUOM] [nvarchar](50) NOT NULL,
	[strEquipmentType] [nvarchar](50) NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRUOMXref_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRUOMXref] PRIMARY KEY CLUSTERED ([intUOMXrefId] ASC),
	CONSTRAINT [UQ_tblVRUOMXref_intUnitMeasureId_intEntityId] UNIQUE NONCLUSTERED ([intUnitMeasureId] ASC,[intEntityId] ASC),
	CONSTRAINT [UQ_tblVRUOMXref_strVendorUOM_intEntityId] UNIQUE NONCLUSTERED ([strVendorUOM] ASC, [intEntityId] ASC),
	CONSTRAINT [FK_tblVRUOMXref_tblAPVendor] FOREIGN KEY([intEntityId])REFERENCES [dbo].[tblAPVendor] ([intEntityId])
);
GO
