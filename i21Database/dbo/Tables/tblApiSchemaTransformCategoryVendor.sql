
CREATE TABLE [dbo].[tblApiSchemaTransformCategoryVendor](
	[intKey] [int] IDENTITY(1,1) NOT NULL,
	[guiApiUniqueId] [uniqueidentifier] NOT NULL,
	[intRowNumber] [int] NULL,
	[strCategory] [nvarchar](200) NOT NULL,
	[strVendor] [nvarchar](200) NOT NULL,
	[strLocation] [nvarchar](200) NULL,
	[strVendorCategory] [nvarchar](200) NULL,
	[ysnAddOrderingUPCtoPricebook] [nvarchar](3) NULL,
	[ysnUpdateExistingRecords] [nvarchar](3) NULL,
	[ysnAddNewRecords] [nvarchar](3) NULL,
	[ysnUpdatePrice] [nvarchar](3) NULL,
	[strDefaultFamily] [nvarchar](200) NULL,
	[strDefaultSellClass] [nvarchar](200) NULL,
	[strDefaultOrderClass] [nvarchar](200) NULL,
	[strComments] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[intKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO