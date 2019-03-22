CREATE TABLE [dbo].[tblGLAccountStructure] (
    [intAccountStructureId]  INT            IDENTITY (1, 1) NOT NULL,
    [intStructureType]       INT            NOT NULL,
    [strStructureName]       NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strType]                NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [intLength]              INT            NULL,
    [strMask]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intSort]                INT            NULL,
    [ysnBuild]               BIT            CONSTRAINT [DF_tblGLAccountStructure_ysnBuild] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]       INT            DEFAULT 1 NOT NULL,
    [intStartingPosition]    INT            NULL,
    [intOriginLength]        INT            NULL,
    [strOtherSoftwareColumn] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_GLAccountStructure_AccountStructureId] PRIMARY KEY CLUSTERED ([intAccountStructureId] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'intAccountStructureId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Structure Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'intStructureType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Structure Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'strStructureName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'strType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Length' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'intLength' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mask' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'strMask' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sort' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'intSort' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Build' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'ysnBuild' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Starting Position' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'intStartingPosition' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Origin Length' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'intOriginLength' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Other Software Column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountStructure', @level2type=N'COLUMN',@level2name=N'strOtherSoftwareColumn' 
GO