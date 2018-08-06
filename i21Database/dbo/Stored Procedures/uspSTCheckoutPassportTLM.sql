CREATE PROCEDURE [dbo].[uspSTCheckoutPassportTLM]
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
			  DECLARE @SavedPointTransaction AS VARCHAR(500) = 'CheckoutPassportTLM' + CAST(NEWID() AS NVARCHAR(100));
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

			 -- -- OLD
			 -- UPDATE  dbo.tblSTCheckoutSalesTaxTotals 
			 -- SET dblTotalTax = chk.TaxCollectedAmount,
				--dblTaxableSales = chk.TaxableSalesAmount,
				--dblTaxExemptSales = chk.TaxExemptSalesAmount
			 -- FROM #tempCheckoutInsert chk
			 -- WHERE intCheckoutId = @intCheckoutId AND chk.TaxCollectedAmount <> 0 AND intTaxNo = 1

			  DECLARE @intStoreId int
              SELECT @intStoreId = intStoreId
              FROM dbo.tblSTCheckoutHeader
              WHERE intCheckoutId = @intCheckoutId

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
      
			  -- TLM FILE
              UPDATE STT
              SET dblTotalTax = (
                                 SELECT CAST(ISNULL(TaxCollectedAmount, 0) AS DECIMAL(18,6))
                                 FROM #tempCheckoutInsert
                                 WHERE ISNULL(TaxLevelID, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
                              ) 
			  , dblTaxableSales =  (
                                        SELECT CAST(ISNULL(TaxableSalesAmount, 0) AS DECIMAL(18,6))
                                        FROM #tempCheckoutInsert
                                        WHERE ISNULL(TaxLevelID, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
                                     )          
			  , dblTaxExemptSales = (
										SELECT CAST(ISNULL(TaxExemptSalesAmount, 0) AS DECIMAL(18,6))
										FROM #tempCheckoutInsert
										WHERE ISNULL(TaxLevelID, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
									)  
              FROM dbo.tblSTCheckoutSalesTaxTotals STT
              WHERE STT.intCheckoutId = @intCheckoutId

              -- Difference between Passport and Radiant
              -- 1. Passport does not have 'TenderTransactionsCount' tag in MSM register file
              -- 2. Passport does not have Lottery Winners MOP in tblSTRegister (Register screen)

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