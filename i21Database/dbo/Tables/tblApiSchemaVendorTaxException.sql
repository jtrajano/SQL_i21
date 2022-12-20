CREATE TABLE [dbo].[tblApiSchemaVendorTaxException] 
(
	
	[guiApiUniqueId] [uniqueidentifier] NOT NULL,
	[intRowNumber] [int] NULL,

	[intKey] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	
	[strVendorId] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTaxGroup] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocationName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strItemNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTaxClass] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTaxCode] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strState] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCategoryCode] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strException] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmStartDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL

)