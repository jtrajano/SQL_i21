CREATE TABLE [dbo].[tblSMUserMenu] (
    [intUserMenuID]     INT IDENTITY (1, 1) NOT NULL,
    [intUserID]         INT NOT NULL,
    [intUserRoleMenuID] INT NOT NULL,
    [ysnVisible]        BIT CONSTRAINT [DF_tblSMUserMenu_ysnVisible] DEFAULT ((1)) NOT NULL,
    [intSort]           INT NULL,
    [intConcurrencyId]  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMUserMenu] PRIMARY KEY CLUSTERED ([intUserMenuID] ASC),
    CONSTRAINT [FK_tblSMUserMenu_tblSMUserRoleMenu] FOREIGN KEY ([intUserRoleMenuID]) REFERENCES [dbo].[tblSMUserRoleMenu] ([intUserRoleMenuID]),
    CONSTRAINT [FK_tblSMUserMenu_tblSMUserSecurity] FOREIGN KEY ([intUserID]) REFERENCES [dbo].[tblSMUserSecurity] ([intUserSecurityID])
);

