CREATE FUNCTION [dbo].[fnARIsItemTermDiscountExempt]
(
	 @ItemId					INT
	,@LocationId				INT
	,@TransactionDate			DATETIME
)
RETURNS BIT
AS
BEGIN

IF EXISTS	(
			SELECT TOP 1 NULL
			FROM
				tblICItemSpecialPricing ICISP
			INNER  JOIN
				tblICItemLocation ICIL
					ON ICISP.intItemLocationId = ICIL.intItemLocationId
			WHERE
				ISNULL(ICISP.strPromotionType, '') <> ''
				AND ICISP.strPromotionType = 'Terms Discount Exempt'
				AND ICISP.intItemId = @ItemId 
				AND (ICIL.intLocationId = @LocationId OR ICIL.intLocationId IS NULL)
				AND CAST(@TransactionDate AS DATE) BETWEEN CAST(ICISP.dtmBeginDate AS DATE) AND CAST(ISNULL(ICISP.dtmEndDate,@TransactionDate) AS DATE)
			)
	RETURN CAST(1 AS BIT)
ELSE
	RETURN CAST(0 AS BIT)
	
RETURN CAST(0 AS BIT)
END
