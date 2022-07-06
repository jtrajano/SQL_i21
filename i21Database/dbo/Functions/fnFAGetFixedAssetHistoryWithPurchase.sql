CREATE FUNCTION [dbo].[fnFAGetFixedAssetHistoryWithPurchase] ()

RETURNS @tbl TABLE (
		dtmDepreciationToDate DATETIME,
		dblDepreciationToDate DECIMAL(18, 6),
		dblTaxDepreciationToDate DECIMAL(18, 6),
		intAssetId INT,
		intAssetDepreciationId INT,
		intDepreciationMethodId INT,
		strDepreciationMethodId NVARCHAR(50),
		strTransaction NVARCHAR(50),
		strTransactionId NVARCHAR(50),
		dblBasis DECIMAL(18, 6),
		strType NVARCHAR(50),
		strConvention NVARCHAR(50),
		dtmDateInService DATETIME,
		dtmDispositionDate DATETIME,
		dblSalvageValue DECIMAL(18, 6),
		intConcurrencyId INT
	)
AS
BEGIN
DECLARE @tblFixedAssetHistory TABLE (
		dtmDepreciationToDate DATETIME,
		dblDepreciationToDate DECIMAL(18, 6),
		dblTaxDepreciationToDate DECIMAL(18, 6),
		intAssetId INT,
		intAssetDepreciationId INT,
		intDepreciationMethodId INT,
		strDepreciationMethodId NVARCHAR(50),
		strTransaction NVARCHAR(50),
		strTransactionId NVARCHAR(50),
		dblBasis DECIMAL(18, 6),
		strType NVARCHAR(50),
		strConvention NVARCHAR(50),
		dtmDateInService DATETIME,
		dtmDispositionDate DATETIME,
		dblSalvageValue DECIMAL(18, 6),
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
	0 dblTaxDepreciationToDate,
	FA.intAssetId,
	1,
	DM.intDepreciationMethodId, 
	DM.strDepreciationMethodId, 
	GL.strTransactionType, 
	GL.strTransactionId, 
	(FA.dblCost - FA.dblSalvageValue) dblBasis,
	DM.strDepreciationType,
	DM.strConvention, 
	FA.dtmDateInService, 
	FA.dtmDispositionDate, 
	FA.dblSalvageValue,
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
SELECT G.dtmDepreciationToDate, GAAP.dblDepreciationToDate , Tax.dblDepreciationToDate dblTaxDepreciationToDate, G.intAssetId,
ISNULL(GAAP.intAssetDepreciationId,Tax.intAssetDepreciationId) intAssetDepreciationId,
ISNULL(GAAP.intDepreciationMethodId, Tax.intDepreciationMethodId) intDepreciationMethodId,
ISNULL(GAAP.strDepreciationMethodId, Tax.strDepreciationMethodId) strDepreciationMethodId,
ISNULL(GAAP.strTransaction, Tax.strTransaction) strTransaction,
ISNULL(GAAP.strTransactionId, Tax.strTransactionId) strTransactionId,
ISNULL(GAAP.dblBasis,Tax.dblBasis)dblBasis,
ISNULL(GAAP.strType, Tax.strType)strType,
ISNULL(GAAP.strConvention, Tax.strConvention)strConvention,
ISNULL(GAAP.dtmDateInService, Tax.dtmDateInService)dtmDateInService,
ISNULL(GAAP.dtmDispositionDate,Tax.dtmDispositionDate)dtmDispositionDate,
ISNULL(GAAP.dblSalvageValue, Tax.dblSalvageValue)dblSalvageValue,
ISNULL(GAAP.intConcurrencyId, Tax.intConcurrencyId)intConcurrencyId
FROM tblFAFixedAssetDepreciation G
outer apply(
	SELECT 
	intAssetDepreciationId,
	A.intDepreciationMethodId,
	strDepreciationMethodId,
	dblDepreciationToDate,
	strTransaction,
	strTransactionId,
	dblBasis,
	strType,
	A.strConvention,
	dtmDateInService,
	dtmDispositionDate,
	A.dblSalvageValue,
	A.intConcurrencyId
	FROM tblFAFixedAssetDepreciation A
	LEFT JOIN tblFADepreciationMethod B ON A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate 
	AND A.intAssetId = G.intAssetId
	AND intBookId = 1
)GAAP
OUTER APPLY(
	SELECT 
	intAssetDepreciationId,
	A.intDepreciationMethodId,
	strDepreciationMethodId,
	dblDepreciationToDate,
	strTransaction,
	strTransactionId,
	dblBasis,
	strType,
	A.strConvention,
	dtmDateInService,
	dtmDispositionDate,
	A.dblSalvageValue,
	A.intConcurrencyId
	FROM tblFAFixedAssetDepreciation A
	LEFT JOIN tblFADepreciationMethod B on A.intDepreciationMethodId = B.intDepreciationMethodId
	WHERE dtmDepreciationToDate = G.dtmDepreciationToDate 
	AND A.intAssetId = G.intAssetId
	AND intBookId = 2
)Tax

INSERT INTO @tbl
SELECT * FROM @tblFixedAssetHistory

RETURN
END