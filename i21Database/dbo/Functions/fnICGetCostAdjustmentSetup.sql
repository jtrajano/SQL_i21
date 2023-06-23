/*
	Create a centralized function to retrieve the cost adjustment setup
	
	-------------------------------------------------------------------------------------------------------------------------
	Cost Adjustment Types:
	-------------------------------------------------------------------------------------------------------------------------
	1. DETAILED  
		It will escalate the cost adjustment downstream like when the raw material is produced. 
		The produced item is also adjusted. 
	
	2. SUMMARIZED 
		It will only adjust the cost where it is directly related. 
		Those stocks indirectly related are not adjusted. 
		For Example:
			Raw material is used in a transfer. After the transfer it is consumed to produce another item. 
			Cost adjustment will be on the transfer only. It will not adjust the consume and produce valuation. 
*/
CREATE FUNCTION fnICGetCostAdjustmentSetup (
  @intItemId INT = NULL,
  @intItemLocationId INT = NULL  
)
RETURNS TINYINT 
AS 
BEGIN 
	DECLARE @costAdjustmentType_DETAILED AS TINYINT = 1
			,@costAdjustmentType_SUMMARIZED AS TINYINT = 2
			,@costAdjustmentType_RETROACTIVE_DETAILED AS TINYINT = 3
			,@costAdjustmentType_RETROACTIVE_SUMMARIZED AS TINYINT = 4
			,@costAdjustmentType_CURRENT_AVG AS TINYINT = 5
			,@intCostAdjustmentType AS TINYINT

	SELECT 		
		@intCostAdjustmentType = 
			CASE 
				WHEN il.intLocationId IS NULL THEN 
					@costAdjustmentType_DETAILED -- Default In-transit location as Detailed. 

				WHEN il.intCostingMethod = 1 THEN 
					CASE 
						WHEN il.intCostAdjustmentType = @costAdjustmentType_SUMMARIZED THEN @costAdjustmentType_RETROACTIVE_SUMMARIZED
						WHEN il.intCostAdjustmentType = @costAdjustmentType_DETAILED THEN @costAdjustmentType_RETROACTIVE_DETAILED
						ELSE 
							ISNULL(il.intCostAdjustmentType, @costAdjustmentType_RETROACTIVE_SUMMARIZED)
					END 
				ELSE 
					ISNULL(il.intCostAdjustmentType, @costAdjustmentType_SUMMARIZED)					
			END 
	FROM 
		tblICItemLocation il
	WHERE 
		il.intItemId = @intItemId
		AND il.intItemLocationId = @intItemLocationId 

	RETURN ISNULL(@intCostAdjustmentType, @costAdjustmentType_SUMMARIZED) -- If there is no setup, default it to Summarized
END 