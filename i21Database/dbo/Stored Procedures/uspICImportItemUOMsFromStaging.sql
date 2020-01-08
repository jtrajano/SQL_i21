CREATE PROCEDURE uspICImportItemUOMsFromStaging @strIdentifier NVARCHAR(100)
AS

DELETE FROM tblICImportStagingUOM WHERE strImportIdentifier <> @strIdentifier

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strItemNo, strUOM ORDER BY strItemNo, strUOM) AS RowNumber
   FROM tblICImportStagingUOM
   WHERE strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strUPCCode ORDER BY strUPCCode) AS RowNumber
   FROM tblICImportStagingUOM
   WHERE strImportIdentifier = @strIdentifier
	AND NULLIF(RTRIM(LTRIM(strUPCCode)), '') IS NOT NULL
)
DELETE FROM cte WHERE RowNumber > 1;

CREATE TABLE #tmp (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intUnitMeasureId INT NULL
	, strLongUPCCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strUpcCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, dblUnitQty NUMERIC(38, 20) NULL
	, dblHeight NUMERIC(38, 20) NULL
	, dblWidth NUMERIC(38, 20) NULL
	, dblLength NUMERIC(38, 20) NULL
	, dblMaxQty NUMERIC(38, 20) NULL
	, dblVolume NUMERIC(38, 20) NULL
	, dblWeight NUMERIC(38, 20) NULL
	, ysnStockUnit BIT NULL
	, ysnAllowPurchase BIT NULL
	, ysnAllowSale BIT NULL
	, dtmDateCreated DATETIME NULL
	, intCreatedByUserId INT NULL
)

INSERT INTO #tmp (
	intItemId, 
	intUnitMeasureId, 
	strLongUPCCode,
	strUpcCode,
	dblUnitQty,
	dblHeight,
	dblWidth,
	dblLength,
	dblMaxQty,
	dblVolume,
	dblWeight,
	ysnStockUnit,
	ysnAllowPurchase,
	ysnAllowSale,
	dtmDateCreated, 
	intCreatedByUserId
)
SELECT
	  i.intItemId
	, u.intUnitMeasureId
	, strLongUPCCode = CASE WHEN upc.intUpcCode IS NOT NULL THEN NULL ELSE x.strUPCCode END
	, strShortUPCCode
	, x.dblUnitQty
	, x.dblHeight
	, x.dblWidth
	, x.dblLength
	, x.dblMaxQty
	, x.dblVolume
	, x.dblWeight
	, ISNULL(stock.ysnStockUnit, x.ysnIsStockUnit)
	, x.ysnAllowPurchase
	, x.ysnAllowSale
	, x.dtmDateCreated
	, x.intCreatedByUserId
FROM tblICImportStagingUOM x
	INNER JOIN tblICItem i ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(x.strItemNo) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICUnitMeasure u ON RTRIM(LTRIM(u.strUnitMeasure)) COLLATE Latin1_General_CI_AS = LTRIM(x.strUOM) COLLATE Latin1_General_CI_AS
	OUTER APPLY (
		SELECT TOP 1 intUpcCode
		FROM tblICItemUOM
		WHERE intUpcCode = case when x.strUPCCode IS NOT NULL AND isnumeric(rtrim(ltrim(strUPCCode)))=(1) 
			AND NOT (x.strUPCCode like '%.%' OR x.strUPCCode like '%e%' OR x.strUPCCode like '%E%') then CONVERT([bigint],rtrim(ltrim(x.strUPCCode)),0) else CONVERT([bigint],NULL,0) end
	) upc
	OUTER APPLY (
		SELECT TOP 1 CAST(0 AS BIT) ysnStockUnit
		FROM tblICItemUOM
		WHERE intUnitMeasureId = u.intUnitMeasureId
			AND intItemId = i.intItemId
			AND ysnStockUnit = 1
	) stock
WHERE x.strImportIdentifier = @strIdentifier

CREATE TABLE #output (
	  intItemIdDeleted INT NULL
	, strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intItemIdInserted INT NULL)

