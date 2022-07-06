CREATE TABLE [dbo].[tblCMBankAccountType]
(
	[intBankAccountTypeId]	INT IDENTITY (1, 1) NOT NULL,
	[strBankAccountType]	NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]		INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblCMBankAccountType] PRIMARY KEY CLUSTERED ([intBankAccountTypeId] ASC)
)
