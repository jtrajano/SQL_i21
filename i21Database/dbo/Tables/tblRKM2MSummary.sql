CREATE TABLE [dbo].[tblRKM2MSummary]
(
	[intM2MSummaryId] INT NOT NULL IDENTITY, 
    [intM2MHeaderId] INT NOT NULL, 
	[strSummary] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [intCommodityId] INT NULL,
    [strContractOrInventoryType] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [dblQty] NUMERIC(18, 6) NULL,
    [dblTotal] NUMERIC(18, 6) NULL,
    [dblFutures] NUMERIC(18, 6) NULL,
    [dblBasis] NUMERIC(18, 6) NULL,
    [dblCash] NUMERIC(18, 6) NULL,
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKM2MSummary] PRIMARY KEY ([intM2MSummaryId]), 
    CONSTRAINT [FK_tblRKM2MSummary_tblRKM2MHeader] FOREIGN KEY ([intM2MHeaderId]) REFERENCES [tblRKM2MHeader]([intM2MHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKM2MSummary_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId])
)
