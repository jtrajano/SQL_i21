CREATE PROCEDURE uspMFGetProductionReport @intDay int=1
AS
DECLARE @dtmProductionDate DATETIME

IF @dtmProductionDate IS NULL
BEGIN
	SELECT @dtmProductionDate = convert(DATETIME, Convert(CHAR, GetDATE(), 101)) - @intDay
END
ELSE
BEGIN
	SELECT @dtmProductionDate = convert(DATETIME, Convert(CHAR, @dtmProductionDate, 101))
END
if @intDay=-1
Begin
	SELECT *
	FROM vyuMFGetProduction

	SELECT *
	FROM vyuMFGetRMUsage

	SELECT *
	FROM vyuMFGetRMUsageByLot

	SELECT *
	FROM vyuMFGetPMUsage

	SELECT *
	FROM vyuMFGetOverAndUnderWeight

End
Else
Begin
	SELECT *
	FROM vyuMFGetProduction
	WHERE [Production Date] = @dtmProductionDate

	SELECT *
	FROM vyuMFGetRMUsage
	WHERE [Dump Date] = @dtmProductionDate

	SELECT *
	FROM vyuMFGetRMUsageByLot
	WHERE [Dump Date] = @dtmProductionDate

	SELECT *
	FROM vyuMFGetPMUsage
	WHERE [Dump Date] = @dtmProductionDate

	SELECT *
	FROM vyuMFGetOverAndUnderWeight
	WHERE [Production Date] = @dtmProductionDate
End