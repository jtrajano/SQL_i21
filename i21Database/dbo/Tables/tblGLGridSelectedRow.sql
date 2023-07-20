

CREATE TABLE [dbo].[tblGLGridSelectedRow](
	[intSelectedId] [int] IDENTITY(1,1) NOT NULL,
	[guidId] [uniqueidentifier] NULL,
	[intRelatedId] [int] NULL,
	[strType] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblGLGridSelectedRow] PRIMARY KEY CLUSTERED ([intSelectedId] ASC)
)
GO

