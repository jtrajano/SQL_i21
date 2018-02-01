CREATE TABLE [dbo].[tblGLAccount] (
    [intAccountId]      INT             IDENTITY (1, 1) NOT NULL,
    [strAccountId]      NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]    NVARCHAR (255)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strNote]           NTEXT           COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupId] INT             NULL,
    [ysnIsUsed]         BIT             CONSTRAINT [DF_tblGLAccount_ysnIsUsed] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]  INT             DEFAULT 1 NOT NULL,
    [intAccountUnitId]  INT             NULL,
    [strComments]       NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]         BIT             NULL,
    [ysnSystem]         BIT             NULL,
	[ysnRevalue]		BIT				NULL,
    [strCashFlow]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intEntityIdLastModified] INT NULL, 
    [intCurrencyID] INT NULL, 
    [intCurrencyExchangeRateTypeId] INT NULL, 
	[strOldAccountId]   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_GLAccount_AccountId] PRIMARY KEY CLUSTERED ([intAccountId] ASC),
    CONSTRAINT [FK_tblGLAccount_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupId]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupId]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_tblGLAccount_tblGLAccountUnit] FOREIGN KEY ([intAccountUnitId]) REFERENCES [dbo].[tblGLAccountUnit] ([intAccountUnitId]),
	CONSTRAINT [FK_tblGLAccount_tblSMCurrency] FOREIGN KEY([intCurrencyID])REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblGLAccount_tblSMCurrencyExchangeRateType] FOREIGN KEY([intCurrencyExchangeRateTypeId])REFERENCES [dbo].[tblSMCurrencyExchangeRateType] ([intCurrencyExchangeRateTypeId])
);
GO
ALTER TABLE [dbo].[tblGLAccount] ADD  CONSTRAINT [DF_tblGLAccount_strCashFlow]  DEFAULT (N'None') FOR [strCashFlow]
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccount_strAccountId]
    ON [dbo].[tblGLAccount]([strAccountId] ASC);
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'intAccountId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'String Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'strAccountId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'strDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'strNote'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'intAccountGroupId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If account is Used' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'ysnIsUsed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'intConcurrencyId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Unit Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'intAccountUnitId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comments' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'strComments' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If account is active' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'ysnActive' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If account is System Account' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'ysnSystem' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If account is for Revalue' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'ysnRevalue' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cash Flow' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'strCashFlow'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User that Last Modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'intEntityIdLastModified'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default Currency ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'intCurrencyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default Currency Exchange Rate Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccount', @level2type=N'COLUMN',@level2name=N'intCurrencyExchangeRateTypeId'
GO
