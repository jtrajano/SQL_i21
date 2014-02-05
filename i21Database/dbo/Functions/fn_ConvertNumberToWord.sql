
CREATE FUNCTION fn_ConvertNumberToWord(@dblAmount AS NUMERIC(38, 2))	
RETURNS NVARCHAR(4000)
AS
BEGIN 

DECLARE @strReturnValue NVARCHAR(4000)
		,@isNegativeNumber BIT = 0
		
SET @strReturnValue = '' 

IF @dblAmount < 0 
BEGIN 
	SET @dblAmount = ABS(@dblAmount)
	SET @isNegativeNumber = 1
END 


-- INVALID DATA RANGE, GOTO EXIT_SP BLANK
IF @dblAmount > 100000000000000.00 OR @dblAmount < 0.00 RETURN @strReturnValue

DECLARE @intPlaceHolder AS NUMERIC(9, 2)
DECLARE @strAmountChild AS VARCHAR(2000)
DECLARE @intReplicateCount AS INT 
DECLARE @dblHigherPlace AS NUMERIC(9, 2)
DECLARE @dblLowerPlace AS NUMERIC(9, 2)

IF @dblAmount = 0 SET @strReturnValue = 'Zero'

-- TRILLION 
--SET @intPlaceHolder = CAST(@dblAmount AS INT) / 1000000000000
SET @intPlaceHolder = cast((CAST(@dblAmount AS numeric(38,0)) / 1000000000000) as INT)
SET @dblAmount = @dblAmount - (@intPlaceHolder * 1000000000000)
SELECT @strAmountChild = dbo.fn_HundredsPlaceToWord(@intPlaceHolder)
IF @strAmountChild <> '' 
	BEGIN
		SET @strReturnValue = @strAmountChild + 'Trillion'
	END
SET @strAmountChild = ''

-- BILLION 
-- SET @intPlaceHolder = CAST(@dblAmount AS INT) / 1000000000
 SET @intPlaceHolder = cast( (CAST(@dblAmount AS numeric(38,0)) / 1000000000) as INT)

SET @dblAmount = @dblAmount - (@intPlaceHolder * 1000000000) 
SELECT @strAmountChild = dbo.fn_HundredsPlaceToWord(@intPlaceHolder)
IF @strAmountChild <> '' 
	BEGIN
		SET @strReturnValue = ' ' + @strReturnValue + ' ' + @strAmountChild + ' Billion'
	END
SET @strAmountChild = ''

-- MILLION
--SET @intPlaceHolder = CAST(@dblAmount AS INT) / 1000000
SET @intPlaceHolder = cast((CAST(@dblAmount AS numeric(38,0)) / 1000000) as INT)
SET @dblAmount = @dblAmount - (@intPlaceHolder * 1000000)
SELECT @strAmountChild = dbo.fn_HundredsPlaceToWord(@intPlaceHolder)
IF @strAmountChild <> ''
	BEGIN 
		SET @strReturnValue = ' ' + @strReturnValue + ' ' + @strAmountChild + ' Million'
	END
SET @strAmountChild = ''

-- THOUSAND
-- SET @intPlaceHolder = CAST(@dblAmount AS INT) / 1000
SET @intPlaceHolder = cast( (CAST(@dblAmount AS float) / 1000) as INT)
SET @dblAmount = @dblAmount - (@intPlaceHolder * 1000)
SELECT @strAmountChild = dbo.fn_HundredsPlaceToWord(@intPlaceHolder)
IF @strAmountChild <> '' 
	BEGIN
		SET @strReturnValue = ' ' + @strReturnValue + ' ' + @strAmountChild +  ' Thousand'
	END
SET @strAmountChild = ''

-- HUNDREDS
--SET @intPlaceHolder = CAST(@dblAmount AS INT) / 1
SET @intPlaceHolder = cast((CAST(@dblAmount AS INT) / 1) as INT)
SET @dblAmount = @dblAmount - @intPlaceHolder
SELECT @strAmountChild = dbo.fn_HundredsPlaceToWord(@intPlaceHolder)
IF @strAmountChild <> '' 
	BEGIN
		SET @strReturnValue = ' ' + @strReturnValue + ' ' + @strAmountChild 
	END
SET @strAmountChild = ''

-- DECIMAL PLACES
DECLARE @intDecimalPlace AS INT
DECLARE @strDecimal AS NVARCHAR(4)
SET @intDecimalPlace = @dblAmount * 100
SET @strDecimal = CAST(@intDecimalPlace AS NVARCHAR(4))
IF @intDecimalPlace < 10 
	BEGIN SET @strDecimal = '0' + CAST(@intDecimalPlace AS NVARCHAR(2)) END
SET @strReturnValue = @strReturnValue  + ' and ' + @strDecimal + '/100'

-- CHECK IF NUMBER IS NEGATIVE
IF @isNegativeNumber = 1
BEGIN 
	SET @strReturnValue =  'Negative ' + LTRIM(RTRIM(@strReturnValue))
END

SET @strReturnValue = LTRIM(RTRIM(@strReturnValue))

SET @strReturnValue = @strReturnValue 
SET @intReplicateCount = LEN(@strReturnValue)
SET @strReturnValue = @strReturnValue + REPLICATE(' *', (250 - @intReplicateCount) / 2)

RETURN @strReturnValue
END