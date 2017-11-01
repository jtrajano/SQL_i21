CREATE TABLE [dbo].[tblBBCustomerLocationXref](
	[intCustomerLocationXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityLocationId] [int] NOT NULL,
	[intCustomerXrefId] [int] NOT NULL,
	[strVendorCustomerLocation] [nvarchar](50) NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBCustomerLocationXref_intConcurrencyId]  DEFAULT ((0)),
    CONSTRAINT [PK_tblBBCustomerLocationXref] PRIMARY KEY CLUSTERED([intCustomerLocationXrefId] ASC),
	CONSTRAINT [FK_tblBBCustomerLocationXref_tblEMEntityLocation] FOREIGN KEY([intEntityLocationId])REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblBBCustomerLocationXref_tblVRCustomerXref] FOREIGN KEY([intCustomerXrefId])REFERENCES [dbo].[tblVRCustomerXref] ([intCustomerXrefId]) ON DELETE CASCADE,
);
GO