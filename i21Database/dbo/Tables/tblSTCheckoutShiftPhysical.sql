CREATE TABLE [dbo].[tblSTCheckoutShiftPhysical]
(
    [intCheckoutShiftPhysicalId] INT NOT NULL IDENTITY, 
    [intCheckoutId] INT NOT NULL,
    [intItemId] INT NULL,
    [intCountGroupId] INT NULL,
    [intItemLocationId] INT NULL,
    [intItemUOMId] INT NULL, 
    [dblSystemCount] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), --Begin Qty
    [dblQtyReceived] NUMERIC(38, 20) NULL DEFAULT((0)),
    [dblQtySold] NUMERIC(38, 20) NULL DEFAULT((0)),
    [dblPhysicalCount] NUMERIC(38, 20) NOT NULL DEFAULT ((0)),
    [intEntityUserSecurityId] INT NOT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblCheckoutShiftPhysical] PRIMARY KEY ([intCheckoutShiftPhysicalId]),
    CONSTRAINT [FK_tblCheckoutShiftPhysical_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCheckoutShiftPhysical_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
    CONSTRAINT [FK_tblCheckoutShiftPhysical_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
    CONSTRAINT [FK_tblCheckoutShiftPhysical_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
    CONSTRAINT [FK_tblCheckoutShiftPhysical_tblICCountGroup] FOREIGN KEY ([intCountGroupId]) REFERENCES [tblICCountGroup]([intCountGroupId]),
    CONSTRAINT [FK_tblCheckoutShiftPhysical_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId])
)