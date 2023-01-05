PRINT('BEGIN Update Asset Book Depreciation')
GO

UPDATE FAD
	SET 
		intBookDepreciationId = BD.intBookDepreciationId
FROM [dbo].[tblFAFixedAssetDepreciation] FAD
JOIN [dbo].[tblFABookDepreciation] BD 
	ON BD.intAssetId = FAD.intAssetId AND BD.intBookId = FAD.intBookId
WHERE (
	CASE WHEN FAD.intLedgerId IS NOT NULL
		THEN CASE WHEN FAD.intLedgerId = BD.intLedgerId THEN 1 ELSE 0 END
		ELSE 1 END
	) = 1
	AND FAD.intBookDepreciationId IS NULL
GO

PRINT('END Update Asset Book Depreciation')
GO