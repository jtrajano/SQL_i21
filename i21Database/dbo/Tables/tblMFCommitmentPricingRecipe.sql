﻿CREATE TABLE tblMFCommitmentPricingRecipe
(
	intCommitmentPricingRecipeId INT NOT NULL IDENTITY,
	intConcurrencyId INT CONSTRAINT [DF_tblMFCommitmentPricingRecipe_intConcurrencyId] DEFAULT 0,
	intCommitmentPricingId INT NOT NULL,
	intVirtualRecipeId INT,
	intActualRecipeId INT,
	intVirtualRecipeItemId INT,
	intActualRecipeItemId INT,
	dblVirtualPercentage NUMERIC(18, 6),
	dblActualPercentage NUMERIC(18, 6),
	dblVirtualBasis NUMERIC(18, 6),
	dblActualBasis NUMERIC(18, 6),
	dblMargin NUMERIC(18, 6),
	dblCost1 NUMERIC(18, 6),
	dblCost2 NUMERIC(18, 6),
	dblCost3 NUMERIC(18, 6),
	dblCost4 NUMERIC(18, 6),
	dblCost5 NUMERIC(18, 6),
	dblVirtualTotalCost NUMERIC(18, 6),
	dblActualTotalCost NUMERIC(18, 6),
	
	CONSTRAINT [PK_tblMFCommitmentPricingRecipe] PRIMARY KEY (intCommitmentPricingRecipeId),
	CONSTRAINT [FK_tblMFCommitmentPricingRecipe_tblMFCommitmentPricing] FOREIGN KEY (intCommitmentPricingId) REFERENCES tblMFCommitmentPricing(intCommitmentPricingId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFCommitmentPricingRecipe_tblMFRecipe_intVirtualRecipeId] FOREIGN KEY (intVirtualRecipeId) REFERENCES tblMFRecipe(intRecipeId),
	CONSTRAINT [FK_tblMFCommitmentPricingRecipe_tblMFRecipe_intActualRecipeId] FOREIGN KEY (intActualRecipeId) REFERENCES tblMFRecipe(intRecipeId),
	CONSTRAINT [FK_tblMFCommitmentPricingRecipe_tblMFRecipeItem_intVirtualRecipeItemId] FOREIGN KEY (intVirtualRecipeItemId) REFERENCES tblMFRecipeItem(intRecipeItemId),
	CONSTRAINT [FK_tblMFCommitmentPricingRecipe_tblMFRecipeItem_intActualRecipeItemId] FOREIGN KEY (intActualRecipeItemId) REFERENCES tblMFRecipeItem(intRecipeItemId)
)
