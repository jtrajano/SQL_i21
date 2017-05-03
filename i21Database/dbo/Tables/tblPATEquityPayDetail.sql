CREATE TABLE [dbo].[tblPATEquityPayDetail]
(
	[intEquityPayDetailId] INT NOT NULL IDENTITY,
	[intEquityPaySummaryId] INT NOT NULL,
	[intCustomerEquityId] INT NOT NULL,
	[intFiscalYearId] INT NOT NULL,
	[strEquityType] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intRefundTypeId] INT NOT NULL,
	[ysnQualified] BIT NOT NULL,
	[dblEquityAvailable] NUMERIC(18,6) NOT NULL,
	[dblEquityPay] NUMERIC(18,6) NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT 1,
	CONSTRAINT [PK_tblPATEquityPayDetail] PRIMARY KEY ([intEquityPayDetailId]),
	CONSTRAINT [FK_tblPATEquityPayDetail_tblPATEquityPaySummary] FOREIGN KEY ([intEquityPaySummaryId]) REFERENCES [tblPATEquityPaySummary]([intEquityPaySummaryId]) ON DELETE CASCADE
)	