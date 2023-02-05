
CREATE TABLE [dbo].[tblApiSchemaTransformCategoryVendor](
	[intKey] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[guiApiUniqueId] [uniqueidentifier] NOT NULL,
	[intRowNumber] [int] NULL,
	[strCategory] [nvarchar](200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strVendor] [nvarchar](200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocation] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strVendorCategory] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[ysnAddOrderingUPCtoPricebook] BIT NULL,
	[ysnUpdateExistingRecords] BIT NULL,
	[ysnAddNewRecords] BIT NULL,
	[ysnUpdatePrice] BIT NULL,
	[strDefaultFamily] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strDefaultSellClass] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strDefaultOrderClass] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strComments] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL
)
