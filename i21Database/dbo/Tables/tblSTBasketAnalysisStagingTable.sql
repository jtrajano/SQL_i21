
CREATE TABLE [dbo].[tblSTBasketAnalysisStagingTable](
   [intBasketAnalysisId]	 int IDENTITY(1,1) NOT NULL,
	[intUserId]				 int NULL,
	[intItemId]				 int NULL,
	[intCategoryId]			 int NULL,
	[strDescription]		 nvarchar(max) NULL,
	[intRank]				 int NULL,
	[dblBasketAverage]		 numeric(18, 6) NULL,
	[intTotalBasket]		 int NULL,
	[intTotalItem]			 int NULL,
	[strItemId]				 nvarchar(max) NULL,
	[strCategoryId]			 nvarchar(max) NULL,
	[strItemDescription]	 nvarchar(max) NULL,
	[strCategoryDescription] nvarchar(max) NULL,
	[strItemUPC]			 nvarchar(max) NULL,
	CONSTRAINT [PK_tblSTBasketAnalysisStagingTable] PRIMARY KEY CLUSTERED ([intBasketAnalysisId] ASC)
);


