CREATE TABLE [dbo].[tblSMMasterMenu] (
    [intMenuID]        INT            IDENTITY (1, 1) NOT NULL,
    [strMenuName]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strModuleName]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intParentMenuID]  INT            NULL,
    [strDescription]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strType]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strCommand]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strIcon]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [ysnVisible]       BIT            DEFAULT ((0)) NOT NULL,
    [ysnExpanded]      BIT            DEFAULT ((0)) NOT NULL,
    [ysnIsLegacy]      BIT            DEFAULT ((0)) NOT NULL,
    [ysnLeaf]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]          INT            NULL,
    [intConcurrencyId] INT            DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMMasterMenu] PRIMARY KEY CLUSTERED ([intMenuID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'intMenuID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Menu Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'strMenuName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Module Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'strModuleName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Menu Id of Parent Menu',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'intParentMenuID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Type of Menu',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Command used when calling menu',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'strCommand'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Icon on the Menu',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'strIcon'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Visibility of Menu',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'ysnVisible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expanded default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'ysnExpanded'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Is an Origin Menu',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'ysnIsLegacy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Is a leaf on a tree',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'ysnLeaf'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMMasterMenu',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'