CREATE PROCEDURE uspMFGetProductionReport
AS
DECLARE @dtmProductionDate DATETIME

IF @dtmProductionDate IS NULL
BEGIN
	SELECT @dtmProductionDate = convert(DATETIME, Convert(CHAR, GetDATE(), 101)) - 1
END
ELSE
BEGIN
	SELECT @dtmProductionDate = convert(DATETIME, Convert(CHAR, @dtmProductionDate, 101))
END

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
