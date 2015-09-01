﻿CREATE TABLE [dbo].[tblMFWorkOrderInputParentLot]
(
	[intWorkOrderInputParentLotId] INT NOT NULL IDENTITY(1,1), 
    [intWorkOrderId] INT NOT NULL, 
	[intItemId] int NOT NULL,
    [intParentLotId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [dblIssuedQuantity] NUMERIC(18, 6) NULL, 
    [intItemIssuedUOMId] INT NULL, 
    [dblWeightPerUnit] NUMERIC(18, 6) NULL, 
    [intRecipeItemId] INT NULL, 
    [intStorageLocationId] INT NULL, 
    [intLocationId] INT NULL, 
    [intSequenceNo] INT NULL,
	[dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL,
	[dtmLastModified] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderInputParentLot_intConcurrencyId] DEFAULT 0, 
	CONSTRAINT [PK_tblMFWorkOrderInputParentLot_intWorkOrderInputParentLotId] PRIMARY KEY ([intWorkOrderInputParentLotId]),
	CONSTRAINT [FK_tblMFWorkOrderInputParentLot_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFWorkOrderInputParentLot_tblICItem_inItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFWorkOrderInputParentLot_tblICParentLot_inParentLotId] FOREIGN KEY ([intParentLotId]) REFERENCES [tblICParentLot]([intParentLotId]),
	CONSTRAINT [FK_tblMFWorkOrderInputParentLot_tblICItemUOM_inItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFWorkOrderInputParentLot_tblICItemUOM_intIssuedItemUOMId] FOREIGN KEY ([intItemIssuedUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFWorkOrderInputParentLot_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
	CONSTRAINT [FK_tblMFWorkOrderInputParentLot_tblSMCompanyLocation_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)
