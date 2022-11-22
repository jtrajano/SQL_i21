
CREATE TABLE [dbo].[tblSTUpdateItemDiscontinuedPreview](
	[intUpdateItemDiscontinuedPreviewId] [int] IDENTITY(1,1) NOT NULL,
	[strGuid] [uniqueidentifier] NOT NULL,
	[strLocation] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strUpc] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strChangeDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strOldData] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strNewData] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] [int] NULL,
	[intItemUOMId] [int] NULL,
	[intItemLocationId] [int] NULL,
	[intTableIdentityId] [int] NULL,
	[strTableName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strColumnName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strColumnDataType] [nvarchar](50) COLLATE Latin1_General_CI_AS  NULL,
	[intConcurrencyId] [int] NULL,
	[dtmNotSoldSince] [datetime] NULL,
	[dtmNotPurchased] [datetime] NULL,
	[dtmCreatedOlderThan] [datetime] NULL
) ON [PRIMARY]
GO


