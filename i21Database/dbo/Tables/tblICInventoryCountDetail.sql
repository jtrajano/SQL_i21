﻿CREATE TABLE [dbo].[tblICInventoryCountDetail]
(
	[intInventoryCountDetailId] INT NOT NULL IDENTITY, 
    [intInventoryCountId] INT NOT NULL, 
    [intItemId] INT NULL, 
    [intItemLocationId] INT NULL, 
    [intSubLocationId] INT NULL, 
    [intStorageLocationId] INT NULL, 
    [intLotId] INT NULL, 
	[strLotNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intParentLotId] INT NULL, 
	[strParentLotNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strParentLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intStockUOMId] INT NULL,
    [dblSystemCount] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), 
    [dblLastCost] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), 
	[strAutoCreatedLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strCountLine] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblPallets] NUMERIC(38, 20) NULL DEFAULT ((0)), 
    [dblQtyPerPallet] NUMERIC(38, 20) NULL DEFAULT ((0)), 
    [dblPhysicalCount] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), 
    [intItemUOMId] INT NULL, 
    [intWeightUOMId] INT NULL,
    [dblWeightQty] NUMERIC(38, 20) NULL DEFAULT((0)),
    [dblNetQty] NUMERIC(38, 20) NULL DEFAULT((0)),
    [ysnRecount] BIT NOT NULL DEFAULT ((0)), 
    [intEntityUserSecurityId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryCountDetail] PRIMARY KEY ([intInventoryCountDetailId]), 
    CONSTRAINT [FK_tblICInventoryCountDetail_tblICInventoryCount] FOREIGN KEY ([intInventoryCountId]) REFERENCES [tblICInventoryCount]([intInventoryCountId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryCountDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryCountDetail_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]), 
    CONSTRAINT [FK_tblICInventoryCountDetail_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblICInventoryCountDetail_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
    CONSTRAINT [FK_tblICInventoryCountDetail_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]), 
    CONSTRAINT [FK_tblICInventoryCountDetail_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryCountDetail_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityUserSecurityId]) 
)