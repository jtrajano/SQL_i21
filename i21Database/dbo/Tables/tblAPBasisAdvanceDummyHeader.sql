CREATE TABLE [dbo].[tblAPBasisAdvanceDummyHeader]
(
	[intBasisAdvanceDummyHeaderId] INT NOT NULL PRIMARY KEY,
	[intCompanyId] INT NULL,
	[intAdvanceCurrencyId] INT NULL,
	[intRateTypeId] INT NULL,
	[dblRate] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[intConcurrencyId] INT DEFAULT(0) NOT NULL 
)
