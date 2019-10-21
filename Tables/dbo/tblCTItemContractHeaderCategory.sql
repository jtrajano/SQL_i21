CREATE TABLE [dbo].[tblCTItemContractHeaderCategory](
	[intItemCategoryId]					[int] IDENTITY(1,1) NOT NULL,	
	[intItemContractHeaderId]			[int] NOT NULL,
	[intCategoryId]						[int] NULL, 
	[intConcurrencyId]					[int] CONSTRAINT [DF_tblCTItemContractHeaderCategory_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	
	CONSTRAINT [PK_tblCTItemContractHeaderCategory_intItemContractHeaderId] PRIMARY KEY CLUSTERED ([intItemCategoryId] ASC),
    CONSTRAINT [FK_tblCTItemContractHeaderCategory_tblCTItemContractHeader] FOREIGN KEY ([intItemContractHeaderId]) REFERENCES [dbo].[tblCTItemContractHeader] ([intItemContractHeaderId]) ON DELETE CASCADE	
)