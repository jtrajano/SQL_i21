CREATE TABLE [dbo].[tblVRVendorSetup](
	[intVendorSetupId] INT IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strExportFileType] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[strExportFilePath] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strBuybackExportFileType] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[strBuybackExportFilePath] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCompany1Id] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strCompany2Id] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strReimbursementType] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF_tblVRVendorSetup_strReimbursementType]  DEFAULT (N'AP'),
	[intAccountId] [int] NULL,
	[intConcurrencyId] INT DEFAULT 0 NOT NULL ,
	CONSTRAINT [PK_tblVRVendorSetup] PRIMARY KEY CLUSTERED([intVendorSetupId] ASC),
	CONSTRAINT [UQ_tblVRVendorSetup_intEntityId] UNIQUE NONCLUSTERED ([intEntityId] ASC), 
	CONSTRAINT [FK_tblVRVendorSetup_tblAPVendor] FOREIGN KEY([intEntityId]) REFERENCES [dbo].[tblAPVendor] ([intEntityId]),
)
GO
