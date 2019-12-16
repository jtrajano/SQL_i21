CREATE PROCEDURE uspICImportItemsFromStaging @strIdentifier NVARCHAR(100)
AS

INSERT INTO tblICItemUOM (
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
WHERE NOT EXISTS(
	SELECT TOP 1 1
	FROM tblICItemUOM
	WHERE (intUnitMeasureId = u.intUnitMeasureId
		AND intItemId = i.intItemId) OR RTRIM(LTRIM(strLongUPCCode)) COLLATE Latin1_General_CI_AS = LTRIM(x.strUPCCode) COLLATE Latin1_General_CI_AS
) AND x.strImportIdentifier = @strIdentifier

UPDATE l
SET l.intRowsImported = @@ROWCOUNT
FROM tblICImportLog l
WHERE l.strUniqueId = @strIdentifier

DELETE FROM tblICImportStagingUOM WHERE strImportIdentifier = @strIdentifier