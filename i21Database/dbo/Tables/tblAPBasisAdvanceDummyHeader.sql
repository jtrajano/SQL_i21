CREATE TABLE [dbo].[tblAPBasisAdvanceDummyHeader]
(
	[intBasisAdvanceDummyHeaderId] INT NOT NULL PRIMARY KEY,
	[intAdvanceCurrencyId] INT NULL,
	[intRateTypeId] INT NULL,
	[dblPrice] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[intConcurrencyId] INT DEFAULT(0) NOT NULL 
)
