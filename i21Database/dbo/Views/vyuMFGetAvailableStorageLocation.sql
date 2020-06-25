CREATE VIEW vyuMFGetAvailableStorageLocation
AS
SELECT DISTINCT SL.strName
	,SL.strDescription
	,CASE 
		WHEN L.intLotId IS NULL
			THEN 'Yes'
		ELSE 'No'
		END COLLATE Latin1_General_CI_AS AS strAvailable
		,LS.strSubLocationName 
		,SL.intLocationId
FROM tblICStorageLocation SL
JOIN tblSMCompanyLocationSubLocation LS On LS.intCompanyLocationSubLocationId =SL.intSubLocationId 
LEFT JOIN tblICLot L ON L.intStorageLocationId = SL.intStorageLocationId
	AND dblQty > 0
