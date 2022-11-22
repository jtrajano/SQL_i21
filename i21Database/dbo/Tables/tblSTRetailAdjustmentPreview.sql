
CREATE TABLE [dbo].[tblSTRetailAdjustmentPreview](
	[intRetailAdjustmentPreviewId] [int] IDENTITY(1,1) NOT NULL,
	[strGuid] [uniqueidentifier] NOT NULL,
	[strLocation] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strUpc] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strChangeDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strOldData] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strNewData] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL
) ON [PRIMARY]
GO


