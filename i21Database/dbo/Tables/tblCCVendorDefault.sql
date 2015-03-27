CREATE TABLE [dbo].[tblCCVendorDefault]
(
	[intVendorDefaultId] INT NOT NULL IDENTITY,
	[intVendorId] INT NULL,
	[intBankAccountId]  INT NOT NULL DEFAULT 0,
	[strApType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strEnterTotalsAsGrossOrNet] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFileType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strImportFileName] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strImportAuxiliaryFileName] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strImportFilePath] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCVendorDefault] PRIMARY KEY ([intVendorDefaultId]),
	CONSTRAINT [FK_tblCCVendorDefault_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [dbo].[tblAPVendor] ([intEntityVendorId]),
	CONSTRAINT [FK_tblCCVendorDefault_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]) 

)
