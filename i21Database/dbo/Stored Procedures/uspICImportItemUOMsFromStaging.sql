CREATE PROCEDURE uspICImportItemUOMsFromStaging 
	@strIdentifier NVARCHAR(100), 
	@ysnAllowOverwrite BIT = 0,
	@intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingUOM WHERE strImportIdentifier <> @strIdentifier

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strItemNo, strUOM ORDER BY strItemNo, strUOM) AS RowNumber
   FROM tblICImportStagingUOM
   WHERE strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

DECLARE @tblDuplicateUPCCodes TABLE(strItemNo NVARCHAR(200), strUPCCode NVARCHAR(200), strDescription NVARCHAR(MAX))
DECLARE @tblInvalidStockUnitQuantities TABLE(strItemNo NVARCHAR(200), strUOM NVARCHAR(200), strDescription NVARCHAR(MAX))
DECLARE @tblMissingUOMs TABLE(strItemNo NVARCHAR(200), strUOM NVARCHAR(200))
DECLARE @tblMissingItems TABLE (strItemNo NVARCHAR(200))
DECLARE @tblDuplicateUPCImported TABLE(strItemNo NVARCHAR(200), strUPCCode NVARCHAR(200))
DECLARE @tblInvalidModifier TABLE(strItemNo NVARCHAR(200), intModifier INT)


--Validate Records

--Check Imported UPC duplicates

INSERT INTO @tblDuplicateUPCImported (
	strItemNo,
	strUPCCode
)
SELECT 
	strItemNo,
	strUPCCode
FROM
(
	SELECT
	strItemNo,
	strUPCCode,
	ROW_NUMBER() OVER (PARTITION BY strUPCCode
						ORDER BY strUPCCode) AS RowNumber 
	FROM tblICImportStagingUOM 
	WHERE intModifier IS NULL
) AS ROWS
WHERE RowNumber > 1 
AND 
strUPCCode IS NOT NULL

--Make Imported UPC duplicates NULL

UPDATE UOM
SET UOM.strUPCCode = NULL
FROM
(
	SELECT
	strUPCCode,
	intModifier,
	ROW_NUMBER() OVER (PARTITION BY strUPCCode
						ORDER BY strUPCCode) AS RowNumber 
	FROM tblICImportStagingUOM
	WHERE intModifier IS NULL
) UOM
WHERE 
UOM.RowNumber > 1 
AND 
UOM.strUPCCode IS NOT NULL

--Check Imported UPC and Modifier duplicates

INSERT INTO @tblDuplicateUPCImported (
	strItemNo,
	strUPCCode
)
SELECT 
	strItemNo,
	strUPCCode
FROM
(
	SELECT
	strItemNo,
	strUPCCode,
	intModifier,
	ROW_NUMBER() OVER (PARTITION BY strUPCCode, intModifier
						ORDER BY strUPCCode) AS RowNumber 
FROM tblICImportStagingUOM 
) AS ROWS
WHERE RowNumber > 1 
AND 
strUPCCode IS NOT NULL
AND
intModifier IS NOT NULL

--Make Imported UPC and Modifier duplicates NULL

UPDATE UOM
SET 
	UOM.strUPCCode = NULL,
	UOM.intModifier = NULL
FROM
(
	SELECT
	strUPCCode,
	intModifier,
	ROW_NUMBER() OVER (PARTITION BY strUPCCode, intModifier
						ORDER BY strUPCCode) AS RowNumber 
	FROM tblICImportStagingUOM
) UOM
WHERE 
UOM.RowNumber > 1 
AND 
UOM.strUPCCode IS NOT NULL
AND
UOM.intModifier IS NOT NULL

--Check Imported Short UPC duplicates

INSERT INTO @tblDuplicateUPCImported (
	strItemNo,
	strUPCCode
)
SELECT 
	strItemNo,
	strShortUPCCode
FROM
(
	SELECT
	strItemNo,
	strShortUPCCode,
	ROW_NUMBER() OVER (PARTITION BY strShortUPCCode
						ORDER BY strShortUPCCode) AS RowNumber 
	FROM tblICImportStagingUOM 
	WHERE intModifier IS NULL
) AS ROWS
WHERE 
RowNumber > 1 
AND 
strShortUPCCode IS NOT NULL

--Make Imported Short UPC duplicates NULL

