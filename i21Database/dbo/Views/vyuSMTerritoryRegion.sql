CREATE VIEW [dbo].[vyuSMTerritoryRegion]
AS

SELECT 
	Region.intRegionId
	, Territory.intTerritoryId
	, Region.strRegion
	, Territory.strTerritory 
	
FROM tblSMRegion Region
	JOIN tblSMTerritory Territory
		ON Region.intRegionId = Territory.intRegionId