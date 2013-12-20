CREATE TABLE [dbo].[tblGLAccountTemplateDetail] (
    [intGLAccountTempalteDetailID] INT            IDENTITY (1, 1) NOT NULL,
    [intGLAccountTemplateID]       INT            NULL,
    [strTemplate]                  NVARCHAR (30)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strModuleName]                NVARCHAR (25)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDefaultName]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]               NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strRowFilter]                 NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyID]             INT            CONSTRAINT [DF__tblGLCOAT__intCo__05F8DC4F] DEFAULT ((1)) NULL,
    [ysnSelected]                  BIT            NULL,
    [intAccountID]                 INT            NULL,
    CONSTRAINT [PK_tblGLAccountTemplateDetail_1] PRIMARY KEY CLUSTERED ([intGLAccountTempalteDetailID] ASC),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccount] FOREIGN KEY ([intAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate1] FOREIGN KEY ([intGLAccountTemplateID]) REFERENCES [dbo].[tblGLAccountTemplate] ([intGLAccountTemplateID])
);

