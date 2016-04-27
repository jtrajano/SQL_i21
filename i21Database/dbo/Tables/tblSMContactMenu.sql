CREATE TABLE [dbo].[tblSMContactMenu]
(
	[intContactMenuId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intMasterMenuId] INT NOT NULL, 
	[ysnContactOnly] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [FK_tblSMContactMenu_tblSMMasterMenu] FOREIGN KEY ([intMasterMenuId]) REFERENCES [tblSMMasterMenu]([intMenuID]) ON DELETE CASCADE,
)
