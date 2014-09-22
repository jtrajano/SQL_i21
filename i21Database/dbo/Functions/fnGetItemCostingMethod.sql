

CREATE FUNCTION [dbo].[fnGetItemCostingMethod](
	@intItemId int
)
RETURNS INT
AS
BEGIN 
	--Removed routine, costing method which used to be Item Level configuration is now location level config..
	--DECLARE @intCostingMethodId AS INT 
	--SELECT @intCostingMethodId = intCostingMethodId FROM tblICItem

	--RETURN @intCostingMethodId
	RETURN 0
END 