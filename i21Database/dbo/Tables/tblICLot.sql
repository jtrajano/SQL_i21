/*
## Overview
The master table for lot numbers. 
Lot numbers are unique per item-location. 

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
		[dblQty]					NUMERIC(18,6) DEFAULT ((0)),		
		[dtmExpiryDate]				DATETIME NULL,
		[strLotAlias]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intLotStatusId]			INT NOT NULL,
		[intParentLotId]			INT NULL,
		[intSplitFromLotId]			INT NULL,
		[dblWeightQuantity]			NUMERIC(18,6) NOT NULL DEFAULT ((0)),
		[dblWeightUOMId]			INT NOT NULL,
		[intOriginId]				INT NULL,
		[strBOLNo]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strVessel]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 		
		[strReceiptNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strMarkings]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strNotes]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[intVendorId]				INT NULL,		
		[strVendorLotNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intVendorLocationId]		INT NULL, 
		[strContractNo]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmManufacturedDate]		DATETIME NULL,
		[ysnReleasedToWarehouse]	BIT DEFAULT((0)),
		[ysnProduced]				BIT DEFAULT((0)),
		[dtmDateCreated]			DATETIME NULL,
		[intCreatedUserId]			INT NULL,
		[intConcurrencyId]			INT NULL DEFAULT ((1)),
		CONSTRAINT [PK_tblICLot] PRIMARY KEY CLUSTERED ([intLotId] ASC),
		CONSTRAINT [UN_tblICLot] UNIQUE NONCLUSTERED ([strLotNumber] ASC, [intLocationId] ASC, [intSubLocationId] ASC, [intStorageLocationId] ASC),		
		CONSTRAINT [FK_tblICLot_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),		
		CONSTRAINT [FK_tblICLot_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
		CONSTRAINT [FK_tblICLot_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
		CONSTRAINT [FK_tblICLot_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
		CONSTRAINT [FK_tblICLot_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICLot_strLotNumber_intLocationId_intSubLocationId_intStorageLocationId]
		ON [dbo].[tblICLot](strLotNumber ASC, intLocationId ASC, intSubLocationId ASC, intStorageLocationId ASC);
