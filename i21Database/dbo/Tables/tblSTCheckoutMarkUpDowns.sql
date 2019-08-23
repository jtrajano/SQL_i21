CREATE TABLE [dbo].[tblSTCheckoutMarkUpDowns]
(
       [intCheckoutMarkUpDownId]	INT				NOT NULL IDENTITY,
       [intCheckoutId]				INT				NOT NULL,
	   [intItemMovementId]			INT				NULL,				--> This will be used to modify MarkU/D when ItemMovement value is changed
       [intCategoryId]				INT				NOT NULL,
       [intItemUOMId]				INT				NOT NULL,
       [dblQty]						DECIMAL(18, 6)	NULL,
       [dblRetailUnit]				DECIMAL(18, 6)	NULL,
       [dblAmount]					DECIMAL(18, 6)	NULL,
       [dblShrink]					DECIMAL(18, 6)	NULL,
       [strUpDownNotes]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
       [intConcurrencyId]			INT				NULL,
CONSTRAINT [PK_tblSTCheckoutMarkUpDowns_intCheckoutMarkUpDownId] PRIMARY KEY ([intCheckoutMarkUpDownId]),
CONSTRAINT [FK_tblSTCheckoutMarkUpDowns_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblSTCheckoutMarkUpDowns_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
CONSTRAINT [FK_tblSTCheckoutMarkUpDowns_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
