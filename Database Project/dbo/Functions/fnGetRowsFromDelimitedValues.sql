CREATE FUNCTION [dbo].fnGetRowsFromDelimitedValues(@strParam NVARCHAR(MAX))
RETURNS @IntegerTable TABLE 
	(
		intID INT
	)
AS
BEGIN

	WITH ValuesCTE AS (
	  SELECT 
		  CASE
			  WHEN CHARINDEX(',',@strParam) = 0
				THEN @strParam
			  WHEN CHARINDEX(',',@strParam) > 0
				THEN LEFT(@strParam,CHARINDEX(',',@strParam) - 1)
		  END Value,     
		  CASE
			  WHEN CHARINDEX(',',@strParam) > 0
				THEN RIGHT(@strParam,LEN(@strParam) - CHARINDEX(',', @strParam))
			  ELSE NULL
		  END Remainder
	  UNION ALL
	  SELECT 
		  CASE
			  WHEN CHARINDEX(',',Remainder) = 0
				THEN Remainder
			  WHEN CHARINDEX(',',Remainder) > 0
				THEN LEFT(Remainder,CHARINDEX(',',Remainder) - 1)
		  END Value,
      
		  CASE
			  WHEN CHARINDEX(',',Remainder) > 0
				THEN RIGHT(Remainder,LEN(Remainder) - CHARINDEX(',',Remainder))
			  ELSE NULL
		  END Remainder
      
	  FROM ValuesCTE
	  WHERE Remainder IS NOT NULL
	)

	INSERT INTO @IntegerTable
		SELECT CAST([dbo].fnTrimX(Value) AS INT) FROM ValuesCTE OPTION (MAXRECURSION 0)

	RETURN
END
GO