CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantCSH]
	@intCheckoutId INT,
	@UDT_CSH	StagingPassportMSM		READONLY,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows INT OUTPUT
AS
BEGIN

	--SET NOCOUNT ON
    SET XACT_ABORT ON
       
	   BEGIN TRY
              
				BEGIN TRANSACTION


				DECLARE @intStoreId INT
					  , @intCustomerChargeMopId INT
					  , @intCashTransctionMopId INT

				SELECT @intStoreId			  = ch.intStoreId
					 , @intCustomerChargeMopId = st.intCustomerChargeMopId
					 , @intCashTransctionMopId = st.intCashTransctionMopId
				FROM dbo.tblSTCheckoutHeader ch
				INNER JOIN dbo.tblSTStore st
					ON ch.intStoreId = st.intStoreId
				WHERE ch.intCheckoutId = @intCheckoutId

				-- ==================================================================================================================  
				-- [START] Validate if MSM xml file matches the Mapping on i21 
				-- ================================================================================================================== 
				IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_CSH)
					BEGIN
							-- Add to error logging
							INSERT INTO tblSTCheckoutErrorLogs 
							(
								strErrorType
								, strErrorMessage 
								, strRegisterTag
								, strRegisterTagValue
								, intCheckoutId
								, intConcurrencyId
							)
							VALUES
							(
								'XML LAYOUT MAPPING'
								, 'Radiant CSH XML file did not match the layout mapping'
								, ''
								, ''
								, @intCheckoutId
								, 1
							)

							SET @intCountRows = 0
							SET @strStatusMsg = 'Radiant CSH XML file did not match the layout mapping'

							GOTO ExitWithCommit
					END
				-- ================================================================================================================== 
				-- [END] Validate if MSM xml file matches the Mapping on i21   
				-- ==================================================================================================================

			  -------------------------------------------------------------------------------------------------------------
			  -- [START] - Cashiers TAB 
			  -------------------------------------------------------------------------------------------------------------
			  BEGIN
					/*
						Insert first the cashiers in checkout that has matching ID then Update it
					*/
					IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutCashiers WHERE intCheckoutId = @intCheckoutId)
						BEGIN

							DECLARE @intCashierId AS INT
							DECLARE @strCashierId AS VARCHAR(MAX)

							
							IF(OBJECT_ID('tempdb..#tempCashier') IS NOT NULL) BEGIN DROP TABLE #tempCashier END

							INSERT INTO tblSTCheckoutCashiers (intCheckoutId, intCashierId)
							SELECT DISTINCT @intCheckoutId, C.intCashierId
							FROM tblSTCashier C
							INNER JOIN @UDT_CSH udt
								ON C.strCashierNumber = udt.strCashierId COLLATE DATABASE_DEFAULT

							--Create Temp table for while loop use
							SELECT * INTO #tempCashier FROM tblSTCheckoutCashiers WHERE intCheckoutId = @intCheckoutId

							WHILE EXISTS (SELECT TOP 1 1 FROM #tempCashier)
								BEGIN

									
									SELECT TOP 1 @intCashierId = c.intCashierId, @strCashierId = c.strCashierNumber
									FROM #tempCashier tmp
									JOIN tblSTCashier c
										ON tmp.intCashierId = c.intCashierId

									--dblTotalSales
									UPDATE cashier
										SET cashier.dblTotalSales = (	
																SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryAmount, 0) AS DECIMAL(18, 6)))
																   FROM @UDT_CSH
																	WHERE ISNULL(strMiscellaneousSummaryCode, '')  = '9' 
																	AND ISNULL(strMiscellaneousSummarySubCode, '') = '1'
																	AND ISNULL(strMiscellaneousSummarySubCodeModifier, '') IN ('2', '3')
																	AND strCashierId = @strCashierId
															   ),
											cashier.intNoSalesCount = (	
											SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryCount, 0) AS DECIMAL(18, 6)))
												FROM @UDT_CSH
												WHERE ISNULL(strMiscellaneousSummaryCode, '')  = '9' 
												AND ISNULL(strMiscellaneousSummarySubCode, '') = '1'
												AND ISNULL(strMiscellaneousSummarySubCodeModifier, '') IN ('2', '3')
												AND strCashierId = @strCashierId
											)
									FROM tblSTCheckoutCashiers cashier
									WHERE cashier.intCheckoutId = @intCheckoutId 
										AND cashier.intCashierId = @intCashierId

										
									--dblTotalPaymentOption
									UPDATE cashier
										SET cashier.dblTotalPaymentOption = (	
																SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryAmount, 0) AS DECIMAL(18, 6)))
																   FROM @UDT_CSH csh
																	WHERE ISNULL(strMiscellaneousSummaryCode, '')  = '19' 
																	AND ISNULL(strMiscellaneousSummarySubCode, '') = '1'
																	AND strMiscellaneousSummarySubCodeModifier COLLATE Latin1_General_CI_AS IN (SELECT ISNULL(strRegisterMop, '') 
																													FROM tblSTPaymentOption
																													WHERE intStoreId = @intStoreId)
																	AND strCashierId = @strCashierId
															   )
									FROM tblSTCheckoutCashiers cashier
									WHERE cashier.intCheckoutId = @intCheckoutId 
										AND cashier.intCashierId = @intCashierId
										
										
									--intNumberOfVoids and dblVoidAmount
									UPDATE cashier
										SET cashier.intNumberOfVoids = (	
																SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryCount, 0) AS DECIMAL(18, 6)))
																   FROM @UDT_CSH
																	WHERE ISNULL(strMiscellaneousSummaryCode, '')  = '7' 
																	AND ISNULL(strMiscellaneousSummarySubCode, '') = '8'
																	AND ISNULL(strMiscellaneousSummarySubCodeModifier, '') = ''
																	AND strCashierId = @strCashierId
															   ),
											cashier.dblVoidAmount = (	
																SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryAmount, 0) AS DECIMAL(18, 6)))
																	FROM @UDT_CSH
																	WHERE ISNULL(strMiscellaneousSummaryCode, '')  = '7' 
																	AND ISNULL(strMiscellaneousSummarySubCode, '') = '8'
																	AND ISNULL(strMiscellaneousSummarySubCodeModifier, '') = ''
																	AND strCashierId = @strCashierId
																)
									FROM tblSTCheckoutCashiers cashier
									WHERE cashier.intCheckoutId = @intCheckoutId 
										AND cashier.intCashierId = @intCashierId
										
									--intNumberOfRefunds and dblRefundAmount
									UPDATE cashier
										SET cashier.intNumberOfRefunds = (	
																SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryCount, 0) AS DECIMAL(18, 6)))
																   FROM @UDT_CSH
																	WHERE ISNULL(strMiscellaneousSummaryCode, '')  = '19' 
																	AND ISNULL(strMiscellaneousSummarySubCode, '') = '2'
																	AND strCashierId = @strCashierId
															   ),
											cashier.dblRefundAmount = (	
																SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryAmount, 0) AS DECIMAL(18, 6)))
																	FROM @UDT_CSH
																	WHERE ISNULL(strMiscellaneousSummaryCode, '')  = '19' 
																	AND ISNULL(strMiscellaneousSummarySubCode, '') = '2'
																	AND strCashierId = @strCashierId
																)
									FROM tblSTCheckoutCashiers cashier
									WHERE cashier.intCheckoutId = @intCheckoutId 
										AND cashier.intCashierId = @intCashierId

										
									--dblTotalDeposit
									UPDATE cashier
										SET cashier.dblTotalDeposit = (	
																SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryAmount, 0) AS DECIMAL(18, 6)))
																   FROM @UDT_CSH
																	WHERE ISNULL(strMiscellaneousSummaryCode, '')  = '1' 
																	AND ISNULL(strMiscellaneousSummarySubCode, '') = '0'
																	AND ISNULL(strMiscellaneousSummarySubCodeModifier, '') = ''
																	AND strCashierId = @strCashierId
															   )
									FROM tblSTCheckoutCashiers cashier
									WHERE cashier.intCheckoutId = @intCheckoutId 
										AND cashier.intCashierId = @intCashierId
										
									--intCustomerCount
									UPDATE cashier
										SET cashier.intCustomerCount = (	
																SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryCount, 0) AS DECIMAL(18, 6)))
																   FROM @UDT_CSH
																	WHERE ISNULL(strMiscellaneousSummaryCode, '') IN  ('7', '9') 
																	AND ISNULL(strMiscellaneousSummarySubCode, '') IN  ('7', '1') 
																	AND ISNULL(strMiscellaneousSummarySubCodeModifier, '') IN  ('', '9') 
																	AND strCashierId = @strCashierId
															   )
									FROM tblSTCheckoutCashiers cashier
									WHERE cashier.intCheckoutId = @intCheckoutId 
										AND cashier.intCashierId = @intCashierId




									DELETE FROM #tempCashier WHERE intCashierId = @intCashierId AND intCheckoutId = @intCheckoutId

								END
						END

			  END
			  -------------------------------------------------------------------------------------------------------------
			  -- [END] - Cashiers TAB 
			  -------------------------------------------------------------------------------------------------------------






              SET @intCountRows = 1
              SET @strStatusMsg = 'Success'

			  -- COMMIT
			  GOTO ExitWithCommit
       END TRY

       BEGIN CATCH
			SET @intCountRows = 0
			SET @strStatusMsg = ERROR_MESSAGE()
		

			-- ROLLBACK
			GOTO ExitWithRollback
	END CATCH
END


ExitWithCommit:
	-- Commit Transaction
	COMMIT TRANSACTION --@TransactionName
	GOTO ExitPost
	

ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION --@TransactionName
		END
	
ExitPost:
