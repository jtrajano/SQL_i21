CREATE function dbo.fnSTConvertUPCeToUPCa
( 
	@strUPCe varchar(13)
)
RETURNS NVARCHAR(14)
AS
BEGIN

--DECLARE @strUPCe AS NVARCHAR(7) = '112067'

-- SOURCE: http://www.taltech.com/files/UPC.vb
-- To Validate: http://www.taltech.com/barcodesoftware/symbologies/upc

DECLARE @strManufacturerNumber AS NVARCHAR(5)
DECLARE @strItemNumber AS NVARCHAR(5)
DECLARE @strUPCa AS NVARCHAR(14)

-- Validate if UPCe is numeric
IF(@strUPCe NOT LIKE '%[^0-9]%')
	BEGIN
		-- Validate if length is equal to 6
		IF(LEN(@strUPCe) = 6)
			BEGIN
				DECLARE @strDigit1 AS NVARCHAR(1) = SUBSTRING(@strUPCe, 1, 1)
				DECLARE @strDigit2 AS NVARCHAR(1) = SUBSTRING(@strUPCe, 2, 1)
				DECLARE @strDigit3 AS NVARCHAR(1) = SUBSTRING(@strUPCe, 3, 1)
				DECLARE @strDigit4 AS NVARCHAR(1) = SUBSTRING(@strUPCe, 4, 1)
				DECLARE @strDigit5 AS NVARCHAR(1) = SUBSTRING(@strUPCe, 5, 1)
				DECLARE @strDigit6 AS NVARCHAR(1) = SUBSTRING(@strUPCe, 6, 1)

				IF(@strDigit6 = '0' OR @strDigit6 = '1' OR @strDigit6 = '2')
					BEGIN
						SET @strManufacturerNumber = @strDigit1 + @strDigit2 + @strDigit6 + '00'
						SET @strItemNumber = '00' + @strDigit3 + @strDigit4 + @strDigit5
					END
				ELSE IF(@strDigit6 = '3')
					BEGIN
						SET @strManufacturerNumber = @strDigit1 + @strDigit2 + @strDigit3 + '00'
						SET @strItemNumber = '000' + @strDigit4 + @strDigit5
					END
				ELSE IF(@strDigit6 = '4')
					BEGIN
						SET @strManufacturerNumber = @strDigit1 + @strDigit2 + @strDigit3 + @strDigit4 + '0'
						SET @strItemNumber = '0000' + @strDigit5
					END
				ELSE
					BEGIN
						SET @strManufacturerNumber = @strDigit1 + @strDigit2 + @strDigit3 + @strDigit4 + @strDigit5
						SET @strItemNumber = '0000' + @strDigit6
					END

				SET @strUPCa = '0' + @strManufacturerNumber + @strItemNumber
				--PRINT @strUPCa
			END
		ELSE
			BEGIN
				SET @strUPCa = @strUPCe
				--PRINT 'Wrong size UPCE message'
			END		
	END
ELSE
	BEGIN
		SET @strUPCa = @strUPCe
		--PRINT 'UPC Codes must contain Numeric Data Only!'
	END
	

RETURN @strUPCa
END