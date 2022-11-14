
CREATE TABLE [dbo].[tblSTBasketAnalysisStagingTable](
   [intBasketAnalysisId]	 int IDENTITY(1,1) NOT NULL,
	[intUserId]				 int NULL,
	[intItemId]				 int NULL,
	[intCategoryId]			 int NULL,
	[strDescription]		 nvarchar(max)  COLLATE Latin1_General_CI_AS NULL,
	[intRank]				 int NULL,
	[dblBasketAverage]		 numeric(18, 6) NULL,
	[intTotalBasket]		 int NULL,
	[intTotalItem]			 int NULL,
	[strItemId]				 nvarchar(max)  COLLATE Latin1_General_CI_AS NULL,
	[strCategoryId]			 nvarchar(max)  COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription]	 nvarchar(max)   COLLATE Latin1_General_CI_AS NULL,
	[strCategoryDescription] nvarchar(max)   COLLATE Latin1_General_CI_AS NULL,
	[strItemUPC]			 nvarchar(max)   COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblSTBasketAnalysisStagingTable] PRIMARY KEY CLUSTERED ([intBasketAnalysisId] ASC)
);


