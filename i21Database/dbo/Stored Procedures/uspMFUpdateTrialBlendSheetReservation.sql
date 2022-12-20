CREATE PROCEDURE uspMFUpdateTrialBlendSheetReservation (
	@intWorkOrderId INT
	,@intWorkOrderInputLotId INT = NULL
	)
AS
BEGIN
	UPDATE LI
	SET dblReservedQtyInTBS = IsNULL(LI.dblReservedQtyInTBS, 0) + WI.dblQuantity
	FROM dbo.tblMFLotInventory LI
	JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intLotId = LI.intLotId
	WHERE WI.intWorkOrderId = @intWorkOrderId
		AND intWorkOrderInputLotId = IsNULL(@intWorkOrderInputLotId, intWorkOrderInputLotId)
END
