CREATE TABLE [dbo].[tblGLConsolidateResult](
	[intConsolidateResultId] [int] IDENTITY(1,1) NOT NULL,
	[ysnFiscalOpen] [bit] NULL,
	[ysnUnpostedTrans] [bit] NULL,
	[strResult] [nvarchar](1000) NULL,
	[strCompanyName] [nvarchar](100) NULL,
 CONSTRAINT [PK_tblGLConsolidateResult] PRIMARY KEY CLUSTERED 
(
	[intConsolidateResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLConsolidateResult', @level2type=N'COLUMN',@level2name=N'intConsolidateResultId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Fiscal Open?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLConsolidateResult', @level2type=N'COLUMN',@level2name=N'ysnFiscalOpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unposted Transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLConsolidateResult', @level2type=N'COLUMN',@level2name=N'ysnUnpostedTrans' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Result' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLConsolidateResult', @level2type=N'COLUMN',@level2name=N'strResult' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Company Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLConsolidateResult', @level2type=N'COLUMN',@level2name=N'strCompanyName' 
GO