CREATE FUNCTION [dbo].[fnFAGetFixedAssetHistoryWithPurchase] ()

RETURNS @tbl TABLE (
		dtmDepreciationToDate DATETIME,

		dblDepreciationToDate DECIMAL(18, 6),
		dblFunctionalDepreciationToDate DECIMAL(18, 6),

		dblDepreciation DECIMAL(18, 6),
		dblFunctionalDepreciation DECIMAL(18, 6),
		dblRate DECIMAL(18, 6),

		dblTaxDepreciationToDate DECIMAL(18, 6),
		dblFunctionalTaxDepreciationToDate DECIMAL(18, 6),

		dblTaxDepreciation DECIMAL(18, 6),
		dblFunctionalTaxDepreciation DECIMAL(18, 6),
		dblTaxRate DECIMAL(18, 6),

		intAssetId INT,
		intAssetDepreciationId INT,
		intDepreciationMethodId INT,
		strDepreciationMethodId NVARCHAR(50),
		strTransaction NVARCHAR(50),
		strTransactionId NVARCHAR(50),
		dblBasis DECIMAL(18, 6),
		dblFunctionalBasis DECIMAL(18, 6),
		strType NVARCHAR(50),
		strConvention NVARCHAR(50),
		dtmDateInService DATETIME,
		dtmDispositionDate DATETIME,
		dblSalvageValue DECIMAL(18, 6),
		dblFunctionalSalvageValue DECIMAL(18, 6),
		intConcurrencyId INT
	)
AS
BEGIN
DECLARE @tblFixedAssetHistory TABLE (
		dtmDepreciationToDate DATETIME,

		dblDepreciationToDate DECIMAL(18, 6),
		dblFunctionalDepreciationToDate DECIMAL(18, 6),

		dblDepreciation DECIMAL(18, 6),
		dblFunctionalDepreciation DECIMAL(18, 6),
		dblRate DECIMAL(18, 6),

		dblTaxDepreciationToDate DECIMAL(18, 6),
		dblTaxFunctionalDepreciationToDate DECIMAL(18, 6),

		dblTaxDepreciation DECIMAL(18, 6),
		dblFunctionalTaxDepreciation DECIMAL(18, 6),
		dblTaxRate DECIMAL(18, 6),

		intAssetId INT,
		intAssetDepreciationId INT,
		intDepreciationMethodId INT,
		strDepreciationMethodId NVARCHAR(50),
		strTransaction NVARCHAR(50),
		strTransactionId NVARCHAR(50),
		dblBasis DECIMAL(18, 6),
		dblFunctionalBasis DECIMAL(18, 6),
		strType NVARCHAR(50),
		strConvention NVARCHAR(50),
		dtmDateInService DATETIME,
		dtmDispositionDate DATETIME,
		dblSalvageValue DECIMAL(18, 6),
		dblFunctionalSalvageValue DECIMAL(18, 6),
		intConcurrencyId INT
	)

-- Check if Asset created in GL
IF EXISTS(SELECT TOP 1 1 FROM tblFAFixedAsset FA
			LEFT JOIN tblGLDetail GL ON GL.intTransactionId = FA.intAssetId AND GL.strReference = FA.strAssetId
			LEFT JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = FA.intDepreciationMethodId
			WHERE GL.strTransactionType = 'Purchase'
	)
BEGIN
-- Insert Create Asset transaction in GL
INSERT INTO @tblFixedAssetHistory
 SELECT
	FA.dtmDateInService,
	0 dblDepreciationToDate,
	0 dblFunctionalDepreciationToDate,
	0 dblDepreciation,
	0 dblFunctionalDepreciation,
	FA.dblForexRate dblRate,
	0 dblTaxDepreciationToDate,
	0 dblFunctionalTaxDepreciationToDate,
	0 dblTaxDepreciation,
	0 dblFunctionalTaxDepreciation,
	0 dblTaxRate,
	FA.intAssetId,
	1,
	DM.intDepreciationMethodId, 
	DM.strDepreciationMethodId, 
	GL.strTransactionType, 
	GL.strTransactionId, 
	(FA.dblCost - FA.dblSalvageValue) dblBasis,
	ROUND((FA.dblCost - FA.dblSalvageValue) * ISNULL(FA.dblForexRate, 1), 2) dblFunctionalBasis,
	DM.strDepreciationType,
	DM.strConvention, 
	FA.dtmDateInService, 
	NULL, 
	FA.dblSalvageValue,
	ROUND((FA.dblSalvageValue * ISNULL(FA.dblForexRate, 1)), 2) dblFunctionalSalvageValue,
	FA.intConcurrencyId
 FROM tblFAFixedAsset FA
 LEFT JOIN tblGLDetail GL ON GL.intTransactionId = FA.intAssetId AND GL.strReference = FA.strAssetId
 LEFT JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = FA.intDepreciationMethodId
 WHERE GL.strTransactionType = 'Purchase'
 GROUP BY 
	FA.intAssetId, 
	GL.strTransactionType, 
	GL.strTransactionId, 
	FA.dblCost,
	FA.dblSalvageValue, 
	FA.dblForexRate,
	DM.strDepreciationMethodId, 
	DM.strConvention, 
	FA.dtmDateInService, 
	FA.dtmDispositionDate,
	FA.dblSalvageValue,
	DM.intDepreciationMethodId,
	DM.strDepreciationType,
	GL.dtmTransactionDate,
	FA.intConcurrencyId
