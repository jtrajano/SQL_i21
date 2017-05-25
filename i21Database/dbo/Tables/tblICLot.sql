/*
## Overview
The master table for lot numbers. 
Lot numbers are unique per item, lot number, location, sub location, and storage location.

## Fields, description, and mapping. 
*	[intLotId] INT NOT NULL IDENTITY
	System control number. 
	Maps: None 


* 	[intItemLocationId] INT NOT NULL
	Foreign key to tblICItemLocation. One of the primary keys in this table. 
	Maps: None


* 	[strLotNumber] NVARCHAR(50)
	One of the primary keys in this table. A lot number is unique per item-location
	Maps: None


* 	[intConcurrencyId] INT NULL
	Concurrency field. 
	Maps: None

## Source Code:
*/
	CREATE TABLE [dbo].[tblICLot]
	(
		[intLotId]					INT NOT NULL IDENTITY, 		
		[intItemId]					INT NOT NULL,
		[intLocationId]				INT NOT NULL,
		[intItemLocationId]			INT NOT NULL,
		[intItemUOMId]				INT NOT NULL,			
		[strLotNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intSubLocationId]			INT NULL,
		[intStorageLocationId]		INT NULL,
		[dblQty]					NUMERIC(38,20) DEFAULT ((0)) NOT NULL,		
		[dblLastCost]				NUMERIC(38,20) DEFAULT ((0)) NULL,		
		[dtmExpiryDate]				DATETIME NULL,
		[strLotAlias]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intLotStatusId]			INT NOT NULL DEFAULT ((1)),
		[intParentLotId]			INT NULL,
		[intSplitFromLotId]			INT NULL,
		[dblGrossWeight]			NUMERIC(38,20) NULL, -- Accumulated gross weight of the lot whenever posted or unposted in Inventory Receipt screen. 
		[dblWeight]					NUMERIC(38,20) NULL DEFAULT ((0)),
		[intWeightUOMId]			INT NULL,
		[dblWeightPerQty]			NUMERIC(38,20) NULL DEFAULT ((0)),
		[intOriginId]				INT NULL,
		[strBOLNo]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strVessel]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 		
		[strReceiptNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strMarkings]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[strNotes]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[intEntityVendorId]			INT NULL,		
		[strVendorLotNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strGarden]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strContractNo]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmManufacturedDate]		DATETIME NULL,
		[ysnReleasedToWarehouse]	BIT DEFAULT((0)),
		[ysnProduced]				BIT DEFAULT((0)),
		[ysnStorage]				BIT DEFAULT((0)),
		[intOwnershipType]			INT NOT NULL DEFAULT ((1)),
		[intGradeId]				INT NULL,
		[intNoPallet]				INT NULL DEFAULT ((0)),
		[intUnitPallet]				INT NULL DEFAULT ((0)),
		[strTransactionId]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strSourceTransactionId]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intSourceTransactionTypeId] INT NULL,
		[intItemOwnerId]			INT NULL,
		[strContainerNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 		
		[strCondition]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 		
		[dtmDateCreated]			DATETIME NULL,
		[intCreatedUserId]			INT NULL,
		[intCreatedEntityId]		INT NULL,
		[intConcurrencyId]			INT NULL DEFAULT ((1)),
		CONSTRAINT [PK_tblICLot] PRIMARY KEY CLUSTERED ([intLotId] ASC),
		CONSTRAINT [UN_tblICLot] UNIQUE NONCLUSTERED ([strLotNumber] ASC, [intItemId] ASC, [intLocationId] ASC, [intSubLocationId] ASC, [intStorageLocationId] ASC),		
		CONSTRAINT [FK_tblICLot_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),		
		CONSTRAINT [FK_tblICLot_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
		CONSTRAINT [FK_tblICLot_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
		CONSTRAINT [FK_tblICLot_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
		CONSTRAINT [FK_tblICLot_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
		CONSTRAINT [FK_tblICLot_tblICCommodityAttribute] FOREIGN KEY ([intGradeId]) REFERENCES [tblICCommodityAttribute]([intCommodityAttributeId]),
		CONSTRAINT [FK_tblICLot_tblICItemOwner] FOREIGN KEY ([intItemOwnerId]) REFERENCES [tblICItemOwner]([intItemOwnerId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICLot_strLotNumber_intLocationId_intSubLocationId_intStorageLocationId]
		ON [dbo].[tblICLot](strLotNumber ASC, intLocationId ASC, intSubLocationId ASC, intStorageLocationId ASC);

	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICLot_intItemOwnerId]
		ON [dbo].[tblICLot](intItemOwnerId ASC);

	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICLot_intLotId]
		ON [dbo].[tblICLot](strLotNumber ASC);

	GO 