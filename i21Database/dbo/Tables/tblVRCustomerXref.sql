CREATE TABLE [dbo].[tblVRCustomerXref](
	[intCustomerXrefId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intVendorSetupId] [int] NULL,
	[strVendorCustomer] [nvarchar](50) COLLATE Latin1_General_CI_AS  NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRCustomerXref_intConcurrencyId]  DEFAULT ((0)),
	[guiApiUniqueId] UNIQUEIDENTIFIER NULL,
	[intRowNumber] INT NULL,
	CONSTRAINT [PK_tblVRCustomerXref] PRIMARY KEY CLUSTERED([intCustomerXrefId] ASC),
	CONSTRAINT [UQ_tblVRCustomerXref_intEntityId_intVendorSetupId] UNIQUE NONCLUSTERED ([intEntityId] ASC,[intVendorSetupId] ASC),
	CONSTRAINT [FK_tblVRCustomerXref_tblARCustomer] FOREIGN KEY([intEntityId])REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblVRCustomerXref_tblVRVendorSetup] FOREIGN KEY([intVendorSetupId])REFERENCES [dbo].[tblVRVendorSetup] ([intVendorSetupId]) ON DELETE CASCADE
);
GO