/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
--CREATE TYPE [dbo].[ItemLotTableType] AS TABLE
--(
--	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
--	,[intItemId] INT NOT NULL			
--	,[strItemNo] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL
--	,[intItemLocationId] INT NOT NULL -- The location where the item is stored.
--	,[intItemUOMId] INT NOT NULL -- The UOM used for the lot. 
--	,[intDetailId] INT NOT NULL
--	,[intLotId] INT NULL -- Place holder field for lot numbers
--	,[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- Place holder field for lot numbers	
--	,[intLotTypeId] INT NULL 
--)

/*
## Overview
This is a user-defined table type used in creating records to the lot master table. 

## Fields, description, and mapping. 
*	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	System control number. 
	Not required


*	[intLotId] INT NULL 
	The id from the lot master. If null, it means the system will create a new lot number. 
	Otherwise, it will update an existing lot. 
	Optional


*	[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	The string value that represents a lot number. If blank or null and lot type is serialized, the system
	will generate a new lot number for it. 
	Optional


*	[strLotAlias] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	The string value that is the alias of the lot number. 
	Optional 


*	[intItemId] INT NOT NULL
	The id of the item. 
	Required


*	[intItemLocationId] INT NOT NULL
	The id of the item-location. 
	Required


*	[intSubLocationId] INT NULL
	The id of the sub location. 
	Optional 


*	[intStorageLocationId] INT NULL	
	The id of the storage location. 
	Optional 


*	[dblQty] NUMERIC(18,6) DEFAULT ((0)) NOT NULL	
	The quantity in terms of intItemUOMId. For example if intItemUOMId is a 50-kg bag and the qty is 2, the
	qty is referred to as two (2) 50-kg bags and NOT as 100 (2 x 50 kg). 
	Required


*	[intItemUOMId] INT NOT NULL
	The id of the item UOM id. It is related to the dblQty field. 
	Required


*	[dblWeight] NUMERIC(18,6) NULL DEFAULT ((0))
	The actual weight of the lot in terms of intWeightUOMId. For example: intWeightUOMId is LBS and the weight-qty 
	is 100 for four (4) 50-kg bags. This means the four bags are not really 200 kgs but 100 LBS. The system will
	track the overall stock qty as 100 LBS but there are four bags of it, packed in 50-kg bags. 
	Optional


*	[intWeightUOMId] INT NULL	
	The id of the weight uom id. It is related to the dblWeight. 
	Optional but requried if dblWeight is not zero. 


*	[dtmExpiryDate] DATETIME NULL
	The expiration date of the lot. 
	Optional 


*	[dtmManufacturedDate] DATETIME NULL
	The date when the lot is produced. 
	Optional 


*	[intOriginId] INT NULL
	The place of origin of the lot. 
	Optional 


*	[strBOLNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	The Bill of Lading number of the lot. 
	Optional 


*	[strVessel] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	The vesssel number of the lot. 
	Optional 


*	[strReceiptNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	The receipt number of the lot. 
	Optional 


*	[strMarkings] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	Any markings sticked to the lot packing. 
	Optional 


*	[strNotes] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	Notes for the lot. 
	Optional 


*	[intVendorId] INT NULL
	The vendor where the lot was received. 
	Optional 


*	[strVendorLotNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	The lot number used by the vendor. 
	Optional 


*	[intVendorLocationId] INT NULL
	The id of the vendor location. 
	Optional 


*	[strVendorLocation] COLLATE Latin1_General_CI_AS NULL
	The string value of the vendor locatoin. 
	Optional 


*	[strContractNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	The contract number for the lot. 
	Optional 


*	[ysnReleasedToWarehouse] BIT DEFAULT((0))
	The flag used to indicate the lot is approved by QC and it can be released to the warehouse. Default is 0. 
	Optional 


*	[ysnProduced] BIT DEFAULT((0))
	The flag that indicates the lot is internally produced and not sourced anywhere. 
	Optional 


*	[intDetailId] INT NOT NULL
	The id from the detail table. For example, if the lot is coming Inventory Receipt Detail Lot table, the id
	value is from tblICInventoryReceiptItemLot.intInventoryReceiptItemLotId. 
	This is used as a way to link a record back to the detail table. 
	Required


## Source Code:
*/

CREATE TYPE [dbo].[ItemLotTableType] AS TABLE
(
	[intId]						INT IDENTITY PRIMARY KEY CLUSTERED
	,[intLotId]					INT NULL 
	,[strLotNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[strLotAlias]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[intItemId]				INT NOT NULL
	,[intItemLocationId]		INT NOT NULL
	,[intSubLocationId]			INT NULL
	,[intStorageLocationId]		INT NULL	
	,[dblQty]					NUMERIC(18,6) DEFAULT ((0)) NOT NULL	
	,[intItemUOMId]				INT NOT NULL
	,[dblWeight]				NUMERIC(18,6) NULL DEFAULT ((0))
	,[intWeightUOMId]			INT NULL	
	,[dtmExpiryDate]			DATETIME NULL
	,[dtmManufacturedDate]		DATETIME NULL
	,[intOriginId]				INT NULL
	,[strBOLNo]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[strVessel]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[strReceiptNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[strMarkings]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[strNotes]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[intVendorId]				INT NULL
	,[strVendorLotNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[intVendorLocationId]		INT NULL
	,[strVendorLocation]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[strContractNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[ysnReleasedToWarehouse]	BIT DEFAULT((0))
	,[ysnProduced]				BIT DEFAULT((0))
	,[intDetailId]				INT NOT NULL
)
