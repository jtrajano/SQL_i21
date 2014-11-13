
/*
 fnGetDebit is a function that converts a value to positive and returns it if value is negative. 
 Otherwise if value is positive, it will return zero.

 Note: Table-Valued functions works better than scalar functions
 See: https://www.captechconsulting.com/blog/jennifer-kenney/performance-considerations-user-defined-functions-sql-server-2012
*/

CREATE FUNCTION [dbo].[fnGetCredit] (
	@value AS NUMERIC(18,6)
)
RETURNS TABLE 
AS 

RETURN 
SELECT Value = CASE WHEN @value < 0 THEN ABS(@value) ELSE 0 END 