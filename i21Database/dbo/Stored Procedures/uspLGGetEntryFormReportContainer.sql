CREATE PROCEDURE [dbo].[uspLGGetEntryFormReportContainer]
	@intLoadWarehouseId INT
AS

SELECT
	strContainerNumber = LC.strContainerNumber
	,strMarks = LC.strMarks
	,strSONumber = '' --TODO: Alter logic after LG-2323
	,dblQuantity = LC.dblQuantity --TODO: Alter logic after LG-2323
	,strID1 = LWC.strID1 
	,strID2 = LWC.strID2 
	,strID3 = LWC.strID3 
	,ysnShowID1
	,ysnShowID2
	,ysnShowID3
FROM
	tblLGLoadWarehouse LW
	LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadWarehouseId = LW.intLoadWarehouseId
	LEFT JOIN tblLGLoadContainer LC ON LWC.intLoadContainerId = LC.intLoadContainerId
	OUTER APPLY 
	   (SELECT 
			ysnShowID1 = CONVERT(BIT, CASE WHEN (ISNULL(MAX(strID1), '') <> '') THEN 1 ELSE 0 END)
			,ysnShowID2 = CONVERT(BIT, CASE WHEN (ISNULL(MAX(strID2), '') <> '') THEN 1 ELSE 0 END)
			,ysnShowID3 = CONVERT(BIT, CASE WHEN (ISNULL(MAX(strID3), '') <> '') THEN 1 ELSE 0 END)
		FROM
			tblLGLoadWarehouseContainer
		WHERE intLoadWarehouseId = LW.intLoadWarehouseId) ShowID
WHERE LW.intLoadWarehouseId = @intLoadWarehouseId