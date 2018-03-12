CREATE TABLE [dbo].[tblAPCompanyPreference] (
    [intCompanyPreferenceId] INT             IDENTITY (1, 1) NOT NULL,
	[intApprovalListId]	   INT             NULL,
    [intDefaultAccountId]  INT             NULL,
    [intWithholdAccountId] INT             NULL,
    [intDiscountAccountId] INT             NULL,
	[intInterestAccountId] INT             NULL,
    [dblWithholdPercent]   DECIMAL (18, 6) NULL,
    [strReportGroupName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strClaimReportName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strDebitMemoReportName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    PRIMARY KEY CLUSTERED (intCompanyPreferenceId ASC)
);

