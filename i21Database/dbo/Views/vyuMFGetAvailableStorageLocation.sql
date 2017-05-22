CREATE VIEW vyuMFGetAvailableStorageLocation
AS
SELECT DISTINCT SL.strName
	,SL.strDescription
	,CASE 
		WHEN L.intLotId IS NULL
			THEN 'Yes'
		ELSE 'No'
		END AS strAvailable
FROM tblICStorageLocation SL
LEFT JOIN tblICLot L ON L.intStorageLocationId = SL.intStorageLocationId
	AND dblQty > 0
