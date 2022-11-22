CREATE PROCEDURE uspMFUpdateTrialBlendSheetReservation (@intWorkOrderId INT)
AS
BEGIN
	UPDATE LI
	SET dblReservedQtyInTBS = IsNULL(LI.dblReservedQtyInTBS, 0) + WI.dblQuantity
	FROM dbo.tblMFLotInventory LI
	JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intLotId = LI.intLotId
	WHERE WI.intWorkOrderId = @intWorkOrderId
END