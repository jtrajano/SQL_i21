IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCUomMigrationPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCUomMigrationPt]; 
GO

CREATE PROCEDURE [dbo].[uspICDCUomMigrationPt]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



--------------------------------------------------------------------------------------------------------------------------------------------
-- UnitMeasure data migration from ptuommst origin table to tblICUnitMeasure i21 table 
-- This does not insert duplicates
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @UOMS TABLE (strUnitMeasure NVARCHAR(100) COLLATE Latin1_General_CI_AS, strSymbol NVARCHAR(100) COLLATE Latin1_General_CI_AS)
INSERT INTO @UOMS
SELECT DISTINCT
	  strUnitMeasure	= RTRIM(ptuom_desc) COLLATE Latin1_General_CI_AS 
	, strSymbol			= RTRIM(ptuom_code) COLLATE Latin1_General_CI_AS
FROM ptuommst
WHERE ptuom_code != ' '	

UNION

SELECT DISTINCT
	  strUnitMeasure	= RTRIM(ptpkg_desc) COLLATE Latin1_General_CI_AS 
	, strSymbol			= RTRIM(ptpkg_code) COLLATE Latin1_General_CI_AS
FROM ptpkgmst
WHERE ptpkg_code != ' '

;WITH CTE AS 
(
    SELECT strUnitMeasure, strSymbol, ROW_NUMBER() OVER 
    (
        PARTITION BY strUnitMeasure ORDER BY strUnitMeasure
    ) RowNumber
    FROM  @UOMS
)
DELETE
FROM CTE 
WHERE RowNumber > 1;

MERGE tblICUnitMeasure AS [Target]
USING 
(
	SELECT DISTINCT strUnitMeasure, strSymbol FROM @UOMS
) AS [Source] (strUnitMeasure, strSymbol)
ON [Target].strUnitMeasure = [Source].strUnitMeasure
WHEN NOT MATCHED THEN
INSERT (strUnitMeasure, strSymbol, intConcurrencyId)
VALUES ([Source].strUnitMeasure, [Source].strSymbol, 1);

--update the unit type for the imported uoms
UPDATE tblICUnitMeasure
SET strUnitType = 
CASE WHEN UPPER(strSymbol) IN ('BUSHEL','BUSHELS','BU', 'GAL', 'OZ', 'GA', 'QT') THEN 'Volume'
--when upper(strSymbol) in ('BAG', 'BX') then 'Packed' 
	WHEN UPPER(strSymbol) = 'EA' THEN 'Quantity'
	WHEN UPPER(strSymbol) IN ('TN', 'TON', 'KG', 'LB') THEN 'Weight'
	WHEN UPPER(strSymbol) = 'FT' THEN 'Length'
	WHEN UPPER(strSymbol) IN ('HOUR', 'HR') THEN 'Time'
	ELSE 'Quantity'
END 



GO

