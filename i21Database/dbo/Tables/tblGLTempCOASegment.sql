
CREATE TABLE [dbo].[tblGLTempCOASegment](
	[intAccountId] [int] NOT NULL,
	[strAccountId] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[Location] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Primary Account] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[LOB] [nvarchar](20) NULL,
 CONSTRAINT [PK_tblGLTempCOASegment] PRIMARY KEY CLUSTERED 
(
	[intAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempCOASegment', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id (string)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempCOASegment', @level2type=N'COLUMN',@level2name=N'strAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Account' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempCOASegment', @level2type=N'COLUMN',@level2name=N'Primary Account' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Location' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempCOASegment', @level2type=N'COLUMN',@level2name=N'Location' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'L O B' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLTempCOASegment', @level2type=N'COLUMN',@level2name=N'LOB' 
GO

