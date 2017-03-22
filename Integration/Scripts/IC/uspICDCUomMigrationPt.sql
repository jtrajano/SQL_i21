SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE [dbo].[uspICDCUomMigrationPt]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



--------------------------------------------------------------------------------------------------------------------------------------------
-- UnitMeasure data migration from ptuommst origin table to tblICUnitMeasure i21 table 

--------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tblICUnitMeasure (
	strUnitMeasure
	,strSymbol
	,intConcurrencyId
	)
SELECT RTRIM(ptuom_desc)
	,RTRIM(ptuom_code)
	,1
FROM ptuommst
WHERE ptuom_code != ' '

--update the unit type for the imported uoms
update tblICUnitMeasure set strUnitType = 
case 
when upper(strSymbol) in ('BUSHEL','BUSHELS','BU', 'GAL', 'OZ', 'GA', 'QT') then 'Volume'
--when upper(strSymbol) in ('BAG', 'BX') then 'Packed' 
when upper(strSymbol) = 'EA' then 'Quantity'
when upper(strSymbol) in ('TN', 'TON', 'KG', 'LB') then 'Weight'
when upper(strSymbol) = 'FT' then 'Length'
when upper(strSymbol) in ('HOUR', 'HR') then 'Time'
else 'Quantity'
End 



GO

