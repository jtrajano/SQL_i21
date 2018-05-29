/*
	This is a user-defined table type used in sp uspICAddItemReceipt to add Lot Records 
*/
CREATE TYPE [dbo].[ReceiptItemLotStagingTable] AS TABLE
	(
		[intId] INT IDENTITY PRIMARY KEY CLUSTERED

		--Following fields are needed to match the Receipt
		,[intEntityVendorId] INT NULL
		,[strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[intLocationId] INT NULL    
		,[intShipViaId] INT NULL 
		,[intShipFromId] INT NULL	
		,[intCurrencyId] INT NULL		
		,[intSourceType] INT NULL  
		,[strBillOfLadding] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL

		--Following fields are needed to match the Receipt Item
		,[intItemId] INT NULL	
		,[intSubLocationId] INT NULL
		,[intStorageLocationId] INT NULL
		,[intContractHeaderId] INT NULL	-- Contract Header Id
		,[intContractDetailId] INT NULL -- Contract Detail Id
		,[intSort] INT NULL									
							
		--Following fields are needed to add Lot Record	
		,[intLotId] INT NULL
		,[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[strLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[intItemUnitMeasureId] INT NULL
		,[dblQuantity] NUMERIC(38, 20) NULL DEFAULT ((0))
		,[dblGrossWeight] NUMERIC(38, 20) NULL DEFAULT ((0))
		,[dblTareWeight] NUMERIC(38, 20) NULL DEFAULT ((0))
		,[dblCost] NUMERIC(38, 20) NULL DEFAULT ((0))
		,[intNoPallet] INT NULL DEFAULT ((0))
		,[intUnitPallet] INT NULL DEFAULT ((0))
		,[dblStatedGrossPerUnit] NUMERIC(38, 20) NULL DEFAULT ((0))
		,[dblStatedTarePerUnit] NUMERIC(38, 20) NULL DEFAULT ((0))
		,[strContainerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[strGarden] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[strMarkings] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,[intOriginId] INT NULL 
		,[intGradeId] INT NULL
		,[intSeasonCropYear] INT NULL
		,[strVendorLotId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[dtmManufacturedDate] DATETIME NULL
		,[strRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,[strCondition] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,[dtmCertified] DATETIME NULL
		,[dtmExpiryDate] DATETIME NULL
		,[intParentLotId] INT NULL
		,[strParentLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[strParentLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)