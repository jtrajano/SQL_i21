CREATE TABLE [dbo].[tblRKCreditLine] 
(
    [intCreditLineId] INT IDENTITY(1,1) NOT NULL,
	[intEntityId] INT NOT NULL,
	[strEntityName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransaction] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCreditRating] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NOT NULL,
	[strDUNS] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NOT NULL,
	[dblTotalCreditLimit] NUMERIC(18, 6) NULL,
	[intCurrencyID] INT NOT NULL,
	[strCurrency] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblRKCreditLine_intCreditLineId] PRIMARY KEY ([intCreditLineId]),
	CONSTRAINT [FK_tblRKCreditLine_tblSMCurrency_intCurrencyID] FOREIGN KEY (intCurrencyID) REFERENCES tblSMCurrency([intCurrencyID]),
	CONSTRAINT [FK_tblRKCreditLine_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity([intEntityId])
)