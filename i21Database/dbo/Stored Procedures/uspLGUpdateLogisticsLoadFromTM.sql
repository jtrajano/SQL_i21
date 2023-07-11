CREATE PROCEDURE [dbo].[uspLGUpdateLogisticsLoadFromTM]
	@intDispatchId INT,
	@intEntityUserSecurityId INT = NULL
AS
BEGIN

/* Validate Dispatch Id */
IF NOT EXISTS (SELECT 1 FROM tblTMDispatch WHERE intDispatchID = @intDispatchId)
RETURN;

/* Check for Load/Shipment Schedules */
IF EXISTS (SELECT 1 FROM tblLGLoadDetail WHERE intTMDispatchId = @intDispatchId)
BEGIN
	--Update Prices in LS
	UPDATE LD
	SET dblUnitPrice = TMD.dblPrice
		,dblAmount = ROUND(dbo.fnMultiply(TMD.dblPrice, LD.dblQuantity), 2)
	FROM tblLGLoadDetail LD
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		INNER JOIN tblTMDispatch TMD ON TMD.intDispatchID = LD.intTMDispatchId
	WHERE LD.intTMDispatchId = @intDispatchId
		AND L.intSourceType = 8
		AND L.intShipmentStatus NOT IN (4, 6, 10, 11)
		AND ISNULL(L.ysnCancelled, 0) <> 1
END

/* Check for Dispatch Schedules */
IF EXISTS (SELECT 1 FROM tblLGDispatchOrderDetail WHERE intTMDispatchId = @intDispatchId)
BEGIN
	--Update Prices in DS
	UPDATE DOD
	SET dblPrice = TMD.dblPrice
		,dblTotal = ROUND(dbo.fnMultiply(TMD.dblPrice, DOD.dblQuantity), 2)
	FROM tblLGDispatchOrderDetail DOD
		INNER JOIN tblLGDispatchOrder DO ON DO.intDispatchOrderId = DOD.intDispatchOrderId
		INNER JOIN tblTMDispatch TMD ON TMD.intDispatchID = DOD.intTMDispatchId
	WHERE DOD.intTMDispatchId = @intDispatchId
		AND DOD.intOrderStatus IN (4, 6)
		AND DO.intDispatchStatus NOT IN (5, 6)
END

END
GO