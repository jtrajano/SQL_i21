CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantMSM]
@intCheckoutId Int
AS
BEGIN

    DECLARE @intStoreId int
    SELECT @intStoreId = intStoreId FROM dbo.tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId

 --   Update dbo.tblSTCheckoutPaymentOptions
 --   SET dblRegisterAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
 --   , intRegisterCount = ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0)
	--, dblAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
 --   FROM #tempCheckoutInsert chk
 --   JOIN tblSTPaymentOption PO ON PO.intRegisterMop = chk.TenderSubCode
 --   JOIN tblSTStore S ON S.intStoreId = PO.intStoreId
 --   WHERE S.intStoreId = @intStoreId AND intCheckoutId = @intCheckoutId AND tblSTCheckoutPaymentOptions.intPaymentOptionId = PO.intPaymentOptionId
       
	----Update tblSTCheckoutPaymentOptions
	Update dbo.tblSTCheckoutPaymentOptions
    SET dblRegisterAmount = s.TotalSummaryAmount
    , intRegisterCount = s.TotalSummaryCount
	, dblAmount = s.TotalSummaryAmount
    FROM #tempCheckoutInsert ST
	JOIN (
			SELECT ISNULL(CAST(TenderSubCode as int) ,0) as TenderSubCode,
			       SUM(ISNULL(CAST(MiscellaneousSummaryCount as money) ,0)) as TotalSummaryCount,
			       SUM(ISNULL(CAST(MiscellaneousSummaryAmount as money) ,0)) as TotalSummaryAmount
			FROM #tempCheckoutInsert
			GROUP BY TenderSubCode
	     ) s ON ST.TenderSubCode = s.TenderSubCode
    JOIN tblSTPaymentOption PO ON PO.intRegisterMop = ST.TenderSubCode
    JOIN tblSTStore Store ON Store.intStoreId = PO.intStoreId
	JOIN tblSTCheckoutPaymentOptions CPO ON CPO.intPaymentOptionId = PO.intPaymentOptionId
    WHERE Store.intStoreId = @intStoreId AND ST.TenderSubCode <> ''
	AND intCheckoutId = @intCheckoutId

    Update dbo.tblSTCheckoutPaymentOptions
    SET dblRegisterAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
    , intRegisterCount = ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0)
	, dblAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
    FROM #tempCheckoutInsert chk
    WHERE intCheckoutId = @intCheckoutId AND chk.MiscellaneousSummaryCode = 4 AND chk.MiscellaneousSummarySubCode IN (5,6)
    AND intPaymentOptionId IN (SELECT intLotteryWinnersMopId FROM dbo.tblSTRegister Where intStoreId = @intStoreId)
       
    Update dbo.tblSTCheckoutPaymentOptions
    SET dblRegisterAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
    , intRegisterCount = ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0)
	, dblAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
    FROM #tempCheckoutInsert chk
    WHERE intCheckoutId = @intCheckoutId AND chk.MiscellaneousSummaryCode = 19 AND chk.MiscellaneousSummarySubCodeModifier = 1550
    AND intPaymentOptionId IN (SELECT intPaymentOptionId FROM dbo.tblSTPaymentOption Where intRegisterMop = MiscellaneousSummarySubCodeModifier )

       
    IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutSalesTaxTotals WHERE intCheckoutId = @intCheckoutId)
    BEGIN
            DECLARE @tbl TABLE (intCnt int, intAccountId int, strAccountId nvarchar(100))
            INSERT into @tbl
            EXEC uspSTGetSalesTaxTotalsPreload 0

            INSERT INTO dbo.tblSTCheckoutSalesTaxTotals
            Select @intCheckoutId, intCnt, NULL, NULL, NULL, intAccountId, 0 from @tbl
    END
       
    UPDATE dbo.tblSTCheckoutSalesTaxTotals
    SET dblTaxableSales = CASE WHEN intTaxNo = 1 THEN (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                        WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =1
                                                                                        AND MiscellaneousSummarySubCodeModifier = 1
                                                                                        )
                                                    WHEN intTaxNo = 2 THEN (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                        WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =1
                                                                                        AND MiscellaneousSummarySubCodeModifier = 2
                                                                                        )
                                                    WHEN intTaxNo = 3 THEN (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                        WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =1
                                                                                        AND MiscellaneousSummarySubCodeModifier = 3
                                                                                        )
                                                    WHEN intTaxNo = 4 THEN (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                        WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =1
                                                                                        AND MiscellaneousSummarySubCodeModifier = 4
                                                                                        )
                                            END
    , dblTotalTax = CASE WHEN intTaxNo = 1 THEN (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                        WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =3
                                                                                        AND MiscellaneousSummarySubCodeModifier = 1
                                                                                        )
                                                    WHEN intTaxNo = 2 THEN (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                        WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =3
                                                                                        AND MiscellaneousSummarySubCodeModifier = 2
                                                                                        )
                                                    WHEN intTaxNo = 3 THEN (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                        WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =3
                                                                                        AND MiscellaneousSummarySubCodeModifier = 3
                                                                                        )
                                                    WHEN intTaxNo = 4 THEN (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                        WHERE MiscellaneousSummaryCode = 17 AND MiscellaneousSummarySubCode =3
                                                                                        AND MiscellaneousSummarySubCodeModifier = 4
                                                                                        )
                                            END
    WHERE intCheckoutId = @intCheckoutId AND intTaxNo IN (1, 2, 3, 4)

    --UPDATE dbo.tblSTCheckoutHeader 
    --SET dblCustomerCount = (SELECT SUM(CAST(TenderTransactionsCount as int)) FROM #tempCheckoutInsert) 
    --WHERE intCheckoutId = @intCheckoutId


	--Update TenderTransactionsCount
	Update dbo.tblSTCheckoutHeader
	SET dblCustomerCount = (S.TenderTransactionsCount)
	FROM
	(SELECT 
		SUM(CAST(TenderTransactionsCount as int)) as TenderTransactionsCount
    FROM #tempCheckoutInsert ST
    JOIN dbo.tblSTPaymentOption PO ON PO.intRegisterMop = ST.TenderSubCode
    JOIN dbo.tblSTStore Store ON Store.intStoreId = PO.intStoreId
	JOIN dbo.tblSTCheckoutPaymentOptions CPO ON CPO.intPaymentOptionId = PO.intPaymentOptionId
    WHERE ST.TenderSubCode <> ''
	AND Store.intStoreId = @intStoreId  
	AND intCheckoutId = @intCheckoutId) as S
       

    UPDATE dbo.tblSTCheckoutHeader 
    SET intTotalNoSalesCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 7 AND MiscellaneousSummarySubCode =4) 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET intFuelAdjustmentCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 7 AND MiscellaneousSummarySubCode =12) 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET dblFuelAdjustmentAmount = (SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6))) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 7 AND MiscellaneousSummarySubCode =12) 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET intTotalRefundCount = (SELECT SUM(CAST(MiscellaneousSummaryCount as int)) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 3 AND MiscellaneousSummarySubCode =0) 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET dblTotalRefundAmount = (SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6))) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 3 AND MiscellaneousSummarySubCode =0) 
    WHERE intCheckoutId = @intCheckoutId
       
    UPDATE dbo.tblSTCheckoutHeader 
    SET dblTotalPaidOuts = (SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6))) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 4 AND MiscellaneousSummarySubCode =0) 
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
            SET intFuelMerchandiseCustomerCount = (SELECT CAST(MiscellaneousSummaryCount as int) FROM #tempCheckoutInsert 
                                                                                WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 1
                                                                                AND MiscellaneousSummarySubCodeModifier = @intCnt),
                    dblFuelMerchandiseCustomerSalesAmount = (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 1
                                                                                AND MiscellaneousSummarySubCodeModifier = @intCnt)
            WHERE intCheckoutId = @intCheckoutId AND intHourNo = @intCnt
              
            UPDATE  dbo.tblSTCheckoutRegisterHourlyActivity 
            SET intMerchandiseCustomerCount = (SELECT CAST(MiscellaneousSummaryCount as int) FROM #tempCheckoutInsert 
                                                                                WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 2
                                                                                AND MiscellaneousSummarySubCodeModifier = @intCnt),
                    dblMerchandiseCustomerSalesAmount = (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 2
                                                                                AND MiscellaneousSummarySubCodeModifier = @intCnt)
            WHERE intCheckoutId = @intCheckoutId AND intHourNo = @intCnt
              
            UPDATE  dbo.tblSTCheckoutRegisterHourlyActivity 
            SET intFuelOnlyCustomersCount = (SELECT CAST(MiscellaneousSummaryCount as int) FROM #tempCheckoutInsert 
                                                                                WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 3
                                                                                AND MiscellaneousSummarySubCodeModifier = @intCnt),
                    dblFuelOnlyCustomersSalesAmount = (SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))FROM #tempCheckoutInsert 
                                                                                WHERE MiscellaneousSummaryCode = 21 AND MiscellaneousSummarySubCode  = 3
                                                                                AND MiscellaneousSummarySubCodeModifier = @intCnt)
            WHERE intCheckoutId = @intCheckoutId AND intHourNo = @intCnt

              

            SET @intCnt = @intCnt + 1
    END

END
GO

