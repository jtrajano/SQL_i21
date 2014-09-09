

CREATE FUNCTION [dbo].[fnGetItemCostingMethod](
	@intItemId int
)
RETURNS INT
AS
BEGIN 
	DECLARE @intCostingMethodId AS INT 
	SELECT @intCostingMethodId = intCostingMethodId FROM tblICItem

	RETURN @intCostingMethodId
END 