CREATE PROCEDURE [dbo].[uspPATProcessVoid]
	@stockIds NVARCHAR(MAX) = ''
AS
BEGIN
	CREATE TABLE #tmpStocks (intCustomerStockId INT)

	IF (@stockIds <> '' AND @stockIds IS NOT NULL)
	BEGIN
		DECLARE @intCustomerStockId INT,
				@pos INT

		WHILE CHARINDEX(',',@stockIds) > 0
		BEGIN
			SELECT @pos  = CHARINDEX(',', @stockIds)  				
			SELECT @intCustomerStockId = CONVERT(INT, SUBSTRING(@stockIds, 1, @pos-1))

			INSERT INTO #tmpStocks VALUES (@intCustomerStockId)

			SELECT @stockIds = SUBSTRING(@stockIds, @pos + 1, LEN(@stockIds) - @pos)
		END
	
		UPDATE tblPATCustomerStock
		   SET strActivityStatus = 'Open',
			   dtmRetireDate = null,
			   strCheckNumber = null,
			   dtmCheckDate = null,
			   dblCheckAmount = null
		 WHERE intCustomerStockId IN (SELECT intCustomerStockId FROM #tmpStocks)

		 DROP TABLE #tmpStocks
	END

	
		
END

GO

