
/*
 Converts a Foreign Credit into a Functional Credit value

 fnGetCreditFunctional is a function that converts a value to positive and returns it if value is negative. 
 Otherwise if value is positive, it will return zero.

 Note: Table-Valued functions works better than scalar functions
 See: https://www.captechconsulting.com/blog/jennifer-kenney/performance-considerations-user-defined-functions-sql-server-2012
*/

CREATE FUNCTION [dbo].[fnGetCreditFunctional] (
	@value AS NUMERIC(18,6)
	,@intCurrencyId AS INT
	,@intFunctionalCurrencyId AS INT 
	,@forexRate AS NUMERIC(38, 20)
)
RETURNS TABLE 
AS 

RETURN 
SELECT Value = 
		CASE 
			WHEN ISNULL(@intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(@forexRate, 0) <> 0 THEN 
				ROUND(CASE WHEN @value < 0 THEN ABS(@value) * @forexRate ELSE 0 END, 2) 			
			WHEN ISNULL(@intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId THEN 
				ROUND(CASE WHEN @value < 0 THEN ABS(@value) ELSE 0 END, 2) 
			ELSE
				0 -- ROUND(CASE WHEN @value < 0 THEN ABS(@value) ELSE 0 END, 2) 
		END 
