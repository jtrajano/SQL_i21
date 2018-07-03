CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMSM]
@intCheckoutId INT,
@strStatusMsg NVARCHAR(250) OUTPUT,
@intCountRows INT OUTPUT
AS
BEGIN
       BEGIN TRY
              
              -------------------------------------------------------------------------------------------- 
              -- Create Save Point. 
              --------------------------------------------------------------------------------------------   
              -- Create a unique transaction name.
              DECLARE @TransactionName AS VARCHAR(500) = 'CheckoutPassportMSM' + CAST(NEWID() AS NVARCHAR(100));
              BEGIN TRAN @TransactionName
              SAVE TRAN @TransactionName --> Save point
              -------------------------------------------------------------------------------------------- 
              -- END Create Save Point. 
              --------------------------------------------------------------------------------------------

              DECLARE @intStoreId int
              SELECT @intStoreId = intStoreId
              FROM dbo.tblSTCheckoutHeader
              WHERE intCheckoutId = @intCheckoutId
      
              ----Update tblSTCheckoutPaymentOptions
              Update dbo.tblSTCheckoutPaymentOptions
              SET dblRegisterAmount = s.TotalSummaryAmount
                     , intRegisterCount = s.TotalSummaryCount
                     , dblAmount = s.TotalSummaryAmount
              FROM #tempCheckoutInsert chk
              JOIN (
                     SELECT ISNULL(CAST(TenderSubCode as int) ,0) as TenderSubCode,
                            SUM(ISNULL(CAST(MiscellaneousSummaryCount as money) ,0)) as TotalSummaryCount,
                            SUM(ISNULL(CAST(MiscellaneousSummaryAmount as money) ,0)) as TotalSummaryAmount
                     FROM #tempCheckoutInsert
                     GROUP BY TenderSubCode
                   ) s ON chk.TenderSubCode = s.TenderSubCode
              JOIN tblSTPaymentOption PO ON PO.intRegisterMop = CAST(chk.TenderSubCode AS INT)
              JOIN tblSTStore Store ON Store.intStoreId = PO.intStoreId
              JOIN tblSTCheckoutPaymentOptions CPO ON CPO.intPaymentOptionId = PO.intPaymentOptionId
              WHERE Store.intStoreId = @intStoreId
              AND chk.TenderSubCode <> ''
              AND intCheckoutId = @intCheckoutId

              --Update dbo.tblSTCheckoutPaymentOptions
              --SET dblRegisterAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --     , intRegisterCount = ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0)
              --     , dblAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --FROM #tempCheckoutInsert chk
              --WHERE intCheckoutId = @intCheckoutId
              --AND chk.MiscellaneousSummaryCode = 4
              --AND chk.MiscellaneousSummarySubCode IN (5,6)
              --AND intPaymentOptionId IN
              --(
              --     SELECT intLotteryWinnersMopId
              --     FROM dbo.tblSTRegister
              --     Where intStoreId = @intStoreId
              --)
      
              --Update dbo.tblSTCheckoutPaymentOptions
              --SET dblRegisterAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --     , intRegisterCount = ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0)
              --     , dblAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --FROM #tempCheckoutInsert chk
              --WHERE intCheckoutId = @intCheckoutId
              --AND chk.MiscellaneousSummaryCode = 19
              --AND chk.MiscellaneousSummarySubCodeModifier = 1550
              --AND intPaymentOptionId IN
              --(
              --     SELECT intPaymentOptionId
              --     FROM dbo.tblSTPaymentOption
              --     Where intRegisterMop = chk.MiscellaneousSummarySubCodeModifier
              --)

				---- Most probably this is not nessesary because sales tax totals is already preloaded
              IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutSalesTaxTotals WHERE intCheckoutId = @intCheckoutId)
              BEGIN
                           DECLARE @tbl TABLE
                           (
                                  intCnt INT,
                                  intAccountId INT,
                                  strAccountId nvarchar(100),
                                  intItemId INT,
                                  strItemNo NVARCHAR(100),
                                  strItemDescription NVARCHAR(100)
                           )
                           INSERT INTO @tbl
                           EXEC uspSTGetSalesTaxTotalsPreload @intStoreId
                           INSERT INTO dbo.tblSTCheckoutSalesTaxTotals
                           (
                                  intCheckoutId
                                  , strTaxNo
                                  , dblTotalTax
                                  , dblTaxableSales
                                  , dblTaxExemptSales
                                  , intSalesTaxAccount
                                  , intConcurrencyId
                           )
                           SELECT
                                  @intCheckoutId
                                  , intCnt
                                  , NULL
                                  , NULL
                                  , NULL
                                  , intAccountId
                                  , 0
                           FROM @tbl
              END
      
          
              UPDATE STT
              SET dblTaxableSales =  (
                                        SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))
                                        FROM #tempCheckoutInsert
                                        WHERE MiscellaneousSummaryCode  = 'taxTotals' 
                                        AND MiscellaneousSummarySubCode = 'taxableSalesByTaxCode'
                                        AND MiscellaneousSummarySubCodeModifier COLLATE DATABASE_DEFAULT = STT.strTaxNo
                                     ) 
              , dblTotalTax = (
                                 SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))
                                 FROM #tempCheckoutInsert
                                 WHERE MiscellaneousSummaryCode  = 'taxTotals' 
                                 AND MiscellaneousSummarySubCode = 'taxableSalesByTaxCode'
                                 AND MiscellaneousSummarySubCodeModifier COLLATE DATABASE_DEFAULT = STT.strTaxNo
                              ) 
              FROM dbo.tblSTCheckoutSalesTaxTotals STT
              WHERE STT.intCheckoutId = @intCheckoutId

    --          -- Difference between Passport and Radiant
    --          -- 1. Passport does not have 'TenderTransactionsCount' tag in MSM register file
    --          -- 2. Passport does not have Lottery Winners MOP in tblSTRegister (Register screen)
    --          -- How or where could we get the count of customer?
    --          --Update dbo.tblSTCheckoutHeader
    --          --SET dblCustomerCount = (S.TenderTransactionsCount)
    --          --FROM
    --          --(SELECT
    --          --     SUM(CAST(TenderTransactionsCount as int)) as TenderTransactionsCount
    --          --FROM #tempCheckoutInsert ST
    --          --JOIN dbo.tblSTPaymentOption PO ON PO.intRegisterMop = ST.TenderSubCode
    --          --JOIN dbo.tblSTStore Store ON Store.intStoreId = PO.intStoreId
    --          --JOIN dbo.tblSTCheckoutPaymentOptions CPO ON CPO.intPaymentOptionId = PO.intPaymentOptionId
    --          --WHERE ST.TenderSubCode <> ''
    --          --AND Store.intStoreId = @intStoreId 
    --          --AND intCheckoutId = @intCheckoutId) as S
      
          -------------------------------------------------------------------------------------------------------------
          ------------------------------------------ NO SALES ---------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
          UPDATE dbo.tblSTCheckoutHeader
          SET dblTotalNoSalesCount = (
                                       SELECT SUM(CAST(MiscellaneousSummaryCount as int))
                                       FROM #tempCheckoutInsert
                                       WHERE MiscellaneousSummaryCode  = 'statistics' 
                                       AND MiscellaneousSummarySubCode = 'noSales'
                                     )
          WHERE intCheckoutId = @intCheckoutId
          -------------------------------------------------------------------------------------------------------------
          ---------------------------------------- END NO SALES -------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------



          -------------------------------------------------------------------------------------------------------------
          ---------------------------------------- FUEL ADJUSTMENTS ---------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
          UPDATE dbo.tblSTCheckoutHeader
          SET dblFuelAdjustmentCount = (
                                         SELECT SUM(CAST(ISNULL(MiscellaneousSummaryCount, 0) AS DECIMAL(18,6)))
                                         FROM #tempCheckoutInsert
                                         WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'fuelSalesByGrade' 
                                          AND ISNULL(MiscellaneousSummarySubCode, '') = 'fuel'
                                       )
          WHERE intCheckoutId = @intCheckoutId
      
          UPDATE dbo.tblSTCheckoutHeader
          SET dblFuelAdjustmentAmount = (
                                          SELECT SUM(CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
                                          FROM #tempCheckoutInsert
                                          WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'fuelSalesByGrade' 
                                          AND ISNULL(MiscellaneousSummarySubCode, '') = 'fuel'
                                        )
          WHERE intCheckoutId = @intCheckoutId
          -------------------------------------------------------------------------------------------------------------
          --------------------------------------- END FUEL ADJUSTMENTS ------------------------------------------------
          -------------------------------------------------------------------------------------------------------------



          -------------------------------------------------------------------------------------------------------------
          ------------------------------------------- REFUND ----------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
          UPDATE dbo.tblSTCheckoutHeader
          SET dblTotalRefundCount = (
                                      SELECT SUM(CAST(MiscellaneousSummaryCount as int))
                                      FROM #tempCheckoutInsert
                                      WHERE
                                      (
                                        MiscellaneousSummaryCode = 'refunds'
                                        AND MiscellaneousSummarySubCode = 'total'
                                      )
                                      OR
                                      (
                                        MiscellaneousSummaryCode = 'statistics'
                                        AND MiscellaneousSummarySubCode = 'refunds'
                                      )
                                    )
          WHERE intCheckoutId = @intCheckoutId
		   
          UPDATE dbo.tblSTCheckoutHeader
          SET dblTotalRefundAmount = (
                                       SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6)))
                                       FROM #tempCheckoutInsert
                                       WHERE
                                       (
                                         MiscellaneousSummaryCode = 'refunds'
                                         AND MiscellaneousSummarySubCode = 'total'
                                       )
                                       OR
                                       (
                                         MiscellaneousSummaryCode = 'statistics'
                                         AND MiscellaneousSummarySubCode = 'refunds'
                                       )
                                     )
          WHERE intCheckoutId = @intCheckoutId
          -------------------------------------------------------------------------------------------------------------
          ------------------------------------------ END REFUND -------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------



          -------------------------------------------------------------------------------------------------------------
          ------------------------------------------ PAID OUTS --------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
          UPDATE dbo.tblSTCheckoutHeader
          SET dblTotalPaidOuts = (
                                   SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6)))
                                   FROM #tempCheckoutInsert
                                   WHERE MiscellaneousSummaryCode = 'payouts'
                                   AND MiscellaneousSummarySubCode = 'total'
                                 )
          WHERE intCheckoutId = @intCheckoutId
          -------------------------------------------------------------------------------------------------------------
          ----------------------------------------- END PAID OUTS -----------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
      
              --DECLARE @intCnt int, @intMaxCnt int
              --SET @intCnt = 1
              --SELECT @intMaxCnt = 23 --MAX(MiscellaneousSummarySubCodeModifier) FROM #tempCheckoutInsert WHERE MiscellaneousSummaryCode = 21 AND (MiscellaneousSummarySubCode =1 OR MiscellaneousSummarySubCode =2 OR MiscellaneousSummarySubCode =3)
              --                                                                   --AND MiscellaneousSummarySubCodeModifier <> 0
              --WHILE(@intCnt <= @intMaxCnt)
              --BEGIN
              --            INSERT INTO dbo.tblSTCheckoutRegisterHourlyActivity
              --            (
              --                   [intCheckoutId]
              --                   ,[intHourNo]
              --            )
              --            VALUES
              --            (
              --                   @intCheckoutId
              --                   , @intCnt
              --            )
             
              --            UPDATE  dbo.tblSTCheckoutRegisterHourlyActivity
              --            SET intFuelMerchandiseCustomerCount = (
              --                                                                                 SELECT CAST(MiscellaneousSummaryCount as int)
              --                                                                                 FROM #tempCheckoutInsert
              --                                                                                 WHERE MiscellaneousSummaryCode = 'statistics'
              --                                                                                 AND MiscellaneousSummarySubCode  = 'itemsSold'
              --                                                                                 AND MiscellaneousSummarySubCodeModifier = @intCnt
              --                                                                            ),
              --                   dblFuelMerchandiseCustomerSalesAmount = (
              --                                                                                              SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))
              --                                                                                              FROM #tempCheckoutInsert
              --                                                                                              WHERE MiscellaneousSummaryCode = 21
              --                                                                                              AND MiscellaneousSummarySubCode  = 1
              --                                                                                              AND MiscellaneousSummarySubCodeModifier = @intCnt
              --                                                                                       )
              --            WHERE intCheckoutId = @intCheckoutId
              --            AND intHourNo = @intCnt
             
              --            UPDATE  dbo.tblSTCheckoutRegisterHourlyActivity
              --            SET intMerchandiseCustomerCount = (
              --                                                                          SELECT CAST(MiscellaneousSummaryCount as int)
              --                                                                          FROM #tempCheckoutInsert
              --                                                                          WHERE MiscellaneousSummaryCode = 21
              --                                                                          AND MiscellaneousSummarySubCode  = 2
              --                                                                          AND MiscellaneousSummarySubCodeModifier = @intCnt
              --                                                                     ),
              --                   dblMerchandiseCustomerSalesAmount = (
              --                                                                                       SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))
              --                                                                                       FROM #tempCheckoutInsert
              --                                                                                       WHERE MiscellaneousSummaryCode = 21
              --                                                                                       AND MiscellaneousSummarySubCode  = 2
              --                                                                                       AND MiscellaneousSummarySubCodeModifier = @intCnt
              --                                                                                 )
              --            WHERE intCheckoutId = @intCheckoutId
              --            AND intHourNo = @intCnt
             
              --            UPDATE  dbo.tblSTCheckoutRegisterHourlyActivity
              --            SET intFuelOnlyCustomersCount = (
              --                                                                          SELECT CAST(MiscellaneousSummaryCount as int)
              --                                                                          FROM #tempCheckoutInsert
              --                                                                          WHERE MiscellaneousSummaryCode = 21
              --                                                                          AND MiscellaneousSummarySubCode  = 3
              --                                                                          AND MiscellaneousSummarySubCodeModifier = @intCnt
              --                                                                   ),
              --                   dblFuelOnlyCustomersSalesAmount = (
              --                                                                                 SELECT CAST(MiscellaneousSummaryAmount as decimal(18,6))
              --                                                                                 FROM #tempCheckoutInsert
              --                                                                                 WHERE MiscellaneousSummaryCode = 21
              --                                                                                 AND MiscellaneousSummarySubCode  = 3
              --                                                                                 AND MiscellaneousSummarySubCodeModifier = @intCnt
              --                                                                            )
              --            WHERE intCheckoutId = @intCheckoutId
              --            AND intHourNo = @intCnt
             
              --            SET @intCnt = @intCnt + 1
              --END

              SET @intCountRows = 1
              SET @strStatusMsg = 'Success'

			  PRINT 'SUCCESS'

              -- IF SUCCESS Commit Transaction
              COMMIT TRAN @TransactionName

       END TRY

       BEGIN CATCH
              -- IF HAS Error Rollback Transaction
              ROLLBACK TRAN @TransactionName    

              SET @intCountRows = 0
              SET @strStatusMsg = ERROR_MESSAGE()

              COMMIT TRAN @TransactionName
       END CATCH
END