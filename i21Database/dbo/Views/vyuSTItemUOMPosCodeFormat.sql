CREATE VIEW [dbo].[vyuSTItemUOMPosCodeFormat]
AS
SELECT Item.intItemId
	   , UOM.intItemUOMId
	   , ItemLoc.intLocationId
       , Item.strItemNo
	   , Item.strDescription
	   , UOM.strLongUPCCode
	   , LEN(UOM.strLongUPCCode) AS intOrigUpcLength
	   , UOM.strLongUPCWOLeadingZero
	   , LEN(UOM.strLongUPCWOLeadingZero) AS intUpcWOLeadingZeroLength
	   , UOM.dblUPCwthOrwthOutCheckDigit

	   -- ***************************************************
	   -- Compare XML UPC with this field
	   -- But first remove leading zeros and last digit(check digit)
	   , UOM.intUpcCode 
	   -- ***************************************************

	   --, LEN(UOM.strUPCwthOrwthOutCheckDigit) AS intUpcWithCheckDigitLength
	   , CASE
			WHEN UOM.dblUPCwthOrwthOutCheckDigit <= 99999
				-- PLU
				THEN LEN(UOM.strUPCwthOrwthOutCheckDigit)

			WHEN UOM.dblUPCwthOrwthOutCheckDigit > 99999
				THEN CASE
						-- upcE  =  6-Numeric Digits. "NOT" included the Check digit
						-- ean8  =  8-Numeric Digits. "NOT" included the Check digit
						-- plu   =  Less than or equal to 5 digits. "NOT" included the Check digit
						-- upcA  =  12-Numeric Digits included the Check digit
						-- ean13 =  13-Numeric Digits included the Check digit
						-- gtin  =  GTINs may be 8, 12, 13 or 14 digits long. Check digit is included

						-- UPC-A
						WHEN (LEN(UOM.dblUPCwthOrwthOutCheckDigit) = 6) OR (UOM.dblUPCwthOrwthOutCheckDigit > 99999 AND UOM.dblUPCwthOrwthOutCheckDigit <= 999999999999)
							THEN CASE 
									WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) < 12
										THEN 12
									ELSE 
										LEN(UOM.strUPCwthOrwthOutCheckDigit)
							END
																
						-- EAN13
						WHEN UOM.dblUPCwthOrwthOutCheckDigit > 999999999999 AND UOM.dblUPCwthOrwthOutCheckDigit <= 9999999999999
							THEN CASE 
									WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) < 13
										THEN 13
									ELSE 
										LEN(UOM.strUPCwthOrwthOutCheckDigit)
							END

						-- GTIN
						WHEN UOM.dblUPCwthOrwthOutCheckDigit > 9999999999999
							THEN CASE
									WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) <= 14
										THEN 14
									WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) > 14 
										THEN LEN(UOM.dblUPCwthOrwthOutCheckDigit)
									--ELSE 
									--	LEN(UOM.strUPCwthOrwthOutCheckDigit) 
							END
					END
			ELSE 0
	   END AS intUpcWithCheckDigitLength

	   -- , UOM.strUPCwthOrwthOutCheckDigit
	   , CASE
			WHEN UOM.dblUPCwthOrwthOutCheckDigit <= 99999
				-- PLU
				THEN CAST(UOM.dblUPCwthOrwthOutCheckDigit AS NVARCHAR(5))

			WHEN UOM.dblUPCwthOrwthOutCheckDigit > 99999
				THEN CASE
						-- upcE  =  6-Numeric Digits. "NOT" included the Check digit
						-- ean8  =  8-Numeric Digits. "NOT" included the Check digit
						-- plu   =  Less than or equal to 5 digits. "NOT" included the Check digit
						-- upcA  =  12-Numeric Digits included the Check digit
						-- ean13 =  13-Numeric Digits included the Check digit
						-- gtin  =  GTINs may be 8, 12, 13 or 14 digits long. Check digit is included

						-- UPC-A
						WHEN (LEN(UOM.dblUPCwthOrwthOutCheckDigit) = 6) OR (UOM.dblUPCwthOrwthOutCheckDigit > 99999 AND UOM.dblUPCwthOrwthOutCheckDigit <= 999999999999)
							THEN CASE 
									WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) < 12
										THEN RIGHT(('000000000000' + CAST(UOM.dblUPCwthOrwthOutCheckDigit AS NVARCHAR(12))), 12)
									ELSE 
										CAST(UOM.dblUPCwthOrwthOutCheckDigit AS NVARCHAR(12))
							END
																
						-- EAN13
						WHEN UOM.dblUPCwthOrwthOutCheckDigit > 999999999999 AND UOM.dblUPCwthOrwthOutCheckDigit <= 9999999999999
							THEN CASE 
									WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) < 13
										THEN RIGHT(('0000000000000' + CAST(UOM.dblUPCwthOrwthOutCheckDigit AS NVARCHAR(13))), 13)
									ELSE 
										CAST(UOM.dblUPCwthOrwthOutCheckDigit AS NVARCHAR(13))
							END

						-- GTIN
						WHEN UOM.dblUPCwthOrwthOutCheckDigit > 9999999999999
							THEN CASE
									WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) <= 14
										THEN RIGHT(('00000000000000' + CAST(UOM.dblUPCwthOrwthOutCheckDigit AS NVARCHAR(14))), 14)
									WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) > 14 
										THEN RIGHT(UOM.dblUPCwthOrwthOutCheckDigit, 14)
										--CAST(UOM.dblUPCwthOrwthOutCheckDigit AS NVARCHAR(15)) 
							END
					END
			ELSE ''
	   END COLLATE Latin1_General_CI_AS AS strUPCwthOrwthOutCheckDigit

	   , UOM.ysnHasCheckDigit
	   , UOM.intCheckDigit COLLATE Latin1_General_CI_AS AS intCheckDigit
	   , CASE
			WHEN UOM.dblUPCwthOrwthOutCheckDigit <= 99999
				THEN 'plu'

			WHEN UOM.dblUPCwthOrwthOutCheckDigit > 99999
				THEN CASE
						-- upcE  =  6-Numeric Digits. "NOT" included the Check digit
						-- ean8  =  8-Numeric Digits. "NOT" included the Check digit
						-- plu   =  Less than or equal to 5 digits. "NOT" included the Check digit
						-- upcA  =  12-Numeric Digits included the Check digit
						-- ean13 =  13-Numeric Digits included the Check digit
						-- gtin  =  GTINs may be 8, 12, 13 or 14 digits long. Check digit is included

						-- UPC-A
						WHEN LEN(UOM.dblUPCwthOrwthOutCheckDigit) = 6 
							THEN 'upcA'
						WHEN UOM.dblUPCwthOrwthOutCheckDigit > 99999 AND UOM.dblUPCwthOrwthOutCheckDigit <= 999999999999
							THEN 'upcA'
																
						-- EAN13
						WHEN UOM.dblUPCwthOrwthOutCheckDigit > 999999999999 AND UOM.dblUPCwthOrwthOutCheckDigit <= 9999999999999
							THEN 'ean13'

						-- GTIN  
						WHEN UOM.dblUPCwthOrwthOutCheckDigit > 9999999999999
							THEN 'gtin'
					END
			ELSE ''
	   END COLLATE Latin1_General_CI_AS AS strPosCodeFormat
