CREATE TABLE [dbo].[tblSMContactMenu]
(
	[intContactMenuId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intMasterMenuId] INT NOT NULL, 
    CONSTRAINT [FK_tblSMContactMenu_tblSMMasterMenu] FOREIGN KEY ([intMasterMenuId]) REFERENCES [tblSMMasterMenu]([intMenuID]) ON DELETE CASCADE,
)