;MERGE INTO tblICItemUOM AS target
USING
(
	SELECT
		  intItemId
		, intUnitMeasureId
		, strLongUPCCode
		, strUpcCode
		, dblUnitQty
		, dblHeight
		, dblWidth
		, dblLength
		, dblMaxQty
		, dblVolume
		, dblWeight
		, ysnStockUnit
		, ysnAllowPurchase
		, ysnAllowSale
		, dtmDateCreated
		, intCreatedByUserId
	FROM #tmp s
) AS source ON (target.intUnitMeasureId = source.intUnitMeasureId AND target.intItemId = source.intItemId)
	OR RTRIM(LTRIM(target.strLongUPCCode)) COLLATE Latin1_General_CI_AS = LTRIM(source.strLongUPCCode) COLLATE Latin1_General_CI_AS
WHEN MATCHED THEN
	UPDATE SET 
		intItemId = source.intItemId,
		intUnitMeasureId = source.intUnitMeasureId,
		strLongUPCCode = source.strLongUPCCode,
		strUpcCode = source.strUpcCode,
		dblUnitQty = source.dblUnitQty,
		dblHeight = source.dblHeight,
		dblWidth = source.dblWidth,
		dblLength = source.dblLength,
		dblMaxQty = source.dblMaxQty,
		dblVolume = source.dblVolume,
		dblWeight = source.dblWeight,
		ysnStockUnit = source.ysnStockUnit,
		ysnAllowPurchase = source.ysnAllowPurchase,
		ysnAllowSale = source.ysnAllowSale,
		dtmDateCreated = source.dtmDateCreated,
		dtmDateModified = GETUTCDATE(),
		intModifiedByUserId = source.intCreatedByUserId,
		intCreatedByUserId = source.intCreatedByUserId
WHEN NOT MATCHED THEN
	INSERT
	(
		intItemId, 
		intUnitMeasureId, 
		strLongUPCCode,
		strUpcCode,
		dblUnitQty,
		dblHeight,
		dblWidth,
		dblLength,
		dblMaxQty,
		dblVolume,
		dblWeight,
		ysnStockUnit,
		ysnAllowPurchase,
		ysnAllowSale,
		dtmDateCreated, 
		intCreatedByUserId
	)
	VALUES
	(
		intItemId, 
		intUnitMeasureId, 
		strLongUPCCode,
		strUpcCode,
		dblUnitQty,
		dblHeight,
		dblWidth,
		dblLength,
		dblMaxQty,
		dblVolume,
		dblWeight,
		ysnStockUnit,
		ysnAllowPurchase,
		ysnAllowSale,
		dtmDateCreated, 
		intCreatedByUserId
	)
	OUTPUT deleted.intItemId, $action, inserted.intItemId INTO #output;

UPDATE l
SET l.intRowsImported = (SELECT COUNT(*) FROM #output WHERE strAction = 'INSERT')
	, l.intRowsUpdated = (SELECT COUNT(*) FROM #output WHERE strAction = 'UPDATE')
FROM tblICImportLog l
WHERE l.strUniqueId = @strIdentifier

DECLARE @TotalImported INT
DECLARE @LogId INT

SELECT @LogId = intImportLogId, @TotalImported = ISNULL(intRowsImported, 0) + ISNULL(intRowsUpdated, 0) 
FROM tblICImportLog 
WHERE strUniqueId = @strIdentifier

IF @TotalImported = 0 AND @LogId IS NOT NULL
BEGIN
	INSERT INTO tblICImportLogDetail(intImportLogId, intRecordNo, strAction, strValue, strMessage, strStatus, strType, intConcurrencyId)
	SELECT @LogId, 0, 'Import finished.', ' ', 'Nothing was imported', 'Success', 'Warning', 1
END

DROP TABLE #tmp
DROP TABLE #output

DELETE FROM tblICImportStagingUOM WHERE strImportIdentifier = @strIdentifier

UPDATE tblICItemUOM SET ysnStockUnit = 0 WHERE dblUnitQty <> 1 AND ysnStockUnit = 1
UPDATE tblICItemUOM SET ysnStockUnit = 1 WHERE ysnStockUnit = 0 AND dblUnitQty = 1

-- Remove duplicate stock unit
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY intItemId ORDER BY intItemId, ysnStockUnit) AS RowNumber
   FROM tblICItemUOM
   WHERE ysnStockUnit = 1
)
UPDATE cte SET ysnStockUnit = 0 WHERE RowNumber > 1;