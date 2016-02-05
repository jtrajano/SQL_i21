CREATE PROCEDURE uspMFGetYieldConfigDetail (@intManufacturingProcessId INT)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @intYieldId INT

	SELECT @intYieldId = intYieldId
	FROM dbo.tblMFYield
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	IF @intYieldId IS NULL
	BEGIN
		SELECT 0 AS intYieldId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,NULL AS strInputFormula
			,NULL AS strOutputFormula
			,NULL AS strYieldFormula
			,0 AS intConcurrencyId
	END
	ELSE
	BEGIN
		SELECT intYieldId
			,intManufacturingProcessId
			,strInputFormula
			,strOutputFormula
			,strYieldFormula
			,intConcurrencyId
		FROM dbo.tblMFYield
		WHERE intYieldId = @intYieldId
	END

	SELECT ISNULL(@intYieldId,0) AS intYieldId
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
		,YD.ysnSelect
	FROM dbo.tblMFYieldDetail YD
	JOIN dbo.tblMFYieldTransaction YT ON YD.intYieldTransactionId = YT.intYieldTransactionId
		AND intYieldId = @intYieldId
END
