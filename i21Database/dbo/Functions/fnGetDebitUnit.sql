
/*
 fnGetDebit is a function that returns the same value if it is positive or zero if value is negative. 

 Note: Table-Valued functions works better than scalar functions
 See: https://www.captechconsulting.com/blog/jennifer-kenney/performance-considerations-user-defined-functions-sql-server-2012
*/

CREATE FUNCTION [dbo].[fnGetDebitUnit] (
	@value AS NUMERIC(38, 20)
)
RETURNS TABLE 
AS 

RETURN 
SELECT Value = ROUND(CASE WHEN @value > 0 THEN @value ELSE 0 END, 6) 
