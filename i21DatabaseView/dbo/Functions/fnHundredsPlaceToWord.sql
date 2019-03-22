
CREATE FUNCTION fnHundredsPlaceToWord(@dblAmount AS NUMERIC(9, 2))
RETURNS NVARCHAR(2000)
AS
BEGIN 

DECLARE @strReturnValue AS NVARCHAR(2000)
DECLARE @intPlaceHolder AS INT
DECLARE @strAmountChild AS NVARCHAR(2000)

IF @dblAmount > 999 or @dblAmount < 0 RETURN ''

-- Get the Hundreds Place
SET @intPlaceHolder = @dblAmount / 100 

IF @dblAmount < 100 
	BEGIN
		SET @intPlaceHolder = @dblAmount 
		SELECT @strAmountChild = dbo.fnTensPlaceToWord(@intPlaceHolder)
		IF @strAmountChild <> '' SELECT @strReturnValue = @strAmountChild		
	END
ELSE
BEGIN
	BEGIN
		SELECT @strReturnValue = CASE	WHEN @intPlaceHolder = 1 THEN 'One Hundred'
										WHEN @intPlaceHolder = 2 THEN 'Two Hundred'
										WHEN @intPlaceHolder = 3 THEN 'Three Hundred'
										WHEN @intPlaceHolder = 4 THEN 'Four Hundred'
										WHEN @intPlaceHolder = 5 THEN 'Five Hundred'
										WHEN @intPlaceHolder = 6 THEN 'Six Hundred'
										WHEN @intPlaceHolder = 7 THEN 'Seven Hundred'
										WHEN @intPlaceHolder = 8 THEN 'Eight Hundred'
										WHEN @intPlaceHolder = 9 THEN 'Nine Hundred'
								END
		SET @intPlaceHolder = @dblAmount - (100 * @intPlaceHolder)
		SELECT @strAmountChild = dbo.fnTensPlaceToWord(@intPlaceHolder)
		IF @strAmountChild <> '' SET @strReturnValue = @strReturnValue + ' ' + @strAmountChild				
	END
END

RETURN @strReturnValue

END