﻿CREATE TABLE [dbo].[tblMFWorkOrderConsumedLot]
(
	[intWorkOrderConsumedLotId] INT NOT NULL IDENTITY(1,1), 
    [intWorkOrderId] INT NOT NULL, 
	intItemId int null,
    [intLotId] INT NULL, 
    [dblQuantity] NUMERIC(38, 20) NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [dblIssuedQuantity] NUMERIC(38, 20) NULL, 
    [intItemIssuedUOMId] INT NULL, 
    [intRecipeItemId] INT NULL,
	[ysnStaged] BIT NULL,
	[intLotTransactionId] INT NULL,
    [intSequenceNo] INT NULL,
	[intBatchId] INT NULL,
	intShiftId INT,
	intSubLocationId INT,
	intStorageLocationId INT,
	intMachineId INT,
	ysnConsumptionReversed BIT,
	intContainerId INT,
	strReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	ysnFeedSent BIT Constraint DF_tblMFWorkOrderConsumedLot_ysnFeedSent Default (0),
	dtmActualInputDateTime DATETIME,
	strBatchId nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL,
	[dtmLastModified] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderConsumedLot_intConcurrencyId] DEFAULT 0, 
	[ysnPosted] bit NULL CONSTRAINT [DF_tblMFWorkOrderConsumedLot_ysnPosted] DEFAULT 0, 
	CONSTRAINT [PK_tblMFWorkOrderConsumedLot_intWorkOrderConsumedLotId] PRIMARY KEY ([intWorkOrderConsumedLotId]),
	CONSTRAINT [FK_tblMFWorkOrderConsumedLot_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFWorkOrderConsumedLot_tblICItem_inItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFWorkOrderConsumedLot_tblICLot_inLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]),
	CONSTRAINT [FK_tblMFWorkOrderConsumedLot_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFWorkOrderConsumedLot_tblICItemUOM_intIssuedItemUOMId] FOREIGN KEY ([intItemIssuedUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	 CONSTRAINT FK_tblMFWorkOrderConsumedLot_tblMFShift_intShiftId FOREIGN KEY (intShiftId) REFERENCES dbo.tblMFShift (intShiftId),
	 CONSTRAINT [FK_tblMFWorkOrderConsumedLot_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	 CONSTRAINT FK_tblMFWorkOrderConsumedLot_tblICStorageLocation_intStorageLocationId FOREIGN KEY (intStorageLocationId) REFERENCES dbo.tblICStorageLocation (intStorageLocationId),
	 CONSTRAINT FK_tblMFWorkOrderConsumedLot_tblMFMachine_intMachineId FOREIGN KEY (intMachineId) REFERENCES dbo.tblMFMachine (intMachineId)
)
