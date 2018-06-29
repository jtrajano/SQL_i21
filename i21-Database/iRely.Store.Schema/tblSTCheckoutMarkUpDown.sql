CREATE TABLE [dbo].[tblSTCheckoutMarkUpDown]
(
	[intCheckoutMarkUpDownId] int IDENTITY(1,1) NOT NULL PRIMARY KEY, 
	[intCheckoutId] int NULL,
	[intCategoryId] int NULL,
	[intItemUOMId] int NULL,
	[dblQtyRetailUnit] decimal(18, 6) NULL,
	[dblAmount] decimal(18, 6) NULL,
	[dblShrink] decimal(18, 6) NULL,
	[strUpDownNotes] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL, 
	CONSTRAINT [FK_tblSTCheckoutMarkUpDown_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSTCheckoutMarkUpDown_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES tblICCategory([intCategoryId]), 
    CONSTRAINT [FK_tblSTCheckoutMarkUpDown_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) 
)
