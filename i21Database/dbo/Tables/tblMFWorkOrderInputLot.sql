﻿CREATE TABLE [dbo].[tblMFWorkOrderInputLot]
(
	[intWorkOrderInputLotId] INT NOT NULL IDENTITY(1,1), 
    [intWorkOrderId] INT NOT NULL, 
	[intItemId] int NULL,
    [intLotId] INT NULL, 
    [dblQuantity] NUMERIC(38, 20) NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [dblIssuedQuantity] NUMERIC(38, 20) NULL, 
    [intItemIssuedUOMId] INT NULL, 
    [intRecipeItemId] INT NULL, 
    [intSequenceNo] INT NULL,
	intShiftId INT NULL,
	intStorageLocationId INT,
	intMachineId INT,
	ysnConsumptionReversed BIT,
	intContainerId INT,
	strReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmActualInputDateTime DATETIME,
	[dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL,
	[dtmLastModified] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderInputLot_intConcurrencyId] DEFAULT 0, 
	dtmBusinessDate datetime null,
	intBusinessShiftId int NULL,
	dtmProductionDate datetime NULL,
	[intBatchId] INT NULL, 
	dblEnteredQty NUMERIC(38, 20),
	intEnteredItemUOMId int,
	intDestinationLotId int NULL,
	intMainItemId int NULL,
	ysnKeep BIT,
	dblTBSQuantity NUMERIC(38, 20) NULL,
	strFW NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblNoOfPallet NUMERIC(38, 20),
	ysnTBSReserved BIT,
    CONSTRAINT [PK_tblMFWorkOrderInputLot_intWorkOrderInputLotId] PRIMARY KEY ([intWorkOrderInputLotId]),
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblICItem_inItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblICLot_inLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]),
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM](intItemUOMId),
	CONSTRAINT [FK_tblMFWorkOrderInputLot_tblICItemUOM_intIssuedItemUOMId] FOREIGN KEY ([intItemIssuedUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT FK_tblMFWorkOrderInputLot_tblMFShift_intShiftId FOREIGN KEY (intShiftId) REFERENCES dbo.tblMFShift (intShiftId),
	CONSTRAINT FK_tblMFWorkOrderInputLot_tblICStorageLocation_intStorageLocationId FOREIGN KEY (intStorageLocationId) REFERENCES dbo.tblICStorageLocation (intStorageLocationId),
	CONSTRAINT FK_tblMFWorkOrderInputLot_tblMFMachine_intMachineId FOREIGN KEY (intMachineId) REFERENCES dbo.tblMFMachine (intMachineId)
)
Go
CREATE NONCLUSTERED INDEX IX_tblMFWorkOrderInputLot_intWorkOrderInputLotId ON [dbo].[tblMFWorkOrderInputLot]
(
	[intWorkOrderInputLotId] ASC
)
INCLUDE ( 	[strReferenceNo],
	[dtmActualInputDateTime]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
Go
CREATE NONCLUSTERED INDEX IX_tblMFWorkOrderInputLot_intWorkOrderId ON [dbo].[tblMFWorkOrderInputLot]
(
	[intWorkOrderId] ASC,
	[intDestinationLotId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]