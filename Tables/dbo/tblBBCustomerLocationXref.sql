CREATE TABLE [dbo].[tblBBCustomerLocationXref](
	[intCustomerLocationXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityLocationId] [int] NOT NULL,
	[intVendorSetupId] [int] NOT NULL,
	[strVendorCustomerLocation] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL ,
	[strVendorShipTo] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strVendorSoldTo] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBCustomerLocationXref_intConcurrencyId]  DEFAULT ((0)),
    CONSTRAINT [PK_tblBBCustomerLocationXref] PRIMARY KEY CLUSTERED([intCustomerLocationXrefId] ASC),
	CONSTRAINT [FK_tblBBCustomerLocationXref_tblEMEntityLocation] FOREIGN KEY([intEntityLocationId])REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblBBCustomerLocationXref_tblVRVendorSetup] FOREIGN KEY([intVendorSetupId])REFERENCES [dbo].[tblVRVendorSetup] ([intVendorSetupId]) ON DELETE CASCADE,
);
GO
