CREATE  TABLE [dbo].[tblRKAllocatedContractsSummary]
(
	[intAllocatedContractsSummaryId] INT NOT NULL IDENTITY, 
    [intAllocatedContractsGainOrLossHeaderId] INT NOT NULL, 
	[strSummary] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [intCommodityId] INT NULL,
    [dblPurchaseAllocatedQty] NUMERIC(18, 6) NULL,
	[dblSalesAllocatedQty] NUMERIC(18, 6) NULL,
	[dblTotal] NUMERIC(18, 6) NULL,
    [dblFutures] NUMERIC(18, 6) NULL,
    [dblBasis] NUMERIC(18, 6) NULL,
    [dblCash] NUMERIC(18, 6) NULL,
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKAllocatedContractsSummary] PRIMARY KEY ([intAllocatedContractsSummaryId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsSummary_tblRKAllocatedContractsGainOrLossHeader] FOREIGN KEY ([intAllocatedContractsGainOrLossHeaderId]) REFERENCES [tblRKAllocatedContractsGainOrLossHeader]([intAllocatedContractsGainOrLossHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKAllocatedContractsSummary_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId])
)