CREATE TYPE [dbo].[FilterTableType] AS TABLE(
	[filterId] [int] IDENTITY(1,1) NOT NULL,
	[fieldname] [nvarchar](50) NULL,
	[condition] [nvarchar](20) NULL,
	[from] [nvarchar](50) NULL,
	[to] [nvarchar](50) NULL,
	[join] [nvarchar](10) NULL,
	[begingroup] [nvarchar](50) NULL,
	[endgroup] [nvarchar](50) NULL,
	[datatype] [nvarchar](50) NULL,
	PRIMARY KEY CLUSTERED 
(
	[filterId] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO