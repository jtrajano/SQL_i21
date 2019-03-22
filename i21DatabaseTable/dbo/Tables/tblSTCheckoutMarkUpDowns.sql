CREATE TABLE [dbo].[tblSTCheckoutMarkUpDowns]
(
       [intCheckoutMarkUpDownId] INT NOT NULL IDENTITY,
       [intCheckoutId] INT NOT NULL,
       [intCategoryId] INT NOT NULL,
       [intItemUOMId] INT NOT NULL,
       [dblQty] decimal(18, 6) NULL,
       [dblRetailUnit] decimal(18, 6) NULL,
       [dblAmount] decimal(18, 6) NULL,
       [dblShrink] decimal(18, 6) NULL,
       [strUpDownNotes] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [intConcurrencyId] INT NULL,
CONSTRAINT [PK_tblSTCheckoutMarkUpDowns_intCheckoutMarkUpDownId] PRIMARY KEY ([intCheckoutMarkUpDownId]),
CONSTRAINT [FK_tblSTCheckoutMarkUpDowns_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblSTCheckoutMarkUpDowns_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
CONSTRAINT [FK_tblSTCheckoutMarkUpDowns_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
