/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
CREATE TABLE [dbo].[tblICInventoryTradeFinanceLot]
(
	[intInventoryTradeFinanceLotId] [int] IDENTITY NOT NULL,
	[intInventoryTradeFinanceId] [int] NOT NULL,	
	[intLotId] INT NULL, 
	[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intItemId] [int] NOT NULL,
	[intSubLocationId] INT NULL, 
	[intStorageLocationId] INT NULL,	
	[intItemUOMId] INT NULL,	
	[intWeightUOMId] INT NULL,	
	[dblQuantity] NUMERIC(38, 15) NULL DEFAULT ((0)), 		
	[dblGrossWeight] NUMERIC(38, 15) NULL DEFAULT ((0)), 
	[dblTareWeight] NUMERIC(38, 15) NULL DEFAULT ((0)), 
	[dblTarePerQuantity] NUMERIC(38, 15) NULL DEFAULT ((0)),
	[dblCost] NUMERIC(38, 15) NULL DEFAULT ((0)), 
	[intNoPallet] INT NULL DEFAULT ((0)),
	[intUnitPallet] INT NULL DEFAULT ((0)), 
	[strContainerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strGarden] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMarkings] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[intOriginId] INT NULL, 
	[intGradeId] INT NULL,
	[intSeasonCropYear] INT NULL, 
	[dtmManufacturedDate] DATETIME NULL, 
	[strCondition] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmExpiryDate] DATETIME NULL, 
	[intParentLotId] INT NULL, 
	[strParentLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strParentLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strCertificate] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 	
	[intProducerId] INT	NULL,
	[strWarehouseRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCertificateId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 	
	[strTrackingNumber] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 	
	[strCargoNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strWarrantNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intWarrantStatus] TINYINT NULL, 
	[intTradeFinanceId] INT	NULL,
	[strTradeFinanceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intLotStatusId] INT NULL, 
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((0)),

	CONSTRAINT [PK_tblICInventoryTradeFinanceLot] PRIMARY KEY ([intInventoryTradeFinanceLotId]), 
	CONSTRAINT [FK_tblICInventoryTradeFinanceLot_intInventoryTradeFinanceId] FOREIGN KEY ([intInventoryTradeFinanceId]) REFERENCES [tblICInventoryTradeFinance] ([intInventoryTradeFinanceId]),
	CONSTRAINT [FK_tblICInventoryTradeFinanceLot_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblICInventoryTradeFinanceLot_intLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot] ([intLotId]),
)
GO