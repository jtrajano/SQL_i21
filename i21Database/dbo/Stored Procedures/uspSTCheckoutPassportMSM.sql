CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMSM]
@intCheckoutId INT,
@strStatusMsg NVARCHAR(250) OUTPUT,
@intCountRows INT OUTPUT
AS
BEGIN

	--SET NOCOUNT ON
    SET XACT_ABORT ON
       
	   BEGIN TRY
              
			  -------------------------------------------------------------------------------------------- 
			  -- Create Save Point. 
			  --------------------------------------------------------------------------------------------   
			  -- Create a unique transaction name.
			  DECLARE @SavedPointTransaction AS VARCHAR(500) = 'CheckoutPassportMSM' + CAST(NEWID() AS NVARCHAR(100));
			  DECLARE @intTransactionCount INT = @@TRANCOUNT;

			  IF(@intTransactionCount = 0)
				  BEGIN
					  BEGIN TRAN @SavedPointTransaction
				  END
			  ELSE
				  BEGIN
					  SAVE TRAN @SavedPointTransaction --> Save point
				  END
			  -------------------------------------------------------------------------------------------- 
			  -- END Create Save Point. 
			  --------------------------------------------------------------------------------------------

              DECLARE @intStoreId int
              SELECT @intStoreId = intStoreId
              FROM dbo.tblSTCheckoutHeader
              WHERE intCheckoutId = @intCheckoutId
      
              ----Update tblSTCheckoutPaymentOptions
              Update dbo.tblSTCheckoutPaymentOptions
              SET dblRegisterAmount = ISNULL(chk.MiscellaneousSummaryAmount, 0)
                     , intRegisterCount = ISNULL(chk.MiscellaneousSummaryCount, 0)
                     , dblAmount = ISNULL(chk.MiscellaneousSummaryAmount, 0)
              FROM #tempCheckoutInsert chk
              JOIN tblSTPaymentOption PO ON PO.strRegisterMop COLLATE DATABASE_DEFAULT = ISNULL(chk.TenderSubCode, '')
              JOIN tblSTStore Store ON Store.intStoreId = PO.intStoreId
              JOIN tblSTCheckoutPaymentOptions CPO ON CPO.intPaymentOptionId = PO.intPaymentOptionId
              WHERE Store.intStoreId = @intStoreId
              AND ISNULL(chk.TenderSubCode, '') <> ''
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
                                        SELECT CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6))
                                        FROM #tempCheckoutInsert
                                        WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'taxTotals' 
                                        AND ISNULL(MiscellaneousSummarySubCode, '') = 'taxableSalesByTaxCode'
                                        AND ISNULL(MiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
                                     ) 
              , dblTotalTax = (
                                 SELECT CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6))
                                 FROM #tempCheckoutInsert
                                 WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'taxTotals' 
                                 AND ISNULL(MiscellaneousSummarySubCode, '') = 'taxableSalesByTaxCode'
                                 AND ISNULL(MiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
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
                                       SELECT SUM(CAST(ISNULL(MiscellaneousSummaryCount, 0) as int))
                                       FROM #tempCheckoutInsert
                                       WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'statistics' 
                                       AND ISNULL(MiscellaneousSummarySubCode, '') = 'noSales'
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
                                      SELECT SUM(CAST(ISNULL(MiscellaneousSummaryCount, 0) as int))
                                      FROM #tempCheckoutInsert
                                      WHERE
                                      (
                                        ISNULL(MiscellaneousSummaryCode, '') = 'refunds'
                                        AND ISNULL(MiscellaneousSummarySubCode, '') = 'total'
                                      )
                                      OR
                                      (
                                        ISNULL(MiscellaneousSummaryCode, '') = 'statistics'
                                        AND ISNULL(MiscellaneousSummarySubCode, '') = 'refunds'
                                      )
                                    )
          WHERE intCheckoutId = @intCheckoutId
		   
          UPDATE dbo.tblSTCheckoutHeader
          SET dblTotalRefundAmount = (
                                       SELECT SUM(CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
                                       FROM #tempCheckoutInsert
                                       WHERE
                                       (
                                         ISNULL(MiscellaneousSummaryCode, '') = 'refunds'
                                         AND ISNULL(MiscellaneousSummarySubCode, '') = 'total'
                                       )
                                       OR
                                       (
                                         ISNULL(MiscellaneousSummaryCode, '') = 'statistics'
                                         AND ISNULL(MiscellaneousSummarySubCode, '') = 'refunds'
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
                                   SELECT SUM(CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
                                   FROM #tempCheckoutInsert
                                   WHERE ISNULL(MiscellaneousSummaryCode, '') = 'payouts'
                                   AND ISNULL(MiscellaneousSummarySubCode, '') = 'total'
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

			  --PRINT 'SUCCESS'

              -- IF SUCCESS Commit Transaction
			  IF(@intTransactionCount = 0)
				BEGIN
					COMMIT TRANSACTION @SavedPointTransaction
				END
       END TRY

       BEGIN CATCH
              SET @intCountRows = 0
              SET @strStatusMsg = ERROR_MESSAGE()

			  PRINT ERROR_MESSAGE()

			  -- IF HAS Error Rollback Transaction
			  IF (XACT_STATE() = 1 OR (@intTransactionCount = 0 AND XACT_STATE() <> 0)) 
				BEGIN
					 ROLLBACK TRANSACTION @SavedPointTransaction;
					 --THROW;
				END
       END CATCH
END