CREATE TABLE [dbo].[tblSMUserSecurityMenu] (
    [intUserSecurityMenuId]     INT IDENTITY (1, 1) NOT NULL,
    [intUserSecurityId]         INT NOT NULL,
	[intMenuId]         INT NOT NULL,
	[intParentMenuId]   INT NULL,
    [ysnVisible]        BIT CONSTRAINT [DF_tblSMUserSecurityMenu_ysnVisible] DEFAULT ((1)) NOT NULL,
    [intSort]           INT NULL,
    [intConcurrencyId]  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMUserSecurityMenu] PRIMARY KEY CLUSTERED ([intUserSecurityMenuId] ASC),
    CONSTRAINT [FK_tblSMUserSecurityMenu_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [dbo].[tblSMUserSecurity] ([intUserSecurityID]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityMenu_tblSMMasterMenu] FOREIGN KEY ([intMenuId]) REFERENCES [dbo].[tblSMMasterMenu] ([intMenuID]) ON DELETE CASCADE
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenu',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenu',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Menu Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenu',
    @level2type = N'COLUMN',
    @level2name = N'intMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field of Parent Menu',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenu',
    @level2type = N'COLUMN',
    @level2name = N'intParentMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Menu is Visible',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenu',
    @level2type = N'COLUMN',
    @level2name = N'ysnVisible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenu',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenu',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'