UPDATE UOM
SET UOM.strShortUPCCode = NULL
FROM
(
	SELECT
	strShortUPCCode,
	intModifier,
	ROW_NUMBER() OVER (PARTITION BY strShortUPCCode, intModifier
						ORDER BY strShortUPCCode) AS RowNumber 
	FROM tblICImportStagingUOM
) UOM
WHERE 
UOM.RowNumber > 1 
AND 
UOM.strShortUPCCode IS NOT NULL
AND
UOM.intModifier IS NULL

--Check Imported Short UPC and Modifier duplicates

INSERT INTO @tblDuplicateUPCImported (
	strItemNo,
	strUPCCode
)
SELECT 
	strItemNo,
	strShortUPCCode
FROM
(
	SELECT
	strItemNo,
	strShortUPCCode,
	intModifier,
	ROW_NUMBER() OVER (PARTITION BY strShortUPCCode, intModifier
						ORDER BY strShortUPCCode) AS RowNumber 
FROM tblICImportStagingUOM 
) AS ROWS
WHERE 
RowNumber > 1 
AND 
strShortUPCCode IS NOT NULL
AND
intModifier IS NOT NULL

--Make Imported Short UPC duplicates NULL

UPDATE UOM
SET 
	UOM.strShortUPCCode = NULL,
	UOM.intModifier = NULL
FROM
(
	SELECT
	strShortUPCCode,
	intModifier,
	ROW_NUMBER() OVER (PARTITION BY strShortUPCCode, intModifier
						ORDER BY strShortUPCCode) AS RowNumber 
	FROM tblICImportStagingUOM
) UOM
WHERE 
UOM.RowNumber > 1 
AND 
UOM.strShortUPCCode IS NOT NULL
AND
UOM.intModifier IS NOT NULL

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
FROM
	tblICImportStagingUOM x
LEFT JOIN
	tblICItem i
	ON
		i.strItemNo COLLATE Latin1_General_CI_AS = x.strItemNo COLLATE Latin1_General_CI_AS
LEFT JOIN
	tblICItemUOM longUPCMathces
	ON
		longUPCMathces.strLongUPCCode = x.strUPCCode
		AND
		ISNULL(NULLIF(longUPCMathces.intModifier, x.intModifier), NULLIF(x.intModifier, longUPCMathces.intModifier)) IS NULL
LEFT JOIN
	tblICItemUOM shortUPCMathces
	ON
		shortUPCMathces.strUpcCode = x.strShortUPCCode
		AND
		ISNULL(NULLIF(shortUPCMathces.intModifier, x.intModifier), NULLIF(x.intModifier, shortUPCMathces.intModifier)) IS NULL
LEFT JOIN @tblMissingUOMs missingUOM ON missingUOM.strItemNo = x.strItemNo COLLATE Latin1_General_CI_AS
LEFT JOIN @tblMissingItems missingItem ON missingItem.strItemNo = x.strItemNo COLLATE Latin1_General_CI_AS
WHERE
	(
		longUPCMathces.intItemId <> i.intItemId
		OR
		shortUPCMathces.intItemId <> i.intItemId
	)
	AND 
	missingUOM.strItemNo IS NULL
	AND
	missingItem.strItemNo IS NULL

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
	(
		CONVERT(DECIMAL(38,20), x.dblUnitQty) <> 1
		OR
		x.dblUnitQty IS NULL
	)
	AND
	missingUOM.strItemNo IS NULL AND
	missingItem.strItemNo IS NULL

INSERT INTO @tblInvalidModifier (strItemNo, intModifier)
SELECT
	x.strItemNo,
	x.intModifier
FROM tblICImportStagingUOM x
WHERE
	x.intModifier < 0
	AND 
	x.intModifier > 999

