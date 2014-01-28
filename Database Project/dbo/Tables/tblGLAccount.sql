CREATE TABLE [dbo].[tblGLAccount] (
    [intAccountID]      INT             IDENTITY (1, 1) NOT NULL,
    [strAccountID]      NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]    NVARCHAR (255)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strNote]           NTEXT           COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupID] INT             NULL,
    [dblOpeningBalance] NUMERIC (18, 6) NULL,
    [ysnIsUsed]         BIT             CONSTRAINT [DF_tblGLAccount_ysnIsUsed] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]  INT             NOT NULL DEFAULT 1,
    [intAccountUnitID]  INT             NULL,
    [strComments]       NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]         BIT             NULL,
    [ysnSystem]         BIT             NULL,
    [strCashFlow]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_GLAccount_AccountID] PRIMARY KEY CLUSTERED ([intAccountID] ASC),
    CONSTRAINT [FK_tblGLAccount_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupID]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_tblGLAccount_tblGLAccountUnit] FOREIGN KEY ([intAccountUnitID]) REFERENCES [dbo].[tblGLAccountUnit] ([intAccountUnitID])
);

