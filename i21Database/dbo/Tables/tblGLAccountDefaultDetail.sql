CREATE TABLE [dbo].[tblGLAccountDefaultDetail] (
    [intAccountDefaultDetailID] INT            IDENTITY (1, 1) NOT NULL,
    [intAccountDefaultID]       INT            NOT NULL,
    [strModuleName]             NVARCHAR (25)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDefaultName]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]            NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strRowFilter]              NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]          INT            DEFAULT 1 NOT NULL,
    [intAccountID]              INT            NULL,
    CONSTRAINT [PK_GLAccountDefault_AccountDefaultID] PRIMARY KEY CLUSTERED ([intAccountDefaultDetailID] ASC),
    CONSTRAINT [FK_tblGLAccountDefault_tblGLAccount] FOREIGN KEY ([intAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]),
    CONSTRAINT [FK_tblGLAccountDefaultDetail_tblGLAccountDefault] FOREIGN KEY ([intAccountDefaultID]) REFERENCES [dbo].[tblGLAccountDefault] ([intAccountDefaultID])
);

