CREATE TABLE [dbo].[tblGLCOATemplateDetail] (
    [intAccountTemplateDetailId] INT           IDENTITY (1, 1) NOT NULL,
    [intAccountTemplateId]       INT           NULL,
    [strCode]                    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]             NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupId]          INT           NULL,
    [intAccountStructureId]      INT           NULL,
    [intConcurrencyId]           INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountTemplateDetail] PRIMARY KEY CLUSTERED ([intAccountTemplateDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupId]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupId]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountStructure] FOREIGN KEY ([intAccountStructureId]) REFERENCES [dbo].[tblGLAccountStructure] ([intAccountStructureId]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate] FOREIGN KEY ([intAccountTemplateId]) REFERENCES [dbo].[tblGLCOATemplate] ([intAccountTemplateId])
);

