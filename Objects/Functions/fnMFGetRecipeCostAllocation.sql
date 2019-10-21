CREATE FUNCTION dbo.fnMFGetRecipeCostAllocation (@strWorkOrderNo NVARCHAR(50))
RETURNS @returntable TABLE (
	intItemId INT NOT NULL
	,dblCostAllocation NUMERIC(18, 6) NULL
	)
AS
BEGIN
	DECLARE @intWorkOrderId INT

	SELECT @intWorkOrderId = intWorkOrderId
	FROM tblMFWorkOrder
	WHERE strWorkOrderNo = @strWorkOrderNo

	INSERT INTO @returntable (
		intItemId
		,dblCostAllocation
		)
	SELECT intItemId = intItemId
		,dblCostAllocation = dblPercentage
	FROM tblMFWorkOrderRecipeItem
	WHERE intRecipeItemTypeId = 2
		AND intWorkOrderId = @intWorkOrderId

	RETURN
END