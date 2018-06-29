CREATE TABLE [dbo].[tblCFItemCategory](
	[intItemCategoryId] INT IDENTITY(1,1) NOT NULL,
	[intCategoryId] INT  NOT NULL,
	[intConcurrencyId] INT CONSTRAINT [DF_tblCFItemCategory_intConcurrencyId] DEFAULT ((1)) NOT NULL,
	CONSTRAINT [PK_tblCFItemCategory] PRIMARY KEY CLUSTERED ([intItemCategoryId] ASC),
	CONSTRAINT [UQ_tblCFItemCategory_intCategoryId] UNIQUE ([intCategoryId]), 
);
GO