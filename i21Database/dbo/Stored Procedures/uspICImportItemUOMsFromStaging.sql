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


CREATE TABLE #tmp_missingItem (
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

CREATE TABLE #tmp_missingUOM (
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

-- Validate records

-- Check if the item is missing
IF @ysnAllowOverwrite = 1
BEGIN 
	INSERT INTO #tmp_missingItem (
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
END 

-- Check if the UOM is missing
IF @ysnAllowOverwrite = 1
BEGIN 
	INSERT INTO #tmp_missingUOM (
		strItemNo
		,strUnitMeasure
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
END 



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
	LEFT JOIN #tmp_missingItem v1 ON v1.strItemNo = x.strItemNo
	LEFT JOIN #tmp_missingUOM v2 ON v2.strItemNo = x.strItemNo
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
	)
	SELECT
		@strIdentifier
		,intRowsImported = ISNULL(@intRowsImported, 0)
		,intRowsUpdated = ISNULL(@intRowsUpdated, 0) 
		,intRowsSkipped = ISNULL(@intRowsSkipped, 0)

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
		#tmp_missingItem

	UNION ALL
	SELECT 
		@strIdentifier
		, 'UOM'
		, 'Import Failed.'
		, strUnitMeasure
		, 'Missing unit of measure: "' + strUnitMeasure + '" on item "' + strItemNo + '"'
		, 'Failed'
		, 'Error'
		, 1
	FROM 
		#tmp_missingUOM
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