CREATE TABLE #tmp (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intUnitMeasureId INT NULL
	, strLongUPCCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strUpcCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intCheckDigit INT NULL
	, strUPCDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, intModifier INT NULL
	, dblUnitQty NUMERIC(38, 20) NULL
	, dblHeight NUMERIC(38, 20) NULL
	, dblWidth NUMERIC(38, 20) NULL
	, dblLength NUMERIC(38, 20) NULL
	, dblMaxQty NUMERIC(38, 20) NULL
	, dblVolume NUMERIC(38, 20) NULL
	, dblWeight NUMERIC(38, 20) NULL
	, dblStandardWeight NUMERIC(38, 20) NULL
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
	intCheckDigit,
	strUPCDescription,
	intModifier,
	dblUnitQty,
	dblHeight,
	dblWidth,
	dblLength,
	dblMaxQty,
	dblVolume,
	dblWeight,
	dblStandardWeight,
	ysnStockUnit,
	ysnAllowPurchase,
	ysnAllowSale,
	dtmDateCreated, 
	intCreatedByUserId
)
SELECT
	  i.intItemId
	, u.intUnitMeasureId
	, strLongUPCCode = CASE 
							WHEN v3.strUPCCode IS NOT NULL AND v3.strUPCCode COLLATE Latin1_General_CI_AS = x.strUPCCode COLLATE Latin1_General_CI_AS
							THEN NULL
							ELSE x.strUPCCode 
						END
	, strShortUPCCode =	CASE 
							WHEN v3.strUPCCode IS NOT NULL AND v3.strUPCCode COLLATE Latin1_General_CI_AS = x.strShortUPCCode COLLATE Latin1_General_CI_AS
							THEN NULL
							ELSE x.strShortUPCCode 
						END
	, dbo.fnICCalculateCheckDigit(CASE 
							WHEN v3.strUPCCode IS NOT NULL AND v3.strUPCCode COLLATE Latin1_General_CI_AS = x.strUPCCode COLLATE Latin1_General_CI_AS
							THEN NULL
							ELSE x.strUPCCode 
						END)
	, x.strUPCDescription
	, x.intModifier
	, x.dblUnitQty
	, x.dblHeight
	, x.dblWidth
	, x.dblLength
	, x.dblMaxQty
	, x.dblVolume
	, x.dblWeight
	, x.dblStandardWeight
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
	LEFT JOIN @tblInvalidModifier v4 ON v4.strItemNo COLLATE Latin1_General_CI_AS = x.strItemNo COLLATE Latin1_General_CI_AS
	LEFT JOIN @tblDuplicateUPCCodes v3 ON v3.strItemNo COLLATE Latin1_General_CI_AS = x.strItemNo COLLATE Latin1_General_CI_AS
WHERE x.strImportIdentifier = @strIdentifier
AND v1.strItemNo IS NULL 
AND v2.strItemNo IS NULL
AND v3.strItemNo IS NULL
AND v4.strItemNo IS NULL

DECLARE @intItemId INT 
DECLARE @intUnitMeasureId INT 
DECLARE @strLongUPCCode NVARCHAR(200)
DECLARE @strUpcCode NVARCHAR(200)
DECLARE @intCheckDigit INT
DECLARE @strUPCDescription NVARCHAR(200)
DECLARE @intModifier INT
DECLARE @dblUnitQty NUMERIC(38, 20) 
DECLARE @dblHeight NUMERIC(38, 20) 
DECLARE @dblWidth NUMERIC(38, 20) 
DECLARE @dblLength NUMERIC(38, 20) 
DECLARE @dblMaxQty NUMERIC(38, 20) 
DECLARE @dblVolume NUMERIC(38, 20) 
DECLARE @dblWeight NUMERIC(38, 20) 
DECLARE @dblStandardWeight NUMERIC(38, 20) 
DECLARE @ysnStockUnit BIT 
DECLARE @ysnAllowPurchase BIT 
DECLARE @ysnAllowSale BIT 
DECLARE @dtmDateCreated DATETIME 
DECLARE @intCreatedByUserId INT 
DECLARE @intRowsImported INT = 0
DECLARE @intRowsUpdated INT = 0

DECLARE uom_cursor CURSOR FOR 
SELECT
	intItemId
	,intUnitMeasureId
	,strLongUPCCode
	,strUpcCode
	,intCheckDigit
	,strUPCDescription
	,intModifier
	,dblUnitQty
	,dblHeight
	,dblWidth
	,dblLength
	,dblMaxQty
	,dblVolume
	,dblWeight
	,dblStandardWeight
	,ysnStockUnit
	,ysnAllowPurchase
	,ysnAllowSale
	,dtmDateCreated
	,intCreatedByUserId
FROM #tmp

OPEN uom_cursor  
FETCH NEXT FROM uom_cursor INTO 
	@intItemId
	,@intUnitMeasureId
	,@strLongUPCCode
	,@strUpcCode
	,@intCheckDigit
	,@strUPCDescription
	,@intModifier
	,@dblUnitQty
	,@dblHeight
	,@dblWidth
	,@dblLength
	,@dblMaxQty
	,@dblVolume
	,@dblWeight
	,@dblStandardWeight
	,@ysnStockUnit
	,@ysnAllowPurchase
	,@ysnAllowSale
	,@dtmDateCreated
	,@intCreatedByUserId  

