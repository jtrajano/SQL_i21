CREATE TABLE [dbo].[tblGLAccountTemplate] (
    [intGLAccountTemplateId] INT           IDENTITY (1, 1) NOT NULL,
    [strTemplate]            NVARCHAR (30) COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]         NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOATemplate] PRIMARY KEY CLUSTERED ([intGLAccountTemplateId] ASC)
);

