CREATE TABLE [dbo].[tblCCCompanyPreferenceOption]
(
	[intCompanyPreferenceOption] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intDealerSiteCreditItem] INT NULL, 
    [intDealerSiteFeeItem] INT NULL, 
    [intConcurrencyId] INT NULL,
    [strImportProcessFilePath] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strImportArchiveFilePath] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
