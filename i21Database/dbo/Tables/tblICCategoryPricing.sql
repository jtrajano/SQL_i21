/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
CREATE TABLE [dbo].[tblICCategoryPricing]
(
	[intCategoryPricingId] INT NOT NULL IDENTITY, 
	[intCategoryId] INT NOT NULL, 
	[intItemLocationId] INT NOT NULL, 
	[dblTotalCostValue] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[dblTotalRetailValue] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[dblAverageMargin] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[intSort] INT NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblICCategoryPricing] PRIMARY KEY ([intCategoryPricingId]), 
	CONSTRAINT [FK_tblICCategoryPricing_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblICCategoryPricing_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]), 
	CONSTRAINT [AK_tblICCategoryPricing] UNIQUE ([intCategoryId], [intItemLocationId])
)

