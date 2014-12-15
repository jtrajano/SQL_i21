CREATE TABLE [dbo].[tblTempError](
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[guidSessionId] [uniqueidentifier] NOT NULL,
	[strTitle] [nvarchar](50) NULL,
	[strDescription] [varchar](150) NULL,
	[dteAdded] [datetime] NULL
) 