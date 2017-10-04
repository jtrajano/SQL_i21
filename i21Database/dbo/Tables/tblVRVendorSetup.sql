CREATE TABLE [dbo].[tblVRVendorSetup](
	[intVendorSetupId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strVendorExportId] [nvarchar](10) NULL,
	[strExportFileType] [nvarchar](3) NULL,
	[strExportFilePath] [nvarchar](200) NULL,
	[strCompany1Id] [nvarchar](20) NULL,
	[strCompany2Id] [nvarchar](20) NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRVendorSetup_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRVendorSetup] PRIMARY KEY CLUSTERED([intVendorSetupId] ASC),
	CONSTRAINT [UQ_tblVRVendorSetup_intEntityId] UNIQUE NONCLUSTERED ([intEntityId] ASC), 
	CONSTRAINT [FK_tblVRVendorSetup_tblAPVendor] FOREIGN KEY([intEntityId]) REFERENCES [dbo].[tblAPVendor] ([intEntityId]),
)
GO
