CREATE TABLE [dbo].[tblDBPanelOwner]
(
	[intPanelOwnerId] [int] IDENTITY(1,1) NOT NULL,
	[intPanelId] [int] NOT NULL,
	[intUserId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblDBPanelOwner] PRIMARY KEY CLUSTERED ([intPanelOwnerId] ASC),
	CONSTRAINT [UK_tblDBPanelOwne_1] UNIQUE NONCLUSTERED ([intPanelId] ASC,[intUserId] ASC),
	CONSTRAINT [FK_tblDBPanelOwner_tblDBPanel] FOREIGN KEY([intPanelId]) REFERENCES [dbo].[tblDBPanel] ([intPanelId]) ON DELETE CASCADE
)
