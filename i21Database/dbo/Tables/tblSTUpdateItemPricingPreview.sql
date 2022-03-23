CREATE TABLE [dbo].[tblSTUpdateItemPricingPreview]
(
	[intUpdateItemPricingPreviewId] INT NOT NULL IDENTITY, 
	[strGuid] UNIQUEIDENTIFIER NOT NULL, 

	-- Display
	[strLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strUpc] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strChangeDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strUnitMeasure] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strOldData] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strNewData] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strActionType] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,

	-- Item Validation
	[intItemId] INT,
	[intItemUOMId] INT NULL,
	[intItemLocationId] INT NULL,

	-- For generating Update script 
	[intTableIdentityId] INT,
	[strTableName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strColumnName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strColumnDataType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,

	[intConcurrencyId] INT
)