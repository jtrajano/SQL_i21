CREATE VIEW vyuMFShiftActivityWastageTotal
AS
SELECT intShiftActivityId
	,SUM(dblNetWeight) AS dblTotalNetWeight
	,intWastageTypeId
FROM tblMFWastage
GROUP BY intWastageTypeId
	,intShiftActivityId
