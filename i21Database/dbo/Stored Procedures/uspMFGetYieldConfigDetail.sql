CREATE PROCEDURE uspMFGetYieldConfigDetail (@intManufacturingProcessId INT)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @intYieldId INT

	SELECT @intYieldId = intYieldId
	FROM dbo.tblMFYield
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	SELECT intYieldId
		,intManufacturingProcessId
		,strInputFormula
		,strOutputFormula
		,strYieldFormula
		,intConcurrencyId
	FROM dbo.tblMFYield
	WHERE intYieldId = @intYieldId

	SELECT CASE 
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
		,Convert(BIT, CASE 
				WHEN YD.intYieldTransactionId IS NULL
					THEN 0
				ELSE 1
				END) AS ysnSelect
	FROM dbo.tblMFYieldTransaction YT
	LEFT JOIN dbo.tblMFYieldDetail YD ON YD.intYieldTransactionId = YT.intYieldTransactionId
		AND intYieldId = @intYieldId
END
