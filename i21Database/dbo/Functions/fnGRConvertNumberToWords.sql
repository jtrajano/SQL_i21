CREATE FUNCTION [dbo].[fnGRConvertNumberToWords]
(
	@Amount DECIMAL(24, 10)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Ones TABLE 
	(
		 Id INT
		,NAME NVARCHAR(50)
	)
	DECLARE @Decades TABLE 
	(
		 Id INT
		,NAME NVARCHAR(50)
	)

	INSERT INTO @Ones 
	(
		 Id
		,NAME
	)
	SELECT 0,''	
	UNION	
	SELECT 1,'One'	
	UNION	
	SELECT 2,'Two'	
	UNION	
	SELECT 3,'Three'
	UNION
	SELECT 4,'Four'
	UNION
	SELECT 5,'Five'
	UNION
	SELECT 6,'Six'
	UNION
	SELECT 7,'Seven'
	UNION
	SELECT 8,'Eight'
	UNION
	SELECT 9,'Nine'
	UNION
	SELECT 10,'Ten'
	UNION
	SELECT 11,'Eleven'
	UNION
	SELECT 12,'Twelve'
	UNION	
	SELECT 13,'Thirteen'
	UNION
	SELECT 14,'Forteen'
	UNION
	SELECT 15,'Fifteen'
	UNION
	SELECT 16,'Sixteen'
	UNION
	SELECT 17,'Seventeen'
	UNION
	SELECT 18,'Eighteen'
	UNION
	SELECT 19,'Nineteen'

	INSERT INTO @Decades 
	(
		 Id
		,NAME
	)
	SELECT 20,'Twenty'
	UNION
	SELECT 30,'Thirty'
	UNION
	SELECT 40,'Forty'
	UNION
	SELECT 50,'Fifty'
	UNION
	SELECT 60,'Sixty'
	UNION
	SELECT 70,'Seventy'
	UNION
	SELECT 80,'Eighty'
	UNION
	SELECT 90,'Ninety'

	DECLARE @str NVARCHAR(max)

	SET @Amount = FLOOR(@Amount)
	SET @str = ''

	IF (@Amount >= 1 AND @Amount < 20)
		SET @str = @str + (
							SELECT NAME
							FROM @Ones
							WHERE Id = @Amount
						  )

	IF (@Amount >= 20 AND @Amount <= 99)
		SET @str = @str + (
							SELECT NAME
							FROM @Decades
							WHERE Id = (@Amount - @Amount % 10)
						  ) + ' ' + 
						  (
							SELECT NAME
							FROM @Ones
							WHERE Id = (@Amount % 10)
						  ) + ' '

	IF (@Amount >= 100 AND @Amount <= 999)
		SET @str = @str + dbo.NumberToWords(@Amount / 100) + ' Hundred ' + dbo.NumberToWords(@Amount % 100)

	IF (@Amount >= 1000 AND @Amount <= 99999)
		SET @str = @str + dbo.NumberToWords(@Amount / 1000) + ' Thousand ' + dbo.NumberToWords(@Amount % 1000)

	IF (@Amount >= 100000 AND @Amount <= 9999999)
		SET @str = @str + dbo.NumberToWords(@Amount / 100000) + ' Lac ' + dbo.NumberToWords(@Amount % 100000)

	IF (@Amount >= 10000000)
		SET @str = @str + dbo.NumberToWords(@Amount / 10000000) + ' Crore ' + dbo.NumberToWords(@Amount % 10000000)
	
	RETURN @str
END
