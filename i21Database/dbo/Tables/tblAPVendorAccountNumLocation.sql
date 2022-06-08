CREATE TABLE [dbo].[tblAPVendorAccountNumLocation]
(
	[intVendorAccountNumLocationId] INT NOT NULL IDENTITY,
    [intEntityVendorId] INT NOT NULL, 
    [intCompanyLocationId] INT NOT NULL, 
	[strVendorAccountNum] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intPayFromBankAccountId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblAPVendorAccountNumLocation] PRIMARY KEY ([intVendorAccountNumLocationId])
)
