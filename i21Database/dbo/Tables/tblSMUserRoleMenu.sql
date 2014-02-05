CREATE TABLE [dbo].[tblSMUserRoleMenu] (
    [intUserRoleMenuID] INT IDENTITY (1, 1) NOT NULL,
    [intUserRoleID]     INT NOT NULL,
    [intMenuID]         INT NOT NULL,
    [intParentMenuID]   INT NULL,
    [ysnVisible]        BIT CONSTRAINT [DF_tblSMUserRoleMenu_ysnVisible] DEFAULT ((1)) NOT NULL,
    [intSort]           INT NULL,
    [intConcurrencyId]  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMUserRoleMenu] PRIMARY KEY CLUSTERED ([intUserRoleMenuID] ASC),
    CONSTRAINT [FK_tblSMUserRoleMenu_tblSMMasterMenu] FOREIGN KEY ([intMenuID]) REFERENCES [dbo].[tblSMMasterMenu] ([intMenuID]),
    CONSTRAINT [FK_tblSMUserRoleMenu_tblSMUserRole] FOREIGN KEY ([intUserRoleID]) REFERENCES [dbo].[tblSMUserRole] ([intUserRoleID])
);

