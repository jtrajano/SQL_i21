CREATE FUNCTION [dbo].[fnGRConvertQuantityToTargetCommodityUOM]
(
	@intCommodityUOMIdFrom INT,
	@intCommodityUOMIdTo INT,
	@dblQty NUMERIC(38,20)
)
RETURNS TABLE
AS RETURN
    SELECT [dblResultQty] = CASE
                                WHEN ISNULL(CUOM_FROM.dblUnitQty, 0) = 0 OR ISNULL(CUOM_TO.dblUnitQty, 0) = 0
                                    THEN NULL
                                WHEN CUOM_FROM.dblUnitQty = CUOM_TO.dblUnitQty
                                    THEN @dblQty
                                WHEN CUOM_TO.dblUnitQty <> 0
                                    THEN CAST((@dblQty * CUOM_FROM.dblUnitQty) AS NUMERIC(38,20)) / CUOM_TO.dblUnitQty							
                                ELSE
                                    NULL 
                            END
    FROM tblICCommodityUnitMeasure CUOM_FROM
    INNER JOIN tblICCommodityUnitMeasure CUOM_TO ON CUOM_TO.intCommodityUnitMeasureId = @intCommodityUOMIdTo
    WHERE CUOM_FROM.intCommodityUnitMeasureId = @intCommodityUOMIdFrom
GO