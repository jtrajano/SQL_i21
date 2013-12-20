CREATE TABLE [dbo].[tblGLCOATemplate] (
    [intAccountTemplateID]   INT           IDENTITY (1, 1) NOT NULL,
    [strAccountTemplateName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID]       INT           CONSTRAINT [DF_tblGLAccountTemplate_intConcurrencyID] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblGLAccountTemplate] PRIMARY KEY CLUSTERED ([intAccountTemplateID] ASC)
);

