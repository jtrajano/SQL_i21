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
--import all stock unit of measures
insert into tblICUnitMeasure (strUnitMeasure)
SELECT UnitMeasure
FROM (
select distinct upper(rtrim(agitm_un_desc)) UnitMeasure
from agitmmst
where upper(rtrim(agitm_un_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS not in (select upper(strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS from tblICUnitMeasure)
) u
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICUnitMeasure WHERE strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS <> u.UnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS)

--CREATE 'LB' unit of Measure if not available in Origin
IF NOT EXISTS (select distinct upper(rtrim(agitm_un_desc)) UnitMeasure
from agitmmst where upper(rtrim(agitm_un_desc)) = 'LB')
INSERT INTO [dbo].[tblICUnitMeasure] ([strUnitMeasure]) SELECT 'LB' WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICUnitMeasure WHERE strUnitMeasure = 'LB')

--import all packing description with pack per unit not equal to 1. These are pack units and have a different stock unit.
--concatenate unit desc with pack per unit to make a unique uom
insert into tblICUnitMeasure (strUnitMeasure)
SELECT UnitMeasure
FROM (
select distinct upper(rtrim(agitm_pak_desc)) UnitMeasure
from agitmmst
left join tblICUnitMeasure I on I.strUnitMeasure = upper(rtrim(agitm_pak_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS
where agitm_un_per_pak not in (1,0) and I.strUnitMeasure is null
) u
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICUnitMeasure WHERE strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS <> u.UnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS)

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

--update the unit type for the imported uoms with pack per unit greater than 1
--update tblICUnitMeasure set strUnitType = 'Quantity'
--where strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS in  
--(select upper(rtrim(agitm_un_desc))+' '+SUBSTRING(cast(agitm_un_per_pak as varchar(15)), 0, CHARINDEX('.', agitm_un_per_pak)) 
--COLLATE SQL_Latin1_General_CP1_CS_AS
--from agitmmst where agitm_un_per_pak > 1) 

--insert conversion factors for units with pack per unit > 1
insert into tblICUnitMeasureConversion (intUnitMeasureId, intStockUnitMeasureId, dblConversionToStock, intSort, intConcurrencyId)
select distinct intUnitMeasureId, 
(select top 1 intUnitMeasureId from tblICUnitMeasure U where U.strUnitMeasure = upper(rtrim(agitm_un_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS) intToUnit,
agitm_un_per_pak, 0,1
from tblICUnitMeasure U join agitmmst I on U.strUnitMeasure = upper(rtrim(agitm_pak_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS
where agitm_un_per_pak not in (1,0)

GO

