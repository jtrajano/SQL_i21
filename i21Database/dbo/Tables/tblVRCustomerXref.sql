CREATE TABLE [dbo].[tblVRCustomerXref](
	[intCustomerXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intCustomerEntityId] [int] NOT NULL,
	[intVendorEntityId] [int] NOT NULL,
	[strVendorCustomer] [nvarchar](50) NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRCustomerXref_intConcurrencyId]  DEFAULT ((0)),
	[strType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblVRCustomerXref] PRIMARY KEY CLUSTERED([intCustomerXrefId] ASC),
	CONSTRAINT [UQ_tblVRCustomerXref_intCustomerEntityId_intVendorEntityId] UNIQUE NONCLUSTERED ([intCustomerEntityId] ASC,[intVendorEntityId] ASC),
	CONSTRAINT [UQ_tblVRCustomerXref_strVendorCustomer_intVendorEntity] UNIQUE NONCLUSTERED ([strVendorCustomer] ASC,[intVendorEntityId] ASC),
	CONSTRAINT [FK_tblVRCustomerXref_tblARCustomer] FOREIGN KEY([intCustomerEntityId])REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblVRCustomerXref_tblAPVendor] FOREIGN KEY([intVendorEntityId])REFERENCES [dbo].[tblAPVendor] ([intEntityId])
);
GO