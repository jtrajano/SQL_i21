CREATE TABLE [dbo].[tblSMInterCompanyTransactionType]
(
	[intInterCompanyTransactionTypeId] INT NOT NULL PRIMARY KEY IDENTITY,
	[strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1
)