END

-- Get and insert Fixed Asset Depreciaton history

INSERT INTO @tblFixedAssetHistory
SELECT G.dtmDepreciationToDate, 
ISNULL(GAAP.dblDepreciationToDate, 0),
ISNULL(GAAP.dblFunctionalDepreciationToDate, 0),
ISNULL(GAAP.dblDepreciation, 0),
ISNULL(GAAP.dblFunctionalDepreciation, 0),
ISNULL(GAAP.dblRate, 1),
dblTaxDepreciationToDate = CASE WHEN G.strTransaction NOT IN ('Basis Adjustment', 'Depreciation Adjustment') 
							THEN ISNULL(Tax.dblDepreciationToDate, FullyDepreciatedTax.dblDepreciationToDate) 
							ELSE ISNULL(Tax.dblDepreciationToDate, 0) END,
dblFunctionalTaxDepreciationToDate = CASE WHEN G.strTransaction NOT IN ('Basis Adjustment', 'Depreciation Adjustment') 
							THEN ISNULL(Tax.dblFunctionalDepreciationToDate, FullyDepreciatedTax.dblFunctionalDepreciationToDate) 
							ELSE ISNULL(Tax.dblFunctionalDepreciationToDate, 0) END,
ISNULL(Tax.dblDepreciation, 0),
ISNULL(Tax.dblFunctionalDepreciation, 0),
ISNULL(Tax.dblRate, 1),
G.intAssetId,
ISNULL(GAAP.intAssetDepreciationId,Tax.intAssetDepreciationId) intAssetDepreciationId,
ISNULL(GAAP.intDepreciationMethodId, Tax.intDepreciationMethodId) intDepreciationMethodId,
ISNULL(GAAP.strDepreciationMethodId, Tax.strDepreciationMethodId) strDepreciationMethodId,
ISNULL(GAAP.strTransaction, Tax.strTransaction) strTransaction,
ISNULL(GAAP.strTransactionId, Tax.strTransactionId) strTransactionId,
ISNULL(GAAP.dblBasis,Tax.dblBasis)dblBasis,
ISNULL(GAAP.dblFunctionalBasis,Tax.dblFunctionalBasis)dblFunctionalBasis,
ISNULL(GAAP.strType, Tax.strType)strType,
ISNULL(GAAP.strConvention, Tax.strConvention)strConvention,
ISNULL(GAAP.dtmDateInService, Tax.dtmDateInService)dtmDateInService,
ISNULL(GAAP.dtmDispositionDate,Tax.dtmDispositionDate)dtmDispositionDate,
ISNULL(GAAP.dblSalvageValue, Tax.dblSalvageValue)dblSalvageValue,
ISNULL(GAAP.dblFunctionalSalvageValue, Tax.dblFunctionalSalvageValue)dblFunctionalSalvageValue,
ISNULL(GAAP.intConcurrencyId, Tax.intConcurrencyId)intConcurrencyId
FROM tblFAFixedAssetDepreciation G
outer apply(
	SELECT 
	intAssetDepreciationId,
	A.intDepreciationMethodId,
	strDepreciationMethodId,
	dblDepreciationToDate,
	dblFunctionalDepreciationToDate,
	strTransaction,
	strTransactionId,
	dblBasis,
	dblFunctionalBasis,
	strType,
	A.strConvention,
	dtmDateInService,
	dtmDispositionDate,
	A.dblSalvageValue,
	A.dblFunctionalSalvageValue,
	dblRate,
	dblDepreciation,
	dblFunctionalDepreciation,
	A.intConcurrencyId
	FROM tblFAFixedAssetDepreciation A
	LEFT JOIN tblFADepreciationMethod B ON A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate 
	AND A.intAssetId = G.intAssetId
	AND intBookId = 1
	AND A.strTransaction = G.strTransaction
)GAAP
OUTER APPLY(
	SELECT 
	intAssetDepreciationId,
	A.intDepreciationMethodId,
	strDepreciationMethodId,
	dblDepreciationToDate,
	dblFunctionalDepreciationToDate,
	strTransaction,
	strTransactionId,
	dblBasis,
	dblFunctionalBasis,
	strType,
	A.strConvention,
	dtmDateInService,
	dtmDispositionDate,
	A.dblSalvageValue,
	A.dblFunctionalSalvageValue,
	dblRate,
	dblDepreciation,
	dblFunctionalDepreciation,
	A.intConcurrencyId
	FROM tblFAFixedAssetDepreciation A
	LEFT JOIN tblFADepreciationMethod B on A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate 
	AND A.intAssetId = G.intAssetId
	AND intBookId = 2
	AND A.strTransaction = G.strTransaction
)Tax
OUTER APPLY (
	SELECT TOP 1 FAD.dblDepreciationToDate, FAD.intAssetDepreciationId, FAD.dblFunctionalDepreciationToDate
	FROM tblFAFixedAssetDepreciation FAD
	WHERE FAD.intAssetId = G.intAssetId AND FAD.intBookId = 2 AND FAD.strTransaction = 'Depreciation'
	ORDER BY FAD.dtmDepreciationToDate DESC
) FullyDepreciatedTax


INSERT INTO @tbl
SELECT * FROM @tblFixedAssetHistory

RETURN
END