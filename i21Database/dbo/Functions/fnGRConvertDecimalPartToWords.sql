CREATE FUNCTION [dbo].[fnGRConvertDecimalPartToWords]
(
	@Amount DECIMAL(24, 10)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @COUNT INT = 1
	DECLARE @str1 NVARCHAR(MAX) = ''
	DECLARE @DecimalPart FLOAT
	DECLARE @DecimalPartString NVARCHAR(50)
	DECLARE @DigitsAfterDecimal INT

	SET @DecimalPart = LTRIM(@Amount - FLOOR(@Amount))	
	SET @DigitsAfterDecimal = LEN(@DecimalPart)

	IF @DecimalPart > 0
	BEGIN
		SET @DigitsAfterDecimal = @DigitsAfterDecimal - CHARINDEX( '.',@DecimalPart)
		SET @DecimalPartString = SUBSTRING(
											 CONVERT(NVARCHAR,@DecimalPart)
											,CHARINDEX( '.',@DecimalPart)+1
											,@DigitsAfterDecimal
										  ) 
		
		WHILE @COUNT <= @DigitsAfterDecimal
		BEGIN
			SET @str1 = @str1 + CASE	
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 0 THEN 'Zero'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 1 THEN 'One'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 2 THEN 'Two'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 3 THEN 'Three'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 4 THEN 'Four'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 5 THEN 'Five'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 6 THEN 'Six'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 7 THEN 'Seven'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 8 THEN 'Eight'
									WHEN SUBSTRING(LTRIM(@DecimalPartString), @COUNT, 1) = 9 THEN 'Nine'
								END 
								+ ' '
						 
			SET @COUNT = @COUNT + 1
		END
	END
		
	RETURN @str1
END