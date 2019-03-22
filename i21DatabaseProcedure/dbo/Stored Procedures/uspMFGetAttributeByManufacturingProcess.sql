CREATE PROCEDURE uspMFGetAttributeByManufacturingProcess (
	@intManufacturingProcessId INT
	,@intLocationId INT
	)
AS
BEGIN
	SELECT MP.strProcessName
		,A.strAttributeName
		,PA.strAttributeValue
	FROM dbo.tblMFManufacturingProcess MP
	JOIN dbo.tblMFManufacturingProcessAttribute PA ON PA.intManufacturingProcessId = MP.intManufacturingProcessId
	JOIN dbo.tblMFAttribute A ON PA.intAttributeId = A.intAttributeId
	WHERE MP.intManufacturingProcessId = @intManufacturingProcessId
		AND PA.intLocationId = @intLocationId
END