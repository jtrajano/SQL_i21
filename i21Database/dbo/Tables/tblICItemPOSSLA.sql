﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemPOSSLA]
	(
		[intItemPOSSLAId] INT NOT NULL IDENTITY , 
		[intItemId] INT NOT NULL, 
		[strSLAContract] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[dblContractPrice] NUMERIC(18, 6) NULL, 
		[ysnServiceWarranty] BIT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICItemPOSSLA] PRIMARY KEY ([intItemPOSSLAId]), 
		CONSTRAINT [FK_tblICItemPOSSLA_tblICItemPOS] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE
	)
