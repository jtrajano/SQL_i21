CREATE TABLE [dbo].[tblSMShortcutKeys](
	[intShortcutKeyId] [int] IDENTITY(1,1) NOT NULL,
	[strModule] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL ,
	[strItemId] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[strShortcutKey] [nvarchar](5) COLLATE Latin1_General_CI_AS NOT NULL,
	[ctrl] [bit] NULL,
	[shift] [bit] NULL,
	[alt] [bit] NULL,
	[isEnabled] [bit] NULL,
	[intConcurrencyId] [int] NULL
) ON [PRIMARY]