WHILE @@FETCH_STATUS = 0  
BEGIN  
      
	
	UPDATE tblICItemUOM 
	SET 
		intItemId = @intItemId
		,intUnitMeasureId = @intUnitMeasureId
		,strLongUPCCode = @strLongUPCCode
		,strUpcCode = @strUpcCode
		,intCheckDigit = @intCheckDigit
		,strUPCDescription = @strUPCDescription
		,intModifier = @intModifier
		,dblUnitQty = @dblUnitQty
		,dblHeight = @dblHeight
		,dblWidth = @dblWidth
		,dblLength = @dblLength
		,dblMaxQty = @dblMaxQty
		,dblVolume = @dblVolume
		,dblWeight = @dblWeight
		,dblStandardWeight = @dblStandardWeight
		,ysnStockUnit = @ysnStockUnit
		,ysnAllowPurchase = @ysnAllowPurchase
		,ysnAllowSale = @ysnAllowSale
		,dtmDateCreated = @dtmDateCreated
		,intCreatedByUserId = @intCreatedByUserId
	WHERE 
		(intUnitMeasureId = @intUnitMeasureId AND intItemId = @intItemId)
		OR
		(
			RTRIM(LTRIM(strLongUPCCode)) COLLATE Latin1_General_CI_AS = LTRIM(@strLongUPCCode) COLLATE Latin1_General_CI_AS 
			AND 
			@strLongUPCCode IS NOT NULL
			AND
			ISNULL(NULLIF(intModifier, @intModifier), NULLIF(@intModifier, intModifier)) IS NULL
			AND
			intItemId = @intItemId
		)
		OR
		(
			RTRIM(LTRIM(strUpcCode)) COLLATE Latin1_General_CI_AS = LTRIM(@strUpcCode) COLLATE Latin1_General_CI_AS 
			AND 
			@strUpcCode IS NOT NULL
			AND
			ISNULL(NULLIF(intModifier, @intModifier), NULLIF(@intModifier, intModifier)) IS NULL
			AND
			intItemId = @intItemId
		)
	IF (@@ROWCOUNT > 0)
	BEGIN
		SET @intRowsUpdated = @intRowsUpdated + 1
	END
	ELSE
	BEGIN
		INSERT INTO tblICItemUOM
		(
			intItemId, 
			intUnitMeasureId, 
			strLongUPCCode,
			strUpcCode,
			intCheckDigit,
			strUPCDescription,
			intModifier,
			dblUnitQty,
			dblHeight,
			dblWidth,
			dblLength,
			dblMaxQty,
			dblVolume,
			dblWeight,
			dblStandardWeight,
			ysnStockUnit,
			ysnAllowPurchase,
			ysnAllowSale,
			dtmDateCreated, 
			intCreatedByUserId,
			intDataSourceId
		)
		SELECT 
			RowItem.intItemId, 
			RowItem.intUnitMeasureId, 
			RowItem.strLongUPCCode,
			RowItem.strUpcCode,
			RowItem.intCheckDigit,
			RowItem.strUPCDescription,
			RowItem.intModifier,
			RowItem.dblUnitQty,
			RowItem.dblHeight,
			RowItem.dblWidth,
			RowItem.dblLength,
			RowItem.dblMaxQty,
			RowItem.dblVolume,
			RowItem.dblWeight,
			RowItem.dblStandardWeight,
			RowItem.ysnStockUnit,
			RowItem.ysnAllowPurchase,
			RowItem.ysnAllowSale,
			RowItem.dtmDateCreated, 
			RowItem.intCreatedByUserId,
			RowItem.intDataSourceId
		FROM
		(
			SELECT
			intItemId = @intItemId
			,intUnitMeasureId = @intUnitMeasureId
			,strLongUPCCode = @strLongUPCCode
			,strUpcCode = @strUpcCode
			,intCheckDigit = @intCheckDigit
			,strUPCDescription = @strUPCDescription
			,intModifier = @intModifier
			,dblUnitQty = @dblUnitQty
			,dblHeight = @dblHeight
			,dblWidth = @dblWidth
			,dblLength = @dblLength
			,dblMaxQty = @dblMaxQty
			,dblVolume = @dblVolume
			,dblWeight = @dblWeight
			,dblStandardWeight = @dblStandardWeight
			,ysnStockUnit = @ysnStockUnit
			,ysnAllowPurchase = @ysnAllowPurchase
			,ysnAllowSale = @ysnAllowSale
			,dtmDateCreated = @dtmDateCreated
			,intCreatedByUserId = @intCreatedByUserId
			,intDataSourceId = @intDataSourceId
		) AS RowItem
		LEFT JOIN 
		tblICItemUOM ItemUOM
		ON 
		RowItem.intItemId = ItemUOM.intItemId
		AND
		RowItem.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE
		ItemUOM.intItemUOMId IS NULL

		IF (@@ROWCOUNT > 0)
		BEGIN
			SET @intRowsImported = @intRowsImported + 1
		END
	END


	FETCH NEXT FROM uom_cursor INTO 
		@intItemId
		,@intUnitMeasureId
		,@strLongUPCCode
		,@strUpcCode
		,@intCheckDigit
		,@strUPCDescription
		,@intModifier
		,@dblUnitQty
		,@dblHeight
		,@dblWidth
		,@dblLength
		,@dblMaxQty
		,@dblVolume
		,@dblWeight
		,@dblStandardWeight
		,@ysnStockUnit
		,@ysnAllowPurchase
		,@ysnAllowSale
		,@dtmDateCreated
		,@intCreatedByUserId   
