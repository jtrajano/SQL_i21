﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceiptInspection]
	(
		[intInventoryReceiptInspectionId] INT NOT NULL IDENTITY, 
		[intInventoryReceiptId] INT NOT NULL, 
		[intQAPropertyId] INT NOT NULL, 
		[ysnSelected] BIT NOT NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[strPropertyName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICInventoryReceiptInspection] PRIMARY KEY ([intInventoryReceiptInspectionId]), 
		CONSTRAINT [FK_tblICInventoryReceiptInspection_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE
	)
