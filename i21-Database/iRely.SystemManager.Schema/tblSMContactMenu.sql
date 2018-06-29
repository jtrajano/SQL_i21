CREATE TABLE [dbo].[tblSMContactMenu]
(
	[intContactMenuId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intMasterMenuId] INT NOT NULL, 
	[strMenuName] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[intRow] INT NULL,
	[ysnContactOnly] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [FK_tblSMContactMenu_tblSMMasterMenu] FOREIGN KEY ([intMasterMenuId]) REFERENCES [tblSMMasterMenu]([intMenuID]) ON DELETE CASCADE,
)
