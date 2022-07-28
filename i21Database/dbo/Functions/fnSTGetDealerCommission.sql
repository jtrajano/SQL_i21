CREATE FUNCTION [dbo].[fnSTGetDealerCommission] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,2)
AS BEGIN

    DECLARE     @dblDealerCommission DECIMAL(18,2) = 0

    SELECT		@dblDealerCommission = ISNULL(SUM(dblCommissionAmount),0)
	FROM		tblSTCheckoutDealerCommission
	WHERE		intCheckoutId = @intCheckoutId

    RETURN      @dblDealerCommission
END