PRINT('BEGIN Update Asset Depreciation Currency')
GO

UPDATE FAD
	SET 
		intCurrencyId = BD.intCurrencyId
		,intFunctionalCurrencyId = BD.intFunctionalCurrencyId
FROM [dbo].[tblFAFixedAssetDepreciation] FAD
JOIN [dbo].[tblFABookDepreciation] BD 
	ON BD.intAssetId = FAD.intAssetId AND BD.intBookId = FAD.intBookId

GO

PRINT('END Update Asset Depreciation Currency')
GO