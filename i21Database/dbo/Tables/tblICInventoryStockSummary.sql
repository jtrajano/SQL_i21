﻿/*
## Overview
This table summarizes the total stocks (for both ins and outs) of item per location-store. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryStockSummary]
	(
		[intInventoryStockSummaryId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intLocationId] INT NOT NULL, 
		[dblStockIn] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[dblStockOut] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intCreatedEntityId] INT NULL,
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryStockSummary] PRIMARY KEY ([intInventoryStockSummaryId]),
		CONSTRAINT [UK_tblICInventoryStockSummary] UNIQUE CLUSTERED ([intItemId], [intLocationId])
	)
	GO
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryStockSummary_intInventoryStockSummaryId]
		ON [dbo].[tblICInventoryStockSummary]([intInventoryStockSummaryId] ASC);

	GO
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryStockSummary_intItemId]
		ON [dbo].[tblICInventoryStockSummary]([intItemId] ASC);

	GO
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryStockSummary_intLocationId]
		ON [dbo].[tblICInventoryStockSummary]([intLocationId] ASC);
