CREATE TABLE [dbo].[tblICRecostFormulationDetail]
(
	[intRecostFormulationDetailId] INT NOT NULL PRIMARY KEY
	,[intRecostFormulationId] INT NOT NULL 
	,[intItemId] INT NOT NULL 
	,[intLocationId] INT NOT NULL
	,[dblOldStandardCost] NUMERIC(38, 20) NULL 
	,[dblNewStandardCost] NUMERIC(38, 20) NULL
	,[dblDifference] NUMERIC(38, 20) NULL
	,[dblOldRetailPrice] NUMERIC(38, 20) NULL 
	,[dblNewRetailPrice] NUMERIC(38, 20) NULL 
    ,[intConcurrencyId] INT NULL DEFAULT ((1))
    ,[dtmDateCreated] DATETIME NULL
    ,[dtmDateModified] DATETIME NULL
    ,[intCreatedByUserId] INT NULL
    ,[intModifiedByUserId] INT NULL 
)
