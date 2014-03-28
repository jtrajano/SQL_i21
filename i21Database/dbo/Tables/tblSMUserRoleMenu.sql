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

