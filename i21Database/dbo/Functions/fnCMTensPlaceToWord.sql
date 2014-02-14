
CREATE FUNCTION fnCMTensPlaceToWord(@dblAmount AS NUMERIC(9, 2))
RETURNS	NVARCHAR(2000)
AS
BEGIN

DECLARE @strReturnValue AS NVARCHAR(2000)
DECLARE @intPlaceHolder AS INT
DECLARE @strAmountChild AS NVARCHAR(50)

IF @dblAmount > 99 or @dblAmount < 0 RETURN ''

SET @intPlaceHolder = @dblAmount / 10
IF @dblAmount < 10
	SELECT @strReturnValue = dbo.fnCMOnesPlaceToWord(@dblAmount)
ELSE IF @intPlaceHolder = 1
BEGIN
	SELECT @strReturnValue =	CASE WHEN @dblAmount = 10 THEN 'Ten'
									 WHEN @dblAmount = 11 THEN 'Eleven'
									 WHEN @dblAmount = 12 THEN 'Twelve'
									 WHEN @dblAmount = 13 THEN 'Thirteen'
									 WHEN @dblAmount = 14 THEN 'Fourteen'
									 WHEN @dblAmount = 15 THEN 'Fifteen'
									 WHEN @dblAmount = 16 THEN 'Sixteen'
									 WHEN @dblAmount = 17 THEN 'Seventeen'
									 WHEN @dblAmount = 18 THEN 'Eighteen'
									 WHEN @dblAmount = 19 THEN 'Nineteen'									 
								END
END
ELSE
BEGIN
	SELECT @strReturnValue =	CASE WHEN @intPlaceHolder = 2 THEN 'Twenty'
									 WHEN @intPlaceHolder = 3 THEN 'Thirty'
									 WHEN @intPlaceHolder = 4 THEN 'Forty'
									 WHEN @intPlaceHolder = 5 THEN 'Fifty'
									 WHEN @intPlaceHolder = 6 THEN 'Sixty'
									 WHEN @intPlaceHolder = 7 THEN 'Seventy'
									 WHEN @intPlaceHolder = 8 THEN 'Eighty'
									 WHEN @intPlaceHolder = 9 THEN 'Ninety'
								END	
	SET @intPlaceHolder = @dblAmount - (10 * @intPlaceHolder)
	SELECT @strAmountChild = dbo.fnCMOnesPlaceToWord(@intPlaceHolder)
	IF @strAmountChild <> '' SELECT @strReturnValue = @strReturnValue + '-' + @strAmountChild 	
END

EXIT_FN:
RETURN @strReturnValue

END