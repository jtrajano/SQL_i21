CREATE TABLE [dbo].[tblMFWorkOrderInputLot]
(
	[intWorkOrderInputLotId] INT NOT NULL IDENTITY(1,1), 
    [intWorkOrderId] INT NOT NULL, 
    [intLotId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [dblIssuedQuantity] NUMERIC(18, 6) NULL, 
    [intItemIssuedUOMId] INT NULL, 
    [intRecipeItemId] INT NULL, 
    [intSequenceNo] INT NULL,
	[dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL,
	[dtmLastModified] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderInputLot_intConcurrencyId] DEFAULT 0, 
	CONSTRAINT [PK_tblMFWorkOrderInputLot_intWorkOrderInputLotId] PRIMARY KEY ([intWorkOrderInputLotId]),
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblICLot_inLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]),
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM](intItemUOMId),
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblICItemUOM_intIssuedItemUOMId] FOREIGN KEY ([intItemIssuedUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