END 

CLOSE uom_cursor  
DEALLOCATE uom_cursor 

-- Logs 
BEGIN 

	DECLARE @intRowsSkipped INT
	DECLARE @intTotalUPCCodeDuplicates INT
	DECLARE @intTotalUPCImportDuplicates INT
	DECLARE @intTotalInvalidStockUnit INT
	DECLARE @intTotalMissingItem INT
	DECLARE @intTotalMissingUOM INT
	DECLARE @intTotalInvalidModifier INT

	SELECT @intTotalUPCCodeDuplicates = COUNT(*) FROM @tblDuplicateUPCCodes 
	SELECT @intTotalUPCImportDuplicates = COUNT(*) FROM @tblDuplicateUPCImported 
	SELECT @intTotalInvalidStockUnit = COUNT(*) FROM @tblInvalidStockUnitQuantities
	SELECT @intTotalMissingUOM = COUNT(*) FROM @tblMissingUOMs
	SELECT @intTotalUPCImportDuplicates = COUNT(*) FROM @tblDuplicateUPCImported 
	SELECT @intTotalInvalidModifier = COUNT(*) FROM @tblInvalidModifier

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
		,[intTotalErrors]
	)
	SELECT
		@strIdentifier
		,intRowsImported = ISNULL(@intRowsImported, 0)
		,intRowsUpdated = ISNULL(@intRowsUpdated, 0) 
		,intRowsSkipped = ISNULL(@intRowsSkipped, 0)
		,intTotalWarnings = ISNULL(ISNULL(@intTotalUPCCodeDuplicates, 0) + ISNULL(@intTotalUPCImportDuplicates, 0) + ISNULL(@intTotalInvalidStockUnit, 0), 0)
		,intTotalErrors = @intTotalMissingItem + @intTotalMissingUOM + @intTotalInvalidModifier
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
	UNION ALL
	SELECT 
		@strIdentifier
		, 'Modifier'
		, 'Import Failed.'
		, intModifier
		, 'Invalid modifier.'
		, 'Failed'
		, 'Error'
		, 1
	FROM
		@tblInvalidModifier
	UNION ALL
	SELECT 
			@strIdentifier,
			'UPC Code',
			'Import Failed.',
			Codes.strUPCCode,
			'Duplicate UPC Code - ' + Codes.strUPCCode + ' on Item ' + Codes.strItemNo + ' - ' + Codes.strDescription + '.',
			'Failed',
			'Error',
			1
	FROM 
		@tblDuplicateUPCCodes Codes
	UNION ALL
	SELECT 
			@strIdentifier,
			'UPC Code',
			'Import Finished.',
			Codes.strUPCCode,
			'Duplicate on CSV file imported on UPC Code  - ' + Codes.strUPCCode + ' on Item ' + Codes.strItemNo + ' and still uploaded UOM with empty UPC Code.',
			'Success',
			'Warning',
			1
	FROM 
		@tblDuplicateUPCImported Codes
	UNION ALL
	SELECT 
			@strIdentifier,
			'UOM',
			'Import Finished.',
			UOMs.strUOM,
			'Unit Qty for Stock Unit ' + UOMs.strUOM + ' of ' + UOMs.strItemNo + ' - ' + UOMs.strDescription + ' is greater than 1. Setting it to not stock unit',
			'Success',
			'Warning',
			1
	FROM 
		@tblInvalidStockUnitQuantities UOMs
END

DROP TABLE #tmp

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