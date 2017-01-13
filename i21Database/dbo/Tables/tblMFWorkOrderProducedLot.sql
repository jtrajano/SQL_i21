﻿CREATE TABLE [dbo].[tblMFWorkOrderProducedLot]
(
	[intWorkOrderProducedLotId] INT NOT NULL IDENTITY(1,1), 
    [intWorkOrderId] INT NOT NULL, 
	intItemId int null,
    [intLotId] INT NULL, 
    [dblQuantity] NUMERIC(38, 20) NOT NULL, 
    [intItemUOMId] INT NOT NULL,
	[dblTareWeight] NUMERIC(38, 20) NULL,
    [dblWeightPerUnit] NUMERIC(38, 20) NULL, 
	[dblPhysicalCount] NUMERIC(38, 20) NULL, 
    [intPhysicalItemUOMId] INT NULL,
	[strDateCode] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strMarking] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[dblReleaseQty] NUMERIC(38, 20) NULL,
	[intReleasedUserId] INT NULL,
	[dtmReleasedDate] DATETIME NULL,
    [intReleasedShiftId] INT NULL,
	[intShiftActivityId] INT NULL,
	[ysnReleased] BIT NULL DEFAULT 0,
	[strVesselNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intBatchId] INT NULL,
	strBatchId nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL,
	[dtmLastModified] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderProducedLot_intConcurrencyId] DEFAULT 0,
	intContainerId INT,
	intStorageLocationId INT,
	dtmProductionDate datetime NULL,
	intShiftId INT null,
	ysnProductionReversed BIT CONSTRAINT [DF_tblMFWorkOrderProducedLot_ysnProductionReversed] DEFAULT 0,
	strReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intMachineId int,
	dtmBusinessDate datetime null,
	intBusinessShiftId int null,
	[intUnitPerLayer] INT NULL, 
    [intLayerPerPallet] INT NULL, 
    [strParentLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intInputLotId int,
	intInputStorageLocationId int,
	ysnFeedProcessed bit Constraint DF_tblMFWorkOrderProducedLot_ysnFeedSent Default (0),
	ysnFillPartialPallet bit Constraint DF_tblMFWorkOrderProducedLot_ysnFillPartialPallet Default (0),
	intSpecialPalletLotId  int NULL,
	intItemTypeId INT NULL,
    CONSTRAINT [PK_tblMFWorkOrderProducedLot_intWorkOrderProducedLotId] PRIMARY KEY ([intWorkOrderProducedLotId]),
	CONSTRAINT [FK_tblMFWorkOrderProducedLot_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFWorkOrderProducedLot_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFWorkOrderProducedLot_tblICLot_intLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]),
	CONSTRAINT [FK_tblMFWorkOrderProducedLot_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFWorkOrderProducedLot_tblICItemUOM_intItemUOMId_intPhysicalItemUOMId] FOREIGN KEY ([intPhysicalItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFWorkOrderProducedLot_tblICContainer_intContainerId] FOREIGN KEY([intContainerId]) REFERENCES dbo.tblICContainer (intContainerId),
	CONSTRAINT FK_tblMFWorkOrderProducedLot_tblICStorageLocation_intStorageLocationId FOREIGN KEY(intStorageLocationId) REFERENCES dbo.tblICStorageLocation (intStorageLocationId),
	CONSTRAINT FK_tblMFWorkOrderProducedLot_tblMFShift_intShiftId FOREIGN KEY(intShiftId) REFERENCES dbo.tblMFShift (intShiftId),
	CONSTRAINT FK_tblMFWorkOrderProducedLot_tblMFMachine_intMachineId FOREIGN KEY (intMachineId) REFERENCES dbo.tblMFMachine (intMachineId),
	CONSTRAINT [FK_tblMFWorkOrderProducedLot_tblICLot_intInputLotId] FOREIGN KEY ([intInputLotId]) REFERENCES [tblICLot]([intLotId]),
	CONSTRAINT FK_tblMFWorkOrderProducedLot_tblICStorageLocation_intInputStorageLocationId FOREIGN KEY(intInputStorageLocationId) REFERENCES dbo.tblICStorageLocation (intStorageLocationId),
)
