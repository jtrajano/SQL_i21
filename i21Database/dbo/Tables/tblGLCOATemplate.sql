CREATE TABLE [dbo].[tblGLCOATemplate] (
    [intAccountTemplateId]   INT           IDENTITY (1, 1) NOT NULL,
    [strAccountTemplateName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]				 NVARCHAR (15) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountTemplate] PRIMARY KEY CLUSTERED ([intAccountTemplateId] ASC)
);

