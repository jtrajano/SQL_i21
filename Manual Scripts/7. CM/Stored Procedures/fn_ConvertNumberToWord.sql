/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: August 17, 2006
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  fn_ConvertNumberToWord
   Description		   :  Converts a currency number to word. 
   Last Modified By    : 1. 
                         2.
                         :
                         :
                         n.

   Last Modified Date  : 1. 
                         2. 
                         :
                         :
                         n.

   Synopsis            : 1. 
                         2. 
                         :
                         :
                         n.
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_ConvertNumberToWord') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_ConvertNumberToWord
GO

CREATE FUNCTION fn_ConvertNumberToWord(@dblAmount AS NUMERIC(38, 2))	
RETURNS NVARCHAR(4000)
AS
BEGIN 

DECLARE @strReturnValue AS NVARCHAR(4000)
SET @strReturnValue = '' 

-- INVALid DATA RANGE, GOTO EXIT_SP BLANK
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

SET @strReturnValue = LTRIM(RTRIM(@strReturnValue))

SET @strReturnValue = @strReturnValue 
SET @intReplicateCount = LEN(@strReturnValue)
SET @strReturnValue = @strReturnValue + REPLICATE(' *', (250 - @intReplicateCount) / 2)

RETURN @strReturnValue
END



GO

/*****************************************************************************************************
   Procedure Name	   :	fn_OnesPlaceToWord
   Created By          :	Feb Montefrio
   Created Date        :	August 17, 2006

   Last Modified By    : 	1. 

   Last Modified Date  : 	1. 

   Synopsis            : 	1.  One's place word representation on the amount specified.
								Range is Zero to 100 Trillion
  
 *****************************************************************************************************/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_OnesPlaceToWord') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_OnesPlaceToWord
GO

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
GO


/*****************************************************************************************************
   Procedure Name	   :	fn_TensPlaceToWord
   Created By          :	Feb Montefrio
   Created Date        :	August 17, 2006

   Last Modified By    : 	1. 

   Last Modified Date  : 	1. 

   Synopsis            : 	1.  Ten's Place word representation on the amount specified.
								Range is Zero to 100 Trillion
  
 *****************************************************************************************************/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_TensPlaceToWord') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_TensPlaceToWord
GO

CREATE FUNCTION fn_TensPlaceToWord(@dblAmount AS NUMERIC(9, 2))
RETURNS	NVARCHAR(2000)
AS
BEGIN

DECLARE @strReturnValue AS NVARCHAR(2000)
DECLARE @intPlaceHolder AS INT
DECLARE @strAmountChild AS NVARCHAR(50)

IF @dblAmount > 99 or @dblAmount < 0 RETURN ''

SET @intPlaceHolder = @dblAmount / 10
IF @dblAmount < 10
	SELECT @strReturnValue = dbo.fn_OnesPlaceToWord(@dblAmount)
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
	SELECT @strAmountChild = dbo.fn_OnesPlaceToWord(@intPlaceHolder)
	IF @strAmountChild <> '' SELECT @strReturnValue = @strReturnValue + ' ' + @strAmountChild 	
END

EXIT_FN:
RETURN @strReturnValue

END
GO		

/*****************************************************************************************************
   Procedure Name	   :	fn_HundredsPlaceToWord
   Created By          :	Feb Montefrio
   Created Date        :	August 17, 2006

   Last Modified By    : 	

   Last Modified Date  : 	1. 

   Synopsis            : 	1.  Hundred's Place word representation on the amount specified.
								Range is Zero to 100 Trillion
  
 *****************************************************************************************************/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_HundredsPlaceToWord') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_HundredsPlaceToWord
GO

CREATE FUNCTION fn_HundredsPlaceToWord(@dblAmount AS NUMERIC(9, 2))
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
		SELECT @strAmountChild = dbo.fn_TensPlaceToWord(@intPlaceHolder)
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
		SELECT @strAmountChild = dbo.fn_TensPlaceToWord(@intPlaceHolder)
		IF @strAmountChild <> '' SET @strReturnValue = @strReturnValue + ' ' + @strAmountChild				
	END
END

RETURN @strReturnValue

END
GO