CREATE VIEW dbo.vyuMFGetPutawayDate
AS
SELECT IA.intSourceLotId AS intLotId
	,MAX(IA.dtmDate) dtmPutawayDate
FROM dbo.tblMFInventoryAdjustment IA
WHERE IA.intTransactionTypeId = 20
AND IA.intSourceLotId is not null
GROUP BY IA.intSourceLotId

