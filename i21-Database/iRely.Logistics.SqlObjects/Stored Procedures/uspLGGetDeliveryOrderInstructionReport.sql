CREATE PROCEDURE uspLGGetDeliveryOrderInstructionReport 
					@strLoadNumber NVARCHAR(100)
AS
SELECT L.strLoadNumber
	,L.intLoadId
	,LWS.strCategory
	,LWS.strActivity
FROM tblLGLoad L
JOIN tblLGLoadWarehouse LW ON L.intLoadId = LW.intLoadId
JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
WHERE L.strLoadNumber = @strLoadNumber