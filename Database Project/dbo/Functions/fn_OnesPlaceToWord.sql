
CREATE FUNCTION fn_OnesPlaceToWord(@dblAmount AS NUMERIC(9, 2))
RETURNS NVARCHAR(2000) 
AS
BEGIN 

DECLARE @strReturnValue AS NVARCHAR(2000)
SET @strReturnValue = ''
SELECT @strReturnValue = CASE	WHEN @dblAmount = 1 THEN 'One'
								WHEN @dblAmount = 2 THEN 'Two'
								WHEN @dblAmount = 3 THEN 'Three'
								WHEN @dblAmount = 4 THEN 'Four'
								WHEN @dblAmount = 5 THEN 'Five'
								WHEN @dblAmount = 6 THEN 'Six'
								WHEN @dblAmount = 7 THEN 'Seven'
								WHEN @dblAmount = 8 THEN 'Eight'
								WHEN @dblAmount = 9 THEN 'Nine'
						 END
RETURN @strReturnValue
END
