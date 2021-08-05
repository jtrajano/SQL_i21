CREATE TABLE [dbo].[tblSTModifier]
(
	[intModifierId] INT NOT NULL IDENTITY, 
    [intItemUOMId] INT NOT NULL, 
    [intModifier] INT NULL,
    [dblModifierQuantity] NUMERIC(18, 6),
    [dblModifierPrice] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [FK_tblSTModifier_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) ON DELETE CASCADE,
);