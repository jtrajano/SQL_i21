
CREATE TABLE [dbo].[tblSTUpdateItemDiscontinuedPreview](
	[intUpdateItemDiscontinuedPreviewId] [int] IDENTITY(1,1) NOT NULL,
	[strGuid] [uniqueidentifier] NOT NULL,
	[strLocation] [nvarchar](100) NULL,
	[strUpc] [nvarchar](20) NULL,
	[strDescription] [nvarchar](250) NULL,
	[strChangeDescription] [nvarchar](150) NULL,
	[strOldData] [nvarchar](150) NULL,
	[strNewData] [nvarchar](150) NULL,
	[intItemId] [int] NULL,
	[intItemUOMId] [int] NULL,
	[intItemLocationId] [int] NULL,
	[intTableIdentityId] [int] NULL,
	[strTableName] [nvarchar](100) NULL,
	[strColumnName] [nvarchar](50) NULL,
	[strColumnDataType] [nvarchar](50) NULL,
	[intConcurrencyId] [int] NULL,
	[dtmNotSoldSince] [datetime] NULL,
	[dtmNotPurchased] [datetime] NULL,
	[dtmCreatedOlderThan] [datetime] NULL
) ON [PRIMARY]
GO


