CREATE TABLE [dbo].[tblCCCompanyPreferenceOption]
(
	[intCompanyPreferenceOption] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intDealerSiteCreditItem] INT NULL, 
    [intDealerSiteFeeItem] INT NULL, 
    [intConcurrencyId] INT NULL
)
