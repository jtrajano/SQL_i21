CREATE FUNCTION [dbo].[fnSTGenerateCheckDigit]
(
  @CheckDigitString AS VARCHAR(14)
)

-- To validate check here https://www.gs1.org/services/check-digit-calculator

RETURNS INT
AS BEGIN
	
	DECLARE @intCheckDigit AS INT

	IF(LEN(@CheckDigitString) < 11)
		BEGIN
			SET @intCheckDigit = NULL
		END
	ELSE IF(@CheckDigitString IS NULL)
		BEGIN
			SET @intCheckDigit = NULL
		END
	ELSE
		BEGIN
			-- Remove 1st Leading Zero
			SELECT @CheckDigitString =
				CASE 
					WHEN @CheckDigitString LIKE '0%'
						THEN RIGHT(@CheckDigitString,LEN(@CheckDigitString)-1)
					ELSE
						@CheckDigitString
				END


			SET @intCheckDigit = 
			(
				SELECT 
					--CASE 
					--	WHEN SUM(A.intTotal) > ROUND(SUM(A.intTotal), -1)
					--		THEN SUM(A.intTotal) - ROUND(SUM(A.intTotal), -1)
					--	ELSE ROUND(SUM(A.intTotal), -1) - SUM(A.intTotal)
					--END AS intCheckDigit
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
							WHEN (B.n % 2) = 0
								THEN SUBSTRING(@CheckDigitString, B.n, 1) * 3
							ELSE SUBSTRING(@CheckDigitString, B.n, 1) * 1
					   END intTotal
					FROM 
					(
						SELECT TOP (LEN(@CheckDigitString))
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