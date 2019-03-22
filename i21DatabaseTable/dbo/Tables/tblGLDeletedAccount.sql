
CREATE TABLE [dbo].tblGLDeletedAccount(
	[intDeletedAccountId] [int] IDENTITY(1,1) NOT NULL,
	[intAccountId] [int] NOT NULL,
	[strAccountId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strNote] [ntext]  COLLATE Latin1_General_CI_AS NULL,
	[intAccountGroupId] [int] NULL,
	[ysnIsUsed] [bit] ,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((1)),
	[intAccountUnitId] [int] NULL,
	[strComments] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] [bit] NULL,
	[ysnSystem] [bit] NULL,
	[ysnRevalue] [bit] NULL,
	[strCashFlow] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intEntityIdLastModified] [int] NULL,
	[intCurrencyID] [int] NULL,
	[intCurrencyExchangeRateTypeId] [int] NULL,
 CONSTRAINT [PK_GLAccountDeleted_AccountId] PRIMARY KEY CLUSTERED 
(
	[intDeletedAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'intDeletedAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id (string)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'strAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'strNote' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Used' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'ysnIsUsed' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Unit Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'intAccountUnitId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comments' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'strComments' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'ysnActive' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'ysnSystem' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Revalue' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'ysnRevalue' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cash Flow' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'strCashFlow' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id Last Modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'intEntityIdLastModified' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency I D' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'intCurrencyID' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Exchange Rate Type Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDeletedAccount', @level2type=N'COLUMN',@level2name=N'intCurrencyExchangeRateTypeId' 
GO