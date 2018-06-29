CREATE PROCEDURE uspWHMBLGetTaskCountByTruck 
		@strTruckNo NVARCHAR(100)
AS
BEGIN
	DECLARE @tbl TABLE (SlNo INT, TaskCount INT)

	INSERT INTO @tbl
	SELECT 1 SlNo, COUNT(*) AS TaskCount
	FROM tblWHOrderHeader oh
	JOIN tblWHTruck tr ON tr.intTruckId = oh.intTruckId
	JOIN tblWHTask tsk ON tsk.strTaskNo = oh.strBOLNo
	JOIN tblWHSKU s ON s.intSKUId = tsk.intSKUId
	JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
	JOIN tblWHTaskType tt ON tt.intTaskTypeId = tsk.intTaskTypeId
	WHERE tt.strInternalCode = 'Load'
		AND tr.strTruckNo = @strTruckNo
	
	UNION ALL
	
	SELECT 1 SlNo, COUNT(*) AS TaskCount
	FROM tblWHOrderHeader oh
	JOIN tblWHTruck tr ON tr.intTruckId = oh.intTruckId
	JOIN tblWHTask tsk ON tsk.strTaskNo = oh.strBOLNo
	JOIN tblWHSKU s ON s.intSKUId = tsk.intSKUId
	JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
	JOIN tblWHTaskType tt ON tt.intTaskTypeId = tsk.intTaskTypeId
	WHERE tt.strInternalCode = 'SHIP'
		AND tr.strTruckNo = @strTruckNo

	SELECT *
	FROM (
		SELECT SlNo, TaskCount, 'TaskCount' + cast(row_number() OVER (
					PARTITION BY SlNo ORDER BY SlNo
					) AS VARCHAR(10)) rn
		FROM @tbl
		) src
	Pivot(Max(TaskCount) FOR rn IN (
				TaskCount1
				,TaskCount2
				)) Piv
END