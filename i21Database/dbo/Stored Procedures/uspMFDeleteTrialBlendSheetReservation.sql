CREATE PROCEDURE uspMFDeleteTrialBlendSheetReservation (@intWorkOrderId INT)
AS
BEGIN
	UPDATE LI
	SET dblReservedQtyInTBS = (
			CASE 
				WHEN LI.dblReservedQtyInTBS - WI.dblQuantity > 0
					THEN LI.dblReservedQtyInTBS - WI.dblQuantity
				ELSE 0
				END
			)
	FROM dbo.tblMFLotInventory LI
	JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intLotId = LI.intLotId
	WHERE WI.intWorkOrderId = @intWorkOrderId
END