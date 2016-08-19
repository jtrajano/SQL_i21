CREATE PROCEDURE uspMFGetYieldConfigDetail (
	@intManufacturingProcessId INT
	,@intUserId INT
	)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @intYieldId INT

	SELECT @intYieldId = intYieldId
	FROM dbo.tblMFYield
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	IF @intYieldId IS NULL
	BEGIN
		INSERT INTO dbo.tblMFYield (
			intManufacturingProcessId
			,strInputFormula
			,strOutputFormula
			,strYieldFormula
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			,intConcurrencyId
			)
		SELECT @intManufacturingProcessId
			,'Input+Opening Quantity'
			,'Output+Output Opening Quantity+Output Count Quantity+Count Quantity'
			,'Output/Input'
			,@intUserId
			,GetDate()
			,@intUserId
			,GetDate()
			,1

		SELECT @intYieldId = intYieldId
		FROM dbo.tblMFYield
		WHERE intManufacturingProcessId = @intManufacturingProcessId

		INSERT INTO tblMFYieldDetail (
			intYieldId
			,intYieldTransactionId
			,ysnSelect
			)
		SELECT @intYieldId
			,intYieldTransactionId
			,1
		FROM tblMFYieldTransaction
		WHERE strYieldTransactionName IN (
				'Input'
				,'Output'
				,'Output Opening Quantity'
				,'Output Count Quantity'
				,'Opening Quantity'
				,'Count Quantity'
				)
		
		UNION
		
		SELECT @intYieldId
			,intYieldTransactionId
			,0
		FROM tblMFYieldTransaction
		WHERE strYieldTransactionName IN (
				'Empty Out Adj'
				,'Cycle Count Adj'
				,'Queued Qty Adj'
				)
	END

	SELECT intYieldId
		,intManufacturingProcessId
		,strInputFormula
		,strOutputFormula
		,strYieldFormula
		,intConcurrencyId
	FROM dbo.tblMFYield
	WHERE intYieldId = @intYieldId

	SELECT ISNULL(@intYieldId, 0) AS intYieldId
		,CASE 
			WHEN ysnProcessRelated = 1
				THEN 'Process Related'
			ELSE 'Non-Process Related'
			END AS strGroupName
		,strYieldTransactionName AS strTransactionName
		,CASE 
			WHEN ysnInputTransaction = 1
				THEN 'Input'
			ELSE 'Output'
			END AS strSection
		,YT.intYieldTransactionId
		,ISNULL(YD.ysnSelect, 0) AS ysnSelect
		,Convert(bit,CASE 
			WHEN YT.strYieldTransactionName IN (
					'Empty Out Adj'
					,'Cycle Count Adj'
					,'Queued Qty Adj'
					)
				THEN 0
			ELSE 1
			END) ysnLock
	FROM dbo.tblMFYieldTransaction YT
	LEFT JOIN dbo.tblMFYieldDetail YD ON YD.intYieldTransactionId = YT.intYieldTransactionId
		AND intYieldId = @intYieldId
END
