CREATE FUNCTION [dbo].[fnSTGetSalesRestriction] 
(
	@intItemId AS INT,
	@intLocationId AS INT
)
RETURNS INT
AS BEGIN

	--All will get from Category Level aside from Open Price PLU
	DECLARE @intReturnSalesRestriction INT

	SELECT	@intReturnSalesRestriction = 
		(CASE WHEN CL.ysnIdRequiredLiquor = 1 THEN 4 WHEN CL.ysnIdRequiredCigarette = 1 THEN 2 ELSE 0 END) + 
		(CASE WHEN CL.ysnFoodStampable = 1 THEN 4096 ELSE 2048 END) + 
		(CASE WHEN IL.ysnOpenPricePLU = 1 THEN 128 ELSE 0 END)
	FROM tblICItem I
	JOIN tblICItemLocation IL
		ON I.intItemId = IL.intItemId
	JOIN tblICCategoryLocation CL
		ON I.intCategoryId = CL.intCategoryId
	WHERE I.intItemId = @intItemId 
	AND IL.intLocationId = @intLocationId
	AND CL.intLocationId = @intLocationId

	/*
		Note: Values for non-related restrictions may be combined. However, there can only be one "Age Limit" and
				one "Tender Restriction" present.

		Page 216 of RPOS NAXML Maintenance Imports - Interface Specification
	*/


	RETURN	@intReturnSalesRestriction
END