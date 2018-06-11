CREATE TABLE [dbo].[tblSMUserSecurityMenu] (
    [intUserSecurityMenuId]     INT IDENTITY (1, 1) NOT NULL,
    [intEntityUserSecurityId]         INT NOT NULL,
	[intMenuId]         INT NOT NULL,
	[intParentMenuId]   INT NULL,
    [ysnVisible]        BIT CONSTRAINT [DF_tblSMUserSecurityMenu_ysnVisible] DEFAULT ((1)) NOT NULL,
    [intSort]           INT NULL,
    [intConcurrencyId]  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMUserSecurityMenu] PRIMARY KEY CLUSTERED ([intUserSecurityMenuId] ASC),
    CONSTRAINT [FK_tblSMUserSecurityMenu_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [dbo].[tblSMUserSecurity] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityMenu_tblSMMasterMenu] FOREIGN KEY ([intMenuId]) REFERENCES [dbo].[tblSMMasterMenu] ([intMenuID]) ON DELETE CASCADE
);


GO
