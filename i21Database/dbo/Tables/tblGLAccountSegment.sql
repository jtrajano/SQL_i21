CREATE TABLE [dbo].[tblGLAccountSegment] (
    [intAccountSegmentId]   INT            IDENTITY (1, 1) NOT NULL,
    [strCode]               NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intAccountStructureId] INT            NOT NULL,
    [intAccountGroupId]     INT            NULL,
    [ysnActive]             BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnActive] DEFAULT ((1)) NULL,
    [ysnSelected]           BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnSelected] DEFAULT ((0)) NOT NULL,
    [ysnBuild]              BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnBuild] DEFAULT ((0)) NOT NULL,
    [ysnIsNotExisting]      BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnIsNotExisting] DEFAULT ((0)) NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_GLAccountSegment_AccountSegmentId] PRIMARY KEY CLUSTERED ([intAccountSegmentId] ASC),
    CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupId]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupId]),
    CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountStructure] FOREIGN KEY ([intAccountStructureId]) REFERENCES [dbo].[tblGLAccountStructure] ([intAccountStructureId])
);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccountSegment_strCode]
    ON [dbo].[tblGLAccountSegment]([strCode] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccountSegment_intAccountStructureId]
    ON [dbo].[tblGLAccountSegment]([intAccountStructureId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccountSegment_intAccountGroupId]
    ON [dbo].[tblGLAccountSegment]([intAccountGroupId] ASC);
GO