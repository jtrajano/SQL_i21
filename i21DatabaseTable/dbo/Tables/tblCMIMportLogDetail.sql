CREATE TABLE [dbo].[tblCMImportLogDetail](
	[intImportLogId] [int] NOT NULL,
	[intImportLogDetailId] [int] IDENTITY(1,1) NOT NULL,
	[strDescription] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[intLineNo] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblCMImportLogDetail] PRIMARY KEY CLUSTERED 
(
	[intImportLogDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMImportLogDetail] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Foreign Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLogDetail', @level2type=N'COLUMN',@level2name=N'intImportLogId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLogDetail', @level2type=N'COLUMN',@level2name=N'intImportLogDetailId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLogDetail', @level2type=N'COLUMN',@level2name=N'strDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Line No.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLogDetail', @level2type=N'COLUMN',@level2name=N'intLineNo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLogDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId'
GO

