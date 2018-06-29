CREATE VIEW vyuMFLotStatus
AS
SELECT intLotStatusId
	,strSecondaryStatus
	,strDescription
	,strPrimaryStatus
FROM tblICLotStatus
WHERE intLotStatusId NOT IN (
		SELECT intLotStatusId
		FROM tblMFLotStatusException
		)
