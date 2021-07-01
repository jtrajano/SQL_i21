CREATE TABLE [dbo].[tblSCGrainReceiptDiscountMapping]
(
	[intGrainReceiptDiscountMapping200Id]	int not null identity(1,1)
	,[intCommodityId]						int not null	   
    ,[intGradeId]							int not null    
	,[intConcurrencyId]						int default(0) not null 
	,CONSTRAINT [PK_tblSCGrainReceiptDiscountMapping200_intGrainReceiptDiscountMapping200Id] PRIMARY KEY CLUSTERED ([intGrainReceiptDiscountMapping200Id] ASC)
	,CONSTRAINT [UK_tblSCGrainReceiptDiscountMapping200_intCommodityId] UNIQUE ([intCommodityId] ASC)			
	,CONSTRAINT [FK_tblSCGrainReceiptDiscountMapping200_tblICItem_GradeId] FOREIGN KEY ([intGradeId]) REFERENCES [tblICItem]([intItemId])
)
