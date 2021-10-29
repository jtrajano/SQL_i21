IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCUomMigrationAg]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCUomMigrationAg]; 
GO

CREATE PROCEDURE [dbo].[uspICDCUomMigrationAg]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--------------------------------------------------------------------------------------------------------------------------------------------
-- UnitMeasure data migration from agitmmst origin table to tblICUnitMeasure i21 table 
-- Section 1
--import units of mesaure from the item setup. USe distinct to get unit uoms
--------------------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpImportUnitMeasure')) 
BEGIN 
	CREATE TABLE #tmpImportUnitMeasure (UnitMeasure NVARCHAR(100))
END 
	
DELETE FROM #tmpImportUnitMeasure

--import all stock unit of measures
INSERT INTO #tmpImportUnitMeasure
SELECT * FROM (
				SELECT DISTINCT UPPER(RTRIM(agitm_un_desc)) UnitMeasure
				FROM agitmmst
				UNION
				--CREATE 'LB' unit of Measure if not available in Origin
				SELECT 'LB' UnitMeasure WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICUnitMeasure WHERE strUnitMeasure = 'LB') 
				UNION 
				--import all packing description with pack per unit not equal to 1. These are pack units and have a different stock unit.
				SELECT DISTINCT UPPER(RTRIM(agitm_pak_desc)) UnitMeasure
				FROM agitmmst
				WHERE agitm_un_per_pak not in (1,0) AND agitm_pak_desc IS NOT NULL
				) ALLUOM
	WHERE UPPER(RTRIM(UnitMeasure)) COLLATE SQL_Latin1_General_CP1_CS_AS NOT IN (SELECT UPPER(RTRIM(strUnitMeasure)) COLLATE SQL_Latin1_General_CP1_CS_AS FROM tblICUnitMeasure)

	--select 'debug #tmpImportUnitMeasure', * from #tmpImportUnitMeasure

INSERT INTO tblICUnitMeasure (strUnitMeasure)
SELECT UnitMeasure FROM #tmpImportUnitMeasure

--update the unit type for the imported uoms
update tblICUnitMeasure set strUnitType = 
case 
when upper(strUnitMeasure) in ('BUSHEL','BUSHELS','BU', 'GAL', 'OZ', 'GA', 'QT') then 'Volume'
--when upper(strUnitMeasure) in ('BAG', 'BX') then 'Packed' 
when upper(strUnitMeasure) = 'EA' then 'Quantity'
when upper(strUnitMeasure) in ('TN', 'TON', 'KG', 'LB', 'LBS') then 'Weight'
when upper(strUnitMeasure) = 'FT' then 'Length'
else 'Quantity'
End 
WHERE strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT UnitMeasure FROM #tmpImportUnitMeasure)

--update the unit type for the imported uoms with pack per unit greater than 1
--update tblICUnitMeasure set strUnitType = 'Quantity'
--where strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS in  
--(select upper(rtrim(agitm_un_desc))+' '+SUBSTRING(cast(agitm_un_per_pak as varchar(15)), 0, CHARINDEX('.', agitm_un_per_pak)) 
--COLLATE SQL_Latin1_General_CP1_CS_AS
--from agitmmst where agitm_un_per_pak > 1) 
--insert conversion factors for units with pack per unit > 1 <<MSA: looks like NOT equal to 0 or 1 as indicated in the where condition
		
insert into tblICUnitMeasureConversion (
	intUnitMeasureId
	, intStockUnitMeasureId
	, dblConversionToStock
	, intSort
	, intConcurrencyId
)
select distinct 
	U.intUnitMeasureId 
	,toUnit.intUnitMeasureId --(select top 1 intUnitMeasureId from tblICUnitMeasure U where U.strUnitMeasure = upper(rtrim(agitm_un_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS) intToUnit,
	,agitm_un_per_pak
	,0
	,1
from 
	(
		SELECT DISTINCT 
			agitm_pak_desc = UPPER(agitm_pak_desc)
			,agitm_un_desc = UPPER(agitm_un_desc)				
		FROM 
			agitmmst I 
		WHERE
			agitm_pak_desc IS NOT NULL
	) I INNER JOIN tblICUnitMeasure U 
		ON U.strUnitMeasure = RTRIM(agitm_pak_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICUnitMeasure toUnit 
		ON toUnit.strUnitMeasure = RTRIM(agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
	CROSS APPLY (
		SELECT TOP 1 
			agitm_un_per_pak
		FROM 
			agitmmst pak
		WHERE
			UPPER(pak.agitm_pak_desc) = I.agitm_pak_desc 
			AND UPPER(pak.agitm_un_desc) = I.agitm_un_desc 				
	) pak
where 		
	agitm_un_per_pak not in (1,0) 
	AND agitm_un_per_pak IS NOT NULL 
	AND U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT UnitMeasure FROM #tmpImportUnitMeasure)
GO
