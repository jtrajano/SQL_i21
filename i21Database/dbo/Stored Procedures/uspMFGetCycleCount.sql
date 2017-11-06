CREATE PROCEDURE [dbo].uspMFGetCycleCount (@intWorkOrderId int)
AS
BEGIN 
SELECT CC.intCycleCountSessionId
		,CC.intCycleCountId
		,0 As intMachineId
		,(SELECT STUFF((SELECT ',' + M.strName 
            FROM tblMFMachine M 
			JOIN tblMFProcessCycleCountMachine CM on M.intMachineId =CM.intMachineId 
			Where CM.intCycleCountId =CC.intCycleCountId
            FOR XML PATH('')) ,1,1,''))  AS strMachineName
		,SL1.intSubLocationId
		,SL.strSubLocationName 
		,CC.intLotId
		,CC.intItemId
		,I.strItemNo
		,I.strDescription
		,I.strType
		,CC.dblQuantity
		,CC.dblQtyInProdStagingLocation 
		,CC.dblRequiredQty 
		,CC.dblSystemQty
		,SL1.strName as strStorageLocation
		,CC.intCreatedUserId 
		,U.strUserName strCreatedUser
		,CC.dtmCreated
		,CC.intLastModifiedUserId
		,U1.strUserName strLastModifiedUser
		,CC.dtmLastModified
		,CC.intConcurrencyId
	FROM dbo.tblMFProcessCycleCount CC
	JOIN dbo.tblMFProcessCycleCountSession CS on CS.intCycleCountSessionId=CC.intCycleCountSessionId
	JOIN dbo.tblICStorageLocation SL1 on SL1.intStorageLocationId=CC.intProductionStagingLocationId
	JOIN dbo.tblICItem I ON I.intItemId = CC.intItemId
	JOIN dbo.tblSMUserSecurity U ON U.[intEntityId] = CC.intCreatedUserId
	JOIN dbo.tblSMUserSecurity U1 ON U1.[intEntityId] = CC.intCreatedUserId
	JOIN dbo.tblSMCompanyLocationSubLocation SL on SL.intCompanyLocationSubLocationId =SL1.intSubLocationId
 	WHERE CS.intWorkOrderId=@intWorkOrderId
	ORDER BY CC.intCycleCountId
END 
GO


