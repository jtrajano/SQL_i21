CREATE TABLE [dbo].[tblSMShortcutKeys](
	[intShortcutKeyId] [int] IDENTITY(1,1) NOT NULL,
	[strModule] [nvarchar](50) NULL,
	[strItemId] [nvarchar](30) NOT NULL,
	[strShortcutKey] [nvarchar](5) NOT NULL,
	[ctrl] [bit] NULL,
	[shift] [bit] NULL,
	[alt] [bit] NULL,
	[isEnabled] [bit] NULL,
	[intConcurrencyId] [int] NULL
) ON [PRIMARY]

