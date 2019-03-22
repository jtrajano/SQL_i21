CREATE TABLE [dbo].[tblMFItemSubstitutionRecipe]
(
	[intItemSubstitutionRecipeId] INT NOT NULL IDENTITY(1,1), 
    [intItemSubstitutionId] INT NOT NULL, 
    [intRecipeId] INT NOT NULL, 
    [ysnApplied] BIT NOT NULL, 
    [intRecipeItemId] INT NULL,
	[dtmValidFrom] DATETIME NULL, 
    [dtmValidTo] DATETIME NULL,
	[ysnYearValidationRequired] BIT NOT NULL CONSTRAINT [DF_tblMFItemSubstitutionRecipe_ysnYearValidationRequired] DEFAULT 0,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL ,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,	 
    [intConcurrencyId] INT NULL DEFAULT 0,
	CONSTRAINT [PK_tblMFItemSubstitutionRecipe_intItemSubstitutionRecipeId] PRIMARY KEY ([intItemSubstitutionRecipeId]),
	CONSTRAINT [FK_tblMFItemSubstitutionRecipe_tblMFItemSubstitution_intItemSubstitutionId] FOREIGN KEY ([intItemSubstitutionId]) REFERENCES [tblMFItemSubstitution]([intItemSubstitutionId]) ON DELETE CASCADE, 

)
