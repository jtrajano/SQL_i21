CREATE TABLE [dbo].[tblSMShortcutKeys](
	[intShortcutKeyId] [int] IDENTITY(1,1) NOT NULL,
	[intMenuId] [int] NULL,
	[strShortcutKey] [nvarchar](5) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnCtrl] [bit] NULL,
	[ysnShift] [bit] NULL,
	[ysnAlt] [bit] NULL,
	[ysnEnabled] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblSMShortcutKeys] PRIMARY KEY CLUSTERED ([intShortcutKeyId] ASC),
	CONSTRAINT [FK_tblSMMasterMenu_tblSMShortcutKeys] FOREIGN KEY ([intMenuId]) REFERENCES [tblSMMasterMenu]([intMenuID])
)

