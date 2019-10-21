CREATE TABLE [dbo].[tblARLetterPlaceHolder](
	[intPlaceHolderId]				[int]					IDENTITY(1,1)					NOT NULL,
	[strPlaceHolderId]				[nvarchar](50)			COLLATE Latin1_General_CI_AS	NULL,
	[strModules]					[nvarchar](200)			COLLATE Latin1_General_CI_AS	NULL,
	[strPlaceHolder]				[varchar](max)			COLLATE Latin1_General_CI_AS	NULL,
	[strSourceTable]				[nvarchar](200)			COLLATE Latin1_General_CI_AS	NULL,
	[strSourceColumn]				[nvarchar](200)			COLLATE Latin1_General_CI_AS	NULL,
	[strDataType]					[nvarchar](max)			COLLATE Latin1_General_CI_AS	NULL,
	[strPlaceHolderName]			[nvarchar](200)			COLLATE Latin1_General_CI_AS	NULL,
	[strPlaceHolderDescription]		[nvarchar](200)			COLLATE Latin1_General_CI_AS	NULL,	
	[ysnTable]						[bit]					DEFAULT ((0))					NULL,	
	[intConcurrencyId]				[int]					DEFAULT ((0))					NULL			
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
