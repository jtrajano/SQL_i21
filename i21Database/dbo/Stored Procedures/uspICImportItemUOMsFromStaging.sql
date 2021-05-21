CREATE PROCEDURE uspICImportItemUOMsFromStaging 
	@strIdentifier NVARCHAR(100)
	, @ysnAllowOverwrite BIT = 0
	, @intDataSourceId INT = 2
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

DECLARE @tblDuplicateUPCCodes TABLE(strItemNo NVARCHAR(200), strUPCCode NVARCHAR(200), strDescription NVARCHAR(MAX))
DECLARE @tblInvalidStockUnitQuantities TABLE(strItemNo NVARCHAR(200), strUOM NVARCHAR(200), strDescription NVARCHAR(MAX))
DECLARE @tblMissingUOMs TABLE(strItemNo NVARCHAR(200), strUOM NVARCHAR(200))
DECLARE @tblMissingItems TABLE (strItemNo NVARCHAR(200))

--Validate Records

--Check missing Items

INSERT INTO @tblMissingItems (
	strItemNo
)
SELECT
	s.strItemNo
FROM 
	tblICImportStagingUOM s	LEFT JOIN tblICItem i 
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(s.strItemNo) COLLATE Latin1_General_CI_AS	
WHERE
	s.strImportIdentifier = @strIdentifier
	AND i.intItemId IS NULL

--Check missing UOMs

INSERT INTO @tblMissingUOMs (
	strItemNo
	,strUOM
)
SELECT
	s.strItemNo
	,s.strUOM
FROM 
	tblICImportStagingUOM s	LEFT JOIN tblICUnitMeasure u 
		ON RTRIM(LTRIM(u.strUnitMeasure)) COLLATE Latin1_General_CI_AS = LTRIM(s.strUOM) COLLATE Latin1_General_CI_AS
WHERE
	s.strImportIdentifier = @strIdentifier
	AND u.intUnitMeasureId IS NULL

--Check Duplicate UPC codes

INSERT INTO @tblDuplicateUPCCodes (strItemNo, strUPCCode, strDescription)
SELECT
	x.strItemNo,
	x.strUPCCode,
	i.strDescription
FROM tblICImportStagingUOM x
INNER JOIN tblICItem i 
ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(x.strItemNo) COLLATE Latin1_General_CI_AS
OUTER APPLY (
	SELECT TOP 1 intUpcCode
	FROM tblICItemUOM
	WHERE intUpcCode = case when x.strUPCCode IS NOT NULL AND isnumeric(rtrim(ltrim(strUPCCode)))=(1) 
		AND NOT (x.strUPCCode like '%.%' OR x.strUPCCode like '%e%' OR x.strUPCCode like '%E%') then CONVERT([bigint],rtrim(ltrim(x.strUPCCode)),0) else CONVERT([bigint],NULL,0) end
) upc
LEFT JOIN @tblMissingUOMs missingUOM ON missingUOM.strItemNo = x.strItemNo COLLATE Latin1_General_CI_AS
WHERE upc.intUpcCode IS NOT NULL AND missingUOM.strItemNo IS NULL

--Check invalid Stock Unit quantities

INSERT INTO @tblInvalidStockUnitQuantities (strItemNo, strUOM, strDescription)
SELECT
	x.strItemNo,
	x.strUOM,
	i.strDescription
FROM tblICImportStagingUOM x
INNER JOIN tblICItem i 
ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(x.strItemNo) COLLATE Latin1_General_CI_AS
LEFT JOIN @tblMissingUOMs missingUOM 
	ON missingUOM.strItemNo = x.strItemNo COLLATE Latin1_General_CI_AS
LEFT JOIN @tblMissingItems missingItem 
	ON missingItem.strItemNo = x.strItemNo COLLATE Latin1_General_CI_AS
WHERE 
	x.ysnIsStockUnit = 1 AND 
	CONVERT(DECIMAL(38,20), x.dblUnitQty) <> 1 AND 
	missingUOM.strItemNo IS NULL AND
	missingItem.strItemNo IS NULL

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
	LEFT JOIN @tblMissingItems v1 ON v1.strItemNo COLLATE Latin1_General_CI_AS = x.strItemNo  COLLATE Latin1_General_CI_AS	
	LEFT JOIN @tblMissingUOMs v2 ON v2.strItemNo COLLATE Latin1_General_CI_AS = x.strItemNo COLLATE Latin1_General_CI_AS	
WHERE 
	x.strImportIdentifier = @strIdentifier
	AND v1.strItemNo IS NULL 
	AND v2.strItemNo IS NULL 

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
) AS source 
	ON (target.intUnitMeasureId = source.intUnitMeasureId AND target.intItemId = source.intItemId)
	--OR RTRIM(LTRIM(target.strLongUPCCode)) COLLATE Latin1_General_CI_AS = LTRIM(source.strLongUPCCode) COLLATE Latin1_General_CI_AS -- Comment this one. It can cause bugs. 

