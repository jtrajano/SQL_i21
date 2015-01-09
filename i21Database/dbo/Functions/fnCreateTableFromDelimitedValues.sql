-- =============================================
-- Author:		Trajano, Jeffrey
-- Create date: 12-11-2014
-- Description:	Creates table variable for delimited string (used by uspGLUpdateAccountStructure)
-- =============================================
CREATE FUNCTION [dbo].[fnCreateTableFromDelimitedValues]
(@strParam NVARCHAR(MAX),@delimiter NVARCHAR(1))
RETURNS @IntegerTable TABLE 
	(
		intID int IDENTITY(1,1) NOT NULL,
		intValue INT
	)
AS
BEGIN
	WITH ValuesCTE AS (
	  SELECT 
		  CASE
			  WHEN CHARINDEX(@delimiter,@strParam) = 0
				THEN @strParam
			  WHEN CHARINDEX(@delimiter,@strParam) > 0
				THEN LEFT(@strParam,CHARINDEX(@delimiter,@strParam) - 1)
		  END Value,     
		  CASE
			  WHEN CHARINDEX(@delimiter,@strParam) > 0
				THEN RIGHT(@strParam,LEN(@strParam) - CHARINDEX(@delimiter, @strParam))
			  ELSE NULL
		  END Remainder
	  UNION ALL
	  SELECT 
		  CASE
			  WHEN CHARINDEX(@delimiter,Remainder) = 0
				THEN Remainder
			  WHEN CHARINDEX(@delimiter,Remainder) > 0
				THEN LEFT(Remainder,CHARINDEX(@delimiter,Remainder) - 1)
		  END Value,
      
		  CASE
			  WHEN CHARINDEX(@delimiter,Remainder) > 0
				THEN RIGHT(Remainder,LEN(Remainder) - CHARINDEX(@delimiter,Remainder))
			  ELSE NULL
		  END Remainder
      
	  FROM ValuesCTE
	  WHERE Remainder IS NOT NULL
	)

	INSERT INTO @IntegerTable
		SELECT CAST([dbo].fnTrimX(Value) AS INT) FROM ValuesCTE OPTION (MAXRECURSION 0)
	RETURN
END
