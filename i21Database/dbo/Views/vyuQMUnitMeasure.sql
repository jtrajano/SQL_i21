CREATE VIEW [dbo].[vyuQMUnitMeasure]
	AS
SELECT UM.intUnitMeasureId		
     , UM.strUnitMeasure				
     , UM.strSymbol
     , UM.strUnitType	
FROM tblICUnitMeasure UM
WHERE strUnitType NOT IN ('Time', 'Length') 
