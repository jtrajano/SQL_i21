CREATE TABLE [dbo].[tblICItemAddOn]
(
	[intItemAddOnId] INT NOT NULL IDENTITY, 
	[intItemId] INT NOT NULL, 
	[intAddOnItemId] INT NOT NULL, 
	[dblQuantity] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[intItemUOMId] INT NULL, 
	[ysnAutoAdd] BIT NULL DEFAULT((0)),
	[intConcurrencyId] INT NULL DEFAULT ((0)), 
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	CONSTRAINT [PK_tblICItemAddOn] PRIMARY KEY ([intItemAddOnId]),
	CONSTRAINT [FK_tblICItemAddOn_Item] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblICItemAddOn_AddOn] FOREIGN KEY ([intAddOnItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblICItemAddOn_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICItemAddOn_intAddOnItemId]
	ON [dbo].[tblICItemAddOn]([intAddOnItemId] ASC)
	INCLUDE ([intItemId])
GO