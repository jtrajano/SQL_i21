CREATE VIEW dbo.vyuMFGetPutawayDate
	WITH schemabinding
AS
SELECT IA.intSourceLotId AS intLotId
	,MAX(IA.dtmDate) dtmPutawayDate
FROM dbo.tblMFInventoryAdjustment IA
WHERE IA.intTransactionTypeId = 20
GROUP BY IA.intSourceLotId

