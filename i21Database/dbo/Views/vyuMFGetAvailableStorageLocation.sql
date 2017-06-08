CREATE VIEW vyuMFGetAvailableStorageLocation
AS
SELECT DISTINCT SL.strName
	,SL.strDescription
	,CASE 
		WHEN L.intLotId IS NULL
			THEN 'Yes'
		ELSE 'No'
		END AS strAvailable
		,LS.strSubLocationName 
FROM tblICStorageLocation SL
JOIN tblSMCompanyLocationSubLocation LS On LS.intCompanyLocationSubLocationId =SL.intSubLocationId 
LEFT JOIN tblICLot L ON L.intStorageLocationId = SL.intStorageLocationId
	AND dblQty > 0
