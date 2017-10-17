CREATE TABLE [dbo].[tblAPBasisAdvanceCommodity]
(
	[intBasisAdvanceCommodityId] INT NOT NULL PRIMARY KEY,
	[intBasisAdvanceDummyHeaderId] INT NOT NULL,
	[intCommodityId] INT NOT NULL,
	[strCommodity] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[dblPercentage] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[intConcurrencyId] INT DEFAULT(0) NOT NULL ,
	CONSTRAINT [FK_tblAPBasisAdvanceCommodity_tblAPBasisAdvanceDummyHeader] FOREIGN KEY ([intBasisAdvanceDummyHeaderId]) REFERENCES [dbo].[tblAPBasisAdvanceDummyHeader] ([intBasisAdvanceDummyHeaderId])
)
