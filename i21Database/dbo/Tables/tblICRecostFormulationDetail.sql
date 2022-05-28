CREATE TABLE [dbo].[tblICRecostFormulationDetail]
(
	[intRecostFormulationDetailId] INT NOT NULL PRIMARY KEY
	,[intRecostFormulationId] INT NOT NULL 
	,[intItemId] INT NOT NULL 
	,[intLocationId] INT NOT NULL
	,[intRecipeId] INT NOT NULL
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
	,CONSTRAINT [FK_tblICRecostFormulationDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) 
	,CONSTRAINT [FK_tblICRecostFormulationDetail_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	,CONSTRAINT [FK_tblICRecostFormulationDetail_tblMFRecipe] FOREIGN KEY ([intRecipeId]) REFERENCES [tblMFRecipe]([intRecipeId])
)
