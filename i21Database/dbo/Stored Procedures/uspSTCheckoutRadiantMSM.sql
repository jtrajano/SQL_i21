CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantMSM]
@intCheckoutId Int
AS
BEGIN

	IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutSalesTaxTotals WHERE intCheckoutId = @intCheckoutId)
	BEGIN
		DECLARE @tbl TABLE (intCnt int, intAccountId int, strAccountId nvarchar(100))
		INSERT into @tbl
		EXEC uspSTGetSalesTaxTotalsPreload 0

		INSERT INTO dbo.tblSTCheckoutSalesTaxTotals
		Select @intCheckoutId, intCnt, NULL, NULL, NULL, intAccountId, 0 from @tbl
	END
	
	UPDATE dbo.tblSTCheckoutSalesTaxTotals
	SET dblTaxableSales = CASE WHEN intTaxNo = 1 THEN (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
													WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =1
													AND MiscellaneousSummarySubCodeModifier = 1
													)
								WHEN intTaxNo = 2 THEN (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
													WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =1
													AND MiscellaneousSummarySubCodeModifier = 2
													)
								WHEN intTaxNo = 3 THEN (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
													WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =1
													AND MiscellaneousSummarySubCodeModifier = 3
													)
								WHEN intTaxNo = 4 THEN (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
													WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =1
													AND MiscellaneousSummarySubCodeModifier = 4
													)
							END
	, dblTotalTax = CASE WHEN intTaxNo = 1 THEN (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
													WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =3
													AND MiscellaneousSummarySubCodeModifier = 1
													)
								WHEN intTaxNo = 2 THEN (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
													WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =3
													AND MiscellaneousSummarySubCodeModifier = 2
													)
								WHEN intTaxNo = 3 THEN (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
													WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =3
													AND MiscellaneousSummarySubCodeModifier = 3
													)
								WHEN intTaxNo = 4 THEN (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
													WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =3
													AND MiscellaneousSummarySubCodeModifier = 4
													)
							END
	WHERE intCheckoutId = @intCheckoutId AND intTaxNo IN (1, 2, 3, 4)

	UPDATE dbo.tblSTCheckoutHeader 
	SET dblCustomerCount = (SELECT SUM(CAST(TenderTransactionsCount as int)) FROM #tempCheckoutInsert) 
	WHERE intCheckoutId = @intCheckoutId
	
	UPDATE dbo.tblSTCheckoutHeader 
	SET intTotalNoSalesCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 7 AND MiscellaneousSummarySubCode =4) 
	WHERE intCheckoutId = @intCheckoutId
	
	UPDATE dbo.tblSTCheckoutHeader 
	SET intFuelAdjustmentCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 7 AND MiscellaneousSummarySubCode =12) 
	WHERE intCheckoutId = @intCheckoutId
	
	UPDATE dbo.tblSTCheckoutHeader 
	SET dblFuelAdjustmentAmount = (SELECT SUM(CAST(MiscellaneousSummaryAmount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 7 AND MiscellaneousSummarySubCode =12) 
	WHERE intCheckoutId = @intCheckoutId
	
	UPDATE dbo.tblSTCheckoutHeader 
	SET intTotalRefundCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 3 AND MiscellaneousSummarySubCode =0) 
	WHERE intCheckoutId = @intCheckoutId
	
	UPDATE dbo.tblSTCheckoutHeader 
	SET dblTotalRefundAmount = (SELECT SUM(CAST(MiscellaneousSummaryAmount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 3 AND MiscellaneousSummarySubCode =0) 
	WHERE intCheckoutId = @intCheckoutId
	
	UPDATE dbo.tblSTCheckoutHeader 
	SET dblTotalPaidOuts = (SELECT SUM(CAST(MiscellaneousSummaryAmount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 4 AND MiscellaneousSummarySubCode =0) 
	WHERE intCheckoutId = @intCheckoutId


	
	DECLARE @intCnt int, @intMaxCnt int
	SET @intCnt = 1
	SELECT @intMaxCnt = 23 --MAX(MiscellaneousSummarySubCodeModifier) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 21 AND (MiscellaneousSummarySubCode =1 OR MiscellaneousSummarySubCode =2 OR MiscellaneousSummarySubCode =3)
							--AND MiscellaneousSummarySubCodeModifier <> 0
	WHILE(@intCnt <= @intMaxCnt)
	BEGIN
		INSERT INTO dbo.tblSTCheckoutRegisterHourlyActivity ([intCheckoutId]
           ,[intHourNo]) VALUES (@intCheckoutId, @intCnt)
		
		UPDATE  dbo.tblSTCheckoutRegisterHourlyActivity 
		SET intFuelMerchandiseCustomerCount = (SELECT MiscellaneousSummaryCount FROM #tempCheckoutInsert 
												WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 1
												AND MiscellaneousSummarySubCodeModifier = @intCnt),
			dblFuelMerchandiseCustomerSalesAmount = (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
												WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 1
												AND MiscellaneousSummarySubCodeModifier = @intCnt)
		WHERE intCheckoutId = @intCheckoutId AND intHourNo = @intCnt
		
		UPDATE  dbo.tblSTCheckoutRegisterHourlyActivity 
		SET intMerchandiseCustomerCount = (SELECT MiscellaneousSummaryCount FROM #tempCheckoutInsert 
												WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 2
												AND MiscellaneousSummarySubCodeModifier = @intCnt),
			dblMerchandiseCustomerSalesAmount = (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
												WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 2
												AND MiscellaneousSummarySubCodeModifier = @intCnt)
		WHERE intCheckoutId = @intCheckoutId AND intHourNo = @intCnt
		
		UPDATE  dbo.tblSTCheckoutRegisterHourlyActivity 
		SET intFuelOnlyCustomersCount = (SELECT MiscellaneousSummaryCount FROM #tempCheckoutInsert 
												WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 3
												AND MiscellaneousSummarySubCodeModifier = @intCnt),
			dblFuelOnlyCustomersSalesAmount = (SELECT MiscellaneousSummaryAmount FROM #tempCheckoutInsert 
												WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 3
												AND MiscellaneousSummarySubCodeModifier = @intCnt)
		WHERE intCheckoutId = @intCheckoutId AND intHourNo = @intCnt

		

		SET @intCnt = @intCnt + 1
	END

END
GO

