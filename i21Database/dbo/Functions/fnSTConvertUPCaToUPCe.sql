
-- Converts Long UPC (UPC A) to Short UPC (UPC E) 
-- Test: 
/*
SELECT dbo.fnSTConvertUPCaToUPCe('012300000642'), [expected] = '123643'
SELECT dbo.fnSTConvertUPCaToUPCe('042100005264'), [expected] = '425261'
SELECT dbo.fnSTConvertUPCaToUPCe('065100004327'), [expected] = '654321'
SELECT dbo.fnSTConvertUPCaToUPCe('012300000642'), [expected] = '123643'
SELECT dbo.fnSTConvertUPCaToUPCe('01200000134'), [expected] = '121340'
SELECT dbo.fnSTConvertUPCaToUPCe('01200000130'), [expected] = '121300'
SELECT dbo.fnSTConvertUPCaToUPCe('01200081131'), [expected] = NULL
SELECT dbo.fnSTConvertUPCaToUPCe('01200000131'), [expected] = '121310'
*/

CREATE FUNCTION dbo.fnSTConvertUPCaToUPCe
( 
	@strUPCA NVARCHAR(50) -- Long UPC is expected to be 11 characters, without the check digit (last digit). 
)
RETURNS NVARCHAR(50)
AS
BEGIN

DECLARE @strUPCE AS NVARCHAR(50) 

-- If UPC A is less than 12 chars, add prefix of zeroes. 
IF LEN(@strUPCA) < 11
BEGIN 
	SET @strUPCA = '000000000000' + @strUPCA
	SET @strUPCA = SUBSTRING(@strUPCA, LEN(@strUPCA) - 10, 11)
END 

-- Replace the check digit (last digit) with zero to make it 12 or more digits. 
SET @strUPCA = @strUPCA + '0'

-- Validate if UPC A is numeric
IF 
	(@strUPCA NOT LIKE '%[^0-9]%')	
	AND @strUPCA IS NOT NULL 
	AND LEN(@strUPCA) >= 12
BEGIN
	-- Logic derived from https://www.taltech.com/js/UPC.js and https://en.wikipedia.org/wiki/Universal_Product_Code
	-- To verify, use the converter in https://www.morovia.com/education/utility/upc-ean.asp. 
	SET @strUPCE = 
		CASE 
			-- Check if Long UPC begins with zero or one. 
			WHEN SUBSTRING(@strUPCA, 1, 1) NOT IN ('0', '1') THEN NULL

			-- Check if the product codes are between 000 and 999. 
			WHEN CAST(SUBSTRING(@strUPCA, 7, 5) AS INT) > 999 THEN NULL 
			
			-- Check for specific valid chars in the code to convert to Short UPC Code
			WHEN SUBSTRING(@strUPCA, 4, 3) IN ('000' , '100', '200')  THEN 
				SUBSTRING(@strUPCA, 2, 2) + SUBSTRING(@strUPCA, 9, 3) + SUBSTRING(@strUPCA, 4, 1) 

			WHEN SUBSTRING(@strUPCA, 5, 2) IN ('00') THEN 
				SUBSTRING(@strUPCA, 2, 3) + SUBSTRING(@strUPCA, 10, 2) + '3'

			WHEN SUBSTRING(@strUPCA, 6, 1) IN ('0') THEN 
				SUBSTRING(@strUPCA, 2, 4) + SUBSTRING(@strUPCA, 11, 1) + '4'

			WHEN CAST(SUBSTRING(@strUPCA, 11, 1) AS INT) >= 5 THEN 
				SUBSTRING(@strUPCA, 2, 5) + SUBSTRING(@strUPCA, 11, 1)
					
			ELSE 
				NULL 
		END
END
	
RETURN @strUPCE
END