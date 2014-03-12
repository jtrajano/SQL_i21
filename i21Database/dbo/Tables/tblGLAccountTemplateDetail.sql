CREATE TABLE [dbo].[tblGLAccountTemplateDetail] (
    [intGLAccountTempalteDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intGLAccountTemplateId]       INT            NULL,
    [strTemplate]                  NVARCHAR (30)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strModuleName]                NVARCHAR (25)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDefaultName]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]               NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strRowFilter]                 NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [ysnSelected]                  BIT            NULL,
    [intAccountId]                 INT            NULL,
    [intConcurrencyId]             INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountTemplateDetail_1] PRIMARY KEY CLUSTERED ([intGLAccountTempalteDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate1] FOREIGN KEY ([intGLAccountTemplateId]) REFERENCES [dbo].[tblGLAccountTemplate] ([intGLAccountTemplateId])
);

