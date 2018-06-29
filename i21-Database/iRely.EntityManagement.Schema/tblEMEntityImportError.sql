CREATE TABLE [dbo].[tblEMEntityImportError]
(
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[guidSessionId] [uniqueidentifier] NOT NULL,
	[strTitle] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [varchar](150) COLLATE Latin1_General_CI_AS NULL,
	[dteAdded] [datetime] NULL,
	CONSTRAINT [PK_tblEMEntityImportError] PRIMARY KEY CLUSTERED ([intId] ASC),

)
