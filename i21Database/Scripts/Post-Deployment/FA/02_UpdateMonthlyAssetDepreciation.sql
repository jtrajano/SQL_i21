PRINT('BEGIN update GAAP monthly depreciation take')

CREATE TABLE #tblFAGaapDep (
	intAssetDepreciationId INT,
	intAssetId INT,
	intBookId INT NULL,
	dtmDepreciationToDate DATETIME NULL,
	dblDepreciationToDate DECIMAL(18, 6) NULL,
	dblFunctionalDepreciationToDate DECIMAL(18, 6) NULL,
	strTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	dblDepreciation DECIMAL(18, 6) NULL,
	ysnProcessed BIT NULL DEFAULT(0)
)

DECLARE
	@dblPrevDepreciation DECIMAL(18, 6),
	@dblCurrentDepreciation DECIMAL (18, 6) = 0,
	@dblDepreciation DECIMAL (18, 6),
	@dblPrevDepreciationFn DECIMAL(18, 6),
	@dblCurrentDepreciationFn DECIMAL (18, 6) = 0,
	@dblDepreciationFn DECIMAL (18, 6),
	@intCurrentAssetDepreciationId INT,
	@intCurrentAssetId INT,
	@intPrevAssetId INT

INSERT INTO #tblFAGaapDep
SELECT intAssetDepreciationId, intAssetId, intBookId, dtmDepreciationToDate, dblDepreciationToDate, dblFunctionalDepreciationToDate, strTransaction, 0, 0 
FROM tblFAFixedAssetDepreciation
WHERE strTransaction IN ('Depreciation', 'Imported') AND intBookId = 1 AND dblDepreciation = 0 AND dblFunctionalDepreciation = 0
ORDER BY intAssetId, intAssetDepreciationId

WHILE EXISTS(SELECT TOP 1 1 FROM #tblFAGaapDep WHERE ysnProcessed = 0 AND intBookId = 1)
BEGIN
	SET @dblPrevDepreciation = @dblCurrentDepreciation
	SET @dblPrevDepreciationFn = @dblCurrentDepreciationFn
	SET @intPrevAssetId = @intCurrentAssetId
	
	SELECT TOP 1 @intCurrentAssetDepreciationId = intAssetDepreciationId, @intCurrentAssetId = intAssetId, @dblCurrentDepreciation = dblDepreciationToDate, @dblCurrentDepreciationFn = dblFunctionalDepreciationToDate 
	FROM #tblFAGaapDep WHERE ysnProcessed = 0  AND intBookId = 1 ORDER BY intAssetId, intAssetDepreciationId
	
	IF (@intPrevAssetId <> @intCurrentAssetId) -- Reset values on next AssetId
	BEGIN
		SET @dblPrevDepreciation  = 0
		SET	@dblDepreciation = 0
		SET	@dblPrevDepreciationFn = 0
		SET	@dblDepreciationFn = 0
	END

	SET	@dblDepreciation = @dblCurrentDepreciation - @dblPrevDepreciation
	SET	@dblDepreciationFn = @dblCurrentDepreciationFn - @dblPrevDepreciationFn

	UPDATE tblFAFixedAssetDepreciation
	SET dblDepreciation = @dblDepreciation, dblFunctionalDepreciation = @dblDepreciationFn
	WHERE intAssetDepreciationId = @intCurrentAssetDepreciationId AND intAssetId = @intCurrentAssetId AND intBookId = 1

	UPDATE #tblFAGaapDep 
	SET dblDepreciation = @dblDepreciation, ysnProcessed = 1
	WHERE intAssetDepreciationId = @intCurrentAssetDepreciationId AND intAssetId = @intCurrentAssetId AND intBookId = 1

END


IF OBJECT_ID('tempdb..#tblFAGaapDep') IS NOT NULL
BEGIN
	DROP TABLE #tblFAGaapDep
END

PRINT('END update Fixed Asset monthly depreciation take')



PRINT('BEGIN update Tax monthly depreciation take')


SET @dblPrevDepreciation  = 0
SET	@dblCurrentDepreciation = 0
SET	@dblDepreciation = 0
SET	@dblPrevDepreciationFn = 0
SET	@dblCurrentDepreciationFn = 0
SET	@dblDepreciationFn = 0
SET	@intCurrentAssetDepreciationId = NULL
SET	@intCurrentAssetId = NULL

CREATE TABLE #tblFATaxDep (
	intAssetDepreciationId INT,
	intAssetId INT,
	intBookId INT NULL,
	dtmDepreciationToDate DATETIME NULL,
	dblDepreciationToDate DECIMAL(18, 6) NULL,
	dblFunctionalDepreciationToDate DECIMAL(18, 6) NULL,
	strTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	dblDepreciation DECIMAL(18, 6) NULL,
	ysnProcessed BIT NULL DEFAULT(0)
)

INSERT INTO #tblFATaxDep
SELECT intAssetDepreciationId, intAssetId, intBookId, dtmDepreciationToDate, dblDepreciationToDate, dblFunctionalDepreciationToDate, strTransaction, 0, 0 
FROM tblFAFixedAssetDepreciation
WHERE strTransaction IN ('Depreciation', 'Imported') AND intBookId = 2 AND dblDepreciation = 0 AND dblFunctionalDepreciation = 0
ORDER BY intAssetId, intAssetDepreciationId

WHILE EXISTS(SELECT TOP 1 1 FROM #tblFATaxDep WHERE ysnProcessed = 0 AND intBookId = 2)
BEGIN
	SET @dblPrevDepreciation = @dblCurrentDepreciation
	SET @dblPrevDepreciationFn = @dblCurrentDepreciationFn
	SET @intPrevAssetId = @intCurrentAssetId

	SELECT TOP 1 @intCurrentAssetDepreciationId = intAssetDepreciationId, @intCurrentAssetId = intAssetId, @dblCurrentDepreciation = dblDepreciationToDate, @dblCurrentDepreciationFn = dblFunctionalDepreciationToDate 
	FROM #tblFATaxDep WHERE ysnProcessed = 0 AND intBookId = 2 ORDER BY intAssetId, intAssetDepreciationId
		
	IF (@intPrevAssetId <> @intCurrentAssetId) -- Reset values on next AssetId
	BEGIN
		SET @dblPrevDepreciation  = 0
		SET	@dblDepreciation = 0
		SET	@dblPrevDepreciationFn = 0
		SET	@dblDepreciationFn = 0
	END

	SET	@dblDepreciation = @dblCurrentDepreciation - @dblPrevDepreciation
	SET	@dblDepreciationFn = @dblCurrentDepreciationFn - @dblPrevDepreciationFn

	UPDATE tblFAFixedAssetDepreciation
	SET dblDepreciation = @dblDepreciation, dblFunctionalDepreciation = @dblDepreciationFn
	WHERE intAssetDepreciationId = @intCurrentAssetDepreciationId AND intAssetId = @intCurrentAssetId AND intBookId = 2

	UPDATE #tblFATaxDep 
	SET dblDepreciation = @dblDepreciation, ysnProcessed = 1
	WHERE intAssetDepreciationId = @intCurrentAssetDepreciationId AND intAssetId = @intCurrentAssetId AND intBookId = 2

END


IF OBJECT_ID('tempdb..#tblFATaxDep') IS NOT NULL
BEGIN
	DROP TABLE #tblFATaxDep
END

PRINT('END update Fixed Asset Tax depreciation take')