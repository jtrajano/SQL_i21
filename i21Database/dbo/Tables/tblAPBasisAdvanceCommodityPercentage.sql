CREATE TABLE [dbo].[tblAPBasisAdvanceCommodityPercentage]
(
	[intCommodityPercentageId] INT NOT NULL PRIMARY KEY,
	[intScaleTicketId] INT NOT NULL,
	[intCommodityId] INT NOT NULL,
	[dblPercentage] DECIMAL(18,6) NOT NULL DEFAULT(0)
)