WHEN MATCHED AND @ysnAllowOverwrite = 1 THEN
	UPDATE SET 
		--intItemId = source.intItemId, -- Do not update the item id. Why update it when it is the on used in the source-target as linking keys. 
		--intUnitMeasureId = source.intUnitMeasureId, -- Do not update the unit measure id. Why update it when it is the on used in the source-target as linking keys. 
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
		intCreatedByUserId,
		intDataSourceId
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
		intCreatedByUserId,
		@intDataSourceId
	)
	OUTPUT deleted.intItemId, $action, inserted.intItemId INTO #output;

-- Logs 
BEGIN 
	DECLARE 
		@intRowsImported AS INT 
		,@intRowsUpdated AS INT
		,@intRowsSkipped AS INT

	DECLARE @intTotalUPCCodeDuplicates INT
	DECLARE @intTotalInvalidStockUnit INT

	SELECT @intTotalUPCCodeDuplicates = COUNT(*) FROM @tblDuplicateUPCCodes 
	SELECT @intTotalInvalidStockUnit = COUNT(*) FROM @tblInvalidStockUnitQuantities

	SELECT @intRowsImported = COUNT(*) FROM #output WHERE strAction = 'INSERT'
	SELECT @intRowsUpdated = COUNT(*) FROM #output WHERE strAction = 'UPDATE'
	SELECT 
		@intRowsSkipped = COUNT(1) - ISNULL(@intRowsImported, 0) - ISNULL(@intRowsUpdated, 0) 
	FROM 
		tblICImportStagingUOM s
	WHERE
		s.strImportIdentifier = @strIdentifier

	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intRowsUpdated] 
		,[intRowsSkipped]
		,[intTotalWarnings]
	)
	SELECT
		@strIdentifier
		,intRowsImported = ISNULL(@intRowsImported, 0)
		,intRowsUpdated = ISNULL(@intRowsUpdated, 0) 
		,intRowsSkipped = ISNULL(@intRowsSkipped, 0)
		,intTotalWarnings = ISNULL(ISNULL(@intTotalUPCCodeDuplicates, 0) + ISNULL(@intTotalInvalidStockUnit, 0), 0)
	-- Log Detail for missing items and uoms
	INSERT INTO tblICImportLogDetailFromStaging(
		strUniqueId
		, strField
		, strAction
		, strValue
		, strMessage
		, strStatus
		, strType
		, intConcurrencyId
	)
	SELECT 
		@strIdentifier
		, 'Item No.'
		, 'Import Failed.'
		, strItemNo
		, 'Missing item: "' + strItemNo + '"'
		, 'Failed'
		, 'Error'
		, 1
	FROM 
		@tblMissingItems

	UNION ALL
	SELECT 
		@strIdentifier
		, 'UOM'
		, 'Import Failed.'
		, strUOM
		, 'Missing unit of measure: "' + strUOM + '" on item "' + strItemNo + '"'
		, 'Failed'
		, 'Error'
		, 1
	FROM 
		@tblMissingUOMs

	-- Check if there are UPC duplicates to log as warning

	IF @intTotalUPCCodeDuplicates > 0
	BEGIN
		INSERT INTO tblICImportLogDetailFromStaging(
			strUniqueId
			, strField
			, strAction
			, strValue
			, strMessage
			, strStatus
			, strType
			, intConcurrencyId
		)
		SELECT 
			@strIdentifier,
			'UPC Code',
			'Import Finished.',
			Codes.strUPCCode,
			'Duplicate UPC Code - ' + Codes.strUPCCode + ' on Item ' + Codes.strItemNo + ' - ' + Codes.strDescription + ' and still uploaded UOM with empty UPC Code.',
			'Success',
			'Warning',
			1
		FROM @tblDuplicateUPCCodes Codes
	END

	-- Check if there are invalid stock unit quantity to log as warning

	IF @intTotalInvalidStockUnit > 0
	BEGIN
		INSERT INTO tblICImportLogDetailFromStaging(
			strUniqueId
			, strField
			, strAction
			, strValue
			, strMessage
			, strStatus
			, strType
			, intConcurrencyId
		)
		SELECT 
			@strIdentifier,
			'UOM',
			'Import Finished.',
			UOMs.strUOM,
			'Unit Qty for Stock Unit ' + UOMs.strUOM + ' of ' + UOMs.strItemNo + ' - ' + UOMs.strDescription + ' is greater than 1. Setting it to not stock unit',
			'Success',
			'Warning',
			1
		FROM @tblInvalidStockUnitQuantities UOMs
	END
END

DROP TABLE #tmp
DROP TABLE #output

DELETE FROM tblICImportStagingUOM WHERE strImportIdentifier = @strIdentifier

UPDATE ItemUOM 
SET ItemUOM.dblUnitQty = 1 
FROM tblICItemUOM ItemUOM
INNER JOIN tblICItem Item
	ON Item.intItemId = ItemUOM.intItemId
INNER JOIN @tblInvalidStockUnitQuantities InvalidStockUnit
	ON Item.strItemNo COLLATE Latin1_General_CI_AS = InvalidStockUnit.strItemNo COLLATE Latin1_General_CI_AS

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