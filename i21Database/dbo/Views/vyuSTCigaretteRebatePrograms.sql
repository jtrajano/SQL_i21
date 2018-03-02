CREATE VIEW [dbo].[vyuSTCigaretteRebatePrograms]
AS
SELECT 
CRP.*
, UOM.intItemUOMId
, UM.strUnitMeasure
, UOM.strUpcCode
, (CASE WHEN LEN(UOM.strLongUPCCode) = 12 THEN 
	'00' + UOM.strLongUPCCode 
  WHEN LEN(UOM.strLongUPCCode) = 8 THEN 
	'000000' + UOM.strLongUPCCode 
  END) AS strLongUPCCode
, IC.strDescription as strItemDescription
FROM tblSTCigaretteRebateProgramsDetails CRPD
JOIN tblSTCigaretteRebatePrograms CRP ON CRP.intCigaretteRebateProgramId = CRPD.intCigaretteRebateProgramId 
JOIN tblICItemUOM UOM on UOM.intItemUOMId = CRPD.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = UOM.intUnitMeasureId
JOIN tblICItem IC ON IC.intItemId = UOM.intItemId