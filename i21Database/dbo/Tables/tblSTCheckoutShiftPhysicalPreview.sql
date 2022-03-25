CREATE TABLE [dbo].[tblSTCheckoutShiftPhysicalPreview]
(
    [intCheckoutShiftPhysicalPreviewId] INT NOT NULL IDENTITY, 
    [intCheckoutId] INT NULL,
    [intItemId] INT NULL,
    [intCountGroupId] INT NULL,
    [intItemLocationId] INT NULL,
    [intItemUOMId] INT NULL, 
    [dblSystemCount] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), --Begin Qty
    [dblQtyReceived] NUMERIC(38, 20) NULL DEFAULT((0)),
    [dblQtySold] NUMERIC(38, 20) NULL DEFAULT((0)),
    [dblPhysicalCount] NUMERIC(38, 20) NOT NULL DEFAULT ((0)),
    [intEntityUserSecurityId] INT NOT NULL,
    [dtmCheckoutDate] DATETIME NULL,
    [intLocationId] INT NOT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0))
)