CREATE TABLE [dbo].[tblSCGrainReceiptDiscountMapping]
(
	[intGrainReceiptDiscountMappingId]	int not null identity(1,1)
	,[intCommodityId]					int not null	
    ,[intTestWeightId]					int null
    ,[intCCFMId]						int null
    ,[intGradeId]						int null
    ,[intFactorId]						int null
    ,[intProteinId]						int null
    ,[intMoistureId]					int null
    ,[intSplitId]						int null
	,[intConcurrencyId]					int default(0) not null 
	,CONSTRAINT [PK_tblSCGrainReceiptDiscountMapping_intGrainReceiptDiscountMappingId] PRIMARY KEY CLUSTERED ([intGrainReceiptDiscountMappingId] ASC)
	,CONSTRAINT [UK_tblSCGrainReceiptDiscountMapping_intCommodityId] UNIQUE ([intCommodityId] ASC)		
	,CONSTRAINT [FK_tblSCGrainReceiptDiscountMapping_tblICItem_TestWeightId] FOREIGN KEY ([intTestWeightId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblSCGrainReceiptDiscountMapping_tblICItem_CCFMId] FOREIGN KEY ([intCCFMId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblSCGrainReceiptDiscountMapping_tblICItem_GradeId] FOREIGN KEY ([intGradeId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblSCGrainReceiptDiscountMapping_tblICItem_FactorId] FOREIGN KEY ([intFactorId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblSCGrainReceiptDiscountMapping_tblICItem_ProteinId] FOREIGN KEY ([intProteinId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblSCGrainReceiptDiscountMapping_tblICItem_MoistureId] FOREIGN KEY ([intMoistureId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblSCGrainReceiptDiscountMapping_tblICItem_SplitId] FOREIGN KEY ([intSplitId]) REFERENCES [tblICItem]([intItemId])
)
