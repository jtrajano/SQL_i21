
CREATE TABLE [dbo].[tblSTBatchRetailAdjustmentPreview](
	[intBatchRetailAdjustmentPreviewId] [int] IDENTITY(1,1) NOT NULL,
	[strGuid] [uniqueidentifier] NOT NULL,
	[strLocation] [nvarchar](100) NULL,
	[strUpc] [nvarchar](20) NULL,
	[strDescription] [nvarchar](150) NULL,
	[strChangeDescription] [nvarchar](150) NULL,
	[strOldData] [nvarchar](150) NULL,
	[strNewData] [nvarchar](150) NULL,
	strRetailPriceAdjustmentNumber [nvarchar](150) NULL,
	strItemDescription [nvarchar](150) NULL,
	[intConcurrencyId] [int] NULL
) ON [PRIMARY]
GO


