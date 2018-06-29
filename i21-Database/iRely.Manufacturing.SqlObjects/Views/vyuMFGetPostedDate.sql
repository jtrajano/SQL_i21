CREATE VIEW dbo.vyuMFGetPostedDate
	WITH SCHEMABINDING
AS
SELECT IT.intLotId
	,IT.intTransactionId
	,MIN(dtmCreated) AS dtmPostedDate
FROM dbo.tblICInventoryTransaction IT
WHERE IT.intTransactionTypeId = 5
	AND IT.ysnIsUnposted = 0
GROUP BY IT.intLotId
	,IT.intTransactionId
