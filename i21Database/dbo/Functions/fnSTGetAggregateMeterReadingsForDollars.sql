CREATE FUNCTION [dbo].[fnSTGetAggregateMeterReadingsForDollars] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,2)
AS BEGIN

    DECLARE @dblAggregateMeterReadingsForDollars DECIMAL(18,2) = 0

    SELECT		@dblAggregateMeterReadingsForDollars = ISNULL(SUM(dblAmount),0)
    FROM        tblSTCheckoutPumpTotals
    WHERE		intCheckoutId = @intCheckoutId

    RETURN @dblAggregateMeterReadingsForDollars
END