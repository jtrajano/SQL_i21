CREATE TYPE [dbo].[PlaceHolderTable] AS TABLE(
	[intPlaceHolderId] [int] NULL,
	[strPlaceHolder] [varchar](max) NULL,
	[intEntityCustomerId] [int] NULL,
	[strPlaceValue] [varchar](max) NULL
)