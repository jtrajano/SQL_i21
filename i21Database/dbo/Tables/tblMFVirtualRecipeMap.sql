CREATE TABLE tblMFVirtualRecipeMap
(
	[intVirtualRecipeMapId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFVirtualRecipeMap_intConcurrencyId] DEFAULT 0, 
	[intRecipeId] INT,
	[intVirtualRecipeId] INT,

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblMFVirtualRecipeMap_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblMFVirtualRecipeMap_dtmLastModified] DEFAULT GetDate(),

	CONSTRAINT [FK_tblMFVirtualRecipeMap_tblMFRecipe] FOREIGN KEY (intRecipeId) REFERENCES [tblMFRecipe](intRecipeId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFVirtualRecipeMap_tblMFRecipe_intVirtualRecipeId] FOREIGN KEY (intVirtualRecipeId) REFERENCES [tblMFRecipe](intRecipeId)
)
