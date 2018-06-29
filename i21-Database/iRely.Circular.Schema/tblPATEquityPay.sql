CREATE TABLE [dbo].[tblPATEquityPay]
(
	[intEquityPayId] INT NOT NULL IDENTITY,
	[dtmPaymentDate] DATETIME NOT NULL,
	[strPaymentNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblPayoutPercent] NUMERIC(18,6) NOT NULL,
	[strDistributionMethod] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnPosted] BIT NOT NULL DEFAULT 0,
	[intConcurrencyId] INT NULL DEFAULT 1,
	CONSTRAINT [PK_tblPATEquityPay] PRIMARY KEY ([intEquityPayId])
)