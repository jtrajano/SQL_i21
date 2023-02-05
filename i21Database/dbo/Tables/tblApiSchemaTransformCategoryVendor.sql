CREATE TABLE [dbo].[tblApiSchemaTransformCategoryVendor](
	[intKey] [int] IDENTITY(1,1) NOT NULL,
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
	[strComments] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[intKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO