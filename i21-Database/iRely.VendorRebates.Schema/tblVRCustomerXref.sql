CREATE TABLE [dbo].[tblVRCustomerXref](
	[intCustomerXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intVendorSetupId] [int] NULL,
	[strVendorCustomer] [nvarchar](50) NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRCustomerXref_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRCustomerXref] PRIMARY KEY CLUSTERED([intCustomerXrefId] ASC),
	CONSTRAINT [UQ_tblVRCustomerXref_intCustomerEntityId_intVendorEntityId] UNIQUE NONCLUSTERED ([intEntityId] ASC,[intVendorSetupId] ASC),
	CONSTRAINT [UQ_tblVRCustomerXref_strVendorCustomer_intVendorEntity] UNIQUE NONCLUSTERED ([strVendorCustomer] ASC,[intVendorSetupId] ASC),
	CONSTRAINT [FK_tblVRCustomerXref_tblARCustomer] FOREIGN KEY([intEntityId])REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblVRCustomerXref_tblVRVendorSetup] FOREIGN KEY([intVendorSetupId])REFERENCES [dbo].[tblVRVendorSetup] ([intVendorSetupId]) ON DELETE CASCADE
);
GO