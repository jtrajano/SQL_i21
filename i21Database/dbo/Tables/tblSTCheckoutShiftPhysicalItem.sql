CREATE TABLE [dbo].[tblSTCheckoutShiftPhysicalItem]
(
    [intCheckoutShiftPhysicalItemId] INT NOT NULL IDENTITY, 
    [intCheckoutId] INT NOT NULL,
    [intItemId] INT NULL,
    [intItemLocationId] INT NULL,
    [intItemUOMId] INT NULL, 
    [dblSystemCount] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), --Begin Qty
    [dblQtyReceived] NUMERIC(38, 20) NULL DEFAULT((0)),
	[dblQtyTransferred] NUMERIC(38, 20) NULL DEFAULT((0)),
    [dblQtySold] NUMERIC(38, 20) NULL DEFAULT((0)),
    [dblPhysicalCount] NUMERIC(38, 20) NOT NULL DEFAULT ((0)),
    [intEntityUserSecurityId] INT NOT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblCheckoutShiftPhysicalItem] PRIMARY KEY ([intCheckoutShiftPhysicalItemId]),
    --CONSTRAINT [AK_tblSTCheckoutShiftPhysicalItem_intCheckoutId_intItemId_intItemLocationId_intItemUOMId] UNIQUE NONCLUSTERED ([intCheckoutId],[intItemId],[intItemLocationId],[intItemUOMId]  ASC), 
    CONSTRAINT [FK_tblCheckoutShiftPhysicalItem_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCheckoutShiftPhysicalItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
    CONSTRAINT [FK_tblCheckoutShiftPhysicalItem_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
    CONSTRAINT [FK_tblCheckoutShiftPhysicalItem_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
    CONSTRAINT [FK_tblCheckoutShiftPhysicalItem_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId])
)