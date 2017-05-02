
/*
 fnSMGetForexRate is a function that exchange rate of a currency based on the supplied forex rate type and transaction date. 

 Note: Table-Valued functions works better than scalar functions
 See: https://www.captechconsulting.com/blog/jennifer-kenney/performance-considerations-user-defined-functions-sql-server-2012
*/

CREATE FUNCTION [dbo].[fnSMGetForexRate] (
	@intCurrencyId AS INT 
	,@intForexRateTypeId AS INT
	,@dtmDate AS DATETIME
)
RETURNS TABLE 
AS 

RETURN 
	SELECT TOP 1 
		[dblRate]
		,[intCurrencyExchangeRateDetailId] 
	FROM 
		[vyuSMForex] 
	WHERE 
		[intFromCurrencyId] = @intCurrencyId 
		AND [intCurrencyExchangeRateTypeId] = @intForexRateTypeId 
		AND [intFunctionalCurrencyId] = [intToCurrencyId] 
		AND dbo.fnDateLessThanEquals(dtmValidFromDate, @dtmDate) = 1
	ORDER BY
		[dtmValidFromDate] 
