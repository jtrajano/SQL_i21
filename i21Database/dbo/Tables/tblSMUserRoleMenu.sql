CREATE TABLE [dbo].[tblSMUserRoleMenu] (
    [intUserRoleMenuId] INT IDENTITY (1, 1) NOT NULL,
    [intUserRoleId]     INT NOT NULL,
    [intMenuId]         INT NOT NULL,
    [intParentMenuId]   INT NULL,
    [ysnVisible]        BIT CONSTRAINT [DF_tblSMUserRoleMenu_ysnVisible] DEFAULT ((1)) NOT NULL,
    [intSort]           INT NULL,
    [intConcurrencyId]  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMUserRoleMenu] PRIMARY KEY CLUSTERED ([intUserRoleMenuId] ASC),
    CONSTRAINT [FK_tblSMUserRoleMenu_tblSMMasterMenu] FOREIGN KEY ([intMenuId]) REFERENCES [dbo].[tblSMMasterMenu] ([intMenuID]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSMUserRoleMenu_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [dbo].[tblSMUserRole] ([intUserRoleID]) ON DELETE CASCADE
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleMenu',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Role Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleMenu',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Menu Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleMenu',
    @level2type = N'COLUMN',
    @level2name = N'intMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field of Parent Menu',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleMenu',
    @level2type = N'COLUMN',
    @level2name = N'intParentMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Menu is Visible',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleMenu',
    @level2type = N'COLUMN',
    @level2name = N'ysnVisible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleMenu',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleMenu',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'