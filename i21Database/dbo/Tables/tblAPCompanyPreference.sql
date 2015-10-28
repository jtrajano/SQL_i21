CREATE TABLE [dbo].[tblAPCompanyPreference] (
    [intCompanyPreferenceId] INT             IDENTITY (1, 1) NOT NULL,
	[intApprovalListId]	   INT             NULL,
    [intDefaultAccountId]  INT             NULL,
    [intWithholdAccountId] INT             NULL,
    [intDiscountAccountId] INT             NULL,
	[intInterestAccountId] INT             NULL,
    [dblWithholdPercent]   DECIMAL (18, 6) NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    PRIMARY KEY CLUSTERED (intCompanyPreferenceId ASC)
);

