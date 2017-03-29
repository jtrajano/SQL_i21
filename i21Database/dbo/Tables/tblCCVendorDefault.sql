CREATE TABLE [dbo].[tblCCVendorDefault]
(
	[intVendorDefaultId] INT NOT NULL IDENTITY,
	[intVendorId] INT NULL,
	[intBankAccountId]  INT NULL ,
	[intCompanyLocationId] INT NULL,
	[strApType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strEnterTotalsAsGrossOrNet] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFileType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strImportFileName] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strImportAuxiliaryFileName] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strImportFilePath] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intImportFileHeaderId] [int] NULL,
	[intSort] [int] NULL,	
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCVendorDefault] PRIMARY KEY ([intVendorDefaultId]),
	CONSTRAINT [FK_tblCCVendorDefault_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [dbo].[tblAPVendor] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCCVendorDefault_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]),
	CONSTRAINT [FK_tblCCVendorDefault_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblCCVendorDefault_tblSMImportFileHeader_intImportFileHeaderId] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId])

)
