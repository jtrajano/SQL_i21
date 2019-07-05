CREATE TABLE tblMFRecipeLosses (
	intRecipeLossesId INT NOT NULL identity(1, 1)
	,intConcurrencyId INT
	,intRecipeId INT NOT NULL
	,intItemId INT
	,intBundleItemId INT
	,dblLoss1 NUMERIC(18, 6)
	,dblLoss2 NUMERIC(18, 6)
	,intCreatedUserId INT NULL
	,dtmCreated DATETIME NULL CONSTRAINT DF_tblMFRecipeLosses_dtmCreated DEFAULT GETDATE()
	,intLastModifiedUserId INT NULL
	,dtmLastModified DATETIME NULL CONSTRAINT DF_tblMFRecipeLosses_dtmLastModified DEFAULT GETDATE()
	,CONSTRAINT PK_tblMFRecipeLosses_intRecipeLossesId PRIMARY KEY (intRecipeLossesId)
	,CONSTRAINT UQ_tblMFRecipeLosses_intRecipeId_intItemId_intBundleItemId UNIQUE (
		intRecipeId
		,intItemId
		,intBundleItemId
		)
	,CONSTRAINT FK_tblMFRecipeLosses_tblMFRecipe_intRecipeId FOREIGN KEY (intRecipeId) REFERENCES tblMFRecipe(intRecipeId)
	,CONSTRAINT FK_tblMFRecipeLosses_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	)
