CREATE TABLE [dbo].[tblARLetterPlaceHolder](
	[intPlaceHolderId] [int] IDENTITY(1,1) NOT NULL,
	[strPlaceHolderId] [nvarchar](50) NULL,
	[strModules] [nvarchar](200) NULL,
	[strPlaceHolder] [varchar](max) NULL,
	[strSourceTable] [nvarchar](200) NULL,
	[strSourceColumn] [nvarchar](200) NULL,
	[strDataType] [nvarchar](max) NULL,
	[strPlaceHolderName] [nvarchar](200) NULL,
	[strPlaceHolderDescription] [nvarchar](200) NULL,	
	[ysnTable] [bit] NULL DEFAULT ((0)),	
	[intConcurrencyId] [int] NULL DEFAULT ((0))	
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
