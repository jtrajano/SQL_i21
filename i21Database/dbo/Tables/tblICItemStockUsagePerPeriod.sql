/*
## Overview
This table holds stock information like quantity on hand and etc. 

## Fields, description, and mapping. 
*	[intId] INT NOT NULL IDENTITY
	Internal id for this table. 
	Maps: None

*	[intItemId] INT NOT NULL
	FK to the tblICItem table. 
	Maps: None

*	[intItemLocationId] INT NOT NULL
	FK to the tblICItemLocation table. 
	Maps: None

*	[intGLFiscalYearPeriodId] INT NOT NULL
	FK to the tblGLFiscalYearPeriod table. 
	Maps: None

*	[dblQty] NUMERIC(38, 20) NULL DEFAULT ((0))
	The number of stocks currently at hand. At hand means those transactions that has been posted in the system regardless of the transaction date. 
	Maps: None

*	[intConcurrencyId] INT NULL DEFAULT ((0))
	An internal field that mananges the concurrency of a record. 
	Maps: None

## Important Notes:
	The cost fields like Average Cost, Last Cost, and Standard Cost are moved to tblICItemPricing table. The users can edit that cost from that table whereas editing of values are not allowed on this table. 

## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemStockUsagePerPeriod]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL, 
		[intGLFiscalYearPeriodId] INT NOT NULL, 
		[dblQty] NUMERIC(38, 20) NULL DEFAULT ((0)), 		
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		CONSTRAINT [PK_tblICItemStockUsagePerPeriod] PRIMARY KEY ([intId]), 
		CONSTRAINT [UN_tblICItemStockUsagePerPeriod] UNIQUE NONCLUSTERED ([intItemId] ASC, [intItemLocationId] ASC, [intGLFiscalYearPeriodId] ASC),
		CONSTRAINT [FK_tblICItemStockUsagePerPeriod_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemStockUsagePerPeriod_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId])
		--CONSTRAINT [FK_tblICItemStockUsagePerPeriod_tblGLFiscalYearPeriod] FOREIGN KEY ([intGLFiscalYearPeriodId]) REFERENCES [tblGLFiscalYearPeriod]([intGLFiscalYearPeriodId]) 
	)
	GO
	CREATE NONCLUSTERED INDEX [IX_tblICItemStockUsagePerPeriod_intItemId_intLocationId_intGLFiscalYearPeriodId]
		ON [dbo].[tblICItemStockUsagePerPeriod]([intItemId] ASC, [intItemLocationId] ASC, [intGLFiscalYearPeriodId] ASC)
	GO