FROM 
(
	SELECT 
			ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS strLongUPCWOLeadingZero

		   , CASE 
				WHEN LEN(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0')) = 6 -- (UPC-E) Convert to UPC-A
					THEN RIGHT('00000000000' + ISNULL(dbo.fnSTConvertUPCeToUPCa(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0')),''), 11) + CAST(dbo.fnSTGenerateCheckDigit(U.strLongUPCCode) AS NVARCHAR(1))

				WHEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT)) <= 99999 -- (PLU) No Check digit
					THEN ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') 

				WHEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT)) > 99999 -- (UPC-A, EAN13, GTIN) With Check Digit
					THEN ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0')
			             + CAST(dbo.fnSTGenerateCheckDigit(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), 0)) AS NVARCHAR(1))
		   END AS strUPCwthOrwthOutCheckDigit

		   , CASE
				WHEN LEN(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0')) = 6
					THEN CONVERT(NUMERIC(32, 0),CAST(RIGHT('00000000000' + ISNULL(dbo.fnSTConvertUPCeToUPCa(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0')),''), 11) + CAST(dbo.fnSTGenerateCheckDigit(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), 0)) AS NVARCHAR(1)) AS FLOAT))
					 
				WHEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT)) <= 99999
					THEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT))
				
				WHEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT)) > 99999
					THEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') + CAST(dbo.fnSTGenerateCheckDigit(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), 0)) AS NVARCHAR(1)) AS FLOAT))
		   END AS dblUPCwthOrwthOutCheckDigit

		   , CASE 
				WHEN LEN(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0')) = 6
					THEN CAST(1 AS BIT)

				WHEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT)) <= 99999 -- (PLU) No Check digit
					THEN CAST(0 AS BIT)

				WHEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT)) > 99999 -- (UPC-A, EAN13, GTIN) With Check Digit
					THEN CAST(1 AS BIT)
		   END AS ysnHasCheckDigit

		   , CASE 
				WHEN LEN(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0')) = 6
					THEN CAST(dbo.fnSTGenerateCheckDigit(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), 0)) AS NVARCHAR(1))

				WHEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT)) <= 99999
					THEN NULL

				WHEN CONVERT(NUMERIC(32, 0),CAST(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), '0') AS FLOAT)) > 99999
					THEN CAST(dbo.fnSTGenerateCheckDigit(ISNULL(SUBSTRING(U.strLongUPCCode, PATINDEX('%[^0]%',U.strLongUPCCode), LEN(U.strLongUPCCode)), 0)) AS NVARCHAR(1))
		   END AS intCheckDigit

		   , U.* 
	FROM tblICItemUOM U
) AS UOM
INNER JOIN tblICItem Item
	ON UOM.intItemId = Item.intItemId
INNER JOIN tblICItemLocation ItemLoc
	ON Item.intItemId = ItemLoc.intItemId
WHERE Item.ysnFuelItem = CAST(0 AS BIT) 
	AND UOM.strLongUPCCode	IS NOT NULL
	AND UOM.strLongUPCCode	NOT LIKE '%[^0-9]%'
	AND LEN(UOM.strLongUPCCode)		<= 13     -- ST-1366 (Max Upc length is 13 without check digit, we should skip upc that has more than 13 digits)
	AND UOM.ysnStockUnit = CAST(1 AS BIT)
	AND ISNULL(SUBSTRING(UOM.strLongUPCCode, PATINDEX('%[^0]%',UOM.strLongUPCCode), LEN(UOM.strLongUPCCode)), 0) NOT IN ('')