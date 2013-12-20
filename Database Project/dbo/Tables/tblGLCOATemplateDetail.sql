CREATE TABLE [dbo].[tblGLCOATemplateDetail] (
    [intAccountTemplateDetailID] INT           IDENTITY (1, 1) NOT NULL,
    [intAccountTemplateID]       INT           NULL,
    [strCode]                    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]             NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupID]          INT           NULL,
    [intAccountStructureID]      INT           NULL,
    [intConcurrencyID]           INT           NULL,
    CONSTRAINT [PK_tblGLAccountTemplateDetail] PRIMARY KEY CLUSTERED ([intAccountTemplateDetailID] ASC),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupID]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupID]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountStructure] FOREIGN KEY ([intAccountStructureID]) REFERENCES [dbo].[tblGLAccountStructure] ([intAccountStructureID]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate] FOREIGN KEY ([intAccountTemplateID]) REFERENCES [dbo].[tblGLCOATemplate] ([intAccountTemplateID])
);

