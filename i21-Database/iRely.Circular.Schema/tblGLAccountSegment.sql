CREATE TABLE [dbo].[tblGLAccountSegment] (
    [intAccountSegmentId]   INT            IDENTITY (1, 1) NOT NULL,
    [strCode]               NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[strChartDesc]          NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intAccountStructureId] INT            NOT NULL,
    [intAccountGroupId]     INT            NULL,
    [ysnActive]             BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnActive] DEFAULT ((1)) NULL,
    [ysnSelected]           BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnSelected] DEFAULT ((0)) NOT NULL,
    [ysnIsNotExisting]      BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnIsNotExisting] DEFAULT ((0)) NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    [intAccountCategoryId] INT NULL, 
    [intEntityIdLastModified] INT NULL, 
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

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intAccountSegmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'strCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Structure Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intAccountStructureId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'ysnActive' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Selected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'ysnSelected' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Not Existing' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'ysnIsNotExisting' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intAccountCategoryId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id Last Modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegment', @level2type=N'COLUMN',@level2name=N'intEntityIdLastModified' 
GO