﻿CREATE TABLE [dbo].[tblGLAccount] (
    [intAccountId]      INT             IDENTITY (1, 1) NOT NULL,
    [strAccountId]      NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]    NVARCHAR (255)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strNote]           NTEXT           COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupId] INT             NULL,
    [dblOpeningBalance] NUMERIC (18, 6) NULL,
    [ysnIsUsed]         BIT             CONSTRAINT [DF_tblGLAccount_ysnIsUsed] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]  INT             DEFAULT 1 NOT NULL,
    [intAccountUnitId]  INT             NULL,
    [strComments]       NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]         BIT             NULL,
    [ysnSystem]         BIT             NULL,
	[ysnRevalue]		BIT				NULL,
    [strCashFlow]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intAccountCategoryId] INT NULL, 
    [intEntityIdLastModified] INT NULL, 
    [intCurrencyID] INT NULL, 
    [intCurrencyExchangeRateTypeId] INT NULL, 
    CONSTRAINT [PK_GLAccount_AccountId] PRIMARY KEY CLUSTERED ([intAccountId] ASC),
    CONSTRAINT [FK_tblGLAccount_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupId]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupId]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_tblGLAccount_tblGLAccountUnit] FOREIGN KEY ([intAccountUnitId]) REFERENCES [dbo].[tblGLAccountUnit] ([intAccountUnitId]),
	CONSTRAINT [FK_tblGLAccount_tblGLAccountCategory] FOREIGN KEY([intAccountCategoryId])REFERENCES [dbo].[tblGLAccountCategory] ([intAccountCategoryId]),
	CONSTRAINT [FK_tblGLAccount_tblSMCurrency] FOREIGN KEY([intCurrencyID])REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblGLAccount_tblSMCurrencyExchangeRateType] FOREIGN KEY([intCurrencyExchangeRateTypeId])REFERENCES [dbo].[tblSMCurrencyExchangeRateType] ([intCurrencyExchangeRateTypeId])
);
GO
ALTER TABLE [dbo].[tblGLAccount] ADD  CONSTRAINT [DF_tblGLAccount_strCashFlow]  DEFAULT (N'NONE') FOR [strCashFlow]
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccount_strAccountId]
    ON [dbo].[tblGLAccount]([strAccountId] ASC);
GO


