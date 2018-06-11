CREATE TABLE [dbo].[tblGLAccountDefaultDetail] (
    [intAccountDefaultDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intAccountDefaultId]       INT            NOT NULL,
    [strModuleName]             NVARCHAR (25)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDefaultName]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]            NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strRowFilter]              NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]          INT            DEFAULT 1 NOT NULL,
    [intAccountId]              INT            NULL,
    CONSTRAINT [PK_GLAccountDefault_AccountDefaultId] PRIMARY KEY CLUSTERED ([intAccountDefaultDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountDefault_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountDefaultDetail_tblGLAccountDefault] FOREIGN KEY ([intAccountDefaultId]) REFERENCES [dbo].[tblGLAccountDefault] ([intAccountDefaultId])
);

