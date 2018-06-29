CREATE PROCEDURE uspMFGetAttributeByAttributeName (
	@intManufacturingProcessId INT
	,@intLocationId INT
	,@strAttributeName NVARCHAR(50)
	,@strAttributeValue NVARCHAR(MAX) OUTPUT
	)
AS
BEGIN
	SELECT @strAttributeValue = PA.strAttributeValue
	FROM dbo.tblMFManufacturingProcess MP
	JOIN dbo.tblMFManufacturingProcessAttribute PA ON PA.intManufacturingProcessId = MP.intManufacturingProcessId
	JOIN dbo.tblMFAttribute A ON PA.intAttributeId = A.intAttributeId
	WHERE MP.intManufacturingProcessId = @intManufacturingProcessId
		AND PA.intLocationId = @intLocationId
		AND A.strAttributeName = @strAttributeName

	IF @strAttributeValue IS NULL
		SELECT @strAttributeValue = ''
END
