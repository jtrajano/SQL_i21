CREATE TABLE [dbo].[tblVRVendorSetup](
	[intVendorSetupId] INT IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strVendorExportId] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strExportFileType] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[strExportFilePath] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCompany1Id] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strCompany2Id] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strVendorType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT DEFAULT 0 NOT NULL ,
	CONSTRAINT [PK_tblVRVendorSetup] PRIMARY KEY CLUSTERED([intVendorSetupId] ASC),
	CONSTRAINT [UQ_tblVRVendorSetup_intEntityId] UNIQUE NONCLUSTERED ([intEntityId] ASC, [strVendorType] ASC), 
	CONSTRAINT [FK_tblVRVendorSetup_tblAPVendor] FOREIGN KEY([intEntityId]) REFERENCES [dbo].[tblAPVendor] ([intEntityId]),
)
GO
