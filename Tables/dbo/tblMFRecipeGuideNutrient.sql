CREATE TABLE [dbo].[tblMFRecipeGuideNutrient]
(
	[intRecipeGuideNutrientId] INT NOT NULL IDENTITY(1,1),
	[intRecipeGuideId] INT NOT NULL,
	[intPropertyId] INT NOT NULL,
	[dblProposed] NUMERIC(18,6) DEFAULT 0,
	[dblActual] NUMERIC(18,6) DEFAULT 0,
	[dblPercentage] NUMERIC(18,6) DEFAULT 0,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFRecipeGuideNutrient_intConcurrencyId] DEFAULT 0, 
	CONSTRAINT [PK_tblMFRecipeGuideNutrient_intRecipeGuideNutrientId] PRIMARY KEY ([intRecipeGuideNutrientId]),
	CONSTRAINT [FK_tblMFRecipeGuideNutrient_tblMFRecipeGuide_intRecipeGuideId] FOREIGN KEY ([intRecipeGuideId]) REFERENCES [tblMFRecipeGuide]([intRecipeGuideId]),
	CONSTRAINT [FK_tblMFRecipeGuideNutrient_tblQMProperty_intPropertyId] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]),
)
