CREATE TABLE [dbo].[tblICRecostFormulationDetail]
(
	[intRecostFormulationDetailId] INT NOT NULL PRIMARY KEY
	,[intRecostFormulationId] INT NOT NULL 
	,[intItemId] INT NOT NULL 
	,[dblOldStandardCost] NUMERIC(38, 20) NULL 
	,[dblNewStandardCost] NUMERIC(38, 20) NULL
	,[dblDifference] NUMERIC(38, 20) NULL
	,[dblOldRetailPrice] NUMERIC(38, 20) NULL 
	,[dblNewRetailPrice] NUMERIC(38, 20) NULL 
	,[ysnUpdatePrices] BIT NULL DEFAULT(0) -- Flag to update the item price or not. 
	,[intDecimalPlaces] INT NOT NULL DEFAULT(6) -- Decimal places used to update the price. 	
	,[intCalculatePriceBasedOn] TINYINT NOT NULL DEFAULT(1) -- 'Ingredient Prices', 'Finished Margin'
    ,[intConcurrencyId] INT NULL DEFAULT ((1))
    ,[dtmDateCreated] DATETIME NULL
    ,[dtmDateModified] DATETIME NULL
    ,[intCreatedByUserId] INT NULL
    ,[intModifiedByUserId] INT NULL 
)
