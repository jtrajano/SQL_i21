CREATE FUNCTION dbo.fnSTGenerateCheckDigit
(
  @strUpcCode AS VARCHAR(14)
)

-- To validate check here https://www.gs1.org/services/check-digit-calculator

RETURNS INT
AS BEGIN
	
	DECLARE @intCheckDigit AS INT
	--DECLARE @strProcessUpcCode AS NVARCHAR(14)

	IF(LEN(@strUpcCode) <= 5)
		BEGIN
			SET @intCheckDigit = NULL
		END
	ELSE IF(@strUpcCode IS NULL)
		BEGIN
			SET @intCheckDigit = NULL
		END
	ELSE
		BEGIN
			IF(LEN(@strUpcCode) = 6)
				BEGIN
					-- Convert Short Upc(UPC-E) to Long Upc(UPC-A)
					SET @strUpcCode = dbo.fnSTConvertUPCeToUPCa(@strUpcCode)
				END
			ELSE IF(LEN(@strUpcCode) >= 7 AND LEN(@strUpcCode) <= 12)
				BEGIN
					SET @strUpcCode = RIGHT('0000000000000' + ISNULL(@strUpcCode,''),13)
				END

			-- Remove 1st Leading Zero
			SELECT @strUpcCode =
				CASE 
					WHEN @strUpcCode LIKE '0%'
						THEN RIGHT(@strUpcCode,LEN(@strUpcCode)-1)
					ELSE
						@strUpcCode
				END


			SET @intCheckDigit = 
			(
				SELECT 
					CASE 
						WHEN SUM(A.intTotal) > ROUND(SUM(A.intTotal), -1)
							THEN (ROUND(SUM(A.intTotal), -1) + 10) - SUM(A.intTotal)
						ELSE
							ROUND(SUM(A.intTotal), -1) - SUM(A.intTotal)
					END AS intCheckDigit
				FROM 
				(
					--SELECT n AS intRowCount
					--	   , CASE	
					--			WHEN (n % 2) = 0
					--				THEN 3
					--			ELSE 1
					--	   END intMultiplyBy
					--	 , intDigitToCheck = SUBSTRING(@CheckString, n, 1)
					SELECT CASE
							WHEN LEN(@strUpcCode) = 13 THEN
							CASE
								WHEN (B.n % 2) = 0
									THEN SUBSTRING(@strUpcCode, B.n, 1) * 1
								ELSE SUBSTRING(@strUpcCode, B.n, 1) * 3
							END 
							ELSE 
							CASE
								WHEN (B.n % 2) = 0
									THEN SUBSTRING(@strUpcCode, B.n, 1) * 3
								ELSE SUBSTRING(@strUpcCode, B.n, 1) * 1
							END 
						END AS intTotal
					FROM 
					(
						SELECT TOP (LEN(@strUpcCode))
							ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
						FROM (VALUES (0),(0),(0),(0),(0),(0),(0),(0)) a(n)
						CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(n)
						CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) c(n)
						CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) d(n)
					) AS B
				) AS A
			)
			--GROUP BY A.intRowCount, A.intMultiplyBy, A.intDigitToCheck, A.intTotal 
		END
	

    RETURN @intCheckDigit
END