CREATE TABLE [dbo].[tblAPBasisAdvanceContractFuturesPrice]
(
	[intFuturesPriceId] INT NOT NULL PRIMARY KEY,
	[intScaleTicketId] INT NOT NULL,
	[intFuturesId] INT NOT NULL,
	[dblFuturesPrice] DECIMAL(18,6) NOT NULL DEFAULT(0)
)
