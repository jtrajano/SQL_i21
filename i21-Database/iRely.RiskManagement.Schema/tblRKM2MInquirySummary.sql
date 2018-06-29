CREATE TABLE [dbo].[tblRKM2MInquirySummary]
(
	[intM2MInquirySummaryId] INT IDENTITY(1,1) NOT NULL,	
    [intConcurrencyId] INT NOT NULL, 
    [intM2MInquiryId] INT NOT NULL, 
    [strSummary]  NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [intCommodityId] INT NULL,
    [strContractOrInventoryType] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [dblQty] NUMERIC(18, 6) NULL,
    [dblTotal] NUMERIC(18, 6) NULL,
    [dblFutures] NUMERIC(18, 6) NULL,
    [dblBasis] NUMERIC(18, 6) NULL,
    [dblCash] NUMERIC(18, 6) NULL,    
    CONSTRAINT [PK_tblRKM2MInquirySummary_intM2MInquirySummaryId] PRIMARY KEY (intM2MInquirySummaryId),
	CONSTRAINT [FK_tblRKM2MInquirySummary_tblRKM2MInquiry_intM2MInquiryId] FOREIGN KEY([intM2MInquiryId])REFERENCES [dbo].[tblRKM2MInquiry] (intM2MInquiryId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKM2MInquirySummary_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [dbo].[tblICCommodity] ([intCommodityId])
)
