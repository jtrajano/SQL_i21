CREATE TABLE [dbo].[tblPATEquityPaySummary]
(
	[intEquityPaySummaryId] INT NOT NULL IDENTITY,
	[intEquityPayId] INT NOT NULL,
	[intCustomerPatronId] INT NOT NULL,
	[ysnQualified] BIT NOT NULL,
	[dblEquityAvailable] NUMERIC(18,6) NOT NULL,
	[dblEquityPaid] NUMERIC(18,6) NOT NULL,
	[dblFWT] NUMERIC(18,6) NOT NULL,
	[dblCheckAmount] NUMERIC(18,6) NOT NULL,
	[intBillId] INT NULL,
	[intConcurrencyId] INT NULL DEFAULT 1, 
	CONSTRAINT [PK_tblPATEquityPaySummary] PRIMARY KEY ([intEquityPaySummaryId]),
	CONSTRAINT [FK_tblPATEquityPaySummary_tblPATEquityPay] FOREIGN KEY ([intEquityPayId]) REFERENCES [tblPATEquityPay]([intEquityPayId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPATEquityPaySummary_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [tblAPBill]([intBillId]) ON DELETE SET NULL
)