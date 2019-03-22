CREATE TABLE [dbo].[tblSMInterDatabaseUserRoleMenu] (
    [intUserRoleMenuId] INT IDENTITY (1, 1) NOT NULL,
    [intUserRoleId]     INT NOT NULL,
    [intMenuId]         INT NOT NULL,
    [intParentMenuId]   INT NULL,
    [ysnVisible]        BIT CONSTRAINT [DF_tblSMInterDatabaseUserRoleMenuu_ysnVisible] DEFAULT ((1)) NOT NULL,
    [intSort]           INT NULL,
	[ysnAvailable]      BIT NULL,
    [intConcurrencyId]  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMInterDatabaseUserRoleMenu_intUserRoleMenuId] PRIMARY KEY CLUSTERED ([intUserRoleMenuId] ASC)
);