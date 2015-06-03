CREATE PROCEDURE [dbo].uspMFGetCycleCount (@intWorkOrderId int)
AS
BEGIN 
SELECT CC.intCycleCountSessionId
		,CC.intCycleCountId
		,CC.intMachineId
		,M.strName AS strMachineName
		,M.intSubLocationId
		,SL.strSubLocationName 
		,CC.intLotId
		,CC.intItemId
		,I.strItemNo
		,I.strDescription
		,CC.dblQuantity
		,CC.dblSystemQty
		,CC.intCreatedUserId 
		,U.strUserName strCreatedUser
		,CC.dtmCreated
		,CC.intLastModifiedUserId
		,U1.strUserName strLastModifiedUser
		,CC.dtmLastModified
		,CC.intConcurrencyId
	FROM dbo.tblMFProcessCycleCount CC
	JOIN dbo.tblMFProcessCycleCountSession CS on CS.intCycleCountSessionId=CC.intCycleCountSessionId
	JOIN dbo.tblMFMachine M ON M.intMachineId = CC.intMachineId
	JOIN dbo.tblICItem I ON I.intItemId = CC.intItemId
	JOIN dbo.tblSMUserSecurity U ON U.intUserSecurityID = CC.intCreatedUserId
	JOIN dbo.tblSMUserSecurity U1 ON U1.intUserSecurityID = CC.intCreatedUserId
	JOIN dbo.tblSMCompanyLocationSubLocation SL on SL.intCompanyLocationSubLocationId =M.intSubLocationId
	WHERE CS.intWorkOrderId=@intWorkOrderId
END 
GO


