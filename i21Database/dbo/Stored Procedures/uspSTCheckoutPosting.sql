﻿CREATE PROCEDURE [dbo].[uspSTCheckoutPosting]
	@intCurrentUserId					INT,
	@intCheckoutId						INT,
	@intCheckoutProcessId				INT,
	@strDirection						NVARCHAR(50),
	@ysnRecap							BIT,
	@strStatusMsg						NVARCHAR(1000)	OUTPUT,
	@strNewCheckoutStatus				NVARCHAR(100)	OUTPUT,
	@ysnInvoiceStatus					BIT OUTPUT,
	@ysnCustomerChargesInvoiceStatus	BIT OUTPUT,
	@strBatchIdForNewPostRecap			NVARCHAR(1000)	OUTPUT,
	@strErrorCode						NVARCHAR(50)	OUTPUT,
	@ysnDebug							BIT =	0,
	@strConsInvoiceType					NVARCHAR(50),
	@dblConsTotalDeposits				DECIMAL (18,6)
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	BEGIN TRY
		
		-- ==================================================================================================================
		-- [START] - Check Checkout current process using column [intCheckoutCurrentProcess]
		-- ==================================================================================================================
		DECLARE @tblSTLotteryProcessError TABLE 
		( 
			 intCheckoutId				int				  NULL
			,strBookNumber				nvarchar(max)	  NULL
			,strGame					nvarchar(max)	  NULL
			,strError					nvarchar(max)	  NULL
			,strProcess					nvarchar(max)	  NULL
		)

		DECLARE @ysnSetToReady BIT = CAST(0 AS BIT)

		IF(@strDirection IN('Post', 'UnPost') AND @ysnRecap = CAST(0 AS BIT))
			BEGIN
				-- 0 = Ready
				-- 1 = Currently being Posted
				-- 2 = Currently being Un-Posted
				IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId AND intCheckoutCurrentProcess != 0)
					BEGIN
						IF DATEADD(MINUTE, 10, (SELECT dtmCheckoutProcessDate FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)) >= GETDATE()
							BEGIN
								DECLARE @strCheckoutCurrentProcess NVARCHAR(150) = ''
								DECLARE @strMinuteDiff AS NVARCHAR(20) =  CAST(11 - ABS((SELECT DATEDIFF(MINUTE, GETDATE(), (SELECT TOP 1
									dtmCheckoutProcessDate
								FROM tblSTCheckoutHeader 
								WHERE intCheckoutId = @intCheckoutId)))) AS VARCHAR(20))

								SET @strMinuteDiff = CASE WHEN @strMinuteDiff = '1' THEN 
														@strMinuteDiff + ' minute'
														ELSE @strMinuteDiff + ' minutes'
														END

								
								SELECT 
									@strCheckoutCurrentProcess = CASE
																	WHEN intCheckoutCurrentProcess = 1
																		THEN 'End of day is currently posting, please try again after ' + @strMinuteDiff
																	WHEN intCheckoutCurrentProcess = 2
																		THEN 'End of day is currently unposting, please try again after ' + @strMinuteDiff
																END
								FROM tblSTCheckoutHeader 
								WHERE intCheckoutId = @intCheckoutId 



								SET @strStatusMsg = @strCheckoutCurrentProcess
								SET @strNewCheckoutStatus = ''
								SET @ysnInvoiceStatus = 0
								SET @ysnCustomerChargesInvoiceStatus = 0
								SET @strBatchIdForNewPostRecap = ''
								SET @strErrorCode = 'Err' 

								GOTO ExitPost
							END
						ELSE
							BEGIN
								UPDATE tblSTCheckoutHeader
								SET intCheckoutCurrentProcess = CASE 
																	WHEN @strDirection = 'Post'
																		THEN 1
																	WHEN @strDirection = 'UnPost'
																		THEN 2
																END,
									dtmCheckoutProcessDate = GETDATE()
								WHERE intCheckoutId = @intCheckoutId  

								SET @ysnSetToReady = CAST(1 AS BIT)
							END

					END
				ELSE IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId AND intCheckoutCurrentProcess = 0)
					BEGIN
				
						UPDATE tblSTCheckoutHeader
						SET intCheckoutCurrentProcess = CASE 
															WHEN @strDirection = 'Post'
																THEN 1
															WHEN @strDirection = 'UnPost'
																THEN 2
														END,
							dtmCheckoutProcessDate = GETDATE()
						WHERE intCheckoutId = @intCheckoutId  

						SET @ysnSetToReady = CAST(1 AS BIT)

					END
			END
		-- ==================================================================================================================
		-- [END] - Check Checkout current process using column [intCheckoutCurrentProcess]
		-- ==================================================================================================================


		IF @@TRANCOUNT = 0
		BEGIN
			BEGIN TRANSACTION 
		END


		-- OUT Params
		SET @strStatusMsg = 'Success'
		SET @ysnInvoiceStatus = 0
		SET @ysnCustomerChargesInvoiceStatus = 0
		SET @strNewCheckoutStatus = ''
		SET @strBatchIdForNewPostRecap = ''
		SET @strErrorCode = 'Err'

		--CONSIGNMENT
		DECLARE @strErrorMsgDetail VARCHAR(MAX)
		DECLARE @ysnConsignmentStore BIT = 1
		DECLARE @dblInvoiceAndCheckoutDifference DECIMAL(18,6) = 0
		DECLARE @dblConsTolerance DECIMAL(18,6) = 0.01
		DECLARE @dblOutsideFuelDiscount DECIMAL(18,6) = 0
		--DECLARE @dblInsideFuelDiscount DECIMAL(18,6) = 0
		DECLARE @ysnConsMeterReadingsForDollars BIT = 0
		--DECLARE @ysnConsIncludeInsideDiscount BIT = 0
		DECLARE @ysnConsAddOutsideFuelDiscounts BIT = 0
		DECLARE @ysnConsCashOverShort BIT = 0
		DECLARE @intConsInvoiceId AS INT

		DECLARE @LineItems AS LineItemTaxDetailStagingTable -- Dummy Table

		DECLARE @ysnUpdateCheckoutStatus BIT = 1
		DECLARE @strCreateGuidBatch AS NVARCHAR(200)
		DECLARE @intIntegrationLogId AS INT
		
		DECLARE @strAllowMarkUpDown NVARCHAR(1)

		DECLARE @intEntityCustomerId INT
		DECLARE @intCompanyLocationId INT
		DECLARE @intTaxGroupId INT
		DECLARE @intStoreId INT
		DECLARE @strComments NVARCHAR(MAX) = 'Store End of Day' -- All comments should be same to create a single Invoice
		DECLARE @strInvoiceTypeMain AS NVARCHAR(100) = 'Store End of Day' --'Standard' --'Store End of Day'
		DECLARE @strInvoiceTransactionTypeMain AS NVARCHAR(100) --= 'Store End of Day'
		DECLARE @strInvoiceTypeCustomerCharges AS NVARCHAR(100) --= 'Store End of Day'
		DECLARE @strInvoicePaymentMethodMain AS NVARCHAR(100) = 'Cash'
		DECLARE @intPaymentMethodIdMain AS INT = (
													SELECT intPaymentMethodID 
													FROM vyuARPaymentMethodForReceivePayments 
													WHERE strPaymentMethod = @strInvoicePaymentMethodMain
												 )
		
		DECLARE @strStoreName NVARCHAR(60)
		
		SELECT @intCompanyLocationId = intCompanyLocationId
			   , @intEntityCustomerId = intCheckoutCustomerId
			   , @intTaxGroupId = intTaxGroupId
			   , @intStoreId = intStoreId
			   , @ysnConsignmentStore = ysnConsignmentStore
			   , @strAllowMarkUpDown = strAllowRegisterMarkUpDown 
			   , @strStoreName = strDescription
			   , @ysnConsMeterReadingsForDollars = ysnConsMeterReadingsForDollars
			   , @ysnConsAddOutsideFuelDiscounts = ysnConsAddOutsideFuelDiscounts
			   , @dblConsTolerance = dblConsMatchTolerance
		FROM tblSTStore 
		WHERE intStoreId = (
				SELECT intStoreId FROM tblSTCheckoutHeader
				WHERE intCheckoutId = @intCheckoutId
		)

		-- For Mark Up Down Posting
		DECLARE @intMarkUpDownId AS INT = (SELECT intMarkUpDownId FROM tblSTMarkUpDown WHERE intCheckoutId = @intCheckoutId)
		DECLARE @strMarkUpDownPostingStatusMsg AS NVARCHAR(1000) = ''
		DECLARE @strBatchId AS NVARCHAR(1000) = ''
		DECLARE @ysnIsPosted AS BIT

		DECLARE @intCurrencyId INT = (SELECT intDefaultCurrencyId FROM tblSMCompanyPreference)
		DECLARE @intShipViaId INT = (SELECT TOP 1 1 intShipViaId FROM tblEMEntityLocation WHERE intEntityId = @intEntityCustomerId AND intShipViaId IS NOT NULL)

		-- User Defined Tables
		DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
		DECLARE @EntriesForCSCreditMemo AS InvoiceIntegrationStagingTable
		DECLARE @LineItemTaxEntries AS LineItemTaxDetailStagingTable
		DECLARE @PaymentsForInsert AS PaymentIntegrationStagingTable	
		DECLARE @EntriesForInvoiceBatchPost AS InvoiceStagingTable -- For Batch Posting 
		DECLARE @EntriesForCSCreditMemoBatchPost AS InvoiceStagingTable -- For Batch Posting 
		DECLARE @tblIds AS Id

		DECLARE @GLEntries AS RecapTableType 
		DECLARE @ysnPost BIT = NULL
		-- DECLARE @CheckoutCurrentStatus NVARCHAR(50) = ''

		DECLARE @intCurrentInvoiceId INT
		DECLARE @intConsCreditMemoId INT
		DECLARE @strCurrentAllInvoiceIdList NVARCHAR(1000)
		DECLARE @dtmCheckoutDate AS DATETIME
		DECLARE @dblCheckoutTotalDeposited AS DECIMAL(18,6)
		DECLARE @dblCheckoutTotalCustomerPayments AS DECIMAL(18,6)
		DECLARE @dblCheckoutCustomerChargeAmount AS DECIMAL(18,6)
		DECLARE @strCheckoutType NVARCHAR(100)		

		SELECT @intCurrentInvoiceId = intInvoiceId
				, @intConsCreditMemoId = intConsCreditMemoId
				, @strCurrentAllInvoiceIdList = strAllInvoiceIdList
				, @dtmCheckoutDate = dtmCheckoutDate 
				, @dblCheckoutTotalDeposited = dblTotalDeposits
				, @dblCheckoutCustomerChargeAmount = dblTotalDeposits
				, @dblCheckoutTotalCustomerPayments = dblCustomerPayments
				, @strCheckoutType = strCheckoutType
				, @dblOutsideFuelDiscount = dblEditableOutsideFuelDiscount
				--, @dblInsideFuelDiscount = dblEditableInsideFuelDiscount
		FROM tblSTCheckoutHeader 
		WHERE intCheckoutId = @intCheckoutId

		DECLARE @strCASH NVARCHAR(100) = 'Cash'
		DECLARE @strCREDITMEMO NVARCHAR(100) = 'Credit Memo'

		IF @ysnConsignmentStore = 1
		BEGIN
			SET @strCASH = 'Invoice' --@strConsInvoiceType
		END

		------------------------------------------------------------------------------
		-- Set Invoice Type for MAIN
		-- http://jira.irelyserver.com/browse/ST-1352
		IF((ISNULL(@dblCheckoutTotalDeposited, 0) - ISNULL(@dblCheckoutTotalCustomerPayments, 0)) >= 0)
			BEGIN
				SET @strInvoiceTransactionTypeMain = @strCASH
			END
		ELSE
			BEGIN
				-- Error if directly creating a Cash Refund (Error: 'Cash Refund amount is not equal to prepaids/credits applied.')
				-- As per Kelvin the process for @strCREDITMEMO would be
				-- 1. Process this as transaction type='Credit Memo'   (using uspARProcessInvoicesByBatch)
				-- 2. After process has finish Process this as @strCREDITMEMO    (using uspARProcessRefund)
				SET @strInvoiceTransactionTypeMain = @strCREDITMEMO
				--SET @strInvoiceTransactionTypeMain = @strCREDITMEMO
			END

		IF @ysnConsignmentStore = 1
		BEGIN
			IF @strConsInvoiceType = 'CSFuelInvoice'
			BEGIN
				SET @strInvoiceTransactionTypeMain = 'Invoice'
			END
		END
		------------------------------------------------------------------------------
		DECLARE @strItemNo AS NVARCHAR(50) = ''
		DECLARE @strDepartment AS NVARCHAR(150) = ''

		DECLARE @intCreatedInvoiceId INT = NULL
		DECLARE @strAllCreatedInvoiceIdList NVARCHAR(1000)

		-- FOR UNPOST
		DECLARE @strInvoiceIdList NVARCHAR(50) = ''
		DECLARE @strCustomerChargesInvoiceId NVARCHAR(50) = ''
		DECLARE @ysnInvoiceIsPosted BIT = NULL
		DECLARE @intSuccessfullCount INT
		DECLARE @intInvalidCount INT
		DECLARE @ysnSuccess BIT
		DECLARE @strBatchIdUsed NVARCHAR(40)
		DECLARE @ysnError BIT = 1

		DECLARE @tblTempItems TABLE
		(
			intItemId INT
			, strItemNo NVARCHAR(100)
		)

		DECLARE @tblTempInvoiceIds TABLE
		(
			intInvoiceId INT,
			intEntityId INT,
			ysnPosted BIT,
			strTransactionType NVARCHAR(150) COLLATE SQL_Latin1_General_CP1_CS_AS
		)
		
		DECLARE @tblInventoryReceiptIds TABLE
		(
			strReceiptId VARCHAR(40)
		)

		DECLARE @tblTempRank TABLE
		(
			intRankId INT
			, intTempDetailIdForTaxes INT
			, strSourceTransaction NVARCHAR(150) COLLATE SQL_Latin1_General_CP1_CS_AS
		)

		-- Create the temp table for the intInvoiceId's.
		IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NOT NULL  
			BEGIN
				DROP TABLE #tmpCustomerInvoiceIdList
			END
		IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NULL  
			BEGIN
				CREATE TABLE #tmpCustomerInvoiceIdList (
				intInvoiceId INT
			);
			END
			

		----------------------------------------------------------------------
		-------------------- Check current Invoice status --------------------
		----------------------------------------------------------------------
		DECLARE @ysnCurrentInvoiceStatus BIT = NULL
		IF(@intCurrentInvoiceId IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId = @intCurrentInvoiceId)
					BEGIN
						SET @ysnCurrentInvoiceStatus = (SELECT ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intCurrentInvoiceId)
						
						SET @ysnInvoiceStatus = @ysnCurrentInvoiceStatus
					END
			END
		ELSE
			BEGIN
				SET @ysnInvoiceStatus = 0 -- Set to false
			END
		----------------------------------------------------------------------
		------------------ End check current Invoice status ------------------
		----------------------------------------------------------------------


		----------------------------------------------------------------------
		-------------------- Verify Posting Direction ------------------------
		----------------------------------------------------------------------		
		IF(@strDirection = 'Post')
			BEGIN
				IF(@ysnCurrentInvoiceStatus = 0 OR @ysnCurrentInvoiceStatus IS NULL) -- The Invoice current status is 'UnPosted' OR not yet Created
					BEGIN
						SET @ysnPost = 1
					END
				ELSE IF(@ysnCurrentInvoiceStatus = 1) -- The Invoice is already been 'Posted' 
					BEGIN
						SET @ysnPost = NULL -- Set to Null so Posting will not continue
						SET @ysnUpdateCheckoutStatus = 1
						SET @strStatusMsg = 'Checkout already been Posted'
					END
			END
		ELSE IF (@strDirection = 'UnPost')
			BEGIN
				IF(@ysnCurrentInvoiceStatus = 1) -- The Invoice current status is 'Posted'
					BEGIN
						SET @ysnPost = 0
					END
				ELSE IF(@ysnCurrentInvoiceStatus = 0) -- The Invoice is already been 'UnPosted' 
					BEGIN
						SET @ysnPost = NULL -- Set to Null so UnPosting will not continue
						SET @ysnUpdateCheckoutStatus = 1
						SET @strStatusMsg = 'Checkout already been UnPosted'
					END
			END		
		----------------------------------------------------------------------
		-------------------- End Verify Posting Direction --------------------
		----------------------------------------------------------------------


		-- ===================================================================
		-- [Start] - VALIDATION ----------------------------------------------
		-- ===================================================================
		IF(@strDirection = 'Post')
			BEGIN

				--NOTE: This validation was commented for CS-350 - Deprecate the logic that requires a 1:1 relationship between Pump Items and Departments
				-- Department Totals - Check if there are Item Movements that has no matching department in Department Totals
				--IF EXISTS(SELECT TOP 1 1
				--			FROM tblSTCheckoutItemMovements IM
				--			JOIN tblICItemUOM UOM
				--				ON IM.intItemUPCId = UOM.intItemUOMId
				--			JOIN tblICItem Item
				--				ON UOM.intItemId = Item.intItemId
				--			JOIN tblICCategory Cat
				--				ON Item.intCategoryId = Cat.intCategoryId
				--			WHERE IM.intCheckoutId = @intCheckoutId
				--				AND Cat.intCategoryId NOT IN (
				--												SELECT intCategoryId
				--												FROM tblSTCheckoutDepartmetTotals
				--												WHERE intCheckoutId = @intCheckoutId
				--											 )
				--		 )
				--	BEGIN
				--		SELECT TOP 1
				--				@strItemNo     = Item.strItemNo,
				--				@strDepartment = Cat.strCategoryCode
				--			FROM tblSTCheckoutItemMovements IM
				--			JOIN tblICItemUOM UOM
				--				ON IM.intItemUPCId = UOM.intItemUOMId
				--			JOIN tblICItem Item
				--				ON UOM.intItemId = Item.intItemId
				--			JOIN tblICCategory Cat
				--				ON Item.intCategoryId = Cat.intCategoryId
				--			WHERE IM.intCheckoutId = @intCheckoutId
				--				AND Cat.intCategoryId NOT IN (
				--												SELECT intCategoryId
				--												FROM tblSTCheckoutDepartmetTotals
				--												WHERE intCheckoutId = @intCheckoutId
				--											 ) 
				--
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = 'Item # ' + @strItemNo + ' with Category ' + @strDepartment + ' does not exist in the End of day Departments.'
				--		SET @strErrorCode = 'DT-01'
				--
				--		-- ROLLBACK
				--		GOTO ExitWithRollback
				--	END

				--NOTE: This validation was commented for CS-350 - Deprecate the logic that requires a 1:1 relationship between Pump Items and Departments
				-- Department Totals - Check if there are Pump Items that has no matching department in Department Totals
				--ELSE IF EXISTS(SELECT TOP 1 1
				--				FROM tblSTCheckoutPumpTotals PT
				--				JOIN tblICItemUOM UOM
				--					ON PT.intPumpCardCouponId = UOM.intItemUOMId
				--				JOIN tblICItem Item
				--					ON UOM.intItemId = Item.intItemId
				--				JOIN tblICCategory Cat
				--					ON PT.intCategoryId = Cat.intCategoryId
				--				WHERE PT.intCheckoutId = @intCheckoutId
				--					AND Cat.intCategoryId NOT IN (
				--													SELECT intCategoryId
				--													FROM tblSTCheckoutDepartmetTotals
				--													WHERE intCheckoutId = @intCheckoutId
				--												 ) 
				--		 )
				--	BEGIN
				--		SELECT TOP 1
				--				@strItemNo     = Item.strItemNo,
				--				@strDepartment = Cat.strCategoryCode
				--			FROM tblSTCheckoutPumpTotals PT
				--			JOIN tblICItemUOM UOM
				--				ON PT.intPumpCardCouponId = UOM.intItemUOMId
				--			JOIN tblICItem Item
				--				ON UOM.intItemId = Item.intItemId
				--			JOIN tblICCategory Cat
				--				ON PT.intCategoryId = Cat.intCategoryId
				--			WHERE PT.intCheckoutId = @intCheckoutId
				--				AND Cat.intCategoryId NOT IN (
				--												SELECT intCategoryId
				--												FROM tblSTCheckoutDepartmetTotals
				--												WHERE intCheckoutId = @intCheckoutId
				--											 ) 
				--
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = 'Item # ' + @strItemNo + ' with Category ' + @strDepartment + ' does not exist in the End of day Departments.'
				--		SET @strErrorCode = 'DT-02'
				--
				--		-- ROLLBACK
				--		GOTO ExitWithRollback
				--	END

				-- Item Movement - Check if has null 'intItemUPCId'
				IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutItemMovements WHERE intCheckoutId = @intCheckoutId AND intItemUPCId IS NULL)
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'Click Ok to Review Item Movements'
						SET @strErrorCode = 'IM-01'

						-- ROLLBACK
						GOTO ExitWithRollback
					END

				-- Pump Items
				IF EXISTS(SELECT TOP 1 1 FROM tblSTPumpItem WHERE intStoreId = @intStoreId AND intTaxGroupId IS NULL)
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'Please configure Tax Group for the Fuel Items on the Pump Items tab of Store Configuration Screen.'

						-- ROLLBACK
						GOTO ExitWithRollback
					END
					
				-- Cash over/short item id
				IF EXISTS(SELECT TOP 1 1 FROM tblSTStore WHERE intStoreId = @intStoreId AND intOverShortItemId IS NULL)
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'Missing setup of over-short item on Store configuration Setup tab'
					
						-- ROLLBACK
						GOTO ExitWithRollback
					END

				-- Consignment validations
				IF @ysnConsignmentStore = 1
				BEGIN
					DECLARE		@intPaymentMethod INT = 0
					DECLARE		@intCustomerPaymentMethod INT = 0
					DECLARE		@intVendorPaymentMethod INT = 0
					DECLARE		@strCustomerName NVARCHAR(150) = ''

					SELECT		@intPaymentMethod = intPaymentMethodID 
					FROM		tblSMPaymentMethod 
					WHERE		strPaymentMethod = 'ACH'

					SELECT		@intCustomerPaymentMethod = a.intPaymentMethodId,
								@strCustomerName = b.strName
					FROM		tblARCustomer a
					INNER JOIN	tblEMEntity b
					ON			a.intEntityId = b.intEntityId
					WHERE		a.intEntityId = @intEntityCustomerId

					-- DEALER COMMISSION ITEM ID
					IF EXISTS(SELECT TOP 1 1 FROM tblSTStore WHERE intStoreId = @intStoreId AND intConsDealerCommissionItemId IS NULL)
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'Missing setup of Dealer Commission item on Store Consignment configuration Setup tab'
					
						-- ROLLBACK
						GOTO ExitWithRollback
					END

					-- FUEL DISCOUNT ITEM ID
					IF EXISTS(SELECT TOP 1 1 FROM tblSTStore WHERE intStoreId = @intStoreId AND intConsFuelDiscountItemId IS NULL)
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'Missing setup of Fuel Discount item on Store configuration Setup tab'
					
						-- ROLLBACK
						GOTO ExitWithRollback
					END	

					IF @intPaymentMethod != @intCustomerPaymentMethod OR @intCustomerPaymentMethod IS NULL
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'Missing or Incorrect Payment Method for the customer ' + @strCustomerName + '.'

						-- ROLLBACK
						GOTO ExitWithRollback
					END

					--VENDOR VALIDATION
					IF NOT EXISTS(SELECT '' FROM  tblAPVendor WHERE intEntityId = @intEntityCustomerId)
						BEGIN
							SET @ysnUpdateCheckoutStatus = 0
							SET @strStatusMsg = 'Customer ' + @strCustomerName + ' was not configured as a vendor.'
						
							-- ROLLBACK
							GOTO ExitWithRollback
						END
					ELSE
						BEGIN
							SELECT		@intVendorPaymentMethod = a.intPaymentMethodId
							FROM		tblAPVendor a
							WHERE		a.intEntityId = @intEntityCustomerId

							IF @intPaymentMethod != @intVendorPaymentMethod OR @intVendorPaymentMethod IS NULL
							BEGIN
								SET @ysnUpdateCheckoutStatus = 0
								SET @strStatusMsg = 'Missing or Incorrect Payment Method for the vendor ' + @strCustomerName + '.'

								-- ROLLBACK
								GOTO ExitWithRollback
							END
						END

					IF NOT EXISTS(SELECT '' FROM tblEMEntityEFTInformation WHERE intEntityId = @intEntityCustomerId AND intBankId IS NOT NULL)
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'Missing EFT/ACH setup for entity ' + @strCustomerName + '.'

						-- ROLLBACK
						GOTO ExitWithRollback
					END

					--IF @ysnConsMeterReadingsForDollars = 1 AND @ysnConsAddOutsideFuelDiscounts = 1 BEGIN SELECT @ysnConsCashOverShort = 1, @ysnConsIncludeInsideDiscount = 0 END -- Add Outside Discount only
					--ELSE IF @ysnConsMeterReadingsForDollars = 1 AND @ysnConsAddOutsideFuelDiscounts = 0 BEGIN SELECT @ysnConsCashOverShort = 0 END
					--ELSE IF @ysnConsMeterReadingsForDollars = 0 AND @ysnConsAddOutsideFuelDiscounts = 1 BEGIN SELECT @ysnConsCashOverShort = 1, @ysnConsIncludeInsideDiscount = 1 END -- Add Outside and Inside Discount
					--ELSE BEGIN SELECT @ysnConsCashOverShort = 0 END
				END
			END	
		-- ===================================================================
		-- [End] - VALIDATION ------------------------------------------------
		-- ===================================================================


		----------------------------------------------------------------------
		------------------------- POST / UNPOST ------------------------------
		----------------------------------------------------------------------
		IF(@ysnPost = 1)
			BEGIN
				
			DELETE FROM tblSTLotteryProcessError WHERE intCheckoutId = @intCurrentUserId

--PRINT 'PUMP TOTALS'
				----------------------------------------------------------------------
				---------------------------- PUMP TOTALS @strtblSTCheckoutPumpTotals01--------------------------
				----------------------------------------------------------------------
				--http://jira.irelyserver.com/browse/ST-1006
				--http://jira.irelyserver.com/browse/ST-1016

				IF EXISTS(SELECT * FROM tblSTCheckoutPumpTotals WHERE intCheckoutId = @intCheckoutId AND dblAmount > 0)	
					BEGIN
						
						DECLARE @strtblSTCheckoutPumpTotals01 AS NVARCHAR(150) = 'tblSTCheckoutPumpTotals01'


						begin try
							-- For own tax computation
							INSERT INTO @LineItemTaxEntries(
									 [intId]
									,[intDetailId]
									,[intDetailTaxId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[intTaxAccountId]
									,[dblTax]
									,[dblAdjustedTax]
									,[ysnTaxAdjusted]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[ysnTaxExempt]
									,[ysnTaxOnly]
									,[strNotes]
									,[intTempDetailIdForTaxes]
									,[dblCurrencyExchangeRate]
									,[ysnClearExisting]
									,[strTransactionType]
									,[strType]
									,[strSourceTransaction]
									,[intSourceId]
									,[strSourceId]
									,[intHeaderId]
									,[dtmDate]
						)
						SELECT DISTINCT
									 [intId] = CPT.intPumpTotalsId
									,[intDetailId] = NULL
									,[intDetailTaxId] = NULL
									,[intTaxGroupId] = TPI.intTaxGroupId
									,[intTaxCodeId] = TAX.intTaxCodeId
									,[intTaxClassId] = TAX.intTaxClassId
									,[strTaxableByOtherTaxes] = TAX.strTaxableByOtherTaxes
									,[strCalculationMethod] = TAX.strCalculationMethod
									,[dblRate] = TAX.dblRate
									,[intTaxAccountId] = TAX.intTaxAccountId
									--,[dblTax] = TAX.dblTax
									--,[dblAdjustedTax] = TAX.dblAdjustedTax
									,[dblTax] = CASE
													WHEN @strInvoiceTransactionTypeMain = @strCASH
														THEN TAX.dblTax
													WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
														THEN TAX.dblTax * -1
												END
									,[dblAdjustedTax] = CASE
															WHEN @strInvoiceTransactionTypeMain = @strCASH
																THEN TAX.dblAdjustedTax
															WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																THEN TAX.dblAdjustedTax * -1
														END

									,[ysnTaxAdjusted] = 1
									,[ysnSeparateOnInvoice] = 0
									,[ysnCheckoffTax] = TAX.ysnCheckoffTax
									,[ysnTaxExempt] = TAX.ysnTaxExempt
									,[ysnTaxOnly] = TAX.ysnTaxOnly
									,[strNotes] = TAX.strNotes
									,[intTempDetailIdForTaxes] = CPT.intPumpTotalsId        -- Mark for Rank
									,[dblCurrencyExchangeRate] = 0
									,[ysnClearExisting] = 0
									,[strTransactionType] = ''
									,[strType] = ''
									,[strSourceTransaction] = @strtblSTCheckoutPumpTotals01 -- Mark for Rank
									,[intSourceId] = @intCheckoutId
									,[strSourceId] = @intCheckoutId
									,[intHeaderId] = @intCheckoutId
									,[dtmDate] = GETDATE()
							FROM tblSTCheckoutPumpTotals CPT
							JOIN tblICItemUOM UOM 
								ON CPT.intPumpCardCouponId = UOM.intItemUOMId
							JOIN tblSTCheckoutHeader CH 
								ON CPT.intCheckoutId = CH.intCheckoutId
							JOIN tblICItem I 
								ON UOM.intItemId = I.intItemId
							JOIN tblICItemLocation IL 
								ON I.intItemId = IL.intItemId

							-- http://jira.irelyserver.com/browse/ST-1316
							--JOIN tblICItemPricing IP 
							--	ON I.intItemId = IP.intItemId
							--	AND IL.intItemLocationId = IP.intItemLocationId

							JOIN tblSTStore ST 
								ON IL.intLocationId = ST.intCompanyLocationId
							LEFT JOIN tblSTPumpItem TPI 
								ON UOM.intItemUOMId = TPI.intItemUOMId AND ST.intStoreId = TPI.intStoreId
								AND CH.intStoreId = ST.intStoreId	
							JOIN vyuEMEntityCustomerSearch vC 
								ON ST.intCheckoutCustomerId = vC.intEntityId
							CROSS APPLY dbo.fnConstructLineItemTaxDetail (
																				ISNULL(CPT.dblQuantity, 0)						-- Qty
																				, ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0) --[dbo].[fnRoundBanker](CPT.dblPrice, 2) --CAST([dbo].fnRoundBanker(CPT.dblPrice, 2) AS DECIMAL(18,6))	-- Gross Amount
																				, @LineItems
																				, 1										-- is Reversal
																				, I.intItemId							-- Item Id
																				, ST.intCheckoutCustomerId				-- Customer Id
																				, ST.intCompanyLocationId				-- Company Location Id
																				, TPI.intTaxGroupId						-- Tax Group Id
																				, 0										-- 0 Price if not reversal
																				, @dtmCheckoutDate						-- Tax is also computed based on date. Use Checkout date.
																				, vC.intShipToId						-- Ship to Location
																				, 1
																				, 1			                            --@IncludeInvalidCodes
																				, NULL
																				, vC.intFreightTermId					-- FreightTermId
																				, NULL
																				, NULL
																				, 0
																				, 0
																				, UOM.intItemUOMId
																				,NULL									--@CFSiteId
																				,0										--@IsDeliver
																				,0                                      --@IsCFQuote
																				,NULL
																				,NULL
																				,NULL
																		) TAX

								WHERE CPT.intCheckoutId = @intCheckoutId
									AND CPT.dblAmount > 0
									AND TPI.intTaxGroupId IS NOT NULL
									-- AND UOM.ysnStockUnit = CAST(1 AS BIT)
						end try
						begin catch
							SET @strStatusMsg = CAST(ERROR_MESSAGE() AS VARCHAR(MAX))

							-- ROLLBACK
							GOTO ExitWithRollback
						end catch


						-- Insert all Pump Items here using positive amount
						INSERT INTO @EntriesForInvoice(
										 [strSourceTransaction]
										,[strTransactionType]
										,[strType]
										,[intSourceId]
										,[strSourceId]
										,[intInvoiceId]
										,[intEntityCustomerId]
										,[intCompanyLocationId]
										,[intCurrencyId]
										,[intTermId]
										,[dtmDate]
										,[dtmDueDate]
										,[dtmShipDate]
										,[dtmCalculated]
										,[dtmPostDate]
										,[intEntitySalespersonId]
										,[intFreightTermId]
										,[intShipViaId]
										,[intPaymentMethodId]
										,[strInvoiceOriginId]
										,[strPONumber]
										,[strBOLNumber]
										,[strComments]
										,[intShipToLocationId]
										,[intBillToLocationId]
										,[ysnTemplate]
										,[ysnForgiven]
										,[ysnCalculated]
										,[ysnSplitted]
										,[intPaymentId]
										,[intSplitId]
										,[intLoadDistributionHeaderId]
										,[strActualCostId]
										,[intShipmentId]
										,[intTransactionId]
										,[intEntityId]
										,[ysnResetDetails]
										,[ysnRecap] -- RECAP
										,[ysnPost]
										,[intInvoiceDetailId]
										,[intItemId]
										,[ysnInventory]
										,[strItemDescription]
										,[intOrderUOMId]
										,[dblQtyOrdered]
										,[intItemUOMId]
										,[dblQtyShipped]
										,[dblDiscount]
										,[dblPrice]
										,[ysnRefreshPrice]
										,[strMaintenanceType]
										,[strFrequency]
										,[dtmMaintenanceDate]
										,[dblMaintenanceAmount]
										,[dblLicenseAmount]
										,[intTaxGroupId]
										,[ysnRecomputeTax]
										,[intSCInvoiceId]
										,[strSCInvoiceNumber]
										,[intInventoryShipmentItemId]
										,[strShipmentNumber]
										,[intSalesOrderDetailId]
										,[strSalesOrderNumber]
										,[intContractHeaderId]
										,[intContractDetailId]
										,[intShipmentPurchaseSalesContractId]
										,[intTicketId]
										,[intTicketHoursWorkedId]
										,[intSiteId]
										,[strBillingBy]
										,[dblPercentFull]
										,[dblNewMeterReading]
										,[dblPreviousMeterReading]
										,[dblConversionFactor]
										,[intPerformerId]
										,[ysnLeaseBilling]
										,[ysnVirtualMeterReading]
										,[strImportFormat]
										,[dblCOGSAmount]
										,[intTempDetailIdForTaxes]
										,[intConversionAccountId]
										,[intCurrencyExchangeRateTypeId]
										,[intCurrencyExchangeRateId]
										,[dblCurrencyExchangeRate]
										,[intSubCurrencyId]
										,[dblSubCurrencyRate]
										,[intSubLocationId]
										,[intCompanyLocationSubLocationId]
										--,[ysnImportedFromOrigin]
										--,[ysnImportedAsPosted]
									)
									SELECT DISTINCT
										 [strSourceTransaction]		= 'Invoice'
										,[strTransactionType]		= @strInvoiceTransactionTypeMain
										,[strType]					= @strInvoiceTypeMain
										,[intSourceId]				= @intCheckoutId
										,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
										,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
										,[intEntityCustomerId]		= @intEntityCustomerId
										,[intCompanyLocationId]		= @intCompanyLocationId
										,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
										,[intTermId]				= vC.intTermsId						--ADDED
										,[dtmDate]					= @dtmCheckoutDate --GETDATE()
										,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
										,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
										,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
										,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
										,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
										,[intFreightTermId]			= vC.intFreightTermId				--ADDED
										,[intShipViaId]				= vC.intShipViaId					--ADDED
										,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
										,[strInvoiceOriginId]		= NULL -- not sure
										,[strPONumber]				= NULL -- not sure
										,[strBOLNumber]				= NULL -- not sure
										,[strComments]				= @strComments
										,[intShipToLocationId]		= vC.intShipToId					--ADDED
										,[intBillToLocationId]		= NULL
										,[ysnTemplate]				= 0
										,[ysnForgiven]				= 0
										,[ysnCalculated]			= 0 -- not sure
										,[ysnSplitted]				= 0
										,[intPaymentId]				= NULL
										,[intSplitId]				= NULL
										,[intLoadDistributionHeaderId]	= NULL
										,[strActualCostId]			= NULL
										,[intShipmentId]			= NULL
										,[intTransactionId]			= NULL
										,[intEntityId]				= @intCurrentUserId
										,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	  END
										,[ysnRecap]					= @ysnRecap
										,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
										,[intInvoiceDetailId]		= NULL
										,[intItemId]				= I.intItemId
										,[ysnInventory]				= 1
										,[strItemDescription]		= I.strDescription
										,[intOrderUOMId]			= UOM.intItemUOMId
										,[dblQtyOrdered]			= 0 -- CPT.dblQuantity --(Select dblQuantity From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
										,[intItemUOMId]				= UOM.intItemUOMId

										--,[dblQtyShipped]			= ISNULL(CPT.dblQuantity, 0)
										,[dblQtyShipped]			= CASE
																		WHEN @strInvoiceTransactionTypeMain = @strCASH
																			THEN ISNULL(CPT.dblQuantity, 0)
																		WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																			THEN CASE
																					WHEN (ISNULL(CPT.dblQuantity, 0) > 0)
																						-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																						-- If Positive flip the sign to negative
																						THEN (ISNULL(CPT.dblQuantity, 0) * -1)
																					WHEN (ISNULL(CPT.dblQuantity, 0) < 0)
																						-- If Negative flip the sign to positive
																						THEN (ISNULL(CPT.dblQuantity, 0) * 1)
																				END
																	END
																						

										,[dblDiscount]				= 0
										,[dblPrice]					= CASE
																		WHEN @strInvoiceTransactionTypeMain = @strCASH
																		THEN ROUND((ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0) - Tax.[dblAdjustedTax]) / CPT.dblQuantity, 6)
																		WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																		THEN ROUND((ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0) + Tax.[dblAdjustedTax])/ CPT.dblQuantity, 6)
																		END
										--,[dblPrice]					= CASE WHEN @ysnConsignmentStore = 1 THEN ROUND((ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0) - Tax.[dblAdjustedTax]) / CPT.dblQuantity, 6) -- (ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0) - Tax.[dblAdjustedTax]) / CPT.dblQuantity																		
										--								ELSE ROUND((ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0) - Tax.[dblAdjustedTax]) / CPT.dblQuantity, 5) END
										,[ysnRefreshPrice]			= 0
										,[strMaintenanceType]		= NULL
										,[strFrequency]				= NULL
										,[dtmMaintenanceDate]		= NULL
										,[dblMaintenanceAmount]		= NULL
										,[dblLicenseAmount]			= NULL
										,[intTaxGroupId]			= TPI.intTaxGroupId
										,[ysnRecomputeTax]			= 0 -- Should recompute tax only for Pump Total Items
										,[intSCInvoiceId]			= NULL
										,[strSCInvoiceNumber]		= NULL
										,[intInventoryShipmentItemId] = NULL
										,[strShipmentNumber]		= NULL
										,[intSalesOrderDetailId]	= NULL
										,[strSalesOrderNumber]		= NULL
										,[intContractHeaderId]		= NULL
										,[intContractDetailId]		= NULL
										,[intShipmentPurchaseSalesContractId]	= NULL
										,[intTicketId]				= NULL
										,[intTicketHoursWorkedId]	= NULL
										,[intSiteId]				= NULL -- not sure
										,[strBillingBy]				= NULL -- not sure
										,[dblPercentFull]			= NULL
										,[dblNewMeterReading]		= NULL
										,[dblPreviousMeterReading]	= NULL -- not sure
										,[dblConversionFactor]		= NULL -- not sure
										,[intPerformerId]			= NULL -- not sure
										,[ysnLeaseBilling]			= NULL
										,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
										,[strImportFormat]			= @strtblSTCheckoutPumpTotals01 -- Mark for Rank
										,[dblCOGSAmount]			= 0 --IP.dblSalePrice
										,[intTempDetailIdForTaxes]  = CPT.intPumpTotalsId           -- Mark for Rank
										,[intConversionAccountId]	= NULL -- not sure
										,[intCurrencyExchangeRateTypeId]	= NULL
										,[intCurrencyExchangeRateId]		= NULL
										,[dblCurrencyExchangeRate]	= 1.000000
										,[intSubCurrencyId]			= @intCurrencyId
										,[dblSubCurrencyRate]		= 1.000000
										,[intSubLocationId]			= NULL
										,[intCompanyLocationSubLocationId] = tmSite.intCompanyLocationSubLocationId
										--,0
										--,1
							FROM tblSTCheckoutPumpTotals CPT
							JOIN tblICItemUOM UOM 
								ON CPT.intPumpCardCouponId = UOM.intItemUOMId
							JOIN tblSTCheckoutHeader CH 
								ON CPT.intCheckoutId = CH.intCheckoutId
							JOIN tblICItem I 
								ON UOM.intItemId = I.intItemId
							JOIN tblICItemLocation IL 
								ON I.intItemId = IL.intItemId
							JOIN tblSTPumpItem TPI 
								ON UOM.intItemUOMId = TPI.intItemUOMId
							
							-- http://jira.irelyserver.com/browse/ST-1316
							--JOIN tblICItemPricing IP 
							--	ON I.intItemId = IP.intItemId
							--	AND IL.intItemLocationId = IP.intItemLocationId

							JOIN tblSTStore ST 
								ON IL.intLocationId = ST.intCompanyLocationId
								AND CH.intStoreId = ST.intStoreId	
								AND TPI.intStoreId = ST.intStoreId
							JOIN vyuEMEntityCustomerSearch vC 
								ON ST.intCheckoutCustomerId = vC.intEntityId
							LEFT OUTER JOIN
							(
								SELECT 
								   [dblAdjustedTax] = SUM ([dblAdjustedTax])
								 , [intTempDetailIdForTaxes]
								 , [strSourceTransaction]
								FROM
									@LineItemTaxEntries
								GROUP BY
									[intTempDetailIdForTaxes]
									, [strSourceTransaction]
							) Tax
								ON CPT.intPumpTotalsId = Tax.intTempDetailIdForTaxes
								AND Tax.strSourceTransaction = @strtblSTCheckoutPumpTotals01
							LEFT JOIN tblTMSite tmSite
								ON ST.intCompanyLocationId = tmSite.intLocationId AND
									I.intItemId = tmSite.intProduct
							WHERE CPT.intCheckoutId = @intCheckoutId
								AND CPT.dblAmount > 0
								AND TPI.intTaxGroupId IS NOT NULL
							

						-- Insert Department Total Item with Pump Total negative amount 
						-- If DT.intCategoryId = PT.intCategoryId AND DT.dblTotalSalesAmount = 0 AND CPT.dblAmount > 0
						--   Use Department Totals Item
						--   Use Pump Total Amount as negative
						INSERT INTO @EntriesForInvoice(
										 [strSourceTransaction]
										,[strTransactionType]
										,[strType]
										,[intSourceId]
										,[strSourceId]
										,[intInvoiceId]
										,[intEntityCustomerId]
										,[intCompanyLocationId]
										,[intCurrencyId]
										,[intTermId]
										,[dtmDate]
										,[dtmDueDate]
										,[dtmShipDate]
										,[dtmCalculated]
										,[dtmPostDate]
										,[intEntitySalespersonId]
										,[intFreightTermId]
										,[intShipViaId]
										,[intPaymentMethodId]
										,[strInvoiceOriginId]
										,[strPONumber]
										,[strBOLNumber]
										,[strComments]
										,[intShipToLocationId]
										,[intBillToLocationId]
										,[ysnTemplate]
										,[ysnForgiven]
										,[ysnCalculated]
										,[ysnSplitted]
										,[intPaymentId]
										,[intSplitId]
										,[intLoadDistributionHeaderId]
										,[strActualCostId]
										,[intShipmentId]
										,[intTransactionId]
										,[intEntityId]
										,[ysnResetDetails]
										,[ysnRecap] -- RECAP
										,[ysnPost]
										,[intInvoiceDetailId]
										,[intItemId]
										,[ysnInventory]
										,[strItemDescription]
										,[intOrderUOMId]
										,[dblQtyOrdered]
										,[intItemUOMId]
										,[dblQtyShipped]
										,[dblDiscount]
										,[dblPrice]
										,[ysnRefreshPrice]
										,[strMaintenanceType]
										,[strFrequency]
										,[dtmMaintenanceDate]
										,[dblMaintenanceAmount]
										,[dblLicenseAmount]
										,[intTaxGroupId]
										,[ysnRecomputeTax]
										,[intSCInvoiceId]
										,[strSCInvoiceNumber]
										,[intInventoryShipmentItemId]
										,[strShipmentNumber]
										,[intSalesOrderDetailId]
										,[strSalesOrderNumber]
										,[intContractHeaderId]
										,[intContractDetailId]
										,[intShipmentPurchaseSalesContractId]
										,[intTicketId]
										,[intTicketHoursWorkedId]
										,[intSiteId]
										,[strBillingBy]
										,[dblPercentFull]
										,[dblNewMeterReading]
										,[dblPreviousMeterReading]
										,[dblConversionFactor]
										,[intPerformerId]
										,[ysnLeaseBilling]
										,[ysnVirtualMeterReading]
										,[strImportFormat]
										,[dblCOGSAmount]
										,[intTempDetailIdForTaxes]
										,[intConversionAccountId]
										,[intCurrencyExchangeRateTypeId]
										,[intCurrencyExchangeRateId]
										,[dblCurrencyExchangeRate]
										,[intSubCurrencyId]
										,[dblSubCurrencyRate]
										,[intSubLocationId]
										--,[ysnImportedFromOrigin]
										--,[ysnImportedAsPosted]
									)
									SELECT DISTINCT
										 [strSourceTransaction]		= 'Invoice'
										,[strTransactionType]		= @strInvoiceTransactionTypeMain
										,[strType]					= @strInvoiceTypeMain
										,[intSourceId]				= @intCheckoutId
										,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
										,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
										,[intEntityCustomerId]		= @intEntityCustomerId
										,[intCompanyLocationId]		= @intCompanyLocationId
										,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
										,[intTermId]				= vC.intTermsId						--ADDED
										,[dtmDate]					= @dtmCheckoutDate --GETDATE()
										,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
										,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
										,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
										,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
										,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
										,[intFreightTermId]			= vC.intFreightTermId				--ADDED
										,[intShipViaId]				= vC.intShipViaId					--ADDED
										,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
										,[strInvoiceOriginId]		= NULL -- not sure
										,[strPONumber]				= NULL -- not sure
										,[strBOLNumber]				= NULL -- not sure
										,[strComments]				= @strComments
										,[intShipToLocationId]		= vC.intShipToId					--ADDED
										,[intBillToLocationId]		= NULL
										,[ysnTemplate]				= 0
										,[ysnForgiven]				= 0
										,[ysnCalculated]			= 0 -- not sure
										,[ysnSplitted]				= 0
										,[intPaymentId]				= NULL
										,[intSplitId]				= NULL
										,[intLoadDistributionHeaderId]	= NULL
										,[strActualCostId]			= NULL
										,[intShipmentId]			= NULL
										,[intTransactionId]			= NULL
										,[intEntityId]				= @intCurrentUserId
										,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	  END
										,[ysnRecap]					= @ysnRecap
										,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
										,[intInvoiceDetailId]		= NULL
										,[intItemId]				= I.intItemId
										,[ysnInventory]				= 1
										,[strItemDescription]		= I.strDescription
										,[intOrderUOMId]			= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316
										,[dblQtyOrdered]			= 0
										,[intItemUOMId]				= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316

										--,[dblQtyShipped]			= -1
										,[dblQtyShipped]			= CASE
																		-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																		WHEN @strInvoiceTransactionTypeMain = @strCASH
																			THEN -1
																		WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																			THEN 1
																	END

										,[dblDiscount]				= 0
										
										, [dblPrice]				= ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0)

										,[ysnRefreshPrice]			= 0
										,[strMaintenanceType]		= NULL
										,[strFrequency]				= NULL
										,[dtmMaintenanceDate]		= NULL
										,[dblMaintenanceAmount]		= NULL
										,[dblLicenseAmount]			= NULL
										,[intTaxGroupId]			= NULL --@intTaxGroupId
										,[ysnRecomputeTax]			= 0 -- Should recompute tax only for Pump Total Items
										,[intSCInvoiceId]			= NULL
										,[strSCInvoiceNumber]		= NULL
										,[intInventoryShipmentItemId] = NULL
										,[strShipmentNumber]		= NULL
										,[intSalesOrderDetailId]	= NULL
										,[strSalesOrderNumber]		= NULL
										,[intContractHeaderId]		= NULL
										,[intContractDetailId]		= NULL
										,[intShipmentPurchaseSalesContractId]	= NULL
										,[intTicketId]				= NULL
										,[intTicketHoursWorkedId]	= NULL
										,[intSiteId]				= NULL -- not sure
										,[strBillingBy]				= NULL -- not sure
										,[dblPercentFull]			= NULL
										,[dblNewMeterReading]		= NULL
										,[dblPreviousMeterReading]	= NULL -- not sure
										,[dblConversionFactor]		= NULL -- not sure
										,[intPerformerId]			= NULL -- not sure
										,[ysnLeaseBilling]			= NULL
										,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
										,[strImportFormat]			= ''
										,[dblCOGSAmount]			= 0 --IP.dblSalePrice
										,[intTempDetailIdForTaxes]  = NULL
										,[intConversionAccountId]	= NULL -- not sure
										,[intCurrencyExchangeRateTypeId]	= NULL
										,[intCurrencyExchangeRateId]		= NULL
										,[dblCurrencyExchangeRate]	= 1.000000
										,[intSubCurrencyId]			= @intCurrencyId
										,[dblSubCurrencyRate]		= 1.000000
										,[intSubLocationId]			= IL.intSubLocationId
										--,0
										--,1
							FROM tblSTCheckoutDepartmetTotals DT
							JOIN tblSTCheckoutPumpTotals CPT
								ON DT.intCategoryId = CPT.intCategoryId
							JOIN tblICItem I 
								ON DT.intItemId = I.intItemId

							-- http://jira.irelyserver.com/browse/ST-1316
							--JOIN tblICItemUOM UOM 
							--	ON I.intItemId = UOM.intItemId

							JOIN tblSTCheckoutHeader CH 
								ON DT.intCheckoutId = CH.intCheckoutId
								AND CPT.intCheckoutId = CH.intCheckoutId
							JOIN tblICItemLocation IL 
								ON I.intItemId = IL.intItemId

							-- http://jira.irelyserver.com/browse/ST-1316
							--JOIN tblICItemPricing IP 
							--	ON I.intItemId = IP.intItemId
							--	AND IL.intItemLocationId = IP.intItemLocationId
							
							JOIN tblSTStore ST 
								ON IL.intLocationId = ST.intCompanyLocationId
								AND CH.intStoreId = ST.intStoreId
							JOIN vyuEMEntityCustomerSearch vC 
								ON ST.intCheckoutCustomerId = vC.intEntityId
							WHERE CH.intCheckoutId = @intCheckoutId
								-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316
								AND DT.dblTotalSalesAmountComputed = 0
								AND CPT.dblAmount > 0

						-- No need to check ysnStockUnit because ItemMovements have intItemUomId setup for Item
					END
				
				----------------------------------------------------------------------
				------------------------- END PUMP TOTALS ----------------------------
				----------------------------------------------------------------------


--PRINT 'ITEM MOVEMENTS'
				----------------------------------------------------------------------
				---------------------------- ITEM MOVEMENTS --------------------------
				----------------------------------------------------------------------
				
				IF EXISTS(SELECT * FROM tblSTCheckoutItemMovements WHERE intCheckoutId = @intCheckoutId)
					BEGIN																																																	
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- IM.intQtySold
											,[intItemUOMId]				= UOM.intItemUOMId

											--,[dblQtyShipped]			= ISNULL(IM.intQtySold, 0)
											,[dblQtyShipped]			= CASE
																		WHEN @strInvoiceTransactionTypeMain = @strCASH
																			THEN ISNULL(IM.intQtySold, 0)
																		WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																			THEN CASE
																					WHEN (ISNULL(IM.intQtySold, 0) > 0)
																						-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																						-- If Positive flip the sign to negative
																						THEN (ISNULL(IM.intQtySold, 0) * -1)
																					WHEN (ISNULL(IM.intQtySold, 0) < 0)
																						-- If Negative flip the sign to positive
																						THEN (ISNULL(IM.intQtySold, 0) * 1)
																				END
																	END

											,[dblDiscount]				= 0 --ISNULL(IM.dblDiscountAmount, 0)
											,[dblPrice]					= CASE 
																			WHEN ISNULL(IM.intQtySold, 0) = 0
																				THEN 0
																			ELSE 
																				CAST(ISNULL(IM.dblTotalSales, 0) / ISNULL(IM.intQtySold, 0) AS DECIMAL(18,6))
																		END
											-- ,[dblPrice]					= ISNULL( ( ISNULL(IM.dblTotalSales, 0) + ISNULL(IM.dblDiscountAmount, 0) ) / ISNULL(NULLIF(IM.intQtySold, 0), 0) ,0 )
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= ''
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = NULL
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutItemMovements IM
								JOIN tblICItemUOM UOM 
									ON IM.intItemUPCId = UOM.intItemUOMId
								JOIN tblSTCheckoutHeader CH 
									ON IM.intCheckoutId = CH.intCheckoutId
								JOIN tblICItem I 
									ON UOM.intItemId = I.intItemId
								JOIN tblICItemLocation IL 
									ON I.intItemId = IL.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemPricing IP 
								--	ON I.intItemId = IP.intItemId
								--	AND IL.intItemLocationId = IP.intItemLocationId

								JOIN tblSTStore ST 
									ON IL.intLocationId = ST.intCompanyLocationId
									AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC 
									ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE IM.intCheckoutId = @intCheckoutId
									--AND IM.dblTotalSales <> 0

						-- No need to check ysnStockUnit because ItemMovements have intItemUomId setup for Item
					END
				
				----------------------------------------------------------------------
				---------------------------- ITEM MOVEMENTS --------------------------
				----------------------------------------------------------------------

								
				IF @ysnConsignmentStore = 1
				BEGIN
				--SKIP THIS CODE --CS-329
				IF 1 = 0
				BEGIN 
					--PRINT 'DEPARTMENT MOVEMENTS'
					----------------------------------------------------------------------
					------------------------- DEPARTMENT TOTALS --------------------------
					----------------------------------------------------------------------
					IF EXISTS(SELECT * FROM tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId)
						BEGIN																																																																																																																																															
								INSERT INTO @EntriesForInvoice(
													[strSourceTransaction]
												,[strTransactionType]
												,[strType]
												,[intSourceId]
												,[strSourceId]
												,[intInvoiceId]
												,[intEntityCustomerId]
												,[intCompanyLocationId]
												,[intCurrencyId]
												,[intTermId]
												,[dtmDate]
												,[dtmDueDate]
												,[dtmShipDate]
												,[dtmCalculated]
												,[dtmPostDate]
												,[intEntitySalespersonId]
												,[intFreightTermId]
												,[intShipViaId]
												,[intPaymentMethodId]
												,[strInvoiceOriginId]
												,[strPONumber]
												,[strBOLNumber]
												,[strComments]
												,[intShipToLocationId]
												,[intBillToLocationId]
												,[ysnTemplate]
												,[ysnForgiven]
												,[ysnCalculated]
												,[ysnSplitted]
												,[intPaymentId]
												,[intSplitId]
												,[intLoadDistributionHeaderId]
												,[strActualCostId]
												,[intShipmentId]
												,[intTransactionId]
												,[intEntityId]
												,[ysnResetDetails]
												,[ysnRecap] -- RECAP
												,[ysnPost]
												,[intInvoiceDetailId]
												,[intItemId]
												,[ysnInventory]
												,[strItemDescription]
												,[intOrderUOMId]
												,[dblQtyOrdered]
												,[intItemUOMId]
												,[dblQtyShipped]
												,[dblDiscount]
												,[dblPrice]
												,[ysnRefreshPrice]
												,[strMaintenanceType]
												,[strFrequency]
												,[dtmMaintenanceDate]
												,[dblMaintenanceAmount]
												,[dblLicenseAmount]
												,[intTaxGroupId]
												,[ysnRecomputeTax]
												,[intSCInvoiceId]
												,[strSCInvoiceNumber]
												,[intInventoryShipmentItemId]
												,[strShipmentNumber]
												,[intSalesOrderDetailId]
												,[strSalesOrderNumber]
												,[intContractHeaderId]
												,[intContractDetailId]
												,[intShipmentPurchaseSalesContractId]
												,[intTicketId]
												,[intTicketHoursWorkedId]
												,[intSiteId]
												,[strBillingBy]
												,[dblPercentFull]
												,[dblNewMeterReading]
												,[dblPreviousMeterReading]
												,[dblConversionFactor]
												,[intPerformerId]
												,[ysnLeaseBilling]
												,[ysnVirtualMeterReading]
												,[strImportFormat]
												,[dblCOGSAmount]
												,[intTempDetailIdForTaxes]
												,[intConversionAccountId]
												,[intCurrencyExchangeRateTypeId]
												,[intCurrencyExchangeRateId]
												,[dblCurrencyExchangeRate]
												,[intSubCurrencyId]
												,[dblSubCurrencyRate]
												--,[ysnImportedFromOrigin]
												--,[ysnImportedAsPosted]
											)
											SELECT DISTINCT
													[strSourceTransaction]		= 'Invoice'
												,[strTransactionType]		= @strInvoiceTransactionTypeMain
												,[strType]					= @strInvoiceTypeMain
												,[intSourceId]				= @intCheckoutId
												,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
												,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
												,[intEntityCustomerId]		= @intEntityCustomerId
												,[intCompanyLocationId]		= @intCompanyLocationId
												,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
												,[intTermId]				= vC.intTermsId						--ADDED
												,[dtmDate]					= @dtmCheckoutDate --GETDATE()
												,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
												,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
												,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
												,[intFreightTermId]			= vC.intFreightTermId				--ADDED
												,[intShipViaId]				= vC.intShipViaId					--ADDED
												,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
												,[strInvoiceOriginId]		= NULL -- not sure
												,[strPONumber]				= NULL -- not sure
												,[strBOLNumber]				= NULL -- not sure
												,[strComments]				= @strComments
												,[intShipToLocationId]		= vC.intShipToId					--ADDED
												,[intBillToLocationId]		= NULL
												,[ysnTemplate]				= 0
												,[ysnForgiven]				= 0
												,[ysnCalculated]			= 0 -- not sure
												,[ysnSplitted]				= 0
												,[intPaymentId]				= NULL
												,[intSplitId]				= NULL
												,[intLoadDistributionHeaderId]	= NULL
												,[strActualCostId]			= NULL
												,[intShipmentId]			= NULL
												,[intTransactionId]			= NULL
												,[intEntityId]				= @intCurrentUserId
												,[ysnResetDetails]			= CASE
																				WHEN @intCurrentInvoiceId IS NOT NULL
																					THEN CAST(0 AS BIT)
																				ELSE CAST(1 AS BIT)
																				END
												,[ysnRecap]					= @ysnRecap
												,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
												,[intInvoiceDetailId]		= NULL
												,[intItemId]				= I.intItemId
												,[ysnInventory]				= 1
												,[strItemDescription]		= I.strDescription
												,[intOrderUOMId]			= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316
												,[dblQtyOrdered]			= 0
												,[intItemUOMId]				= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316

												--,[dblQtyShipped]			= DT.dblCalculatedInvoiceQty
												,[dblQtyShipped]			= CASE
																				WHEN @strInvoiceTransactionTypeMain = @strCASH
																					THEN ISNULL(DT.dblCalculatedInvoiceQty, 0)
																				WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																					THEN ISNULL(DT.dblCalculatedInvoiceQty, 0) * -1
																					END
												,[dblDiscount]				= 0
												,[dblPrice]					=  DT.dblCalculatedInvoicePrice
												,[ysnRefreshPrice]			= 0
												,[strMaintenanceType]		= NULL
												,[strFrequency]				= NULL
												,[dtmMaintenanceDate]		= NULL
												,[dblMaintenanceAmount]		= NULL
												,[dblLicenseAmount]			= NULL
												,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
												,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
												,[intSCInvoiceId]			= NULL
												,[strSCInvoiceNumber]		= NULL
												,[intInventoryShipmentItemId] = NULL
												,[strShipmentNumber]		= NULL
												,[intSalesOrderDetailId]	= NULL
												,[strSalesOrderNumber]		= NULL
												,[intContractHeaderId]		= NULL
												,[intContractDetailId]		= NULL
												,[intShipmentPurchaseSalesContractId]	= NULL
												,[intTicketId]				= NULL
												,[intTicketHoursWorkedId]	= NULL
												,[intSiteId]				= NULL -- not sure
												,[strBillingBy]				= NULL -- not sure
												,[dblPercentFull]			= NULL
												,[dblNewMeterReading]		= NULL
												,[dblPreviousMeterReading]	= NULL -- not sure
												,[dblConversionFactor]		= NULL -- not sure
												,[intPerformerId]			= NULL -- not sure
												,[ysnLeaseBilling]			= NULL
												,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
												,[strImportFormat]			= ''
												,[dblCOGSAmount]			= 0 --IP.dblSalePrice
												,[intTempDetailIdForTaxes]  = NULL
												,[intConversionAccountId]	= NULL -- not sure
												,[intCurrencyExchangeRateTypeId]	= NULL
												,[intCurrencyExchangeRateId]		= NULL
												,[dblCurrencyExchangeRate]	= 1.000000
												,[intSubCurrencyId]			= NULL
												,[dblSubCurrencyRate]		= 1.000000
												--,0
												--,1
									FROM vyuSTConsCheckoutDepartmentInvoiceEntries DT
									JOIN tblICItem I 
										ON DT.intItemId = I.intItemId

									-- http://jira.irelyserver.com/browse/ST-1316
									--JOIN tblICItemUOM UOM 
									--	ON I.intItemId = UOM.intItemId

									JOIN tblSTCheckoutHeader CH 
										ON DT.intCheckoutId = CH.intCheckoutId
									JOIN tblICItemLocation IL 
										ON I.intItemId = IL.intItemId

									-- http://jira.irelyserver.com/browse/ST-1316
									--JOIN tblICItemPricing IP 
									--	ON I.intItemId = IP.intItemId
									--	AND IL.intItemLocationId = IP.intItemLocationId

									JOIN tblSTStore ST 
										ON IL.intLocationId = ST.intCompanyLocationId
										AND CH.intStoreId = ST.intStoreId
									JOIN vyuEMEntityCustomerSearch vC 
										ON ST.intCheckoutCustomerId = vC.intEntityId
									WHERE DT.intCheckoutId = @intCheckoutId
										-- AND DT.dblTotalSalesAmountComputed <> 0 -- ST-1121
										-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316
						END
					----------------------------------------------------------------------
					--------------------- END DEPARTMENT TOTALS --------------------------
					----------------------------------------------------------------------
				END
				END
				ELSE
				BEGIN
					--PRINT 'DEPARTMENT MOVEMENTS'
					----------------------------------------------------------------------
					------------------------- DEPARTMENT TOTALS --------------------------
					----------------------------------------------------------------------
					IF EXISTS(SELECT * FROM tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId)
						BEGIN																																																																																																																																															
								INSERT INTO @EntriesForInvoice(
													[strSourceTransaction]
												,[strTransactionType]
												,[strType]
												,[intSourceId]
												,[strSourceId]
												,[intInvoiceId]
												,[intEntityCustomerId]
												,[intCompanyLocationId]
												,[intCurrencyId]
												,[intTermId]
												,[dtmDate]
												,[dtmDueDate]
												,[dtmShipDate]
												,[dtmCalculated]
												,[dtmPostDate]
												,[intEntitySalespersonId]
												,[intFreightTermId]
												,[intShipViaId]
												,[intPaymentMethodId]
												,[strInvoiceOriginId]
												,[strPONumber]
												,[strBOLNumber]
												,[strComments]
												,[intShipToLocationId]
												,[intBillToLocationId]
												,[ysnTemplate]
												,[ysnForgiven]
												,[ysnCalculated]
												,[ysnSplitted]
												,[intPaymentId]
												,[intSplitId]
												,[intLoadDistributionHeaderId]
												,[strActualCostId]
												,[intShipmentId]
												,[intTransactionId]
												,[intEntityId]
												,[ysnResetDetails]
												,[ysnRecap] -- RECAP
												,[ysnPost]
												,[intInvoiceDetailId]
												,[intItemId]
												,[ysnInventory]
												,[strItemDescription]
												,[intOrderUOMId]
												,[dblQtyOrdered]
												,[intItemUOMId]
												,[dblQtyShipped]
												,[dblDiscount]
												,[dblPrice]
												,[ysnRefreshPrice]
												,[strMaintenanceType]
												,[strFrequency]
												,[dtmMaintenanceDate]
												,[dblMaintenanceAmount]
												,[dblLicenseAmount]
												,[intTaxGroupId]
												,[ysnRecomputeTax]
												,[intSCInvoiceId]
												,[strSCInvoiceNumber]
												,[intInventoryShipmentItemId]
												,[strShipmentNumber]
												,[intSalesOrderDetailId]
												,[strSalesOrderNumber]
												,[intContractHeaderId]
												,[intContractDetailId]
												,[intShipmentPurchaseSalesContractId]
												,[intTicketId]
												,[intTicketHoursWorkedId]
												,[intSiteId]
												,[strBillingBy]
												,[dblPercentFull]
												,[dblNewMeterReading]
												,[dblPreviousMeterReading]
												,[dblConversionFactor]
												,[intPerformerId]
												,[ysnLeaseBilling]
												,[ysnVirtualMeterReading]
												,[strImportFormat]
												,[dblCOGSAmount]
												,[intTempDetailIdForTaxes]
												,[intConversionAccountId]
												,[intCurrencyExchangeRateTypeId]
												,[intCurrencyExchangeRateId]
												,[dblCurrencyExchangeRate]
												,[intSubCurrencyId]
												,[dblSubCurrencyRate]
												--,[ysnImportedFromOrigin]
												--,[ysnImportedAsPosted]
											)
											SELECT DISTINCT
													[strSourceTransaction]		= 'Invoice'
												,[strTransactionType]		= @strInvoiceTransactionTypeMain
												,[strType]					= @strInvoiceTypeMain
												,[intSourceId]				= @intCheckoutId
												,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
												,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
												,[intEntityCustomerId]		= @intEntityCustomerId
												,[intCompanyLocationId]		= @intCompanyLocationId
												,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
												,[intTermId]				= vC.intTermsId						--ADDED
												,[dtmDate]					= @dtmCheckoutDate --GETDATE()
												,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
												,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
												,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
												,[intFreightTermId]			= vC.intFreightTermId				--ADDED
												,[intShipViaId]				= vC.intShipViaId					--ADDED
												,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
												,[strInvoiceOriginId]		= NULL -- not sure
												,[strPONumber]				= NULL -- not sure
												,[strBOLNumber]				= NULL -- not sure
												,[strComments]				= @strComments
												,[intShipToLocationId]		= vC.intShipToId					--ADDED
												,[intBillToLocationId]		= NULL
												,[ysnTemplate]				= 0
												,[ysnForgiven]				= 0
												,[ysnCalculated]			= 0 -- not sure
												,[ysnSplitted]				= 0
												,[intPaymentId]				= NULL
												,[intSplitId]				= NULL
												,[intLoadDistributionHeaderId]	= NULL
												,[strActualCostId]			= NULL
												,[intShipmentId]			= NULL
												,[intTransactionId]			= NULL
												,[intEntityId]				= @intCurrentUserId
												,[ysnResetDetails]			= CASE
																				WHEN @intCurrentInvoiceId IS NOT NULL
																					THEN CAST(0 AS BIT)
																				ELSE CAST(1 AS BIT)
																				END
												,[ysnRecap]					= @ysnRecap
												,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
												,[intInvoiceDetailId]		= NULL
												,[intItemId]				= I.intItemId
												,[ysnInventory]				= 1
												,[strItemDescription]		= I.strDescription
												,[intOrderUOMId]			= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316
												,[dblQtyOrdered]			= 0
												,[intItemUOMId]				= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316

												--,[dblQtyShipped]			= DT.dblCalculatedInvoiceQty
												,[dblQtyShipped]			= CASE
																				WHEN @strInvoiceTransactionTypeMain = @strCASH
																					THEN ISNULL(DT.dblCalculatedInvoiceQty, 0)
																				WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																					THEN CASE
																							WHEN (ISNULL(DT.dblCalculatedInvoiceQty, 0) > 0)
																								-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																								-- If Positive flip the sign to negative
																								THEN (ISNULL(DT.dblCalculatedInvoiceQty, 0) * -1)
																							WHEN (ISNULL(DT.dblCalculatedInvoiceQty, 0) < 0)
																								-- If Negative flip the sign to positive
																								THEN (ISNULL(DT.dblCalculatedInvoiceQty, 0) * 1)
																						END
																			END

												,[dblDiscount]				= 0
												,[dblPrice]					=  DT.dblCalculatedInvoicePrice
												,[ysnRefreshPrice]			= 0
												,[strMaintenanceType]		= NULL
												,[strFrequency]				= NULL
												,[dtmMaintenanceDate]		= NULL
												,[dblMaintenanceAmount]		= NULL
												,[dblLicenseAmount]			= NULL
												,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
												,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
												,[intSCInvoiceId]			= NULL
												,[strSCInvoiceNumber]		= NULL
												,[intInventoryShipmentItemId] = NULL
												,[strShipmentNumber]		= NULL
												,[intSalesOrderDetailId]	= NULL
												,[strSalesOrderNumber]		= NULL
												,[intContractHeaderId]		= NULL
												,[intContractDetailId]		= NULL
												,[intShipmentPurchaseSalesContractId]	= NULL
												,[intTicketId]				= NULL
												,[intTicketHoursWorkedId]	= NULL
												,[intSiteId]				= NULL -- not sure
												,[strBillingBy]				= NULL -- not sure
												,[dblPercentFull]			= NULL
												,[dblNewMeterReading]		= NULL
												,[dblPreviousMeterReading]	= NULL -- not sure
												,[dblConversionFactor]		= NULL -- not sure
												,[intPerformerId]			= NULL -- not sure
												,[ysnLeaseBilling]			= NULL
												,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
												,[strImportFormat]			= ''
												,[dblCOGSAmount]			= 0 --IP.dblSalePrice
												,[intTempDetailIdForTaxes]  = NULL
												,[intConversionAccountId]	= NULL -- not sure
												,[intCurrencyExchangeRateTypeId]	= NULL
												,[intCurrencyExchangeRateId]		= NULL
												,[dblCurrencyExchangeRate]	= 1.000000
												,[intSubCurrencyId]			= NULL
												,[dblSubCurrencyRate]		= 1.000000
												--,0
												--,1
									FROM vyuSTCheckoutDepartmentInvoiceEntries DT
									JOIN tblICItem I 
										ON DT.intItemId = I.intItemId

									-- http://jira.irelyserver.com/browse/ST-1316
									--JOIN tblICItemUOM UOM 
									--	ON I.intItemId = UOM.intItemId

									JOIN tblSTCheckoutHeader CH 
										ON DT.intCheckoutId = CH.intCheckoutId
									JOIN tblICItemLocation IL 
										ON I.intItemId = IL.intItemId

									-- http://jira.irelyserver.com/browse/ST-1316
									--JOIN tblICItemPricing IP 
									--	ON I.intItemId = IP.intItemId
									--	AND IL.intItemLocationId = IP.intItemLocationId

									JOIN tblSTStore ST 
										ON IL.intLocationId = ST.intCompanyLocationId
										AND CH.intStoreId = ST.intStoreId
									JOIN vyuEMEntityCustomerSearch vC 
										ON ST.intCheckoutCustomerId = vC.intEntityId
									WHERE DT.intCheckoutId = @intCheckoutId
										-- AND DT.dblTotalSalesAmountComputed <> 0 -- ST-1121
										-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316
						END
					----------------------------------------------------------------------
					--------------------- END DEPARTMENT TOTALS --------------------------
					----------------------------------------------------------------------
				END


--PRINT 'SALES TAX MOVEMENTS'
				----------------------------------------------------------------------
				-------------------------- SALES TAX TOTALS --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutSalesTaxTotals WHERE intCheckoutId = @intCheckoutId AND dblTotalTax > 0)
					BEGIN																																					
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316

											--,[dblQtyShipped]			= 1
											,[dblQtyShipped]			= CASE
																		-- Refference: http://jira.irelyserver.com/browse/ST-1558
																			WHEN @strInvoiceTransactionTypeMain = @strCASH
																				THEN 1
																			WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																				THEN -1
																		END

											,[dblDiscount]				= 0
											,[dblPrice]					= ISNULL(STT.dblTotalTax, 0)
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= ''
											,[dblCOGSAmount]			= 0 -- IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = NULL
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutSalesTaxTotals STT
								JOIN tblICItem I 
									ON STT.intItemId = I.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemUOM UOM 
								--	ON I.intItemId = UOM.intItemId
								
								JOIN tblSTCheckoutHeader CH 
									ON STT.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL 
									ON I.intItemId = IL.intItemId
								
								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemPricing IP 
								--	ON I.intItemId = IP.intItemId
								--	AND IL.intItemLocationId = IP.intItemLocationId

								JOIN tblSTStore ST 
									ON IL.intLocationId = ST.intCompanyLocationId
									AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC 
									ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE STT.intCheckoutId = @intCheckoutId
									AND STT.dblTotalTax > 0
									-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316
					END
				----------------------------------------------------------------------
				---------------------- END SALES TAX TOTALS --------------------------
				----------------------------------------------------------------------


--PRINT 'PAYMENT OPTIONS'
				IF @ysnConsignmentStore = 1
				BEGIN
				----------------------------------------------------------------------
				-------------------------- PAYMENT OPTIONS ---------------------------
				----------------------------------------------------------------------
				--http://jira.irelyserver.com/browse/ST-1007
				IF EXISTS(SELECT * FROM tblSTCheckoutPaymentOptions WHERE intCheckoutId = @intCheckoutId AND dblAmount != 0)
					BEGIN
						IF @strConsInvoiceType = 'CSFuelInvoice'
						BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316

											--,[dblQtyShipped]			= CASE
											--									WHEN ISNULL(CPO.dblAmount, 0) > 0
											--										THEN -1
											--									WHEN ISNULL(CPO.dblAmount, 0) < 0 
											--										THEN 1
											--							END
											,[dblQtyShipped]			= CASE
																					-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																					WHEN @strInvoiceTransactionTypeMain = @strCASH
																						THEN -1
																					WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																						THEN 1
																				END
											,[dblDiscount]				= 0

											--,[dblPrice]					= CASE
											--									WHEN ISNULL(CPO.dblAmount, 0) > 0
											--										THEN ISNULL(CPO.dblAmount, 0)
											--									WHEN ISNULL(CPO.dblAmount, 0) < 0 
											--										THEN (ISNULL(CPO.dblAmount, 0) * -1)
											,[dblPrice]					= ISNULL(CPO.dblConsAmountForInvoice,0) -- Reference: http://jira.irelyserver.com/browse/CS-327
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= ''
											,[dblCOGSAmount]			= 0 -- IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = NULL
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutPaymentOptions CPO
								JOIN tblICItem I 
									ON CPO.intItemId = I.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemUOM UOM 
								--	ON I.intItemId = UOM.intItemId

								JOIN tblSTCheckoutHeader CH 
									ON CPO.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL 
									ON I.intItemId = IL.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemPricing IP 
								--	ON I.intItemId = IP.intItemId
								--	AND IL.intItemLocationId = IP.intItemLocationId

								JOIN tblSTStore ST 
									ON IL.intLocationId = ST.intCompanyLocationId
									AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC 
									ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE CPO.intCheckoutId = @intCheckoutId
									AND (ISNULL(CPO.dblAmount, 0) != 0)		-- Make No Entry on Sales Invoice If Payment Option Amount = 0
									-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316
									AND CPO.dblConsAmountForInvoice <> 0

							INSERT INTO @EntriesForCSCreditMemo(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= 'Credit Memo'
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316

											--,[dblQtyShipped]			= CASE
											--									WHEN ISNULL(CPO.dblAmount, 0) > 0
											--										THEN -1
											--									WHEN ISNULL(CPO.dblAmount, 0) < 0 
											--										THEN 1
											--							END
											--,[dblQtyShipped]			= CASE
											--										-- Refference:  http://jira.irelyserver.com/browse/ST-1558
											--										WHEN @strInvoiceTransactionTypeMain = @strCASH
											--											THEN -1
											--										WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
											--											THEN 1
											--									END
											,[dblQtyShipped]			= 1
											,[dblDiscount]				= 0
											--,[dblPrice]					= CASE
											--									WHEN ISNULL(CPO.dblAmount, 0) > 0
											--										THEN ISNULL(CPO.dblAmount, 0)
											--									WHEN ISNULL(CPO.dblAmount, 0) < 0 
											--										THEN (ISNULL(CPO.dblAmount, 0) * -1)
											,[dblPrice]					= ISNULL(CPO.dblConsAmountForCreditMemo, 0) -- Reference: http://jira.irelyserver.com/browse/CS-327
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= ''
											,[dblCOGSAmount]			= 0 -- IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = NULL
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutPaymentOptions CPO
								JOIN tblICItem I 
									ON CPO.intItemId = I.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemUOM UOM 
								--	ON I.intItemId = UOM.intItemId

								JOIN tblSTCheckoutHeader CH 
									ON CPO.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL 
									ON I.intItemId = IL.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemPricing IP 
								--	ON I.intItemId = IP.intItemId
								--	AND IL.intItemLocationId = IP.intItemLocationId

								JOIN tblSTStore ST 
									ON IL.intLocationId = ST.intCompanyLocationId
									AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC 
									ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE CPO.intCheckoutId = @intCheckoutId
									AND (ISNULL(CPO.dblAmount, 0) != 0)		-- Make No Entry on Sales Invoice If Payment Option Amount = 0
									-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316									
									AND CPO.dblConsAmountForCreditMemo <> 0
						END
						ELSE
						BEGIN	
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316

											--,[dblQtyShipped]			= CASE
											--									WHEN ISNULL(CPO.dblAmount, 0) > 0
											--										THEN -1
											--									WHEN ISNULL(CPO.dblAmount, 0) < 0 
											--										THEN 1
											--							END
											,[dblQtyShipped]			= CASE
																					-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																					WHEN @strInvoiceTransactionTypeMain = @strCASH
																						THEN -1
																					WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																						THEN 1
																				END
											,[dblDiscount]				= 0

											--,[dblPrice]					= CASE
											--									WHEN ISNULL(CPO.dblAmount, 0) > 0
											--										THEN ISNULL(CPO.dblAmount, 0)
											--									WHEN ISNULL(CPO.dblAmount, 0) < 0 
											--										THEN (ISNULL(CPO.dblAmount, 0) * -1)
											,[dblPrice]					= ISNULL(CPO.dblAmount,0)
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= ''
											,[dblCOGSAmount]			= 0 -- IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = NULL
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutPaymentOptions CPO
								JOIN tblICItem I 
									ON CPO.intItemId = I.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemUOM UOM 
								--	ON I.intItemId = UOM.intItemId

								JOIN tblSTCheckoutHeader CH 
									ON CPO.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL 
									ON I.intItemId = IL.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemPricing IP 
								--	ON I.intItemId = IP.intItemId
								--	AND IL.intItemLocationId = IP.intItemLocationId

								JOIN tblSTStore ST 
									ON IL.intLocationId = ST.intCompanyLocationId
									AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC 
									ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE CPO.intCheckoutId = @intCheckoutId
									AND (ISNULL(CPO.dblAmount, 0) != 0)		-- Make No Entry on Sales Invoice If Payment Option Amount = 0
									-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316
						END			
					END
				----------------------------------------------------------------------
				----------------------- END PAYMENT OPTIONS --------------------------
				----------------------------------------------------------------------
				END

				ELSE
				BEGIN
				----------------------------------------------------------------------
				-------------------------- PAYMENT OPTIONS ---------------------------
				----------------------------------------------------------------------
				--http://jira.irelyserver.com/browse/ST-1007
				IF EXISTS(SELECT * FROM tblSTCheckoutPaymentOptions WHERE intCheckoutId = @intCheckoutId AND dblAmount != 0)
					BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= NULL -- UOM.intItemUOMId http://jira.irelyserver.com/browse/ST-1316

											--,[dblQtyShipped]			= CASE
											--									WHEN ISNULL(CPO.dblAmount, 0) > 0
											--										THEN -1
											--									WHEN ISNULL(CPO.dblAmount, 0) < 0 
											--										THEN 1
											--							END
											,[dblQtyShipped]			= CASE
																			-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																			WHEN @strInvoiceTransactionTypeMain = @strCASH
																				THEN -1
																			WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																				THEN 1
																		END

											,[dblDiscount]				= 0

											--,[dblPrice]					= CASE
											--									WHEN ISNULL(CPO.dblAmount, 0) > 0
											--										THEN ISNULL(CPO.dblAmount, 0)
											--									WHEN ISNULL(CPO.dblAmount, 0) < 0 
											--										THEN (ISNULL(CPO.dblAmount, 0) * -1)
											,[dblPrice]					=  ISNULL(CPO.dblAmount, 0)
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= ''
											,[dblCOGSAmount]			= 0 -- IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = NULL
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutPaymentOptions CPO
								JOIN tblICItem I 
									ON CPO.intItemId = I.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemUOM UOM 
								--	ON I.intItemId = UOM.intItemId

								JOIN tblSTCheckoutHeader CH 
									ON CPO.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL 
									ON I.intItemId = IL.intItemId

								-- http://jira.irelyserver.com/browse/ST-1316
								--JOIN tblICItemPricing IP 
								--	ON I.intItemId = IP.intItemId
								--	AND IL.intItemLocationId = IP.intItemLocationId

								JOIN tblSTStore ST 
									ON IL.intLocationId = ST.intCompanyLocationId
									AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC 
									ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE CPO.intCheckoutId = @intCheckoutId
									AND (ISNULL(CPO.dblAmount, 0) != 0)		-- Make No Entry on Sales Invoice If Payment Option Amount = 0
									-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316
					END
				----------------------------------------------------------------------
				----------------------- END PAYMENT OPTIONS --------------------------
				----------------------------------------------------------------------
				END	


--PRINT 'CUSTOMER CHARGES'
				----------------------------------------------------------------------
				--------- CUSTOMER CHARGES @strtblSTCheckoutCustomerCharges01---------
				----------------------------------------------------------------------
				--http://jira.irelyserver.com/browse/ST-1020
				IF EXISTS(SELECT * FROM tblSTCheckoutCustomerCharges WHERE intCheckoutId = @intCheckoutId AND dblAmount != 0) --AND intProduct IS NOT NULL)
					BEGIN
						DECLARE @strtblSTCheckoutCustomerCharges01 AS NVARCHAR(150) = 'tblSTCheckoutCustomerCharges01'

						-- For own tax computation for Customer CHarges that has Fuel Item
						begin try
							INSERT INTO @LineItemTaxEntries(
										 [intId]
										,[intDetailId]
										,[intDetailTaxId]
										,[intTaxGroupId]
										,[intTaxCodeId]
										,[intTaxClassId]
										,[strTaxableByOtherTaxes]
										,[strCalculationMethod]
										,[dblRate]
										,[intTaxAccountId]
										,[dblTax]
										,[dblAdjustedTax]
										,[ysnTaxAdjusted]
										,[ysnSeparateOnInvoice]
										,[ysnCheckoffTax]
										,[ysnTaxExempt]
										,[ysnTaxOnly]
										,[strNotes]
										,[intTempDetailIdForTaxes]
										,[dblCurrencyExchangeRate]
										,[ysnClearExisting]
										,[strTransactionType]
										,[strType]
										,[strSourceTransaction]
										,[intSourceId]
										,[strSourceId]
										,[intHeaderId]
										,[dtmDate]
							)
							SELECT
										 [intId] = CC.intCustChargeId
										,[intDetailId] = NULL
										,[intDetailTaxId] = NULL
										,[intTaxGroupId] = TPI.intTaxGroupId
										,[intTaxCodeId] = FuelTax.intTaxCodeId
										,[intTaxClassId] = FuelTax.intTaxClassId
										,[strTaxableByOtherTaxes] = FuelTax.strTaxableByOtherTaxes
										,[strCalculationMethod] = FuelTax.strCalculationMethod
										,[dblRate] = FuelTax.dblRate
										,[intTaxAccountId] = FuelTax.intTaxAccountId

										,[dblTax] = FuelTax.dblTax
										,[dblAdjustedTax] = FuelTax.dblAdjustedTax
										--,[dblTax] = CASE
										--				WHEN @strInvoiceTransactionTypeMain = @strCASH
										--					THEN FuelTax.dblTax
										--				WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
										--					THEN FuelTax.dblTax * -1
										--			END
										--,[dblAdjustedTax] = CASE
										--						WHEN @strInvoiceTransactionTypeMain = @strCASH
										--							THEN FuelTax.dblAdjustedTax
										--						WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
										--							THEN FuelTax.dblAdjustedTax * -1
										--					END

										,[ysnTaxAdjusted] = 1
										,[ysnSeparateOnInvoice] = 0
										,[ysnCheckoffTax] = FuelTax.ysnCheckoffTax
										,[ysnTaxExempt] = FuelTax.ysnTaxExempt
										,[ysnTaxOnly] = FuelTax.ysnTaxOnly
										,[strNotes] = FuelTax.strNotes
										,[intTempDetailIdForTaxes] = CC.intCustChargeId             -- Mark for Rank
										,[dblCurrencyExchangeRate] = 0
										,[ysnClearExisting] = 0
										,[strTransactionType] = ''
										,[strType] = ''
										,[strSourceTransaction] = @strtblSTCheckoutCustomerCharges01 -- Mark for Rank
										,[intSourceId] = @intCheckoutId
										,[strSourceId] = @intCheckoutId
										,[intHeaderId] = @intCheckoutId
										,[dtmDate] = GETDATE()
							FROM tblSTCheckoutCustomerCharges CC
							JOIN tblSTCheckoutHeader CH 
								ON CC.intCheckoutId = CH.intCheckoutId
							JOIN tblSTStore ST 
								ON CH.intStoreId = ST.intStoreId
							JOIN tblICItemUOM STUOM
								ON ST.intCustomerChargesItemId = STUOM.intItemId
							JOIN vyuEMEntityCustomerSearch vC 
								--ON CC.intCustomerId = vC.intEntityId		
								ON ST.intCheckoutCustomerId = vC.intEntityId
							INNER JOIN tblICItemUOM UOM 
								ON UOM.intItemUOMId = CASE 
														WHEN CC.intProduct IS NOT NULL
															THEN CC.intProduct
														ELSE STUOM.intItemUOMId
													END
							LEFT JOIN tblICItem I 
									ON UOM.intItemId = I.intItemId
							LEFT JOIN tblICItemLocation IL 
								ON I.intItemId = IL.intItemId
								AND ST.intCompanyLocationId = IL.intLocationId
							LEFT JOIN tblSTPumpItem TPI 
								ON UOM.intItemUOMId = TPI.intItemUOMId AND ST.intStoreId = TPI.intStoreId

							-- http://jira.irelyserver.com/browse/ST-1316
							--LEFT JOIN tblICItemPricing IP 
							--	ON I.intItemId = IP.intItemId
							--	AND IL.intItemLocationId = IP.intItemLocationId	

							CROSS APPLY dbo.fnConstructLineItemTaxDetail (
																				-- ISNULL(CC.dblQuantity, 0)						    -- Qty
																				CASE
																					-- IF Item is Fuel
																					WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																						THEN
																							CASE
																								WHEN (CC.dblAmount >= 0)
																									THEN (ISNULL(CC.dblQuantity, 0) * -1)
																								WHEN (CC.dblAmount < 0)
																									THEN (ISNULL(CC.dblQuantity, 0) * -1)
																							END
																					ELSE ISNULL(CC.dblQuantity, 0)
																				END
																				--, ABS(ISNULL(CAST(CC.dblAmount AS DECIMAL(18,2)), 0))	-- Gross Amount CC.dblUnitPrice
																				,CASE
																					-- IF Item is Fuel
																					WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																						THEN
																							CASE
																								WHEN (CC.dblAmount >= 0)
																									THEN (ISNULL(CC.dblAmount, 0) * -1)
																								WHEN (CC.dblAmount < 0)
																									THEN (ISNULL(CC.dblAmount, 0) * -1)
																							END
																					ELSE ISNULL(CC.dblUnitPrice, 0)
																				END
																				, @LineItems
																				, 1										-- is Reversal
																				--, I.intItemId							-- Item Id
																				, CASE
																					WHEN I.intItemId IS NOT NULL 
																						THEN I.intItemId
																					ELSE ST.intCustomerChargesItemId
																				END
																				, CC.intCustomerId	-- ST.intCheckoutCustomerId				-- Customer Id
																				, ST.intCompanyLocationId				-- Company Location Id
																				, TPI.intTaxGroupId						-- Tax Group Id
																				, 0										-- 0 Price if not reversal
																				, @dtmCheckoutDate						-- Tax is also computed based on date. Use Checkout date.
																				, vC.intShipToId						-- Ship to Location
																				, 1
																				, 1			                            --@IncludeInvalidCodes
																				, NULL
																				, vC.intFreightTermId					-- FreightTermId
																				, NULL
																				, NULL
																				, 0
																				, 0
																				, UOM.intItemUOMId -- http://jira.irelyserver.com/browse/ST-1316
																				, NULL									--@CFSiteId
																				, 0										--@IsDeliver
																				, 0                                      --@IsCFQuote
																				, NULL
																				, NULL
																				, NULL
																		
							) FuelTax
							WHERE CC.intCheckoutId = @intCheckoutId
								AND ISNULL(CC.dblAmount, 0) != 0
								AND I.intItemId IS NOT NULL
								AND I.ysnFuelItem = CAST(1 AS BIT)
						end try
						begin catch
							SET @strStatusMsg = CAST(ERROR_MESSAGE() AS VARCHAR(MAX))

							-- ROLLBACK
							GOTO ExitWithRollback
						end catch

						INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL

											--,[intItemId]				= I.intItemId
											,[intItemId]				= CASE
																			WHEN I.intItemId IS NOT NULL
																				THEN I.intItemId
																			ELSE ST.intCustomerChargesItemId
																		END

											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= CC.intProduct --UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- -1
											,[intItemUOMId]				= CC.intProduct --UOM.intItemUOMId

											--,[dblQtyShipped]			= -1
											,[dblQtyShipped]			= CASE
																			-- IF Item is NOT Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(0 AS BIT))
																				THEN
																					CASE
																						WHEN (CC.dblAmount > 0 OR CC.dblAmount < 0)
																							--THEN (CC.dblQuantity * -1)
																							THEN CASE 
																									WHEN @strInvoiceTransactionTypeMain = @strCASH
																										THEN (CC.dblQuantity * -1)
																									WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																										THEN (CC.dblQuantity * 1)
																										--THEN CASE
																										--		WHEN ISNULL(CC.dblQuantity, 0) > 0
																										--			THEN (CC.dblQuantity * -1)
																										--		WHEN ISNULL(CC.dblQuantity, 0) < 0
																										--			THEN (CC.dblQuantity * 1)
																										--END
																							END				
																					END

																			-- IF Item is Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																				THEN
																					--CASE
																					--	WHEN (CC.dblAmount >= 0)
																					--		THEN (CC.dblQuantity * -1)
																					--	WHEN (CC.dblAmount < 0)
																					--		THEN (CC.dblQuantity * -1)
																					--END
																					CASE 
																						WHEN @strInvoiceTransactionTypeMain = @strCASH
																							THEN (CC.dblQuantity * -1)
																						WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																							THEN (CC.dblQuantity * 1)
																					END

																			-- IF Item is BLANK
																			WHEN (I.intItemId IS NULL)
																				THEN
																					--CASE
																					--	WHEN (CC.dblAmount >= 0)
																					--		THEN -1
																					--	WHEN (CC.dblAmount < 0)
																					--		THEN 1
																					--END
																					CASE 
																						WHEN @strInvoiceTransactionTypeMain = @strCASH
																							THEN CASE
																									WHEN (CC.dblAmount >= 0)
																										THEN -1
																									WHEN (CC.dblAmount < 0)
																										THEN 1
																								END
																						WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																							THEN CASE
																									WHEN (CC.dblAmount >= 0)
																										THEN 1
																									WHEN (CC.dblAmount < 0)
																										THEN -1
																								END
																					END
																		END

											,[dblDiscount]				= 0

											--,[dblPrice]					= ISNULL(CC.dblAmount,0)
											,[dblPrice]					= CASE
																			-- IF Item is NOT Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(0 AS BIT))
																				THEN
																					CASE
																						WHEN (CC.dblAmount > 0 OR CC.dblAmount < 0)
																							THEN CC.dblUnitPrice
																					END

																			-- IF Item is Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																				THEN
																					CASE
																						WHEN (CC.dblAmount < 0 OR CC.dblAmount >= 0)
																							THEN ABS(ABS(ISNULL(CAST(CC.dblAmount AS DECIMAL(18,2)), 0)) - ABS(FuelTax.dblAdjustedTax)) / ABS(ISNULL(CC.dblQuantity, 0))
																					END

																			-- IF Item is BLANK
																			WHEN (I.intItemId IS NULL)
																				THEN
																					CASE
																						WHEN (CC.dblAmount >= 0)
																							--THEN CC.dblAmount
																							THEN ISNULL(CC.dblUnitPrice, 0)			-- TEST01
																						WHEN (CC.dblAmount < 0)
																							--THEN (CC.dblAmount * -1)
																							THEN (ISNULL(CC.dblUnitPrice, 0) * -1)	-- TEST01
																					END
																		END

											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= CASE 
																				-- IF Item is Fuel
																				WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																					THEN TPI.intTaxGroupId
																				ELSE NULL
																		END	
																			 
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= @strtblSTCheckoutCustomerCharges01 -- Mark for Rank
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = CASE 
																			-- IF Item is Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																				THEN CC.intCustChargeId  -- Mark for Rank
																			ELSE NULL						
																		END
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutCustomerCharges CC
								JOIN tblSTCheckoutHeader CH 
									ON CC.intCheckoutId = CH.intCheckoutId
								JOIN tblSTStore ST 
									ON CH.intStoreId = ST.intStoreId
								JOIN tblICItemUOM STUOM
									ON ST.intCustomerChargesItemId = STUOM.intItemId
								JOIN vyuEMEntityCustomerSearch vC 
									-- ON CC.intCustomerId = vC.intEntityId	
									ON ST.intCheckoutCustomerId = vC.intEntityId
								INNER JOIN tblICItemUOM UOM 
									ON UOM.intItemUOMId = CASE 
															WHEN CC.intProduct IS NOT NULL
																THEN CC.intProduct
															ELSE STUOM.intItemUOMId
														END
								LEFT JOIN tblICItem I 
									ON UOM.intItemId = I.intItemId
								LEFT JOIN tblICItemLocation IL 
									ON I.intItemId = IL.intItemId
									AND ST.intCompanyLocationId = IL.intLocationId
								LEFT JOIN tblSTPumpItem TPI
									ON UOM.intItemUOMId = TPI.intItemUOMId AND ST.intStoreId = TPI.intStoreId

								-- http://jira.irelyserver.com/browse/ST-1316
								--LEFT JOIN tblICItemPricing IP 
								--	ON I.intItemId = IP.intItemId
								--	AND IL.intItemLocationId = IP.intItemLocationId	

								LEFT OUTER JOIN
								(
									SELECT 
									   [dblAdjustedTax] = SUM ([dblAdjustedTax])
									 , [intTempDetailIdForTaxes]
									 , [strSourceTransaction]
									FROM
										@LineItemTaxEntries
									GROUP BY
										[intTempDetailIdForTaxes]
										, [strSourceTransaction]
								) FuelTax
									ON CC.intCustChargeId = FuelTax.intTempDetailIdForTaxes
									AND FuelTax.strSourceTransaction = @strtblSTCheckoutCustomerCharges01
								WHERE CC.intCheckoutId = @intCheckoutId
									AND ISNULL(CC.dblAmount, 0) != 0

					END
				----------------------------------------------------------------------
				----------------------- END CUSTOMER CHARGES -------------------------
				----------------------------------------------------------------------


				IF @ysnConsignmentStore = 1
				BEGIN
					--PRINT 'DEALER COMMISSION'
					----------------------------------------------------------------------
					-------------------------- DEALER COMMISSION -------------------------
					----------------------------------------------------------------------
					IF EXISTS(SELECT * FROM tblSTStore WHERE intStoreId = @intStoreId AND intConsDealerCommissionItemId IS NOT NULL)
						BEGIN
							IF @strConsInvoiceType = 'CSFuelInvoice'
							BEGIN
								INSERT INTO @EntriesForInvoice(
												 [strSourceTransaction]
												,[strTransactionType]
												,[strType]
												,[intSourceId]
												,[strSourceId]
												,[intInvoiceId]
												,[intEntityCustomerId]
												,[intCompanyLocationId]
												,[intCurrencyId]
												,[intTermId]
												,[dtmDate]
												,[dtmDueDate]
												,[dtmShipDate]
												,[dtmCalculated]
												,[dtmPostDate]
												,[intEntitySalespersonId]
												,[intFreightTermId]
												,[intShipViaId]
												,[intPaymentMethodId]
												,[strInvoiceOriginId]
												,[strPONumber]
												,[strBOLNumber]
												,[strComments]
												,[intShipToLocationId]
												,[intBillToLocationId]
												,[ysnTemplate]
												,[ysnForgiven]
												,[ysnCalculated]
												,[ysnSplitted]
												,[intPaymentId]
												,[intSplitId]
												,[intLoadDistributionHeaderId]
												,[strActualCostId]
												,[intShipmentId]
												,[intTransactionId]
												,[intEntityId]
												,[ysnResetDetails]
												,[ysnRecap] -- RECAP
												,[ysnPost]
												,[intInvoiceDetailId]
												,[intItemId]
												,[ysnInventory]
												,[strItemDescription]
												,[intOrderUOMId]
												,[dblQtyOrdered]
												,[intItemUOMId]
												,[dblQtyShipped]
												,[dblDiscount]
												,[dblPrice]
												,[ysnRefreshPrice]
												,[strMaintenanceType]
												,[strFrequency]
												,[dtmMaintenanceDate]
												,[dblMaintenanceAmount]
												,[dblLicenseAmount]
												,[intTaxGroupId]
												,[ysnRecomputeTax]
												,[intSCInvoiceId]
												,[strSCInvoiceNumber]
												,[intInventoryShipmentItemId]
												,[strShipmentNumber]
												,[intSalesOrderDetailId]
												,[strSalesOrderNumber]
												,[intContractHeaderId]
												,[intContractDetailId]
												,[intShipmentPurchaseSalesContractId]
												,[intTicketId]
												,[intTicketHoursWorkedId]
												,[intSiteId]
												,[strBillingBy]
												,[dblPercentFull]
												,[dblNewMeterReading]
												,[dblPreviousMeterReading]
												,[dblConversionFactor]
												,[intPerformerId]
												,[ysnLeaseBilling]
												,[ysnVirtualMeterReading]
												,[strImportFormat]
												,[dblCOGSAmount]
												,[intTempDetailIdForTaxes]
												,[intConversionAccountId]
												,[intCurrencyExchangeRateTypeId]
												,[intCurrencyExchangeRateId]
												,[dblCurrencyExchangeRate]
												,[intSubCurrencyId]
												,[dblSubCurrencyRate]
												--,[ysnImportedFromOrigin]
												--,[ysnImportedAsPosted]
											)
											SELECT 
												 [strSourceTransaction]		= 'Invoice'
												,[strTransactionType]		= 'Invoice'
												,[strType]					= @strInvoiceTypeMain
												,[intSourceId]				= @intCheckoutId
												,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
												,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
												,[intEntityCustomerId]		= @intEntityCustomerId
												,[intCompanyLocationId]		= @intCompanyLocationId
												,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
												,[intTermId]				= vC.intTermsId						--ADDED
												,[dtmDate]					= @dtmCheckoutDate --GETDATE()
												,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
												,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
												,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
												,[intFreightTermId]			= vC.intFreightTermId				--ADDED
												,[intShipViaId]				= vC.intShipViaId					--ADDED
												,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
												,[strInvoiceOriginId]		= NULL -- not sure
												,[strPONumber]				= NULL -- not sure
												,[strBOLNumber]				= NULL -- not sure
												,[strComments]				= @strComments
												,[intShipToLocationId]		= vC.intShipToId					--ADDED
												,[intBillToLocationId]		= NULL
												,[ysnTemplate]				= 0
												,[ysnForgiven]				= 0
												,[ysnCalculated]			= 0 -- not sure
												,[ysnSplitted]				= 0
												,[intPaymentId]				= NULL
												,[intSplitId]				= NULL
												,[intLoadDistributionHeaderId]	= NULL
												,[strActualCostId]			= NULL
												,[intShipmentId]			= NULL
												,[intTransactionId]			= NULL
												,[intEntityId]				= @intCurrentUserId
												,[ysnResetDetails]			= CASE
																				WHEN @intCurrentInvoiceId IS NOT NULL
																					THEN CAST(0 AS BIT)
																				ELSE CAST(1 AS BIT)
																			  END
												,[ysnRecap]					= @ysnRecap
												,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
												,[intInvoiceDetailId]		= NULL
												,[intItemId]				= I.intItemId
												,[ysnInventory]				= 1
												,[strItemDescription]		= I.strDescription
												,[intOrderUOMId]			= NULL -- UOM.intItemUOMId
												,[dblQtyOrdered]			= 0 -- 1
												,[intItemUOMId]				= NULL -- UOM.intItemUOMId
												--,[dblQtyShipped]			= CASE
												--									-- Refference:  http://jira.irelyserver.com/browse/ST-1558
												--									WHEN @strInvoiceTransactionTypeMain = @strCASH
												--										THEN -1
												--									WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
												--										THEN 1
												--								END
												,[dblQtyShipped]			= -1
												,[dblDiscount]				= 0
												,[dblPrice]					= ISNULL(DC.dblCommissionAmount, 0)
												,[ysnRefreshPrice]			= 0
												,[strMaintenanceType]		= NULL
												,[strFrequency]				= NULL
												,[dtmMaintenanceDate]		= NULL
												,[dblMaintenanceAmount]		= NULL
												,[dblLicenseAmount]			= NULL
												,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
												,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
												,[intSCInvoiceId]			= NULL
												,[strSCInvoiceNumber]		= NULL
												,[intInventoryShipmentItemId] = NULL
												,[strShipmentNumber]		= NULL
												,[intSalesOrderDetailId]	= NULL
												,[strSalesOrderNumber]		= NULL
												,[intContractHeaderId]		= NULL
												,[intContractDetailId]		= NULL
												,[intShipmentPurchaseSalesContractId]	= NULL
												,[intTicketId]				= NULL
												,[intTicketHoursWorkedId]	= NULL
												,[intSiteId]				= NULL -- not sure
												,[strBillingBy]				= NULL -- not sure
												,[dblPercentFull]			= NULL
												,[dblNewMeterReading]		= NULL
												,[dblPreviousMeterReading]	= NULL -- not sure
												,[dblConversionFactor]		= NULL -- not sure
												,[intPerformerId]			= NULL -- not sure
												,[ysnLeaseBilling]			= NULL
												,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
												,[strImportFormat]			= ''
												,[dblCOGSAmount]			= 0 --IP.dblSalePrice
												,[intTempDetailIdForTaxes]  = NULL
												,[intConversionAccountId]	= NULL -- not sure
												,[intCurrencyExchangeRateTypeId]	= NULL
												,[intCurrencyExchangeRateId]		= NULL
												,[dblCurrencyExchangeRate]	= 1.000000
												,[intSubCurrencyId]			= NULL
												,[dblSubCurrencyRate]		= 1.000000
												--,0
												--,1
									FROM tblSTStore ST
									JOIN tblSTCheckoutHeader CH 
										ON ST.intStoreId = CH.intStoreId
									JOIN tblSTCheckoutDealerCommission DC
										ON CH.intCheckoutId = DC.intCheckoutId
									JOIN tblICItem I 
										ON ST.intConsDealerCommissionItemId = I.intItemId 
									JOIN tblICItemLocation IL
										ON I.intItemId = IL.intItemId
										AND ST.intCompanyLocationId = IL.intLocationId
									JOIN vyuEMEntityCustomerSearch vC 
										ON ST.intCheckoutCustomerId = vC.intEntityId									
									WHERE CH.intCheckoutId = @intCheckoutId
										AND ISNULL(DC.dblCommissionAmount,0) <> 0
							END
							ELSE
							BEGIN
								INSERT INTO @EntriesForInvoice(
												 [strSourceTransaction]
												,[strTransactionType]
												,[strType]
												,[intSourceId]
												,[strSourceId]
												,[intInvoiceId]
												,[intEntityCustomerId]
												,[intCompanyLocationId]
												,[intCurrencyId]
												,[intTermId]
												,[dtmDate]
												,[dtmDueDate]
												,[dtmShipDate]
												,[dtmCalculated]
												,[dtmPostDate]
												,[intEntitySalespersonId]
												,[intFreightTermId]
												,[intShipViaId]
												,[intPaymentMethodId]
												,[strInvoiceOriginId]
												,[strPONumber]
												,[strBOLNumber]
												,[strComments]
												,[intShipToLocationId]
												,[intBillToLocationId]
												,[ysnTemplate]
												,[ysnForgiven]
												,[ysnCalculated]
												,[ysnSplitted]
												,[intPaymentId]
												,[intSplitId]
												,[intLoadDistributionHeaderId]
												,[strActualCostId]
												,[intShipmentId]
												,[intTransactionId]
												,[intEntityId]
												,[ysnResetDetails]
												,[ysnRecap] -- RECAP
												,[ysnPost]
												,[intInvoiceDetailId]
												,[intItemId]
												,[ysnInventory]
												,[strItemDescription]
												,[intOrderUOMId]
												,[dblQtyOrdered]
												,[intItemUOMId]
												,[dblQtyShipped]
												,[dblDiscount]
												,[dblPrice]
												,[ysnRefreshPrice]
												,[strMaintenanceType]
												,[strFrequency]
												,[dtmMaintenanceDate]
												,[dblMaintenanceAmount]
												,[dblLicenseAmount]
												,[intTaxGroupId]
												,[ysnRecomputeTax]
												,[intSCInvoiceId]
												,[strSCInvoiceNumber]
												,[intInventoryShipmentItemId]
												,[strShipmentNumber]
												,[intSalesOrderDetailId]
												,[strSalesOrderNumber]
												,[intContractHeaderId]
												,[intContractDetailId]
												,[intShipmentPurchaseSalesContractId]
												,[intTicketId]
												,[intTicketHoursWorkedId]
												,[intSiteId]
												,[strBillingBy]
												,[dblPercentFull]
												,[dblNewMeterReading]
												,[dblPreviousMeterReading]
												,[dblConversionFactor]
												,[intPerformerId]
												,[ysnLeaseBilling]
												,[ysnVirtualMeterReading]
												,[strImportFormat]
												,[dblCOGSAmount]
												,[intTempDetailIdForTaxes]
												,[intConversionAccountId]
												,[intCurrencyExchangeRateTypeId]
												,[intCurrencyExchangeRateId]
												,[dblCurrencyExchangeRate]
												,[intSubCurrencyId]
												,[dblSubCurrencyRate]
												--,[ysnImportedFromOrigin]
												--,[ysnImportedAsPosted]
											)
											SELECT 
												 [strSourceTransaction]		= 'Invoice'
												,[strTransactionType]		= @strInvoiceTransactionTypeMain
												,[strType]					= @strInvoiceTypeMain
												,[intSourceId]				= @intCheckoutId
												,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
												,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
												,[intEntityCustomerId]		= @intEntityCustomerId
												,[intCompanyLocationId]		= @intCompanyLocationId
												,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
												,[intTermId]				= vC.intTermsId						--ADDED
												,[dtmDate]					= @dtmCheckoutDate --GETDATE()
												,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
												,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
												,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
												,[intFreightTermId]			= vC.intFreightTermId				--ADDED
												,[intShipViaId]				= vC.intShipViaId					--ADDED
												,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
												,[strInvoiceOriginId]		= NULL -- not sure
												,[strPONumber]				= NULL -- not sure
												,[strBOLNumber]				= NULL -- not sure
												,[strComments]				= @strComments
												,[intShipToLocationId]		= vC.intShipToId					--ADDED
												,[intBillToLocationId]		= NULL
												,[ysnTemplate]				= 0
												,[ysnForgiven]				= 0
												,[ysnCalculated]			= 0 -- not sure
												,[ysnSplitted]				= 0
												,[intPaymentId]				= NULL
												,[intSplitId]				= NULL
												,[intLoadDistributionHeaderId]	= NULL
												,[strActualCostId]			= NULL
												,[intShipmentId]			= NULL
												,[intTransactionId]			= NULL
												,[intEntityId]				= @intCurrentUserId
												,[ysnResetDetails]			= CASE
																				WHEN @intCurrentInvoiceId IS NOT NULL
																					THEN CAST(0 AS BIT)
																				ELSE CAST(1 AS BIT)
																			  END
												,[ysnRecap]					= @ysnRecap
												,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
												,[intInvoiceDetailId]		= NULL
												,[intItemId]				= I.intItemId
												,[ysnInventory]				= 1
												,[strItemDescription]		= I.strDescription
												,[intOrderUOMId]			= NULL -- UOM.intItemUOMId
												,[dblQtyOrdered]			= 0 -- 1
												,[intItemUOMId]				= NULL -- UOM.intItemUOMId

												--,[dblQtyShipped]			= CASE
												--									WHEN ISNULL(CH.dblCashOverShort,0) > 0
												--										THEN 1
												--									WHEN ISNULL(CH.dblCashOverShort,0) < 0
												--										THEN -1
												--							END
												,[dblQtyShipped]			= CASE
																				-- Refference: http://jira.irelyserver.com/browse/ST-1558
																				WHEN @strInvoiceTransactionTypeMain = @strCASH
																					THEN 1
																				WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																					THEN -1
																			END

												,[dblDiscount]				= 0

												--,[dblPrice]					= CASE
												--									WHEN ISNULL(CH.dblCashOverShort,0) > 0
												--										THEN ISNULL(CH.dblCashOverShort, 0)
												--									WHEN ISNULL(CH.dblCashOverShort,0) < 0
												--										THEN ISNULL(CH.dblCashOverShort, 0) * -1
												,[dblPrice]					= ISNULL(DC.dblCommissionAmount, 0) * -1

												,[ysnRefreshPrice]			= 0
												,[strMaintenanceType]		= NULL
												,[strFrequency]				= NULL
												,[dtmMaintenanceDate]		= NULL
												,[dblMaintenanceAmount]		= NULL
												,[dblLicenseAmount]			= NULL
												,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
												,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
												,[intSCInvoiceId]			= NULL
												,[strSCInvoiceNumber]		= NULL
												,[intInventoryShipmentItemId] = NULL
												,[strShipmentNumber]		= NULL
												,[intSalesOrderDetailId]	= NULL
												,[strSalesOrderNumber]		= NULL
												,[intContractHeaderId]		= NULL
												,[intContractDetailId]		= NULL
												,[intShipmentPurchaseSalesContractId]	= NULL
												,[intTicketId]				= NULL
												,[intTicketHoursWorkedId]	= NULL
												,[intSiteId]				= NULL -- not sure
												,[strBillingBy]				= NULL -- not sure
												,[dblPercentFull]			= NULL
												,[dblNewMeterReading]		= NULL
												,[dblPreviousMeterReading]	= NULL -- not sure
												,[dblConversionFactor]		= NULL -- not sure
												,[intPerformerId]			= NULL -- not sure
												,[ysnLeaseBilling]			= NULL
												,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
												,[strImportFormat]			= ''
												,[dblCOGSAmount]			= 0 --IP.dblSalePrice
												,[intTempDetailIdForTaxes]  = NULL
												,[intConversionAccountId]	= NULL -- not sure
												,[intCurrencyExchangeRateTypeId]	= NULL
												,[intCurrencyExchangeRateId]		= NULL
												,[dblCurrencyExchangeRate]	= 1.000000
												,[intSubCurrencyId]			= NULL
												,[dblSubCurrencyRate]		= 1.000000
												--,0
												--,1
									FROM tblSTStore ST
									JOIN tblSTCheckoutHeader CH 
										ON ST.intStoreId = CH.intStoreId
									JOIN tblSTCheckoutDealerCommission DC
										ON CH.intCheckoutId = DC.intCheckoutId
									JOIN tblICItem I 
										ON ST.intConsDealerCommissionItemId = I.intItemId 
									JOIN tblICItemLocation IL
										ON I.intItemId = IL.intItemId
										AND ST.intCompanyLocationId = IL.intLocationId
									JOIN vyuEMEntityCustomerSearch vC 
										ON ST.intCheckoutCustomerId = vC.intEntityId									
									WHERE CH.intCheckoutId = @intCheckoutId
										AND ISNULL(DC.dblCommissionAmount,0) <> 0
							END
						END
				END
				----------------------------------------------------------------------
				------------------------- END DEALER COMMISSION ------------------------
				----------------------------------------------------------------------




				IF @ysnConsignmentStore = 1 AND @ysnConsAddOutsideFuelDiscounts = 1
				BEGIN
					--PRINT 'FUEL DISCOUNT'
					----------------------------------------------------------------------
					---------------------------- FUEL DISCOUNT ---------------------------
					----------------------------------------------------------------------
					IF EXISTS(SELECT * FROM tblSTStore WHERE intStoreId = @intStoreId AND intConsFuelDiscountItemId IS NOT NULL)
						BEGIN
								INSERT INTO @EntriesForInvoice(
												 [strSourceTransaction]
												,[strTransactionType]
												,[strType]
												,[intSourceId]
												,[strSourceId]
												,[intInvoiceId]
												,[intEntityCustomerId]
												,[intCompanyLocationId]
												,[intCurrencyId]
												,[intTermId]
												,[dtmDate]
												,[dtmDueDate]
												,[dtmShipDate]
												,[dtmCalculated]
												,[dtmPostDate]
												,[intEntitySalespersonId]
												,[intFreightTermId]
												,[intShipViaId]
												,[intPaymentMethodId]
												,[strInvoiceOriginId]
												,[strPONumber]
												,[strBOLNumber]
												,[strComments]
												,[intShipToLocationId]
												,[intBillToLocationId]
												,[ysnTemplate]
												,[ysnForgiven]
												,[ysnCalculated]
												,[ysnSplitted]
												,[intPaymentId]
												,[intSplitId]
												,[intLoadDistributionHeaderId]
												,[strActualCostId]
												,[intShipmentId]
												,[intTransactionId]
												,[intEntityId]
												,[ysnResetDetails]
												,[ysnRecap] -- RECAP
												,[ysnPost]
												,[intInvoiceDetailId]
												,[intItemId]
												,[ysnInventory]
												,[strItemDescription]
												,[intOrderUOMId]
												,[dblQtyOrdered]
												,[intItemUOMId]
												,[dblQtyShipped]
												,[dblDiscount]
												,[dblPrice]
												,[ysnRefreshPrice]
												,[strMaintenanceType]
												,[strFrequency]
												,[dtmMaintenanceDate]
												,[dblMaintenanceAmount]
												,[dblLicenseAmount]
												,[intTaxGroupId]
												,[ysnRecomputeTax]
												,[intSCInvoiceId]
												,[strSCInvoiceNumber]
												,[intInventoryShipmentItemId]
												,[strShipmentNumber]
												,[intSalesOrderDetailId]
												,[strSalesOrderNumber]
												,[intContractHeaderId]
												,[intContractDetailId]
												,[intShipmentPurchaseSalesContractId]
												,[intTicketId]
												,[intTicketHoursWorkedId]
												,[intSiteId]
												,[strBillingBy]
												,[dblPercentFull]
												,[dblNewMeterReading]
												,[dblPreviousMeterReading]
												,[dblConversionFactor]
												,[intPerformerId]
												,[ysnLeaseBilling]
												,[ysnVirtualMeterReading]
												,[strImportFormat]
												,[dblCOGSAmount]
												,[intTempDetailIdForTaxes]
												,[intConversionAccountId]
												,[intCurrencyExchangeRateTypeId]
												,[intCurrencyExchangeRateId]
												,[dblCurrencyExchangeRate]
												,[intSubCurrencyId]
												,[dblSubCurrencyRate]
											)
											SELECT 
												 [strSourceTransaction]		= 'Invoice'
												,[strTransactionType]		= @strInvoiceTransactionTypeMain
												,[strType]					= @strInvoiceTypeMain
												,[intSourceId]				= @intCheckoutId
												,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
												,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
												,[intEntityCustomerId]		= @intEntityCustomerId
												,[intCompanyLocationId]		= @intCompanyLocationId
												,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
												,[intTermId]				= vC.intTermsId						--ADDED
												,[dtmDate]					= @dtmCheckoutDate --GETDATE()
												,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
												,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
												,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
												,[intFreightTermId]			= vC.intFreightTermId				--ADDED
												,[intShipViaId]				= vC.intShipViaId					--ADDED
												,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
												,[strInvoiceOriginId]		= NULL -- not sure
												,[strPONumber]				= NULL -- not sure
												,[strBOLNumber]				= NULL -- not sure
												,[strComments]				= @strComments
												,[intShipToLocationId]		= vC.intShipToId					--ADDED
												,[intBillToLocationId]		= NULL
												,[ysnTemplate]				= 0
												,[ysnForgiven]				= 0
												,[ysnCalculated]			= 0 -- not sure
												,[ysnSplitted]				= 0
												,[intPaymentId]				= NULL
												,[intSplitId]				= NULL
												,[intLoadDistributionHeaderId]	= NULL
												,[strActualCostId]			= NULL
												,[intShipmentId]			= NULL
												,[intTransactionId]			= NULL
												,[intEntityId]				= @intCurrentUserId
												,[ysnResetDetails]			= CASE
																				WHEN @intCurrentInvoiceId IS NOT NULL
																					THEN CAST(0 AS BIT)
																				ELSE CAST(1 AS BIT)
																			  END
												,[ysnRecap]					= @ysnRecap
												,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
												,[intInvoiceDetailId]		= NULL
												,[intItemId]				= I.intItemId
												,[ysnInventory]				= 1
												,[strItemDescription]		= I.strDescription
												,[intOrderUOMId]			= NULL -- UOM.intItemUOMId
												,[dblQtyOrdered]			= 0 -- 1
												,[intItemUOMId]				= NULL -- UOM.intItemUOMId

												--,[dblQtyShipped]			= CASE
												--									WHEN ISNULL(CH.dblCashOverShort,0) > 0
												--										THEN 1
												--									WHEN ISNULL(CH.dblCashOverShort,0) < 0
												--										THEN -1
												--							END
												,[dblQtyShipped]			= 1
												,[dblDiscount]				= 0
												,[dblPrice]					= CASE 
																				WHEN @ysnConsMeterReadingsForDollars = 0
																					THEN ABS(ISNULL(CH.dblEditableOutsideFuelDiscount, 0)) --+ ISNULL(CH.dblEditableInsideFuelDiscount, 0))
																				WHEN @ysnConsMeterReadingsForDollars = 1
																					THEN ABS(ISNULL(CH.dblEditableOutsideFuelDiscount, 0))
																				ELSE 
																					0
																				END
												,[ysnRefreshPrice]			= 0
												,[strMaintenanceType]		= NULL
												,[strFrequency]				= NULL
												,[dtmMaintenanceDate]		= NULL
												,[dblMaintenanceAmount]		= NULL
												,[dblLicenseAmount]			= NULL
												,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
												,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
												,[intSCInvoiceId]			= NULL
												,[strSCInvoiceNumber]		= NULL
												,[intInventoryShipmentItemId] = NULL
												,[strShipmentNumber]		= NULL
												,[intSalesOrderDetailId]	= NULL
												,[strSalesOrderNumber]		= NULL
												,[intContractHeaderId]		= NULL
												,[intContractDetailId]		= NULL
												,[intShipmentPurchaseSalesContractId]	= NULL
												,[intTicketId]				= NULL
												,[intTicketHoursWorkedId]	= NULL
												,[intSiteId]				= NULL -- not sure
												,[strBillingBy]				= NULL -- not sure
												,[dblPercentFull]			= NULL
												,[dblNewMeterReading]		= NULL
												,[dblPreviousMeterReading]	= NULL -- not sure
												,[dblConversionFactor]		= NULL -- not sure
												,[intPerformerId]			= NULL -- not sure
												,[ysnLeaseBilling]			= NULL
												,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
												,[strImportFormat]			= ''
												,[dblCOGSAmount]			= 0 --IP.dblSalePrice
												,[intTempDetailIdForTaxes]  = NULL
												,[intConversionAccountId]	= NULL -- not sure
												,[intCurrencyExchangeRateTypeId]	= NULL
												,[intCurrencyExchangeRateId]		= NULL
												,[dblCurrencyExchangeRate]	= 1.000000
												,[intSubCurrencyId]			= NULL
												,[dblSubCurrencyRate]		= 1.000000
												--,0
												--,1
									FROM tblSTStore ST
									JOIN tblSTCheckoutHeader CH 
										ON ST.intStoreId = CH.intStoreId
									JOIN tblICItem I 
										ON ST.intConsFuelDiscountItemId = I.intItemId 
									JOIN tblICItemLocation IL
										ON I.intItemId = IL.intItemId
										AND ST.intCompanyLocationId = IL.intLocationId
									JOIN vyuEMEntityCustomerSearch vC 
										ON ST.intCheckoutCustomerId = vC.intEntityId									
									WHERE CH.intCheckoutId = @intCheckoutId
										AND (ISNULL(CH.dblEditableOutsideFuelDiscount,0) <> 0) --OR ISNULL(CH.dblEditableInsideFuelDiscount,0) <> 0)
						END
				END
				----------------------------------------------------------------------
				-------------------------- END FUEL DISCOUNT -------------------------
				----------------------------------------------------------------------


				--PRINT 'CASH OVER SHORT'
				----------------------------------------------------------------------
				--------------------------- CASH OVER SHORT --------------------------
				----------------------------------------------------------------------
				--http://jira.irelyserver.com/browse/ST-1008
				IF EXISTS(SELECT * FROM tblSTStore WHERE intStoreId = @intStoreId AND intOverShortItemId IS NOT NULL)
					BEGIN
							INSERT INTO @EntriesForInvoice(
												[strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
												[strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
											,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																			END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= NULL -- UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= NULL -- UOM.intItemUOMId

												--,[dblQtyShipped]			= CASE
												--									WHEN ISNULL(CH.dblCashOverShort,0) > 0
												--										THEN 1
												--									WHEN ISNULL(CH.dblCashOverShort,0) < 0
												--										THEN -1
												--							END
												,[dblQtyShipped]			= CASE
																				-- Refference: http://jira.irelyserver.com/browse/ST-1558
																				WHEN @strInvoiceTransactionTypeMain = @strCASH
																					THEN 1
																				WHEN @strInvoiceTransactionTypeMain = @strCREDITMEMO
																					THEN -1
																			END

												,[dblDiscount]				= 0

												--,[dblPrice]					= CASE
												--									WHEN ISNULL(CH.dblCashOverShort,0) > 0
												--										THEN ISNULL(CH.dblCashOverShort, 0)
												--									WHEN ISNULL(CH.dblCashOverShort,0) < 0
												--										THEN ISNULL(CH.dblCashOverShort, 0) * -1
												,[dblPrice]					= ISNULL(CH.dblCashOverShort, 0)

												,[ysnRefreshPrice]			= 0
												,[strMaintenanceType]		= NULL
												,[strFrequency]				= NULL
												,[dtmMaintenanceDate]		= NULL
												,[dblMaintenanceAmount]		= NULL
												,[dblLicenseAmount]			= NULL
												,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
												,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
												,[intSCInvoiceId]			= NULL
												,[strSCInvoiceNumber]		= NULL
												,[intInventoryShipmentItemId] = NULL
												,[strShipmentNumber]		= NULL
												,[intSalesOrderDetailId]	= NULL
												,[strSalesOrderNumber]		= NULL
												,[intContractHeaderId]		= NULL
												,[intContractDetailId]		= NULL
												,[intShipmentPurchaseSalesContractId]	= NULL
												,[intTicketId]				= NULL
												,[intTicketHoursWorkedId]	= NULL
												,[intSiteId]				= NULL -- not sure
												,[strBillingBy]				= NULL -- not sure
												,[dblPercentFull]			= NULL
												,[dblNewMeterReading]		= NULL
												,[dblPreviousMeterReading]	= NULL -- not sure
												,[dblConversionFactor]		= NULL -- not sure
												,[intPerformerId]			= NULL -- not sure
												,[ysnLeaseBilling]			= NULL
												,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
												,[strImportFormat]			= ''
												,[dblCOGSAmount]			= 0 --IP.dblSalePrice
												,[intTempDetailIdForTaxes]  = NULL
												,[intConversionAccountId]	= NULL -- not sure
												,[intCurrencyExchangeRateTypeId]	= NULL
												,[intCurrencyExchangeRateId]		= NULL
												,[dblCurrencyExchangeRate]	= 1.000000
												,[intSubCurrencyId]			= NULL
												,[dblSubCurrencyRate]		= 1.000000
												--,0
												--,1
									FROM tblSTStore ST
									JOIN tblICItem I 
										ON ST.intOverShortItemId = I.intItemId 
									JOIN tblICItemLocation IL
										ON I.intItemId = IL.intItemId
										AND ST.intCompanyLocationId = IL.intLocationId
								
									-- http://jira.irelyserver.com/browse/ST-1316
									--JOIN tblICItemUOM UOM 
									--	ON I.intItemId = UOM.intItemId
									--JOIN tblICItemPricing IP 
									--	ON I.intItemId = IP.intItemId
									--	AND IL.intItemLocationId = IP.intItemLocationId

								JOIN vyuEMEntityCustomerSearch vC 
									ON ST.intCheckoutCustomerId = vC.intEntityId
								JOIN tblSTCheckoutHeader CH 
									ON ST.intStoreId = CH.intStoreId
								WHERE CH.intCheckoutId = @intCheckoutId
									-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316
									AND ISNULL(CH.dblCashOverShort,0) <> 0
					END
				----------------------------------------------------------------------
				------------------------- END CASH OVER SHORT ------------------------
				----------------------------------------------------------------------


--PRINT 'METRICS'
				----------------------------------------------------------------------
				--------------------------- METRICS ----------------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutMetrics WHERE intCheckoutId = @intCheckoutId AND dblAmount != 0)
					BEGIN
						INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= item.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= item.strDescription
											,[intOrderUOMId]			= NULL
											,[dblQtyOrdered]			= 0
											,[intItemUOMId]				= NULL

											,[dblQtyShipped]			= CASE
																			-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																			-- Metric Item
																			WHEN (@strInvoiceTransactionTypeMain = @strCASH AND [Metrics].metricType = 'intMetricItemId')
																				THEN 1	
																			WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND [Metrics].metricType = 'intMetricItemId')
																				THEN -1																			

																			-- Offset Item
																			WHEN (@strInvoiceTransactionTypeMain = @strCASH AND [Metrics].metricType = 'intOffsetItemId')
																				THEN -1
																			WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND [Metrics].metricType = 'intOffsetItemId')
																				THEN 1
																		END
											


											,[dblDiscount]				= 0

											,[dblPrice]					= [Metrics].dblAmount

											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= ''
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = NULL
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
										FROM 
										(
											SELECT DISTINCT intCheckoutId, intRegisterImportFieldId, metricType, dblAmount, intItemId
											FROM 
											(
												SELECT 
													intCheckoutId
													, intRegisterImportFieldId
													, dblAmount
													-- Metric
													, intMetricItemId
													-- Offset
													, intOffsetItemId
												FROM tblSTCheckoutMetrics
											) t
											unpivot
											(
												intItemId for metricType in (intMetricItemId, intOffsetItemId)
											) o
										) [Metrics]
										INNER JOIN tblICItem item
											ON [Metrics].intItemId = item.intItemId
										INNER JOIN tblSTCheckoutHeader chk
											ON [Metrics].intCheckoutId = chk.intCheckoutId
										INNER JOIN tblSTStore st 
											ON chk.intStoreId = st.intStoreId
										INNER JOIN vyuEMEntityCustomerSearch vC 
											ON st.intCheckoutCustomerId = vC.intEntityId
										WHERE [Metrics].intCheckoutId = @intCheckoutId
											AND [Metrics].dblAmount != 0
					END
				----------------------------------------------------------------------
				--------------------------- METRICS ----------------------------------
				----------------------------------------------------------------------


--PRINT 'ATM/Change Fund'
				----------------------------------------------------------------------
				------------------------ ATM/Change Fund -----------------------------
				----------------------------------------------------------------------
                DECLARE @tblCheckout_ATM TABLE
				(
					intCheckoutId	INT
					, strType		NVARCHAR(50)
					, intItemId		INT
					, dblItemAmount DECIMAL(18, 6)
				)

				INSERT INTO @tblCheckout_ATM
				(
					intCheckoutId
					, strType
					, intItemId
					, dblItemAmount
				)
				SELECT DISTINCT 
					intCheckoutId,  
					CASE
						WHEN REPLACE(ITEM, '_ItemId', '') = 'BegBalance'
							THEN 'ATM Beg Balance'
						WHEN REPLACE(ITEM, '_ItemId', '') = 'Withdrawal'
							THEN 'ATM Withdrawals'
						WHEN REPLACE(ITEM, '_ItemId', '') = 'Replenished'
							THEN 'ATM Replenishment'
						WHEN REPLACE(ITEM, '_ItemId', '') = 'EndBalanceActual'
							THEN 'ATM End Balance'
						WHEN REPLACE(ITEM, '_ItemId', '') = 'Variance'
							THEN 'ATM Variance'
					END AS strType,
					intItemId, 
					dblItemAmount
				FROM 
				(
					SELECT ch.intCheckoutId
						 , ch.dblATMBegBalance					AS BegBalance_Amount
						 , ch.dblATMReplenished					AS Replenished_Amount
						 , ch.dblATMWithdrawal					AS Withdrawal_Amount
						 , ch.dblATMEndBalanceActual			AS EndBalanceActual_Amount
						 , ch.dblATMVariance					AS Variance_Amount

						 , st.intATMFundBegBalanceItemId	AS BegBalance_ItemId
						 , st.intATMFundReplenishedItemId	AS Replenished_ItemId
						 , st.intATMFundWithdrawalItemId	AS Withdrawal_ItemId
						 , st.intATMFundEndBalanceItemId	AS EndBalanceActual_ItemId
						 , st.intATMFundVarianceItemId		AS Variance_ItemId
					FROM tblSTCheckoutHeader ch
					INNER JOIN tblSTStore st
						ON ch.intStoreId = st.intStoreId
					WHERE intCheckoutId = @intCheckoutId
				) t
				unpivot
				(
					intItemId for ITEM in (BegBalance_ItemId, Replenished_ItemId, Withdrawal_ItemId, EndBalanceActual_ItemId, Variance_ItemId)
				) o
				unpivot
				(
					dblItemAmount for ITEMAMOUNT in (BegBalance_Amount, Replenished_Amount, Withdrawal_Amount, EndBalanceActual_Amount, Variance_Amount)
				) n
				WHERE  REPLACE(ITEM, '_ItemId', '') = REPLACE(ITEMAMOUNT, '_Amount', '')

				IF EXISTS(SELECT TOP 1 1 FROM @tblCheckout_ATM WHERE intCheckoutId = @intCheckoutId AND dblItemAmount != 0)
					BEGIN
						INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= @strInvoiceTransactionTypeMain
										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= item.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= item.strDescription
											,[intOrderUOMId]			= NULL
											,[dblQtyOrdered]			= 0
											,[intItemUOMId]				= NULL

											,[dblQtyShipped]			= CASE
																				-- ATM: Cash
																				WHEN (@strInvoiceTransactionTypeMain = @strCASH AND atm.strType = 'ATM Beg Balance')
																					THEN 1	
																				WHEN (@strInvoiceTransactionTypeMain = @strCASH AND atm.strType = 'ATM Withdrawals')
																					THEN -1																			
																				WHEN (@strInvoiceTransactionTypeMain = @strCASH AND atm.strType = 'ATM Replenishment')
																					THEN 1
																				WHEN (@strInvoiceTransactionTypeMain = @strCASH AND atm.strType = 'ATM End Balance')
																					THEN -1	
																				WHEN (@strInvoiceTransactionTypeMain = @strCASH AND atm.strType = 'ATM Variance' AND atm.dblItemAmount < 0)
																					THEN -1	
																				WHEN (@strInvoiceTransactionTypeMain = @strCASH AND atm.strType = 'ATM Variance' AND atm.dblItemAmount > 0)
																					THEN 1	
																					
																				-- ATM: Cash Refund
																				WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND atm.strType = 'ATM Beg Balance')
																					THEN -1	
																				WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND atm.strType = 'ATM Withdrawals')
																					THEN 1 																		
																				WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND atm.strType = 'ATM Replenishment')
																					THEN -1
																				WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND atm.strType = 'ATM End Balance')
																					THEN 1
																				WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND atm.strType = 'ATM Variance' AND atm.dblItemAmount < 0)
																					THEN 1
																				WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND atm.strType = 'ATM Variance' AND atm.dblItemAmount > 0)
																					THEN -1	
																		END

											,[dblDiscount]				= 0

											,[dblPrice]					= CASE
																			WHEN (atm.strType = 'ATM Variance')
																				THEN ABS(atm.dblItemAmount)
																			ELSE 
																				atm.dblItemAmount
																		END

											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= ''
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = NULL
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
										FROM @tblCheckout_ATM atm
										INNER JOIN tblICItem item
											ON atm.intItemId = item.intItemId
										INNER JOIN tblSTCheckoutHeader chk
											ON atm.intCheckoutId = chk.intCheckoutId
										INNER JOIN tblSTStore st 
											ON chk.intStoreId = st.intStoreId
										INNER JOIN vyuEMEntityCustomerSearch vC 
											ON st.intCheckoutCustomerId = vC.intEntityId
										WHERE atm.intCheckoutId = @intCheckoutId
											AND atm.dblItemAmount != 0
					END
				----------------------------------------------------------------------
				------------------------ ATM/Change Fund -----------------------------
				----------------------------------------------------------------------
				

--PRINT 'CHANGE FUND'
				----------------------------------------------------------------------
				---------------------- [START] - CHANGE FUND -------------------------
				----------------------------------------------------------------------
				IF @ysnConsignmentStore = 0
				BEGIN
					DECLARE @tblCheckout_CHANGEFUND TABLE
					(
						intCheckoutId	INT
						, strType		NVARCHAR(50)
						, intItemId		INT
						, dblItemAmount DECIMAL(18, 6)
					)

					INSERT INTO @tblCheckout_CHANGEFUND
					(
						intCheckoutId
						, strType
						, intItemId
						, dblItemAmount
					)
					SELECT DISTINCT 
						intCheckoutId,  
						CASE
							WHEN REPLACE(ITEM, '_ItemId', '') = 'BegBalance'
								THEN 'Change Fund Beg Balance'
							WHEN REPLACE(ITEM, '_ItemId', '') = 'EndBalance'
								THEN 'Change Fund End Balance'
							WHEN REPLACE(ITEM, '_ItemId', '') = 'Replenishment'
								THEN 'Change Fund Replenishment'
						END AS strType,
						intItemId, 
						dblItemAmount
					FROM 
					(
						SELECT ch.intCheckoutId

							 , ch.dblChangeFundBegBalance			AS BegBalance_Amount
							 , ch.dblChangeFundEndBalance			AS EndBalance_Amount
							 , ch.dblChangeFundChangeReplenishment	AS Replenishment_Amount

							 , st.intChangeFundBegBalanceItemId		AS BegBalance_ItemId
							 , st.intChangeFundEndBalanceItemId		AS EndBalance_ItemId
							 , st.intChangeFundReplenishItemId		AS Replenishment_ItemId
						FROM tblSTCheckoutHeader ch
						INNER JOIN tblSTStore st
							ON ch.intStoreId = st.intStoreId
						WHERE intCheckoutId = @intCheckoutId
					)t
					unpivot
					(
						intItemId for ITEM in (BegBalance_ItemId, EndBalance_ItemId, Replenishment_ItemId)
					) o
					unpivot
					(
						dblItemAmount for ITEMAMOUNT in (BegBalance_Amount, EndBalance_Amount, Replenishment_Amount)
					) n
					WHERE  REPLACE(ITEM, '_ItemId', '') = REPLACE(ITEMAMOUNT, '_Amount', '')



					IF EXISTS(SELECT TOP 1 1 FROM @tblCheckout_CHANGEFUND WHERE intCheckoutId = @intCheckoutId AND dblItemAmount != 0)
						BEGIN
							INSERT INTO @EntriesForInvoice(
												 [strSourceTransaction]
												,[strTransactionType]
												,[strType]
												,[intSourceId]
												,[strSourceId]
												,[intInvoiceId]
												,[intEntityCustomerId]
												,[intCompanyLocationId]
												,[intCurrencyId]
												,[intTermId]
												,[dtmDate]
												,[dtmDueDate]
												,[dtmShipDate]
												,[dtmCalculated]
												,[dtmPostDate]
												,[intEntitySalespersonId]
												,[intFreightTermId]
												,[intShipViaId]
												,[intPaymentMethodId]
												,[strInvoiceOriginId]
												,[strPONumber]
												,[strBOLNumber]
												,[strComments]
												,[intShipToLocationId]
												,[intBillToLocationId]
												,[ysnTemplate]
												,[ysnForgiven]
												,[ysnCalculated]
												,[ysnSplitted]
												,[intPaymentId]
												,[intSplitId]
												,[intLoadDistributionHeaderId]
												,[strActualCostId]
												,[intShipmentId]
												,[intTransactionId]
												,[intEntityId]
												,[ysnResetDetails]
												,[ysnRecap] -- RECAP
												,[ysnPost]
												,[intInvoiceDetailId]
												,[intItemId]
												,[ysnInventory]
												,[strItemDescription]
												,[intOrderUOMId]
												,[dblQtyOrdered]
												,[intItemUOMId]
												,[dblQtyShipped]
												,[dblDiscount]
												,[dblPrice]
												,[ysnRefreshPrice]
												,[strMaintenanceType]
												,[strFrequency]
												,[dtmMaintenanceDate]
												,[dblMaintenanceAmount]
												,[dblLicenseAmount]
												,[intTaxGroupId]
												,[ysnRecomputeTax]
												,[intSCInvoiceId]
												,[strSCInvoiceNumber]
												,[intInventoryShipmentItemId]
												,[strShipmentNumber]
												,[intSalesOrderDetailId]
												,[strSalesOrderNumber]
												,[intContractHeaderId]
												,[intContractDetailId]
												,[intShipmentPurchaseSalesContractId]
												,[intTicketId]
												,[intTicketHoursWorkedId]
												,[intSiteId]
												,[strBillingBy]
												,[dblPercentFull]
												,[dblNewMeterReading]
												,[dblPreviousMeterReading]
												,[dblConversionFactor]
												,[intPerformerId]
												,[ysnLeaseBilling]
												,[ysnVirtualMeterReading]
												,[strImportFormat]
												,[dblCOGSAmount]
												,[intTempDetailIdForTaxes]
												,[intConversionAccountId]
												,[intCurrencyExchangeRateTypeId]
												,[intCurrencyExchangeRateId]
												,[dblCurrencyExchangeRate]
												,[intSubCurrencyId]
												,[dblSubCurrencyRate]
												--,[ysnImportedFromOrigin]
												--,[ysnImportedAsPosted]
											)
											SELECT 
												 [strSourceTransaction]		= 'Invoice'
												,[strTransactionType]		= @strInvoiceTransactionTypeMain
												,[strType]					= @strInvoiceTypeMain
												,[intSourceId]				= @intCheckoutId
												,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
												,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
												,[intEntityCustomerId]		= @intEntityCustomerId
												,[intCompanyLocationId]		= @intCompanyLocationId
												,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
												,[intTermId]				= vC.intTermsId						--ADDED
												,[dtmDate]					= @dtmCheckoutDate --GETDATE()
												,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
												,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
												,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
												,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
												,[intFreightTermId]			= vC.intFreightTermId				--ADDED
												,[intShipViaId]				= vC.intShipViaId					--ADDED
												,[intPaymentMethodId]		= @intPaymentMethodIdMain --vC.intPaymentMethodId				--ADDED
												,[strInvoiceOriginId]		= NULL -- not sure
												,[strPONumber]				= NULL -- not sure
												,[strBOLNumber]				= NULL -- not sure
												,[strComments]				= @strComments
												,[intShipToLocationId]		= vC.intShipToId					--ADDED
												,[intBillToLocationId]		= NULL
												,[ysnTemplate]				= 0
												,[ysnForgiven]				= 0
												,[ysnCalculated]			= 0 -- not sure
												,[ysnSplitted]				= 0
												,[intPaymentId]				= NULL
												,[intSplitId]				= NULL
												,[intLoadDistributionHeaderId]	= NULL
												,[strActualCostId]			= NULL
												,[intShipmentId]			= NULL
												,[intTransactionId]			= NULL
												,[intEntityId]				= @intCurrentUserId
												,[ysnResetDetails]			= CASE
																				WHEN @intCurrentInvoiceId IS NOT NULL
																					THEN CAST(0 AS BIT)
																				ELSE CAST(1 AS BIT)
																			  END
												,[ysnRecap]					= @ysnRecap
												,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
												,[intInvoiceDetailId]		= NULL
												,[intItemId]				= item.intItemId
												,[ysnInventory]				= 1
												,[strItemDescription]		= item.strDescription
												,[intOrderUOMId]			= NULL
												,[dblQtyOrdered]			= 0
												,[intItemUOMId]				= NULL

												,[dblQtyShipped]			= CASE
																				-- Refference:  http://jira.irelyserver.com/browse/ST-1558
																				-- CHANGE FUND: Cash
																				WHEN (@strInvoiceTransactionTypeMain = @strCASH AND cf.strType = 'Change Fund Beg Balance')
																					THEN 1	
																				WHEN (@strInvoiceTransactionTypeMain = @strCASH AND cf.strType = 'Change Fund End Balance')
																					THEN -1																			
																					
																				-- CHANGE FUND: Cash Refund
																				WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND cf.strType = 'Change Fund Beg Balance')
																					THEN -1	
																				WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO AND cf.strType = 'Change Fund End Balance')
																					THEN 1 																		
																			END

												,[dblDiscount]				= 0

												,[dblPrice]					= cf.dblItemAmount

												,[ysnRefreshPrice]			= 0
												,[strMaintenanceType]		= NULL
												,[strFrequency]				= NULL
												,[dtmMaintenanceDate]		= NULL
												,[dblMaintenanceAmount]		= NULL
												,[dblLicenseAmount]			= NULL
												,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
												,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
												,[intSCInvoiceId]			= NULL
												,[strSCInvoiceNumber]		= NULL
												,[intInventoryShipmentItemId] = NULL
												,[strShipmentNumber]		= NULL
												,[intSalesOrderDetailId]	= NULL
												,[strSalesOrderNumber]		= NULL
												,[intContractHeaderId]		= NULL
												,[intContractDetailId]		= NULL
												,[intShipmentPurchaseSalesContractId]	= NULL
												,[intTicketId]				= NULL
												,[intTicketHoursWorkedId]	= NULL
												,[intSiteId]				= NULL -- not sure
												,[strBillingBy]				= NULL -- not sure
												,[dblPercentFull]			= NULL
												,[dblNewMeterReading]		= NULL
												,[dblPreviousMeterReading]	= NULL -- not sure
												,[dblConversionFactor]		= NULL -- not sure
												,[intPerformerId]			= NULL -- not sure
												,[ysnLeaseBilling]			= NULL
												,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
												,[strImportFormat]			= ''
												,[dblCOGSAmount]			= 0 --IP.dblSalePrice
												,[intTempDetailIdForTaxes]  = NULL
												,[intConversionAccountId]	= NULL -- not sure
												,[intCurrencyExchangeRateTypeId]	= NULL
												,[intCurrencyExchangeRateId]		= NULL
												,[dblCurrencyExchangeRate]	= 1.000000
												,[intSubCurrencyId]			= NULL
												,[dblSubCurrencyRate]		= 1.000000
												--,0
												--,1
											FROM @tblCheckout_CHANGEFUND cf
											INNER JOIN tblICItem item
												ON cf.intItemId = item.intItemId
											INNER JOIN tblSTCheckoutHeader chk
												ON cf.intCheckoutId = chk.intCheckoutId
											INNER JOIN tblSTStore st 
												ON chk.intStoreId = st.intStoreId
											INNER JOIN vyuEMEntityCustomerSearch vC 
												ON st.intCheckoutCustomerId = vC.intEntityId
											WHERE cf.intCheckoutId = @intCheckoutId
												AND cf.dblItemAmount != 0
						END
				END
				----------------------------------------------------------------------
				----------------------- [END] - CHANGE FUND --------------------------
				----------------------------------------------------------------------
				

--PRINT 'START CREATE SEPARATE INVOICE for Customer Charges'
				-- START CREATE SEPARATE INVOICE for Customer Charges
				----------------------------------------------------------------------
				-------------------------- CUSTOMER CHARGES @strtblSTCheckoutCustomerCharges02------------------------
				----------------------------------------------------------------------
				--http://jira.irelyserver.com/browse/ST-1019
				--http://jira.irelyserver.com/browse/ST-1020
				IF EXISTS(SELECT * FROM tblSTCheckoutCustomerCharges WHERE intCheckoutId = @intCheckoutId AND dblAmount != 0) --AND intProduct IS NOT NULL)
					BEGIN
						DECLARE @strtblSTCheckoutCustomerCharges02 AS NVARCHAR(150) = 'tblSTCheckoutCustomerCharges02'

						begin try
							-- For own tax computation for Customer CHarges that has Fuel Item
							INSERT INTO @LineItemTaxEntries(
									 [intId]
									,[intDetailId]
									,[intDetailTaxId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[intTaxAccountId]
									,[dblTax]
									,[dblAdjustedTax]
									,[ysnTaxAdjusted]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[ysnTaxExempt]
									,[ysnTaxOnly]
									,[strNotes]
									,[intTempDetailIdForTaxes]
									,[dblCurrencyExchangeRate]
									,[ysnClearExisting]
									,[strTransactionType]
									,[strType]
									,[strSourceTransaction]
									,[intSourceId]
									,[strSourceId]
									,[intHeaderId]
									,[dtmDate]
					)
					SELECT
									 [intId] = CC.intCustChargeId
									,[intDetailId] = NULL
									,[intDetailTaxId] = NULL
									,[intTaxGroupId] = TPI.intTaxGroupId
									,[intTaxCodeId] = FuelTax.intTaxCodeId
									,[intTaxClassId] = FuelTax.intTaxClassId
									,[strTaxableByOtherTaxes] = FuelTax.strTaxableByOtherTaxes
									,[strCalculationMethod] = FuelTax.strCalculationMethod
									,[dblRate] = FuelTax.dblRate
									,[intTaxAccountId] = FuelTax.intTaxAccountId
									,[dblTax] = FuelTax.dblTax
									,[dblAdjustedTax] = FuelTax.dblAdjustedTax
									,[ysnTaxAdjusted] = 1
									,[ysnSeparateOnInvoice] = 0
									,[ysnCheckoffTax] = FuelTax.ysnCheckoffTax
									,[ysnTaxExempt] = FuelTax.ysnTaxExempt
									,[ysnTaxOnly] = FuelTax.ysnTaxOnly
									,[strNotes] = FuelTax.strNotes
									,[intTempDetailIdForTaxes] = CC.intCustChargeId             -- Mark for Rank
									,[dblCurrencyExchangeRate] = 0
									,[ysnClearExisting] = 0
									,[strTransactionType] = ''
									,[strType] = ''
									,[strSourceTransaction] = @strtblSTCheckoutCustomerCharges02 -- Mark for Rank
									,[intSourceId] = @intCheckoutId
									,[strSourceId] = @intCheckoutId
									,[intHeaderId] = @intCheckoutId
									,[dtmDate] = GETDATE()
						FROM tblSTCheckoutCustomerCharges CC
						JOIN tblSTCheckoutHeader CH 
							ON CC.intCheckoutId = CH.intCheckoutId
						JOIN tblSTStore ST 
							ON CH.intStoreId = ST.intStoreId
						JOIN tblICItemUOM STUOM
							ON ST.intCustomerChargesItemId = STUOM.intItemId
						JOIN vyuEMEntityCustomerSearch vC 
							ON CC.intCustomerId = vC.intEntityId					
						INNER JOIN tblICItemUOM UOM 
							ON UOM.intItemUOMId = CASE 
													WHEN CC.intProduct IS NOT NULL
														THEN CC.intProduct
													ELSE STUOM.intItemUOMId
												END
						LEFT JOIN tblICItem I 
							ON UOM.intItemId = I.intItemId
						LEFT JOIN tblICItemLocation IL 
							ON I.intItemId = IL.intItemId
							AND ST.intCompanyLocationId = IL.intLocationId
						LEFT JOIN tblSTPumpItem TPI 
							ON UOM.intItemUOMId = TPI.intItemUOMId AND ST.intStoreId = TPI.intStoreId

						-- http://jira.irelyserver.com/browse/ST-1316
						--LEFT JOIN tblICItemPricing IP 
						--	ON I.intItemId = IP.intItemId
						--	AND IL.intItemLocationId = IP.intItemLocationId	

						CROSS APPLY dbo.fnConstructLineItemTaxDetail (
																			-- ISNULL(CC.dblQuantity, 0)						    -- Qty
																			CASE
																				WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																					THEN
																						CASE
																							WHEN (CC.dblAmount >= 0)
																								THEN ISNULL(CC.dblQuantity, 0)	
																							WHEN (CC.dblAmount < 0)
																								THEN (ISNULL(CC.dblQuantity, 0) * -1)
																						END
																				ELSE ISNULL(CC.dblQuantity, 0)
																			END
																			, ABS(ISNULL(CAST(CC.dblAmount AS DECIMAL(18,2)), 0))	-- Gross Amount CC.dblUnitPrice
																			, @LineItems
																			, 1										-- is Reversal
																			--, I.intItemId							-- Item Id
																			, CASE
																				WHEN I.intItemId IS NOT NULL 
																					THEN I.intItemId
																				ELSE ST.intCustomerChargesItemId
																			END
																			, CC.intCustomerId	-- ST.intCheckoutCustomerId				-- Customer Id
																			, ST.intCompanyLocationId				-- Company Location Id
																			, TPI.intTaxGroupId						-- Tax Group Id
																			, 0										-- 0 Price if not reversal
																			, @dtmCheckoutDate						-- Tax is also computed based on date. Use Checkout date.
																			, vC.intShipToId						-- Ship to Location
																			, 1
																			, 1			                            --@IncludeInvalidCodes
																			, NULL
																			, vC.intFreightTermId					-- FreightTermId
																			, NULL
																			, NULL
																			, 0
																			, 0
																			, UOM.intItemUOMId
																			,NULL									--@CFSiteId
																			,0										--@IsDeliver
																			,0                                      --@IsCFQuote
																			,NULL
																			,NULL
																			,NULL
																		
						) FuelTax
						WHERE CC.intCheckoutId = @intCheckoutId
							AND ISNULL(CC.dblAmount, 0) != 0
							AND I.intItemId IS NOT NULL
							AND I.ysnFuelItem = CAST(1 AS BIT)
						end try
						begin catch
							SET @strStatusMsg = CAST(ERROR_MESSAGE() AS VARCHAR(MAX))

							-- ROLLBACK
							GOTO ExitWithRollback
						end catch


						INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[dtmCalculated]
											,[dtmPostDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnRecap] -- RECAP
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intOrderUOMId]
											,[dblQtyOrdered]
											,[intItemUOMId]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[strImportFormat]
											,[dblCOGSAmount]
											,[intTempDetailIdForTaxes]
											,[intConversionAccountId]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[intSubCurrencyId]
											,[dblSubCurrencyRate]
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'

											--,[strTransactionType]		= @strInvoiceTypeCustomerCharges
											,[strTransactionType]		= CASE
																			-- IF Item is NOT Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(0 AS BIT))
																				THEN
																					CASE
																						-- WHEN (CC.dblAmount > 0)
																						WHEN (CCMerge.dblAmountSUM >= 0)
																							THEN 'Invoice'
																						-- WHEN (CC.dblAmount < 0)
																						WHEN (CCMerge.dblAmountSUM < 0)
																							THEN 'Credit Memo'
																					END

																			-- IF Item is Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																				THEN
																					CASE
																						-- WHEN (CC.dblAmount > 0)
																						WHEN (CCMerge.dblAmountSUM >= 0)
																							THEN 'Invoice'
																						-- WHEN (CC.dblAmount < 0)
																						WHEN (CCMerge.dblAmountSUM < 0)
																							THEN 'Credit Memo'
																					END

																			-- IF Item is BLANK
																			WHEN (I.intItemId IS NULL)
																				THEN
																					CASE
																						-- WHEN (CC.dblAmount > 0)
																						WHEN (CCMerge.dblAmountSUM >= 0)
																							THEN 'Invoice'
																						-- WHEN (CC.dblAmount < 0)
																						WHEN (CCMerge.dblAmountSUM < 0)
																							THEN 'Credit Memo'
																					END
																		END

										    ,[strType]					= @strInvoiceTypeMain
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId				-- NULL = New
											,[intEntityCustomerId]		= CC.intCustomerId					-- This Customer should come from selected customer in Customer Charges tab, This will also create a separate Invoice
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId					-- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate					--GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate					--GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate					--GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate					--GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate					--GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL								-- not sure
											,[strPONumber]				= NULL								-- not sure
											,[strBOLNumber]				= NULL								-- not sure

											,[strComments]				= @strComments + '[' + CAST(CC.intCustomerId AS NVARCHAR(100)) + ']' -- to be able to create reparate Invoices (intCustomerId + intInvoice)
																															  -- if  row 1 = Customer 1, Invoice = 1234
																															  -- and row 2 = Customer 2, Invoice = 1234
																															  -- then create 1 invoice for both

																															  -- if  row 1 = Customer 1, Invoice = 1234
																															  -- and row 2 = Customer 1, Invoice = 12345
																															  -- then create 1 invoice for each
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
											,[intBillToLocationId]		= NULL
											,[ysnTemplate]				= 0
											,[ysnForgiven]				= 0
											,[ysnCalculated]			= 0 -- not sure
											,[ysnSplitted]				= 0
											,[intPaymentId]				= NULL
											,[intSplitId]				= NULL
											,[intLoadDistributionHeaderId]	= NULL
											,[strActualCostId]			= NULL
											,[intShipmentId]			= NULL
											,[intTransactionId]			= NULL
											,[intEntityId]				= @intCurrentUserId
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnRecap]					= @ysnRecap
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL

											--,[intItemId]				= I.intItemId
											,[intItemId]				= CASE
																			WHEN I.intItemId IS NOT NULL
																				THEN I.intItemId
																			ELSE ST.intCustomerChargesItemId
																		END

											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= CC.intProduct --UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- -1
											,[intItemUOMId]				= CC.intProduct --UOM.intItemUOMId

											--,[dblQtyShipped]			= 1 -- If separate invoice change negative to positive Qty
											,[dblQtyShipped]			= CASE
																			-- IF Item is NOT Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(0 AS BIT))
																				THEN
																					CASE
																						-- WHEN (CC.dblAmount >= 0)
																						WHEN (CCMerge.dblAmountSUM >= 0)
																							THEN CC.dblQuantity
																						-- WHEN (CC.dblAmount < 0)
																						WHEN (CCMerge.dblAmountSUM < 0)
																							THEN (CC.dblQuantity * -1)
																					END

																			-- IF Item is Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																				THEN
																					CASE
																						-- WHEN (CC.dblAmount >= 0)
																						WHEN (CCMerge.dblAmountSUM >= 0)
																							THEN CC.dblQuantity
																						-- WHEN (CC.dblAmount < 0)
																						WHEN (CCMerge.dblAmountSUM < 0)
																							THEN (CC.dblQuantity * -1)
																					END

																			-- IF Item is BLANK
																			WHEN (I.intItemId IS NULL)
																				THEN
																					CASE
																						-- WHEN (CC.dblAmount >= 0)
																						WHEN (CCMerge.dblAmountSUM >= 0)
																							THEN 1
																						-- WHEN (CC.dblAmount < 0)
																						WHEN (CCMerge.dblAmountSUM < 0)
																							THEN 1
																					END
																		END

											,[dblDiscount]				= 0

											--,[dblPrice]					= ISNULL(CC.dblAmount,0)
											,[dblPrice]					= CASE
																			-- IF Item is NOT Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(0 AS BIT))
																				THEN
																					CASE
																						-- WHEN (CC.dblAmount > 0)
																						WHEN (CCMerge.dblAmountSUM >= 0)
																							THEN CC.dblUnitPrice
																						-- WHEN (CC.dblAmount < 0)
																						WHEN (CCMerge.dblAmountSUM < 0)
																							THEN CC.dblUnitPrice
																					END

																			-- IF Item is Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																				THEN
																					CASE
																						-- WHEN (CC.dblAmount < 0 OR CC.dblAmount > 0)
																						WHEN (CCMerge.dblAmountSUM < 0 OR CCMerge.dblAmountSUM >= 0)
																							THEN (ABS(ISNULL(CAST(CC.dblAmount AS DECIMAL(18,2)), 0)) - FuelTax.dblAdjustedTax) / ABS(CC.dblQuantity)
																					END

																			-- IF Item is BLANK
																			WHEN (I.intItemId IS NULL)
																				THEN ABS(CC.dblUnitPrice) -- Always set this to positive
																		END

											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= CASE 
																				-- IF Item is Fuel
																				WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																					THEN TPI.intTaxGroupId
																				ELSE NULL
																		END	
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
											,[intSCInvoiceId]			= NULL
											,[strSCInvoiceNumber]		= NULL
											,[intInventoryShipmentItemId] = NULL
											,[strShipmentNumber]		= NULL
											,[intSalesOrderDetailId]	= NULL
											,[strSalesOrderNumber]		= NULL
											,[intContractHeaderId]		= NULL
											,[intContractDetailId]		= NULL
											,[intShipmentPurchaseSalesContractId]	= NULL
											,[intTicketId]				= NULL
											,[intTicketHoursWorkedId]	= NULL
											,[intSiteId]				= NULL -- not sure
											,[strBillingBy]				= NULL -- not sure
											,[dblPercentFull]			= NULL
											,[dblNewMeterReading]		= NULL
											,[dblPreviousMeterReading]	= NULL -- not sure
											,[dblConversionFactor]		= NULL -- not sure
											,[intPerformerId]			= NULL -- not sure
											,[ysnLeaseBilling]			= NULL
											,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
											,[strImportFormat]			= @strtblSTCheckoutCustomerCharges02 -- Mark for Rank
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = CASE 
																			-- IF Item is Fuel
																			WHEN (I.intItemId IS NOT NULL AND I.ysnFuelItem = CAST(1 AS BIT))
																				THEN CC.intCustChargeId		 -- Mark for Rank
																			ELSE NULL						
																		END
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutCustomerCharges CC

								-- http://jira.irelyserver.com/browse/ST-1342
								INNER JOIN 
								(
									SELECT SUM(cc.dblAmount) AS dblAmountSUM
										   , cc.intCheckoutId
										   , cc.strComment
										   , cc.intCustomerId
									FROM tblSTCheckoutCustomerCharges cc
									GROUP BY cc.intCheckoutId, cc.strComment, cc.intCustomerId
								) CCMerge
									ON CC.intCheckoutId = CCMerge.intCheckoutId
									AND CC.strComment = CCMerge.strComment
									AND CC.intCustomerId = CCMerge.intCustomerId

								INNER JOIN tblSTCheckoutHeader CH 
									ON CC.intCheckoutId = CH.intCheckoutId
								INNER JOIN tblSTStore ST 
									ON CH.intStoreId = ST.intStoreId
								INNER JOIN tblICItemUOM STUOM
									ON ST.intCustomerChargesItemId = STUOM.intItemId
								INNER JOIN vyuEMEntityCustomerSearch vC 
									ON CC.intCustomerId = vC.intEntityId					
								INNER JOIN tblICItemUOM UOM 
									ON UOM.intItemUOMId = CASE 
															WHEN CC.intProduct IS NOT NULL
																THEN CC.intProduct
															ELSE STUOM.intItemUOMId
														END
								LEFT JOIN tblICItem I 
									ON UOM.intItemId = I.intItemId
								LEFT JOIN tblICItemLocation IL 
									ON I.intItemId = IL.intItemId
									AND ST.intCompanyLocationId = IL.intLocationId
								LEFT JOIN tblSTPumpItem TPI 
									ON UOM.intItemUOMId = TPI.intItemUOMId AND ST.intStoreId = TPI.intStoreId

								-- http://jira.irelyserver.com/browse/ST-1316
								--LEFT JOIN tblICItemPricing IP 
								--	ON I.intItemId = IP.intItemId
								--	AND IL.intItemLocationId = IP.intItemLocationId	

								LEFT OUTER JOIN
								(
									SELECT 
									   [dblAdjustedTax] = SUM ([dblAdjustedTax])
									 , [intTempDetailIdForTaxes]
									 , [strSourceTransaction]
									FROM
										@LineItemTaxEntries
									GROUP BY
										[intTempDetailIdForTaxes]
										, [strSourceTransaction]
								) FuelTax
									ON CC.intCustChargeId = FuelTax.intTempDetailIdForTaxes
									AND FuelTax.strSourceTransaction = @strtblSTCheckoutCustomerCharges02
								WHERE CC.intCheckoutId = @intCheckoutId
									AND ISNULL(CC.dblAmount, 0) != 0


					END
				------------------------------------------------------------------------
				------------------------- END CUSTOMER CHARGES -------------------------
				------------------------------------------------------------------------
				-- END CREATE SEPARATE INVOICE for Customer Charges

				
				------------------------------------------------------
				----------------- TEMP TABLE FOR LOTTERY  ------------
				------------------------------------------------------
				
				IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
				BEGIN 
					CREATE TABLE #tmpAddItemReceiptResult 
					(
						intSourceId INT,
						intInventoryReceiptId INT
					)
				END 

				------------------------------------------------------
				----------------- RECEIVE LOTTERY  -------------------
				------------------------------------------------------
				
				DECLARE @receiveLotteryId INT
				DECLARE @inventoryReceiptid INT
				DECLARE @storeId INT
				DECLARE @lotterySetupMode BIT
				DECLARE @Id INT
				DECLARE @ReceiptStagingTable ReceiptStagingTable
				,@OtherCharges ReceiptOtherChargesTableType
				,@defaultCurrency INT
				,@strReceiptType NVARCHAR(500)
				,@strSourceScreenName NVARCHAR(500)

				SELECT * INTO #tblSTTempReceiveLottery  
				FROM tblSTReceiveLottery WHERE intCheckoutId = @intCheckoutId

				IF((SELECT COUNT(*) FROM #tblSTTempReceiveLottery) > 0)
				BEGIN

					SELECT TOP 1 @lotterySetupMode = ISNULL(ysnLotterySetupMode,0)
					FROM tblSTStore WHERE intStoreId = @storeId

					IF (ISNULL(@lotterySetupMode,0) != 1)
					BEGIN
			

					SET @strReceiptType = 'Direct'
					SET @strSourceScreenName = 'Lottery Module'

					DECLARE @loopId INT = 0 
			

					WHILE EXISTS (SELECT TOP 1 * FROM #tblSTTempReceiveLottery )
					BEGIN
						-- VALIDATE IF VALID ITEMS BEFORE CREATING IR
						SELECT TOP 1 @loopId = intReceiveLotteryId FROM #tblSTTempReceiveLottery

						-- Validate if there is Item UOM setup
						IF EXISTS(SELECT TOP 1 1 FROM tblSTReceiveLottery RL
							INNER JOIN tblSTStore S ON S.intStoreId = RL.intStoreId
							INNER JOIN tblSTLotteryGame LG ON LG.intLotteryGameId = RL.intLotteryGameId
							LEFT JOIN tblICItemLocation IL ON IL.intLocationId = S.intCompanyLocationId
								AND IL.intItemId = LG.intItemId
							LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = IL.intIssueUOMId
							WHERE RL.intReceiveLotteryId = @loopId
							AND IU.intItemUOMId IS NULL)
						BEGIN
							-- SET @Success = CAST(0 AS BIT)
							SET @strStatusMsg = 'Missing Sale UOM setup on Item Location.'
							GOTO ExitWithRollback
							RETURN
						END

						DECLARE @strErrorItem AS VARCHAR(250) = (SELECT TOP 1 tblSTLotteryGame.strGame FROM tblSTReceiveLottery
									INNER JOIN tblSTStore 
									ON tblSTReceiveLottery.intStoreId = tblSTStore.intStoreId
									INNER JOIN tblSTLotteryGame 
									ON tblSTReceiveLottery.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
									INNER JOIN tblICItemLocation 
									ON tblICItemLocation.intLocationId = tblSTStore.intCompanyLocationId
										AND tblSTLotteryGame.intItemId = tblICItemLocation.intItemId
									INNER JOIN tblICItemPricing
										ON tblICItemPricing.intItemLocationId = tblICItemLocation.intItemLocationId
										AND tblICItemPricing.intItemId = tblICItemLocation.intItemId
									LEFT JOIN tblAPVendor 
									ON tblAPVendor.intEntityId = tblICItemLocation.intVendorId
									LEFT JOIN tblICItemUOM 
									ON tblICItemUOM.intItemUOMId = tblICItemLocation.intIssueUOMId
									LEFT JOIN tblSMCompanyLocation
									ON tblSTStore.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
									WHERE tblSTReceiveLottery.intCheckoutId = @intCheckoutId
									AND (SELECT intShipFromId FROM tblAPVendor WHERE intEntityId = tblICItemLocation.intVendorId) IS NULL)

						-- Validate if there is Item setup for Vendor
						IF @strErrorItem IS NOT NULL
						BEGIN
							-- SET @Success = CAST(0 AS BIT)
							SET @strStatusMsg = 'Item of Game ' + @strErrorItem + ' is missing Vendor on Item Location setup.'
							GOTO ExitWithRollback
							RETURN
						END
					
						DELETE FROM #tblSTTempReceiveLottery WHERE intReceiveLotteryId = @loopId
					END
				
					--DECLARE @ReceiptStagingTable ReceiptStagingTable 
					INSERT INTO @ReceiptStagingTable(
						strReceiptType
						,strSourceScreenName
						,intEntityVendorId
						,intShipFromId
						,intLocationId
						,intItemId
						,intItemLocationId
						,intItemUOMId
						,intCostUOMId
						,strBillOfLadding
						,intContractHeaderId
						,intContractDetailId
						,dtmDate
						,intShipViaId
						,dblQty
						,dblCost
						,intCurrencyId
						,dblExchangeRate
						,intLotId
						,intSubLocationId
						,intStorageLocationId
						,ysnIsStorage
						,dblFreightRate
						,intSourceId	
						,intSourceType		 	
						,dblGross
						,dblNet
						,intInventoryReceiptId
						,dblSurcharge
						,ysnFreightInPrice
						,strActualCostId
						,intTaxGroupId
						,strVendorRefNo
						,strSourceId			
						,intPaymentOn
						,strChargesLink
						,dblUnitRetail
						,intSort
						,strDataSource
					)	
					SELECT strReceiptType	= @strReceiptType
					,strSourceScreenName	= @strSourceScreenName
					,intEntityVendorId		= tblICItemLocation.intVendorId
					,intShipFromId			= (SELECT TOP 1 intShipFromId FROM tblAPVendor WHERE intEntityId = tblICItemLocation.intVendorId)
					,intLocationId			= tblSTStore.intCompanyLocationId
					,intItemId				= tblSTLotteryGame.intItemId
					,intItemLocationId		= tblICItemLocation.intItemLocationId
					,intItemUOMId			= tblICItemUOM.intItemUOMId
					, intCostUOMId			= tblICItemUOM.intUnitMeasureId
					,strBillOfLadding		= ''
					,intContractHeaderId	= NULL
					,intContractDetailId	= NULL
					,dtmDate				= tblSTReceiveLottery.dtmReceiptDate
					,intShipViaId			= NULL
					,dblQty					= tblSTReceiveLottery.intTicketPerPack
					,dblCost				= tblSTLotteryGame.dblInventoryCost 
					,intCurrencyId			= @defaultCurrency
					,dblExchangeRate		= 1
					,intLotId				= NULL
					,intSubLocationId		= NULL
					,intStorageLocationId	= NULL
					,ysnIsStorage			= 0
					,dblFreightRate			= 0
					,intSourceId			= tblSTReceiveLottery.intReceiveLotteryId
					,intSourceType		 	= 7
					,dblGross				= NULL
					,dblNet					= NULL
					,intInventoryReceiptId	= tblSTReceiveLottery.intInventoryReceiptId 
					,dblSurcharge			= NULL
					,ysnFreightInPrice		= NULL
					,strActualCostId		= NULL
					,intTaxGroupId			= NULL
					,strVendorRefNo			= tblSMCompanyLocation.strVendorRefNoPrefix  + ISNULL(tblSTLotteryGame.strGame,'') + ISNULL(tblSTReceiveLottery.strBookNumber,'')
					,strSourceId			= NULL
					,intPaymentOn			= NULL
					,strChargesLink			= NULL
					,dblUnitRetail			= tblSTLotteryGame.dblTicketValue
					,intSort				= NULL
					,strDataSource			= @strSourceScreenName
					FROM tblSTReceiveLottery
					INNER JOIN tblSTStore 
					ON tblSTReceiveLottery.intStoreId = tblSTStore.intStoreId
					INNER JOIN tblSTLotteryGame 
					ON tblSTReceiveLottery.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
					INNER JOIN tblICItemLocation 
					ON tblICItemLocation.intLocationId = tblSTStore.intCompanyLocationId
						AND tblSTLotteryGame.intItemId = tblICItemLocation.intItemId
					INNER JOIN tblICItemPricing
						ON tblICItemPricing.intItemLocationId = tblICItemLocation.intItemLocationId
						AND tblICItemPricing.intItemId = tblICItemLocation.intItemId
					LEFT JOIN tblAPVendor 
					ON tblAPVendor.intEntityId = tblICItemLocation.intVendorId
					LEFT JOIN tblICItemUOM 
					ON tblICItemUOM.intItemUOMId = tblICItemLocation.intIssueUOMId
					LEFT JOIN tblSMCompanyLocation
					ON tblSTStore.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
					WHERE tblSTReceiveLottery.intCheckoutId = @intCheckoutId

					-- SELECT strVendorRefNoPrefix,* FROM tblSTStore


					EXEC dbo.uspICAddItemReceipt 
						@ReceiptStagingTable
						, @OtherCharges
						, @intCurrentUserId;
				
					UPDATE tblSTReceiveLottery SET intInventoryReceiptId = tblResult.intInventoryReceiptId FROM #tmpAddItemReceiptResult as tblResult WHERE tblSTReceiveLottery.intReceiveLotteryId = tblResult.intSourceId
					-- SELECT * FROM #tmpAddItemReceiptResult

					-- Flag Success
					-- SET @Success = CAST(1 AS BIT)
					-- SET @StatusMsg = ''
					END


					--POST RECEIVE LOTTERY--
					DECLARE @receiveLotteryCount INT = 0 
					SELECT @receiveLotteryCount = COUNT(1) FROM #tmpAddItemReceiptResult
					DECLARE @receiptNumber NVARCHAR(100)

					IF(ISNULL(@receiveLotteryCount,0) != 0)
					BEGIN
						BEGIN TRY
							DECLARE @loopPostInventoryReceiptId INT = 0 
							WHILE EXISTS(SELECT TOP 1 * FROM #tmpAddItemReceiptResult)
							BEGIN
								SELECT TOP 1 @loopPostInventoryReceiptId = intInventoryReceiptId  FROM #tmpAddItemReceiptResult

								SELECT	@receiptNumber = strReceiptNumber 
								FROM	tblICInventoryReceipt 
								WHERE	intInventoryReceiptId = @loopPostInventoryReceiptId
					
								EXEC dbo.uspICPostInventoryReceipt 1, 0, @receiptNumber, @intCurrentUserId;		
						
								UPDATE tblSTReceiveLottery SET ysnPosted = 1 WHERE intInventoryReceiptId = @loopPostInventoryReceiptId	

								-- SET @Success = CAST(1 AS BIT)
								-- SET @StatusMsg = ''

								DELETE FROM #tmpAddItemReceiptResult WHERE intInventoryReceiptId = @loopPostInventoryReceiptId	
							END
						END TRY
						BEGIN CATCH
					
							--UPDATE tblSTReceiveLottery SET ysnPosted = 0 WHERE intInventoryReceiptId = @loopPostInventoryReceiptId	 

							SET @strStatusMsg = ERROR_MESSAGE()
							GOTO ExitWithRollback
						END CATCH
					END
					--POST RECEIVE LOTTERY--
				END				
				
				------------------------------------------------------
				----------------- RECEIVE LOTTERY  -------------------
				------------------------------------------------------

				------------------------------------------------------
				---------- TRANSFER TANK READINGS TO TM  -------------
				------------------------------------------------------
				INSERT INTO		tblTMTankReading (intConcurrencyId, dtmDateTime, intReadingSource, intTankNumber, dblFuelVolume, intCheckoutId, ysnManual, intSiteId, intDeviceId, intDeviceTankMonitorId, strSerialNumber)
                SELECT			1 as intConcurrencyId, 
								dtmFuelInventoryDate, 
								CASE
									WHEN ysnIsManualEntry = 0
									THEN 2
									WHEN ysnIsManualEntry = 1
									THEN 3
									ELSE 1
									END as intReadingSource,
								storeFuelTank.intRegisterTankNumber as intTankNumber, 
								dblGallons, 
								intCheckoutId,
								CASE
									WHEN ysnIsManualEntry = 0
									THEN 0
									WHEN ysnIsManualEntry = 1
									THEN 1
									ELSE 1
									END as ysnManual,
								siteDevice.intSiteID,
								fuelInventory.intDeviceId,
								siteDeviceTankMonitor.intDeviceTankMonitorId,
								tankMonitorDevice.strSerialNumber                
				FROM			tblSTCheckoutFuelInventory fuelInventory
				INNER JOIN		tblTMDevice device
				ON				fuelInventory.intDeviceId = device.intDeviceId
				INNER JOIN		tblSTStoreFuelTanks storeFuelTank
				ON				fuelInventory.intDeviceId = storeFuelTank.intDeviceId
				LEFT JOIN		tblTMSiteDevice siteDevice 
				ON				fuelInventory.intDeviceId = siteDevice.intDeviceId
				LEFT JOIN		tblTMSiteDeviceTankMonitor siteDeviceTankMonitor
				ON				siteDevice.intSiteID = siteDeviceTankMonitor.intSiteId
				LEFT JOIN		tblTMDeviceTankMonitor deviceTankMonitor
				ON				siteDeviceTankMonitor.intDeviceTankMonitorId = deviceTankMonitor.intDeviceTankMonitorId
				LEFT JOIN		tblTMDevice tankMonitorDevice
				ON				tankMonitorDevice.intDeviceId = deviceTankMonitor.intDeviceId
                WHERE			fuelInventory.intCheckoutId = @intCheckoutId
				------------------------------------------------------
				---------- TRANSFER TANK READINGS TO TM  -------------
				------------------------------------------------------

				----------------------------------------------------------------------
				------------------------------- POST ---------------------------------
				----------------------------------------------------------------------
				DECLARE @ErrorMessage AS NVARCHAR(MAX) = ''
				DECLARE @CreatedIvoices AS NVARCHAR(MAX)
				

				-- Note: Do not include Department that has zero ItemSold quantity (http://jira.irelyserver.com/browse/ST-1204)
				--       Include Qty that is < 0 because of the Refunded item
				DELETE FROM @EntriesForInvoice WHERE dblQtyShipped = 0 OR dblQtyShipped IS NULL 
				DELETE FROM @EntriesForCSCreditMemo WHERE dblQtyShipped = 0 OR dblQtyShipped IS NULL 


--PRINT 'START POST TO AR SALES INVOICE'
				----------------------------------------------------------------------
				----------------- START POST TO AR SALES INVOICE ---------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM @EntriesForInvoice)
					BEGIN

						    -- Filter None Lotted Items Only
							INSERT INTO @tblTempItems
							(
								intItemId
								, strItemNo
							)
							SELECT DISTINCT
								I.intItemId
								, I.strItemNo
							FROM @EntriesForInvoice E
							JOIN tblICItem I 
								ON E.intItemId = I.intItemId
							WHERE I.strLotTracking != 'No'

							-- Validate Items if Lotted
							IF EXISTS(SELECT * FROM @tblTempItems)
								BEGIN

									DECLARE @strLottedItem AS NVARCHAR(MAX) = ''

									SELECT @strLottedItem = @strLottedItem + temp.strItemNo + ', '
									FROM @tblTempItems temp
									SELECT @strLottedItem = LEFT(@strLottedItem, LEN(@strLottedItem)-1)

									SET @ysnUpdateCheckoutStatus = 0
									SET @strStatusMsg = 'Lotted Items (' + @strLottedItem + ') Only None Lotted Items are allowed '

									-- ROLLBACK
									GOTO ExitWithRollback
									-- RETURN
								END
							ELSE
								BEGIN

									BEGIN TRY
										
										-- Insert to table for Batch Posting
										INSERT INTO @EntriesForInvoiceBatchPost(
											[intId]
											,[strTransactionType]
											,[strSourceTransaction]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,[dtmDueDate]
											,[dtmShipDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[ysnUseOriginIdAsInvoiceNumber]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intItemUOMId]
											,[dblQtyOrdered]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[ysnClearDetailTaxes]					
											,[intTempDetailIdForTaxes]
											,[strType]
											,[ysnUpdateAvailableDiscount]
											,[strItemTermDiscountBy]
											,[dblItemTermDiscount]
											,[dtmPostDate]
											,[ysnImpactInventory]
											,[dblCOGSAmount]
											,[strImportFormat]
											,[dblSubCurrencyRate]
											,[dblCurrencyExchangeRate]
											,[ysnRecap]
											,[intSubLocationId]
											,[intCompanyLocationSubLocationId]
											)
										SELECT 
											ROW_NUMBER() OVER(ORDER BY intEntityCustomerId ASC)
											,[strTransactionType]
											,[strSourceTransaction]
											,[intSourceId]
											,[strSourceId]
											,[intInvoiceId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[intTermId]
											,[dtmDate]
											,CASE WHEN @ysnConsignmentStore = 0
												THEN [dtmDueDate]
												ELSE CAST(FLOOR(CAST(GETDATE()AS FLOAT))AS DATETIME)
												END
											,[dtmShipDate]
											,[intEntitySalespersonId]
											,[intFreightTermId]
											,[intShipViaId]
											,[intPaymentMethodId]
											,[strInvoiceOriginId]
											,[ysnUseOriginIdAsInvoiceNumber]
											,[strPONumber]
											,[strBOLNumber]
											,[strComments]
											,[intShipToLocationId]
											,[intBillToLocationId]
											,[ysnTemplate]
											,[ysnForgiven]
											,[ysnCalculated]
											,[ysnSplitted]
											,[intPaymentId]
											,[intSplitId]
											,[intLoadDistributionHeaderId]
											,[strActualCostId]
											,[intShipmentId]
											,[intTransactionId]
											,[intEntityId]
											,[ysnResetDetails]
											,[ysnPost]
											,[intInvoiceDetailId]
											,[intItemId]
											,[ysnInventory]
											,[strItemDescription]
											,[intItemUOMId]
											,[dblQtyOrdered]
											,[dblQtyShipped]
											,[dblDiscount]
											,[dblPrice]
											,[ysnRefreshPrice]
											,[strMaintenanceType]
											,[strFrequency]
											,[dtmMaintenanceDate]
											,[dblMaintenanceAmount]
											,[dblLicenseAmount]
											,[intTaxGroupId]
											,[ysnRecomputeTax]
											,[intSCInvoiceId]
											,[strSCInvoiceNumber]
											,[intInventoryShipmentItemId]
											,[strShipmentNumber]
											,[intSalesOrderDetailId]
											,[strSalesOrderNumber]
											,[intContractHeaderId]
											,[intContractDetailId]
											,[intShipmentPurchaseSalesContractId]
											,[intTicketId]
											,[intTicketHoursWorkedId]
											,[intSiteId]
											,[strBillingBy]
											,[dblPercentFull]
											,[dblNewMeterReading]
											,[dblPreviousMeterReading]
											,[dblConversionFactor]
											,[intPerformerId]
											,[ysnLeaseBilling]
											,[ysnVirtualMeterReading]
											,[ysnClearDetailTaxes]					
											,[intTempDetailIdForTaxes]
											,[strType]
											,[ysnUpdateAvailableDiscount]
											,[strItemTermDiscountBy]
											,[dblItemTermDiscount]
											,[dtmPostDate]
											,[ysnImpactInventory]
											,[dblCOGSAmount]
											,[strImportFormat]
											,[dblSubCurrencyRate]
											,[dblCurrencyExchangeRate]
											,[ysnRecap]
											,[intSubLocationId]
											,[intCompanyLocationSubLocationId]
										FROM @EntriesForInvoice



-- ============================================================================================
-- [START] TEST TO DEBUG
-- ============================================================================================
IF(@ysnDebug = 1)
BEGIN
SELECT '@EntriesForInvoiceBatchPost-All Items to send to Sales Invoice'
		, [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments]
		, strComments
		, intEntityCustomerId
		, strTransactionType
		, dblQtyShipped
		, dblPrice
		, strItemDescription
		, * 
FROM @EntriesForInvoiceBatchPost
END
-- ============================================================================================
-- [END] TEST TO DEBUG
-- ============================================================================================


										-------------------------------------------------------------------------------
										------------------------------- Start Rank ------------------------------------
										-------------------------------------------------------------------------------
										IF EXISTS(SELECT TOP 1 1 FROM @LineItemTaxEntries)
											BEGIN
												-- Table @LineItemTaxEntries
												-- intTempDetailIdForTaxes - Primary Id
												-- strSourceTransaction - origin table

												-- Table @EntriesForInvoiceBatchPost
												-- intTempDetailIdForTaxes - Primary Id
												-- strImportFormat - origin table

												-- Create Ranking
												INSERT INTO @tblTempRank
												(
													intRankId
													, intTempDetailIdForTaxes
													, strSourceTransaction
												)
												SELECT 
													RANK() OVER(ORDER BY intTempDetailIdForTaxes, strSourceTransaction) AS intRankId
													, intTempDetailIdForTaxes
													, strSourceTransaction
												FROM @LineItemTaxEntries
												
												-- Update UDTables
												UPDATE tbl
												SET tbl.intTempDetailIdForTaxes = Ranking.intRankId
												FROM @EntriesForInvoiceBatchPost tbl
												INNER JOIN @tblTempRank Ranking
													ON tbl.intTempDetailIdForTaxes = Ranking.intTempDetailIdForTaxes										-- Id
													AND tbl.strImportFormat COLLATE SQL_Latin1_General_CP1_CS_AS = Ranking.strSourceTransaction				-- Table

												UPDATE Tax
												SET Tax.intTempDetailIdForTaxes = Ranking.intRankId
												FROM @LineItemTaxEntries Tax
												INNER JOIN @tblTempRank Ranking
													ON Tax.intTempDetailIdForTaxes = Ranking.intTempDetailIdForTaxes											-- Id
													AND Tax.strSourceTransaction COLLATE SQL_Latin1_General_CP1_CS_AS = Ranking.strSourceTransaction			-- Table


-- ============================================================================================
-- [START] TEST TO DEBUG
-- ============================================================================================
IF(@ysnDebug = 1)
	BEGIN
		SELECT 'For Items that has Tax'

		SELECT '@LineItemTaxEntries-List of Taxes on Items', intTempDetailIdForTaxes, strSourceTransaction, * 
		FROM @LineItemTaxEntries
		WHERE intTempDetailIdForTaxes IS NOT NULL
			AND strSourceTransaction <> ''

		-- 11 = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments]
		SELECT '@EntriesForInvoiceBatchPost-Items that has Tax Calc'
				, [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments]
				, intTempDetailIdForTaxes, strSourceTransaction, strImportFormat, * 
		FROM @EntriesForInvoiceBatchPost
		WHERE intTempDetailIdForTaxes IS NOT NULL
			OR strImportFormat <> ''
	END
-- ============================================================================================
-- [END] TEST TO DEBUG
-- ============================================================================================


												-- Clear values
												UPDATE @LineItemTaxEntries
												SET strSourceTransaction = ''
												WHERE intTempDetailIdForTaxes IS NOT NULL
													OR strSourceTransaction <> ''

												UPDATE @EntriesForInvoiceBatchPost
												SET strImportFormat = ''
												WHERE intTempDetailIdForTaxes IS NOT NULL
													OR strImportFormat <> ''
											END
										-------------------------------------------------------------------------------
										------------------------------- End Rank --------------------------------------
										-------------------------------------------------------------------------------

										--SELECT * FROM @LineItemTaxEntries


										-- POST Main Checkout Invoice (Batch Posting)
										EXEC [dbo].[uspARProcessInvoicesByBatch]
													@InvoiceEntries				= @EntriesForInvoiceBatchPost
													,@LineItemTaxEntries		= @LineItemTaxEntries
													,@UserId					= @intCurrentUserId
		 											,@GroupingOption			= 11
													,@RaiseError				= 1
													,@ErrorMessage				= @ErrorMessage OUTPUT
													,@LogId					    = @intIntegrationLogId OUTPUT

										-- NOT RECAP
										IF(@ysnRecap = CAST(0 AS BIT))
											BEGIN
	
											IF EXISTS(SELECT intIntegrationLogId FROM tblARInvoiceIntegrationLog WHERE intIntegrationLogId = @intIntegrationLogId) AND ISNULL(@ErrorMessage, '') = ''
												BEGIN

													IF NOT EXISTS(SELECT intIntegrationLogId FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId AND ysnPosted = CAST(0 AS BIT))
														BEGIN

															-- Posting to Sales Invoice was successfull
															UPDATE tblSTCheckoutHeader
															SET intSalesInvoiceIntegrationLogId = @intIntegrationLogId
															WHERE intCheckoutId = @intCheckoutId

															SELECT @strBatchIdForNewPostRecap = ISNULL(strBatchIdForNewPostRecap, '')
															FROM tblARInvoiceIntegrationLog
															WHERE intIntegrationLogId = @intIntegrationLogId

															-- Insert to Temp Table
															DELETE FROM @tblTempInvoiceIds

															INSERT INTO @tblTempInvoiceIds
															(
																intInvoiceId,
																intEntityId,
																ysnPosted,
																strTransactionType
															)
															SELECT DISTINCT
																LogDetail.intInvoiceId,
																Inv.intEntityCustomerId,
																Inv.ysnPosted,
																LogDetail.strTransactionType
															FROM tblARInvoiceIntegrationLogDetail LogDetail
															INNER JOIN tblARInvoice Inv
																ON LogDetail.intInvoiceId = Inv.intInvoiceId
															WHERE intIntegrationLogId = (
																							SELECT intSalesInvoiceIntegrationLogId
																							FROM tblSTCheckoutHeader
																							WHERE intCheckoutId =  @intCheckoutId
																						)

															-- Populate variable with Invoice Ids
															SELECT @CreatedIvoices = COALESCE(@CreatedIvoices + ',', '') + CAST(intInvoiceId AS VARCHAR(50))
															FROM @tblTempInvoiceIds

															IF @ysnConsignmentStore = 1
															BEGIN
																SELECT @intConsInvoiceId = intInvoiceId
																FROM @tblTempInvoiceIds;	
															END

															-- =========================================================================================================================
															-- [START] - Proccess 'Credit Memo' as 'Cash Refund'
															-- =========================================================================================================================
															-- Error if directly creating a Cash Refund (Error: 'Cash Refund amount is not equal to prepaids/credits applied.')
															-- As per Kelvin the process for @strCREDITMEMO would be
															-- 1. Process this as transaction type='Credit Memo'   (using uspARProcessInvoicesByBatch)
															-- 2. After process has finish Process this as @strCREDITMEMO    (using uspARProcessRefund)

															IF(@strInvoiceTransactionTypeMain = @strCREDITMEMO)
																BEGIN
																	DECLARE @intMainInvoiceId_CR AS INT = (SELECT TOP 1 intInvoiceId FROM @tblTempInvoiceIds WHERE strTransactionType = @strInvoiceTransactionTypeMain),
																	@intNewTransactionId_CR AS INT,
																	@strErrorMessage_CR AS NVARCHAR(MAX)

																	EXEC [dbo].[uspARProcessRefund]
																		  @intInvoiceId			= @intMainInvoiceId_CR
																		, @intUserId			= @intCurrentUserId
																		, @intNewTransactionId	= @intNewTransactionId_CR OUTPUT
																		, @strErrorMessage		= @strErrorMessage_CR OUTPUT				

																	IF(@ysnDebug = 1)
																		BEGIN
																			--TEST
																			SELECT 'uspARProcessRefund OUTPUT', @intNewTransactionId_CR, @strErrorMessage_CR
																			SELECT 'Invoice', * FROM tblARInvoice WHERE intInvoiceId = @intMainInvoiceId_CR
																		END

																	IF(@strErrorMessage_CR IS NOT NULL)
																		BEGIN
																			SET @ErrorMessage = @strErrorMessage_CR
																			SET @strStatusMsg = 'Process To Cash Refund error. ' + ISNULL(@ErrorMessage, '')

																			-- ROLLBACK
																			GOTO ExitWithRollback
																		END
																	
																END
															
															-- =========================================================================================================================
															-- [END] - Proccess 'Credit Memo' as 'Cash Refund'
															-- =========================================================================================================================


														END
													ELSE
														BEGIN
															-- SELECT * FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId
															SET @ErrorMessage = (SELECT TOP 1 strPostingMessage FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId AND ysnPosted = CAST(0 AS BIT))
															SET @strStatusMsg = 'Main End of day was not Posted correctly. ' + ISNULL(@ErrorMessage, '')

															-- ROLLBACK
															GOTO ExitWithRollback
															-- RETURN
														END
												END
											ELSE
												BEGIN
													SET @strStatusMsg = 'Post Main End of day has error: ' + @ErrorMessage

													-- ROLLBACK
													GOTO ExitWithRollback
													-- RETURN
												END

										END

										-- Check if RECAP
										ELSE IF(@ysnRecap = CAST(1 AS BIT))
											BEGIN -- Start: @ysnRecap = 1
											
												-- Get Batch Id
												
												-- http://jira.irelyserver.com/browse/ST-1277
												-- tblARInvoiceIntegrationLog.strBatchIdForNewPostRecap value is always empty
												-- tblARInvoiceIntegrationLogDetail.strBatchId Top (1) has Batch Id
												SELECT TOP (1) @strBatchIdForNewPostRecap = strBatchId 
												FROM tblARInvoiceIntegrationLogDetail 
												WHERE intIntegrationLogId = @intIntegrationLogId
													AND ysnHeader = 1 
													AND ysnPost = @ysnPost 
													AND ysnRecap = @ysnRecap 
												ORDER BY intIntegrationLogDetailId ASC
												--SELECT @strBatchIdForNewPostRecap = ISNULL(strBatchIdForNewPostRecap, '')
												--FROM tblARInvoiceIntegrationLog 
												--WHERE intIntegrationLogId = @intIntegrationLogId

												IF(@strBatchIdForNewPostRecap IS NOT NULL AND @strBatchIdForNewPostRecap != '')
													BEGIN -- Start:@strBatchIdForNewPostRecap

														IF EXISTS(SELECT strBatchId FROM tblGLPostRecap WHERE strBatchId = @strBatchIdForNewPostRecap)
															BEGIN
																SET @strCreateGuidBatch = NEWID();

																-- GET POST PREVIEW on GL Entries
																INSERT INTO @GLEntries (
																						[dtmDate] 
																						,[strBatchId]
																						,[intAccountId]
																						,[dblDebit]
																						,[dblCredit]
																						,[dblDebitUnit]
																						,[dblCreditUnit]
																						,[strDescription]
																						,[strCode]
																						,[strReference]
																						,[intCurrencyId]
																						,[dblExchangeRate]
																						,[dtmDateEntered]
																						,[dtmTransactionDate]
																						,[strJournalLineDescription]
																						,[intJournalLineNo]
																						,[ysnIsUnposted]
																						,[intUserId]
																						,[intEntityId]
																						,[strTransactionId]
																						,[intTransactionId]
																						,[strTransactionType]
																						,[strTransactionForm]
																						,[strModuleName]
																						,[intConcurrencyId]
																						,[dblDebitForeign]	
																						--,[dblDebitReport]	
																						,[dblCreditForeign]	
																						--,[dblCreditReport]	
																						--,[dblReportingRate]	
																						--,[dblForeignRate]
																						,[strRateType]
																				)
																			SELECT [dtmDate] 
																						,[strBatchId] = @strCreateGuidBatch
																						,[intAccountId]
																						,[dblDebit]
																						,[dblCredit]
																						,[dblDebitUnit]
																						,[dblCreditUnit]
																						,[strDescription]
																						,[strCode]
																						,[strReference]
																						,[intCurrencyId]
																						,[dblExchangeRate]
																						,[dtmDateEntered]
																						,[dtmTransactionDate]
																						,[strJournalLineDescription]
																						,[intJournalLineNo]
																						,[ysnIsUnposted]
																						,[intUserId]
																						,[intEntityId]
																						,[strTransactionId]
																						,[intTransactionId]
																						,[strTransactionType]
																						,[strTransactionForm]
																						,[strModuleName]
																						,[intConcurrencyId]
																						,[dblDebitForeign]	
																						--,[dblDebitReport]	
																						,[dblCreditForeign]	
																						--,[dblCreditReport]	
																						--,[dblReportingRate]	
																						--,[dblForeignRate]
																						,[strRateType]
																				FROM tblGLPostRecap
																				WHERE strBatchId = @strBatchIdForNewPostRecap
																 
																
																IF @@TRANCOUNT > 0
																BEGIN
																	ROLLBACK TRANSACTION
																END


																IF @@TRANCOUNT = 0
																BEGIN
																	BEGIN TRANSACTION
																END

																	EXEC dbo.uspGLPostRecap 
																			@GLEntries
																			,@intCurrentUserId
																	
																	SET @strBatchIdForNewPostRecap = @strCreateGuidBatch

																	GOTO ExitWithCommit
															END

													END -- End:@strBatchIdForNewPostRecap
												ELSE
													BEGIN
														GOTO ExitWithRollback
													END
													
											END -- End: @ysnRecap = 1
											
									END TRY

									BEGIN CATCH
										SET @ErrorMessage = ERROR_MESSAGE()
										SET @strStatusMsg = 'Post Sales Invoice error: ' + @ErrorMessage
										--PRINT @strStatusMsg

										-- ********************************************************
										-- Having Problem on Invoice posting
										-- It still create Invoice even there's error on posting
										-- Need to call rollback after error message
										-- Rollback Transaction here

										-- ROLLBACK
										GOTO ExitWithRollback
										-- RETURN
										-- ********************************************************
										
									END CATCH
								END

						IF(@ErrorMessage IS NULL OR @ErrorMessage = '')
							BEGIN
							 --   -- Insert to temp table
								--INSERT INTO #tmpCustomerInvoiceIdList(intInvoiceId)
								--SELECT [intID] AS intInvoiceId 
								--FROM [dbo].[fnGetRowsFromDelimitedValues](@CreatedIvoices) ORDER BY [intID] ASC

								-- Invoice MAIN Checkout
								SET @intCreatedInvoiceId = (SELECT TOP 1 intInvoiceId FROM @tblTempInvoiceIds WHERE strTransactionType = @strInvoiceTransactionTypeMain)  --(SELECT TOP 1 intInvoiceId FROM #tmpCustomerInvoiceIdList WHERE strTransactionType = @strInvoiceTransactionTypeMain ORDER BY intInvoiceId ASC)

								IF(@ysnDebug = 1)
									BEGIN 
										SELECT 'tblARInvoice', * FROM tblARInvoice
										WHERE intInvoiceId = @intCreatedInvoiceId

										SELECT 'tblARInvoiceDetail', * FROM tblARInvoiceDetail
										WHERE intInvoiceId = @intCreatedInvoiceId
									END


									-- ============================================================================
									-- [START] - Post Invoice Result
									-- ============================================================================
									IF(@ysnDebug = CAST(1 AS BIT))
										BEGIN
											SELECT 'RESULT',
												dblInvoiceTotal				= Inv.dblInvoiceTotal
												, dblCheckoutTotalDeposits	= CASE 
																				WHEN @ysnConsignmentStore = 1
																					THEN (CASE
																							WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																								THEN @dblConsTotalDeposits 
																							ELSE CH.dblTotalDeposits
																						END)
																				WHEN @ysnConsignmentStore = 0
																					THEN CH.dblTotalDeposits
																			END							
												, dblCustomerPayments		= CH.dblCustomerPayments
											FROM tblARInvoice Inv
											OUTER APPLY dbo.tblSTCheckoutHeader CH
											WHERE CH.intCheckoutId = @intCheckoutId
												AND Inv.intInvoiceId = @intCreatedInvoiceId
										END
									-- ============================================================================
									-- [END] - Post Invoice Result
									-- ============================================================================


								DECLARE @ysnEqual AS BIT
                                DECLARE @strRemark AS NVARCHAR(500)
								
								------------------------------------------------------------------------------------------------------
								---- VALIDATE (InvoiceTotalSales) = ((TotalCheckoutDeposits) - (CheckoutCustomerPayments)) -----------
								------------------------------------------------------------------------------------------------------
								SELECT @ysnEqual = A.ysnEqual
										, @strRemark = A.strRemark
								FROM
								(
									SELECT
											CASE
												WHEN (@strInvoiceTransactionTypeMain = @strCASH)
													THEN CASE
														WHEN Inv.dblInvoiceTotal = (
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished)
															THEN CAST(1 AS BIT)
														WHEN Inv.dblInvoiceTotal > (
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END) 
														- CH.dblCustomerPayments + CH.dblATMReplenished)
															THEN CAST(0 AS BIT)
														WHEN Inv.dblInvoiceTotal < (
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished)
															THEN CAST(0 AS BIT)
												END
												WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO)
													THEN CASE
															WHEN Inv.dblInvoiceTotal = ((
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
															- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
																THEN CAST(1 AS BIT)
															WHEN Inv.dblInvoiceTotal > ((
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
															- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
																THEN CAST(0 AS BIT)
															WHEN Inv.dblInvoiceTotal < ((
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END) 
															- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
																THEN CAST(0 AS BIT)
												END
											END AS ysnEqual
-- QQ							
										, CASE
											WHEN (@strInvoiceTransactionTypeMain = @strCASH)
													THEN CASE
														WHEN Inv.dblInvoiceTotal = (
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END) 
														- CH.dblCustomerPayments + CH.dblATMReplenished)
															THEN 'Total of Sales Invoice is equal to Total Deposits - Customer Payments + ATM Replenished'
														WHEN Inv.dblInvoiceTotal > (
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END) 
														- CH.dblCustomerPayments + CH.dblATMReplenished)
															THEN 
																CASE 
																	WHEN @ysnConsignmentStore = 1
																	THEN
																		'The Sum of the Methods of Payments - Gross Fuel Sales + Dealer''s Commissions is not equal to the calculated Bank Deposit/Draft. Posting will not continue: Total Variance: ' +
																		CAST(ISNULL(dbo.fnSTTotalAmountOfDepositablePaymentMethods(@intCheckoutId), 0) 
																		- (ISNULL(dbo.fnSTGetGrossFuelSalesByCheckoutId(@intCheckoutId), 0) + ISNULL(dbo.fnSTGetDealerCommission(@intCheckoutId), 0)) AS NVARCHAR(50))
																	ELSE
																		'Total of Sales Invoice is higher than Total Deposits - Customer Payments + ATM Replenished. Posting will not continue.<br>'
																				+ 'Total of Sales Invoice: ' + CAST(ISNULL(Inv.dblInvoiceTotal, 0) AS NVARCHAR(50)) + '<br>'
																				+ 'Total Deposits: ' + CAST(ISNULL((CASE
																														WHEN @ysnConsignmentStore = 1
																															THEN (CASE
																																	WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																																		THEN @dblConsTotalDeposits
																																	ELSE CH.dblTotalDeposits
																																END)
																														WHEN @ysnConsignmentStore = 0
																															THEN CH.dblTotalDeposits
																													END), 0) AS NVARCHAR(50)) + '<br>'
																				+ 'Customer Payments: ' + CAST(ISNULL(CH.dblCustomerPayments, 0) AS NVARCHAR(50)) + '<br>'
																	END
														WHEN Inv.dblInvoiceTotal < (
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																				THEN CH.dblTotalDeposits
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE 0 --CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished)
															THEN 'Total of Sales Invoice is lower than Total Deposits - Customer Payments + ATM Replenished. Posting will not continue.<br>'
																				+ 'Total of Sales Invoice: ' + CAST(ISNULL(Inv.dblInvoiceTotal, 0) AS NVARCHAR(50)) + '<br>'
																				+ 'Total Deposits: ' + CAST(ISNULL((CASE
																														WHEN @ysnConsignmentStore = 1
																															THEN (CASE
																																	WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																																		THEN @dblConsTotalDeposits
																																	ELSE CH.dblTotalDeposits
																																END)
																														WHEN @ysnConsignmentStore = 0
																															THEN CH.dblTotalDeposits
																													END), 0) AS NVARCHAR(50)) + '<br>'
																				+ 'Customer Payments: ' + CAST(ISNULL(CH.dblCustomerPayments, 0) AS NVARCHAR(50)) + '<br>'
												END
												WHEN (@strInvoiceTransactionTypeMain = @strCREDITMEMO)
													THEN CASE
														WHEN Inv.dblInvoiceTotal = ((
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
															THEN 'Total of Sales Invoice is equal to Total Deposits - Customer Payments + ATM Replenished'
														WHEN Inv.dblInvoiceTotal > ((
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
															THEN 
																CASE 
																	WHEN @ysnConsignmentStore = 1
																	THEN
																		'The Sum of the Methods of Payments - Gross Fuel Sales + Dealer''s Commissions is not equal to the calculated Bank Deposit/Draft. Posting will not continue: Total Variance: ' +
																		CAST(ISNULL(dbo.fnSTTotalAmountOfDepositablePaymentMethods(@intCheckoutId), 0) 
																		- (ISNULL(dbo.fnSTGetGrossFuelSalesByCheckoutId(@intCheckoutId), 0) + ISNULL(dbo.fnSTGetDealerCommission(@intCheckoutId), 0)) AS NVARCHAR(50))
																	ELSE
																		'Total of Sales Invoice is higher than Total Deposits - Customer Payments + ATM Replenished. Posting will not continue.<br>'
																						+ 'Total of Sales Invoice: ' + CAST(ISNULL(Inv.dblInvoiceTotal, 0) AS NVARCHAR(50)) + '<br>'
																						+ 'Total Deposits: ' + CAST(ISNULL(((CASE
																																WHEN @ysnConsignmentStore = 1
																																	THEN (CASE
																																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																																				THEN @dblConsTotalDeposits
																																			ELSE CH.dblTotalDeposits
																																		END)
																																WHEN @ysnConsignmentStore = 0
																																	THEN CH.dblTotalDeposits
																															END) * -1), 0) AS NVARCHAR(50)) + '<br>'
																						+ 'Customer Payments: ' + CAST(ISNULL(CH.dblCustomerPayments, 0) AS NVARCHAR(50)) + '<br>'
																	END
														WHEN Inv.dblInvoiceTotal < ((
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
															THEN 'Total of Sales Invoice is lower than Total Deposits - Customer Payments + ATM Replenished. Posting will not continue.<br>'
																				+ 'Total of Sales Invoice: ' + CAST(ISNULL(Inv.dblInvoiceTotal, 0) AS NVARCHAR(50)) + '<br>'
																				+ 'Total Deposits: ' + CAST(ISNULL(((CASE
																														WHEN @ysnConsignmentStore = 1
																															THEN (CASE
																																	WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																																		THEN @dblConsTotalDeposits
																																	ELSE CH.dblTotalDeposits
																																END)
																														WHEN @ysnConsignmentStore = 0
																															THEN CH.dblTotalDeposits
																													END) * -1), 0) AS NVARCHAR(50)) + '<br>'
																				+ 'Customer Payments: ' + CAST(ISNULL(CH.dblCustomerPayments, 0) AS NVARCHAR(50)) + '<br>'
												END
											
                                             
										END AS strRemark
									FROM tblARInvoice Inv
									OUTER APPLY dbo.tblSTCheckoutHeader CH
									WHERE CH.intCheckoutId = @intCheckoutId
										AND Inv.intInvoiceId = @intCreatedInvoiceId
								) AS A
                                
								IF(@ysnEqual = CAST(0 AS BIT))
									BEGIN
										SET @ysnUpdateCheckoutStatus = CAST(0 AS BIT)
										SET @ysnSuccess = CAST(0 AS BIT)
										SET @strStatusMsg = 'Invoice and End of day Total Validation: ' + @strRemark
								
								
										-- ROLLBACK
										GOTO ExitWithRollback
								END
								------------------------------------------------------------------------------------------------------
								-------------------------------------- VALIDATION ENDED ----------------------------------------------
								------------------------------------------------------------------------------------------------------


								-- Invoice remaining will be used for Customer CHarges
								DELETE FROM #tmpCustomerInvoiceIdList WHERE intInvoiceId = @intCreatedInvoiceId

								-- CUSTOMER CHARGES
								SET @strAllCreatedInvoiceIdList = @CreatedIvoices


								-----------------------------------------------------------------------
								------------- START POST MArk Up / Down -------------------------------
								-----------------------------------------------------------------------
								IF (@strAllowMarkUpDown = 'I' OR @strAllowMarkUpDown = 'D')
									BEGIN
										BEGIN TRY
											-- POST
											EXEC uspSTMarkUpDownCheckoutPosting
														@intCheckoutId		= @intCheckoutId
														,@intCurrentUserId	= @intCurrentUserId
														,@ysnPost			= 1 -- POST
														,@strStatusMsg		= @strMarkUpDownPostingStatusMsg OUTPUT
														,@strBatchId		= @strBatchId OUTPUT
														,@ysnIsPosted		= @ysnIsPosted OUTPUT
										END TRY

										BEGIN CATCH
											SET @ysnUpdateCheckoutStatus = CAST(0 AS BIT)
											SET @ysnSuccess = CAST(0 AS BIT)
											SET @strStatusMsg = 'Post Mark Up/Down error: ' + ERROR_MESSAGE()

											-- ROLLBACK
											GOTO ExitWithRollback
										END CATCH
									END
								-----------------------------------------------------------------------
								------------- END POST MArk Up / Down ---------------------------------
								-----------------------------------------------------------------------

								--------------------------------------------------------------------------
								--- CS-72 - Record Successful Day Processing in Polling Status Report. ---
								--------------------------------- START ----------------------------------
								--------------------------------------------------------------------------
								IF (@ysnConsignmentStore = 1 AND @strCheckoutType = 'Automatic')
								BEGIN
									INSERT INTO tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
									VALUES (@intCheckoutProcessId, @intCheckoutId, 'W', 'Done processing End of day for store: ' + @strStoreName + ' for ' + CONVERT(VARCHAR(12),@dtmCheckoutDate,0), 1)
								END
								--------------------------------------------------------------------------
								--- CS-72 - Record Successful Day Processing in Polling Status Report. ---
								---------------------------------- END -----------------------------------
								--------------------------------------------------------------------------


								SET @ysnUpdateCheckoutStatus = 1
								SET @strStatusMsg = 'Success'
								SET @ysnInvoiceStatus = 1

							END
						ELSE
							BEGIN
								SET @ysnUpdateCheckoutStatus = 0
								SET @strStatusMsg = 'Post Sales Invoice error: ' + @ErrorMessage

								-- ROLLBACK
								GOTO ExitWithRollback
								-- RETURN
							END
					END
				ELSE 
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'No records found to Post'

						-- ROLLBACK
						GOTO ExitWithRollback
						-- RETURN
					END

				-- CS-327 (Creating Credit Memo)
				IF @ysnConsignmentStore = 1 AND @strConsInvoiceType = 'CSFuelInvoice'
				BEGIN
					IF EXISTS(SELECT * FROM @EntriesForCSCreditMemo)
					BEGIN
						-- Filter None Lotted Items Only
						INSERT INTO @tblTempItems
						(
							intItemId
							, strItemNo
						)
						SELECT DISTINCT
							I.intItemId
							, I.strItemNo
						FROM @EntriesForCSCreditMemo E
						JOIN tblICItem I 
							ON E.intItemId = I.intItemId
						WHERE I.strLotTracking != 'No'

						-- Validate Items if Lotted
						IF EXISTS(SELECT * FROM @tblTempItems)
							BEGIN

								DECLARE @strLottedItemCSCreditMemo AS NVARCHAR(MAX) = ''

								SELECT @strLottedItemCSCreditMemo = @strLottedItemCSCreditMemo + temp.strItemNo + ', '
								FROM @tblTempItems temp
								SELECT @strLottedItemCSCreditMemo = LEFT(@strLottedItemCSCreditMemo, LEN(@strLottedItemCSCreditMemo)-1)

								SET @ysnUpdateCheckoutStatus = 0
								SET @strStatusMsg = 'Lotted Items (' + @strLottedItemCSCreditMemo + ') Only None Lotted Items are allowed '

								-- ROLLBACK
								GOTO ExitWithRollback
								-- RETURN
							END
						ELSE
							BEGIN
								BEGIN TRY
										
									-- Insert to table for Batch Posting
									INSERT INTO @EntriesForCSCreditMemoBatchPost(
										[intId]
										,[strTransactionType]
										,[strSourceTransaction]
										,[intSourceId]
										,[strSourceId]
										,[intInvoiceId]
										,[intEntityCustomerId]
										,[intCompanyLocationId]
										,[intCurrencyId]
										,[intTermId]
										,[dtmDate]
										,[dtmDueDate]
										,[dtmShipDate]
										,[intEntitySalespersonId]
										,[intFreightTermId]
										,[intShipViaId]
										,[intPaymentMethodId]
										,[strInvoiceOriginId]
										,[ysnUseOriginIdAsInvoiceNumber]
										,[strPONumber]
										,[strBOLNumber]
										,[strComments]
										,[intShipToLocationId]
										,[intBillToLocationId]
										,[ysnTemplate]
										,[ysnForgiven]
										,[ysnCalculated]
										,[ysnSplitted]
										,[intPaymentId]
										,[intSplitId]
										,[intLoadDistributionHeaderId]
										,[strActualCostId]
										,[intShipmentId]
										,[intTransactionId]
										,[intEntityId]
										,[ysnResetDetails]
										,[ysnPost]
										,[intInvoiceDetailId]
										,[intItemId]
										,[ysnInventory]
										,[strItemDescription]
										,[intItemUOMId]
										,[dblQtyOrdered]
										,[dblQtyShipped]
										,[dblDiscount]
										,[dblPrice]
										,[ysnRefreshPrice]
										,[strMaintenanceType]
										,[strFrequency]
										,[dtmMaintenanceDate]
										,[dblMaintenanceAmount]
										,[dblLicenseAmount]
										,[intTaxGroupId]
										,[ysnRecomputeTax]
										,[intSCInvoiceId]
										,[strSCInvoiceNumber]
										,[intInventoryShipmentItemId]
										,[strShipmentNumber]
										,[intSalesOrderDetailId]
										,[strSalesOrderNumber]
										,[intContractHeaderId]
										,[intContractDetailId]
										,[intShipmentPurchaseSalesContractId]
										,[intTicketId]
										,[intTicketHoursWorkedId]
										,[intSiteId]
										,[strBillingBy]
										,[dblPercentFull]
										,[dblNewMeterReading]
										,[dblPreviousMeterReading]
										,[dblConversionFactor]
										,[intPerformerId]
										,[ysnLeaseBilling]
										,[ysnVirtualMeterReading]
										,[ysnClearDetailTaxes]					
										,[intTempDetailIdForTaxes]
										,[strType]
										,[ysnUpdateAvailableDiscount]
										,[strItemTermDiscountBy]
										,[dblItemTermDiscount]
										,[dtmPostDate]
										,[ysnImpactInventory]
										,[dblCOGSAmount]
										,[strImportFormat]
										,[dblSubCurrencyRate]
										,[dblCurrencyExchangeRate]
										,[ysnRecap]
										,[intSubLocationId])
									SELECT 
										ROW_NUMBER() OVER(ORDER BY intEntityCustomerId ASC)
										,[strTransactionType]
										,[strSourceTransaction]
										,[intSourceId]
										,[strSourceId]
										,[intInvoiceId]
										,[intEntityCustomerId]
										,[intCompanyLocationId]
										,[intCurrencyId]
										,[intTermId]
										,[dtmDate]
										,CASE WHEN @ysnConsignmentStore = 0
											THEN [dtmDueDate]
											ELSE CAST(FLOOR(CAST(GETDATE()AS FLOAT))AS DATETIME)
											END
										,[dtmShipDate]
										,[intEntitySalespersonId]
										,[intFreightTermId]
										,[intShipViaId]
										,[intPaymentMethodId]
										,[strInvoiceOriginId]
										,[ysnUseOriginIdAsInvoiceNumber]
										,[strPONumber]
										,[strBOLNumber]
										,[strComments]
										,[intShipToLocationId]
										,[intBillToLocationId]
										,[ysnTemplate]
										,[ysnForgiven]
										,[ysnCalculated]
										,[ysnSplitted]
										,[intPaymentId]
										,[intSplitId]
										,[intLoadDistributionHeaderId]
										,[strActualCostId]
										,[intShipmentId]
										,[intTransactionId]
										,[intEntityId]
										,[ysnResetDetails]
										,[ysnPost]
										,[intInvoiceDetailId]
										,[intItemId]
										,[ysnInventory]
										,[strItemDescription]
										,[intItemUOMId]
										,[dblQtyOrdered]
										,[dblQtyShipped]
										,[dblDiscount]
										,[dblPrice]
										,[ysnRefreshPrice]
										,[strMaintenanceType]
										,[strFrequency]
										,[dtmMaintenanceDate]
										,[dblMaintenanceAmount]
										,[dblLicenseAmount]
										,[intTaxGroupId]
										,[ysnRecomputeTax]
										,[intSCInvoiceId]
										,[strSCInvoiceNumber]
										,[intInventoryShipmentItemId]
										,[strShipmentNumber]
										,[intSalesOrderDetailId]
										,[strSalesOrderNumber]
										,[intContractHeaderId]
										,[intContractDetailId]
										,[intShipmentPurchaseSalesContractId]
										,[intTicketId]
										,[intTicketHoursWorkedId]
										,[intSiteId]
										,[strBillingBy]
										,[dblPercentFull]
										,[dblNewMeterReading]
										,[dblPreviousMeterReading]
										,[dblConversionFactor]
										,[intPerformerId]
										,[ysnLeaseBilling]
										,[ysnVirtualMeterReading]
										,[ysnClearDetailTaxes]					
										,[intTempDetailIdForTaxes]
										,[strType]
										,[ysnUpdateAvailableDiscount]
										,[strItemTermDiscountBy]
										,[dblItemTermDiscount]
										,[dtmPostDate]
										,[ysnImpactInventory]
										,[dblCOGSAmount]
										,[strImportFormat]
										,[dblSubCurrencyRate]
										,[dblCurrencyExchangeRate]
										,[ysnRecap]
										,[intSubLocationId]
									FROM @EntriesForCSCreditMemo


										-- ============================================================================================
										-- [START] TEST TO DEBUG
										-- ============================================================================================
										IF(@ysnDebug = 1)
											BEGIN
												SELECT '@EntriesForCSCreditMemoBatchPost-All Items to send to Sales Invoice'
													   , [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments]
													   , strComments
													   , intEntityCustomerId
													   , strTransactionType
													   , dblQtyShipped
													   , dblPrice
													   , strItemDescription
													   , * 
												FROM @EntriesForCSCreditMemoBatchPost
											END
										-- ============================================================================================
										-- [END] TEST TO DEBUG
										-- ============================================================================================


										-------------------------------------------------------------------------------
										------------------------------- Start Rank ------------------------------------
										-------------------------------------------------------------------------------
										IF EXISTS(SELECT TOP 1 1 FROM @LineItemTaxEntries)
											BEGIN
												-- Table @LineItemTaxEntries
												-- intTempDetailIdForTaxes - Primary Id
												-- strSourceTransaction - origin table

												-- Table @@EntriesForCSCreditMemoBatchPost
												-- intTempDetailIdForTaxes - Primary Id
												-- strImportFormat - origin table

												-- Create Ranking
												INSERT INTO @tblTempRank
												(
													intRankId
													, intTempDetailIdForTaxes
													, strSourceTransaction
												)
												SELECT 
													RANK() OVER(ORDER BY intTempDetailIdForTaxes, strSourceTransaction) AS intRankId
													, intTempDetailIdForTaxes
													, strSourceTransaction
												FROM @LineItemTaxEntries
												
												-- Update UDTables
												UPDATE tbl
												SET tbl.intTempDetailIdForTaxes = Ranking.intRankId
												FROM @EntriesForCSCreditMemoBatchPost tbl
												INNER JOIN @tblTempRank Ranking
													ON tbl.intTempDetailIdForTaxes = Ranking.intTempDetailIdForTaxes										-- Id
													AND tbl.strImportFormat COLLATE SQL_Latin1_General_CP1_CS_AS = Ranking.strSourceTransaction				-- Table

												UPDATE Tax
												SET Tax.intTempDetailIdForTaxes = Ranking.intRankId
												FROM @LineItemTaxEntries Tax
												INNER JOIN @tblTempRank Ranking
													ON Tax.intTempDetailIdForTaxes = Ranking.intTempDetailIdForTaxes											-- Id
													AND Tax.strSourceTransaction COLLATE SQL_Latin1_General_CP1_CS_AS = Ranking.strSourceTransaction			-- Table


												-- ============================================================================================
												-- [START] TEST TO DEBUG
												-- ============================================================================================
												IF(@ysnDebug = 1)
													BEGIN
														SELECT 'For Items that has Tax'

														SELECT '@LineItemTaxEntries-List of Taxes on Items', intTempDetailIdForTaxes, strSourceTransaction, * 
														FROM @LineItemTaxEntries
														WHERE intTempDetailIdForTaxes IS NOT NULL
															AND strSourceTransaction <> ''

														-- 11 = [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments]
														SELECT '@EntriesForCSCreditMemoBatchPost-Items that has Tax Calc'
															   , [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments]
															   , intTempDetailIdForTaxes, strSourceTransaction, strImportFormat, * 
														FROM @EntriesForCSCreditMemoBatchPost
														WHERE intTempDetailIdForTaxes IS NOT NULL
															OR strImportFormat <> ''
													END
												-- ============================================================================================
												-- [END] TEST TO DEBUG
												-- ============================================================================================


												-- Clear values
												UPDATE @LineItemTaxEntries
												SET strSourceTransaction = ''
												WHERE intTempDetailIdForTaxes IS NOT NULL
													OR strSourceTransaction <> ''

												UPDATE @EntriesForCSCreditMemoBatchPost
												SET strImportFormat = ''
												WHERE intTempDetailIdForTaxes IS NOT NULL
													OR strImportFormat <> ''
											END
										-------------------------------------------------------------------------------
										------------------------------- End Rank --------------------------------------
										-------------------------------------------------------------------------------

										--SELECT * FROM @LineItemTaxEntries


										-- POST Main Checkout Invoice (Batch Posting)
										EXEC [dbo].[uspARProcessInvoicesByBatch]
													@InvoiceEntries				= @EntriesForCSCreditMemoBatchPost
													,@LineItemTaxEntries		= @LineItemTaxEntries
													,@UserId					= @intCurrentUserId
		 											,@GroupingOption			= 11
													,@RaiseError				= 1
													,@ErrorMessage				= @ErrorMessage OUTPUT
													,@LogId					    = @intIntegrationLogId OUTPUT

										-- NOT RECAP
										IF(@ysnRecap = CAST(0 AS BIT))
											BEGIN
	
											IF EXISTS(SELECT intIntegrationLogId FROM tblARInvoiceIntegrationLog WHERE intIntegrationLogId = @intIntegrationLogId) AND ISNULL(@ErrorMessage, '') = ''
												BEGIN

													IF NOT EXISTS(SELECT intIntegrationLogId FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId AND ysnPosted = CAST(0 AS BIT))
														BEGIN

															-- Posting to Sales Invoice was successfull
															UPDATE tblSTCheckoutHeader
															SET intCreditMemoIntegrationLogId = @intIntegrationLogId
															WHERE intCheckoutId = @intCheckoutId

															SELECT @strBatchIdForNewPostRecap = ISNULL(strBatchIdForNewPostRecap, '')
															FROM tblARInvoiceIntegrationLog
															WHERE intIntegrationLogId = @intIntegrationLogId

															-- Insert to Temp Table
															DELETE FROM @tblTempInvoiceIds

															INSERT INTO @tblTempInvoiceIds
															(
																intInvoiceId,
																intEntityId,
																ysnPosted,
																strTransactionType
															)
															SELECT DISTINCT
																LogDetail.intInvoiceId,
																Inv.intEntityCustomerId,
																Inv.ysnPosted,
																LogDetail.strTransactionType
															FROM tblARInvoiceIntegrationLogDetail LogDetail
															INNER JOIN tblARInvoice Inv
																ON LogDetail.intInvoiceId = Inv.intInvoiceId
															WHERE intIntegrationLogId = (
																							SELECT intCreditMemoIntegrationLogId
																							FROM tblSTCheckoutHeader
																							WHERE intCheckoutId =  @intCheckoutId
																						)

															-- Populate variable with Invoice Ids
															SELECT @CreatedIvoices = COALESCE(@CreatedIvoices + ',', '') + CAST(intInvoiceId AS VARCHAR(50))
															FROM @tblTempInvoiceIds


															-- =========================================================================================================================
															-- [START] - Proccess 'Credit Memo' as 'Cash Refund'
															-- =========================================================================================================================
															-- Error if directly creating a Cash Refund (Error: 'Cash Refund amount is not equal to prepaids/credits applied.')
															-- As per Kelvin the process for @strCREDITMEMO would be
															-- 1. Process this as transaction type='Credit Memo'   (using uspARProcessInvoicesByBatch)
															-- 2. After process has finish Process this as @strCREDITMEMO    (using uspARProcessRefund)

															IF(@strConsInvoiceType = 'CSFuelInvoice')
																BEGIN
																	DECLARE @intCSMainInvoiceId_CR AS INT = (SELECT TOP 1 intInvoiceId FROM @tblTempInvoiceIds WHERE strTransactionType = 'Credit Memo'),
																	@intCSNewTransactionId_CR AS INT,
																	@strCSErrorMessage_CR AS NVARCHAR(MAX)

																	EXEC [dbo].[uspARProcessRefund]
																		  @intInvoiceId			= @intCSMainInvoiceId_CR
																		, @intUserId			= @intCurrentUserId
																		, @intNewTransactionId	= @intCSNewTransactionId_CR OUTPUT
																		, @strErrorMessage		= @strCSErrorMessage_CR OUTPUT	
																		
																	UPDATE tblSTCheckoutHeader
																		SET intConsCreditMemoId = @intCSMainInvoiceId_CR
																		, intInvoiceId = @intConsInvoiceId
																		WHERE intCheckoutId = @intCheckoutId																	

																	IF(@ysnDebug = 1)
																		BEGIN
																			--TEST
																			SELECT 'uspARProcessRefund OUTPUT', @intCSNewTransactionId_CR, @strCSErrorMessage_CR
																			SELECT 'Invoice', * FROM tblARInvoice WHERE intInvoiceId = @intCSMainInvoiceId_CR
																		END

																	IF(@strErrorMessage_CR IS NOT NULL)
																		BEGIN
																			SET @ErrorMessage = @strErrorMessage_CR
																			SET @strStatusMsg = 'Process To Cash Refund error. ' + ISNULL(@ErrorMessage, '')

																			-- ROLLBACK
																			GOTO ExitWithRollback
																		END
																	
																END
															
															-- =========================================================================================================================
															-- [END] - Proccess 'Credit Memo' as 'Cash Refund'
															-- =========================================================================================================================
														END
													ELSE
														BEGIN
															-- SELECT * FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId
															SET @ErrorMessage = (SELECT TOP 1 strPostingMessage FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId AND ysnPosted = CAST(0 AS BIT))
															SET @strStatusMsg = 'Main End of day was not Posted correctly. ' + ISNULL(@ErrorMessage, '')

															-- ROLLBACK
															GOTO ExitWithRollback
															-- RETURN
														END
												END
											ELSE
												BEGIN
													SET @strStatusMsg = 'Post Main End of day has error: ' + @ErrorMessage

													-- ROLLBACK
													GOTO ExitWithRollback
													-- RETURN
												END

										END

										-- Check if RECAP
										ELSE IF(@ysnRecap = CAST(1 AS BIT))
											BEGIN -- Start: @ysnRecap = 1
											
												-- Get Batch Id
												
												-- http://jira.irelyserver.com/browse/ST-1277
												-- tblARInvoiceIntegrationLog.strBatchIdForNewPostRecap value is always empty
												-- tblARInvoiceIntegrationLogDetail.strBatchId Top (1) has Batch Id
												SELECT TOP (1) @strBatchIdForNewPostRecap = strBatchId 
												FROM tblARInvoiceIntegrationLogDetail 
												WHERE intIntegrationLogId = @intIntegrationLogId
													AND ysnHeader = 1 
													AND ysnPost = @ysnPost 
													AND ysnRecap = @ysnRecap 
												ORDER BY intIntegrationLogDetailId ASC
												--SELECT @strBatchIdForNewPostRecap = ISNULL(strBatchIdForNewPostRecap, '')
												--FROM tblARInvoiceIntegrationLog 
												--WHERE intIntegrationLogId = @intIntegrationLogId

												IF(@strBatchIdForNewPostRecap IS NOT NULL AND @strBatchIdForNewPostRecap != '')
													BEGIN -- Start:@strBatchIdForNewPostRecap

														IF EXISTS(SELECT strBatchId FROM tblGLPostRecap WHERE strBatchId = @strBatchIdForNewPostRecap)
															BEGIN
																SET @strCreateGuidBatch = NEWID();

																-- GET POST PREVIEW on GL Entries
																INSERT INTO @GLEntries (
																						[dtmDate] 
																						,[strBatchId]
																						,[intAccountId]
																						,[dblDebit]
																						,[dblCredit]
																						,[dblDebitUnit]
																						,[dblCreditUnit]
																						,[strDescription]
																						,[strCode]
																						,[strReference]
																						,[intCurrencyId]
																						,[dblExchangeRate]
																						,[dtmDateEntered]
																						,[dtmTransactionDate]
																						,[strJournalLineDescription]
																						,[intJournalLineNo]
																						,[ysnIsUnposted]
																						,[intUserId]
																						,[intEntityId]
																						,[strTransactionId]
																						,[intTransactionId]
																						,[strTransactionType]
																						,[strTransactionForm]
																						,[strModuleName]
																						,[intConcurrencyId]
																						,[dblDebitForeign]	
																						--,[dblDebitReport]	
																						,[dblCreditForeign]	
																						--,[dblCreditReport]	
																						--,[dblReportingRate]	
																						--,[dblForeignRate]
																						,[strRateType]
																				)
																			SELECT [dtmDate] 
																						,[strBatchId] = @strCreateGuidBatch
																						,[intAccountId]
																						,[dblDebit]
																						,[dblCredit]
																						,[dblDebitUnit]
																						,[dblCreditUnit]
																						,[strDescription]
																						,[strCode]
																						,[strReference]
																						,[intCurrencyId]
																						,[dblExchangeRate]
																						,[dtmDateEntered]
																						,[dtmTransactionDate]
																						,[strJournalLineDescription]
																						,[intJournalLineNo]
																						,[ysnIsUnposted]
																						,[intUserId]
																						,[intEntityId]
																						,[strTransactionId]
																						,[intTransactionId]
																						,[strTransactionType]
																						,[strTransactionForm]
																						,[strModuleName]
																						,[intConcurrencyId]
																						,[dblDebitForeign]	
																						--,[dblDebitReport]	
																						,[dblCreditForeign]	
																						--,[dblCreditReport]	
																						--,[dblReportingRate]	
																						--,[dblForeignRate]
																						,[strRateType]
																				FROM tblGLPostRecap
																				WHERE strBatchId = @strBatchIdForNewPostRecap
																 
																
																IF @@TRANCOUNT > 0
																BEGIN
																	ROLLBACK TRANSACTION
																END


																IF @@TRANCOUNT = 0
																BEGIN
																	BEGIN TRANSACTION
																END

																	EXEC dbo.uspGLPostRecap 
																			@GLEntries
																			,@intCurrentUserId
																	
																	SET @strBatchIdForNewPostRecap = @strCreateGuidBatch

																	GOTO ExitWithCommit
															END

													END -- End:@strBatchIdForNewPostRecap
												ELSE
													BEGIN
														GOTO ExitWithRollback
													END
													
											END -- End: @ysnRecap = 1
											
									END TRY

									BEGIN CATCH
										SET @ErrorMessage = ERROR_MESSAGE() --'Post Sales Invoice error:'
										SET @strStatusMsg = 'Error generating Credit Memo: ' + @ErrorMessage --02/17/2023: Error encountered is not valid for processing Refund. Only Credit Memo, Customer Prepayment and Overpayment is allowed. Continue in this line.
										--PRINT @strStatusMsg

										-- ********************************************************
										-- Having Problem on Invoice posting
										-- It still create Invoice even there's error on posting
										-- Need to call rollback after error message
										-- Rollback Transaction here

										-- ROLLBACK
										GOTO ExitWithRollback
										-- RETURN
										-- ********************************************************
										
									END CATCH
							END

						IF(@ErrorMessage IS NULL OR @ErrorMessage = '')
							BEGIN
							 --   -- Insert to temp table
								--INSERT INTO #tmpCustomerInvoiceIdList(intInvoiceId)
								--SELECT [intID] AS intInvoiceId 
								--FROM [dbo].[fnGetRowsFromDelimitedValues](@CreatedIvoices) ORDER BY [intID] ASC

								-- Invoice MAIN Checkout
								SET @intCreatedInvoiceId = (SELECT TOP 1 intInvoiceId FROM @tblTempInvoiceIds WHERE strTransactionType = 'Credit Memo')  --(SELECT TOP 1 intInvoiceId FROM #tmpCustomerInvoiceIdList WHERE strTransactionType = @strInvoiceTransactionTypeMain ORDER BY intInvoiceId ASC)

								IF(@ysnDebug = 1)
								BEGIN 
									SELECT 'tblARInvoice', * FROM tblARInvoice
									WHERE intInvoiceId = @intCreatedInvoiceId

									SELECT 'tblARInvoiceDetail', * FROM tblARInvoiceDetail
									WHERE intInvoiceId = @intCreatedInvoiceId
								END


								-- ============================================================================
								-- [START] - Post Invoice Result
								-- ============================================================================
								IF(@ysnDebug = CAST(1 AS BIT))
								BEGIN
									SELECT 'RESULT',
										dblInvoiceTotal				= Inv.dblInvoiceTotal
										, dblCheckoutTotalDeposits	= CASE 
																		WHEN @ysnConsignmentStore = 1
																			THEN (CASE
																					WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																						THEN CH.dblTotalDeposits
																					WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																						THEN @dblConsTotalDeposits
																					ELSE 0 --CH.dblTotalDeposits
																				END)
																		WHEN @ysnConsignmentStore = 0
																			THEN CH.dblTotalDeposits
																	END							
										, dblCustomerPayments		= CH.dblCustomerPayments
									FROM tblARInvoice Inv
									OUTER APPLY dbo.tblSTCheckoutHeader CH
									WHERE CH.intCheckoutId = @intCheckoutId
										AND Inv.intInvoiceId = @intCreatedInvoiceId
								END
								-- ============================================================================
								-- [END] - Post Invoice Result
								-- ============================================================================


								DECLARE @ysnEqualCSCreditMemo AS BIT
                                DECLARE @strRemarkCSCreditMemo AS NVARCHAR(500)
								
								------------------------------------------------------------------------------------------------------
								---- VALIDATE (InvoiceTotalSales) = ((TotalCheckoutDeposits) - (CheckoutCustomerPayments)) -----------
								------------------------------------------------------------------------------------------------------
								SELECT @ysnEqualCSCreditMemo = A.ysnEqual
										, @strRemarkCSCreditMemo = A.strRemark
								FROM
								(
									SELECT
											CASE
												WHEN (@strConsInvoiceType = 'CSFuelInvoice')
													THEN CASE
															WHEN Inv.dblInvoiceTotal = ((
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																				THEN CH.dblTotalDeposits
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE 0 --CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
															- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
																THEN CAST(1 AS BIT)
															WHEN Inv.dblInvoiceTotal > ((
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																				THEN CH.dblTotalDeposits
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE 0 --CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
															- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
																THEN CAST(0 AS BIT)
															WHEN Inv.dblInvoiceTotal < ((
															(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																				THEN CH.dblTotalDeposits
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE 0 --CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END) 
															- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
																THEN CAST(0 AS BIT)
												END
											END AS ysnEqual
-- QQ							
										, CASE
												WHEN (@strConsInvoiceType = 'CSFuelInvoice')
													THEN CASE
														WHEN Inv.dblInvoiceTotal = ((
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																				THEN CH.dblTotalDeposits
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE 0 --CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
															THEN 'Total of Sales Invoice is equal to Total Deposits - Customer Payments + ATM Replenished'
														WHEN Inv.dblInvoiceTotal > ((
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																				THEN CH.dblTotalDeposits
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE 0 --CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
															THEN 
																CASE 
																	WHEN @ysnConsignmentStore = 1
																	THEN
																		'The Sum of the Methods of Payments - Gross Fuel Sales + Dealer''s Commissions is not equal to the calculated Bank Deposit/Draft. Posting will not continue: Total Variance: ' +
																		CAST(ISNULL(dbo.fnSTTotalAmountOfDepositablePaymentMethods(@intCheckoutId), 0) 
																		- (ISNULL(dbo.fnSTGetGrossFuelSalesByCheckoutId(@intCheckoutId), 0) + ISNULL(dbo.fnSTGetDealerCommission(@intCheckoutId), 0)) AS NVARCHAR(50))
																	ELSE
																		'Total of Sales Invoice is higher than Total Deposits - Customer Payments + ATM Replenished. Posting will not continue.<br>'
																							+ 'Total of Sales Invoice: ' + CAST(ISNULL(Inv.dblInvoiceTotal, 0) AS NVARCHAR(50)) + '<br>'
																							+ 'Total Deposits: ' + CAST(ISNULL(((CASE
																																	WHEN @ysnConsignmentStore = 1
																																		THEN (CASE
																																				WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																																					THEN CH.dblTotalDeposits
																																				WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																																					THEN @dblConsTotalDeposits
																																				ELSE 0 --CH.dblTotalDeposits
																																			END)
																																	WHEN @ysnConsignmentStore = 0
																																		THEN CH.dblTotalDeposits
																																END) * -1), 0) AS NVARCHAR(50)) + '<br>'
																							+ 'Customer Payments: ' + CAST(ISNULL(CH.dblCustomerPayments, 0) AS NVARCHAR(50)) + '<br>'
																	END
														WHEN Inv.dblInvoiceTotal < ((
														(CASE
																WHEN @ysnConsignmentStore = 1
																	THEN (CASE
																			WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																				THEN CH.dblTotalDeposits
																			WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																				THEN @dblConsTotalDeposits
																			ELSE 0 --CH.dblTotalDeposits
																		END)
																WHEN @ysnConsignmentStore = 0
																	THEN CH.dblTotalDeposits
															END)
														- CH.dblCustomerPayments + CH.dblATMReplenished) * -1)
															THEN 'Total of Sales Invoice is lower than Total Deposits - Customer Payments + ATM Replenished. Posting will not continue.<br>'
																				+ 'Total of Sales Invoice: ' + CAST(ISNULL(Inv.dblInvoiceTotal, 0) AS NVARCHAR(50)) + '<br>'
																				+ 'Total Deposits: ' + CAST(ISNULL(((CASE
																														WHEN @ysnConsignmentStore = 1
																															THEN (CASE
																																	WHEN @strConsInvoiceType = 'Invoice' AND CH.dblTotalDeposits > 0
																																		THEN CH.dblTotalDeposits
																																	WHEN @strConsInvoiceType = 'CSFuelInvoice' AND CH.dblTotalDeposits < 1
																																		THEN @dblConsTotalDeposits
																																	ELSE 0 --CH.dblTotalDeposits
																																END)
																														WHEN @ysnConsignmentStore = 0
																															THEN CH.dblTotalDeposits
																													END) * -1), 0) AS NVARCHAR(50)) + '<br>'
																				+ 'Customer Payments: ' + CAST(ISNULL(CH.dblCustomerPayments, 0) AS NVARCHAR(50)) + '<br>'
												END
											
                                             
										END AS strRemark
									FROM tblARInvoice Inv
									OUTER APPLY dbo.tblSTCheckoutHeader CH
									WHERE CH.intCheckoutId = @intCheckoutId
										AND Inv.intInvoiceId = @intCreatedInvoiceId
								) AS A
                                
								IF(@ysnEqual = CAST(0 AS BIT))
								BEGIN
									SET @ysnUpdateCheckoutStatus = CAST(0 AS BIT)
									SET @ysnSuccess = CAST(0 AS BIT)
									SET @strStatusMsg = 'Invoice and End of day Total Validation: ' + @strRemark
								
								
									-- ROLLBACK
									GOTO ExitWithRollback
								END
								------------------------------------------------------------------------------------------------------
								-------------------------------------- VALIDATION ENDED ----------------------------------------------
								------------------------------------------------------------------------------------------------------


								-- Invoice remaining will be used for Customer CHarges
								DELETE FROM #tmpCustomerInvoiceIdList WHERE intInvoiceId = @intCreatedInvoiceId

								-- CUSTOMER CHARGES
								SET @strAllCreatedInvoiceIdList = @CreatedIvoices


								-----------------------------------------------------------------------
								------------- START POST MArk Up / Down -------------------------------
								-----------------------------------------------------------------------
								IF (@strAllowMarkUpDown = 'I' OR @strAllowMarkUpDown = 'D')
									BEGIN
										BEGIN TRY
											-- POST
											EXEC uspSTMarkUpDownCheckoutPosting
														@intCheckoutId		= @intCheckoutId
														,@intCurrentUserId	= @intCurrentUserId
														,@ysnPost			= 1 -- POST
														,@strStatusMsg		= @strMarkUpDownPostingStatusMsg OUTPUT
														,@strBatchId		= @strBatchId OUTPUT
														,@ysnIsPosted		= @ysnIsPosted OUTPUT
										END TRY

										BEGIN CATCH
											SET @ysnUpdateCheckoutStatus = CAST(0 AS BIT)
											SET @ysnSuccess = CAST(0 AS BIT)
											SET @strStatusMsg = 'Post Mark Up/Down error: ' + ERROR_MESSAGE()

											-- ROLLBACK
											GOTO ExitWithRollback
										END CATCH
									END
								-----------------------------------------------------------------------
								------------- END POST MArk Up / Down ---------------------------------
								-----------------------------------------------------------------------

								--------------------------------------------------------------------------
								--- CS-72 - Record Successful Day Processing in Polling Status Report. ---
								--------------------------------- START ----------------------------------
								--------------------------------------------------------------------------
								--IF (@ysnConsignmentStore = 1 AND @strCheckoutType = 'Automatic' AND @strInvoiceTransactionTypeMain = 'Credit Memo')
								--BEGIN
								--	INSERT INTO tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
								--	VALUES (@intCheckoutProcessId, @intCheckoutId, 'W', 'Done generating End of day Credit Memo for store: ' + @strStoreName + ' for ' + CONVERT(VARCHAR(12),@dtmCheckoutDate,0), 1)
								--END
								--------------------------------------------------------------------------
								--- CS-72 - Record Successful Day Processing in Polling Status Report. ---
								---------------------------------- END -----------------------------------
								--------------------------------------------------------------------------


								SET @ysnUpdateCheckoutStatus = 1
								SET @strStatusMsg = 'Success'
								SET @ysnInvoiceStatus = 1

							END
						ELSE
							BEGIN
								SET @ysnUpdateCheckoutStatus = 0
								SET @strStatusMsg = 'Post Sales Invoice error: ' + @ErrorMessage

								-- ROLLBACK
								GOTO ExitWithRollback
								-- RETURN
							END
					END
				ELSE 
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = 'No records found to Post'

						-- ROLLBACK
						GOTO ExitWithRollback
						-- RETURN
					END	
				END			
				----------------------------------------------------------------------
				------------------ END POST TO AR SALES INVOICE ----------------------
				----------------------------------------------------------------------
				

				----------------------------------------------------------------------
				---------------- START POST TO AR RECIEVE PAYMENT --------------------
				----------------------------------------------------------------------

				-- START CREATE RECIEVE PAYMENTS from Customer Payments
				----------------------------------------------------------------------
				-------------------------- CUSTOMER PAYMENTS -------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutCustomerPayments WHERE intCheckoutId = @intCheckoutId AND dblPaymentAmount > 0)
					BEGIN
							-- Use Recieve Payment UDP
							INSERT INTO @PaymentsForInsert(
									[intId]
									,[strSourceTransaction]
									,[intSourceId]
									,[strSourceId]
									,[intPaymentId]
									,[intEntityCustomerId]
									,[intCompanyLocationId]
									,[intCurrencyId]
									,[dtmDatePaid]
									,[intPaymentMethodId]
									,[strPaymentMethod]
									,[strPaymentInfo]
									,[strNotes]
									,[intAccountId]
									,[intBankAccountId]
									,[intWriteOffAccountId]		
									,[dblAmountPaid]
									,[intExchangeRateTypeId]
									,[dblExchangeRate]
									,[strReceivePaymentType]
									,[strPaymentOriginalId]
									,[ysnUseOriginalIdAsPaymentNumber]
									,[ysnApplytoBudget]
									,[ysnApplyOnAccount]
									,[ysnInvoicePrepayment]
									,[ysnImportedFromOrigin]
									,[ysnImportedAsPosted]
									,[ysnAllowPrepayment]		
									,[ysnPost]
									,[ysnRecap]
									,[ysnUnPostAndUpdate]
									,[intEntityId]
									--Detail																																															
									,[intPaymentDetailId]
									,[intInvoiceId]
									,[strTransactionType]
									,[intBillId]
									,[strTransactionNumber]
									,[intTermId]
									,[intInvoiceAccountId]
									,[ysnApplyTermDiscount]
									,[dblDiscount]
									,[dblDiscountAvailable]
									,[dblInterest]
									,[dblPayment]
									,[strInvoiceReportNumber]
									,[intCurrencyExchangeRateTypeId]
									,[intCurrencyExchangeRateId]
									,[dblCurrencyExchangeRate]
									,[ysnAllowOverpayment]
									,[ysnFromAP]
									)								
								SELECT
										[intId]								= CCP.intCustPaymentsId -- ROW_NUMBER() OVER(ORDER BY CCP.intCustPaymentsId ASC)
									,[strSourceTransaction]					= 'Invoice'
									,[intSourceId]							= CCP.intCustPaymentsId --@intCheckoutId						--CCP.intCustPaymentsId
									,[strSourceId]							= CAST(CCP.intCustPaymentsId AS NVARCHAR(50)) --CAST(@intCheckoutId AS NVARCHAR(50))	--CAST(CCP.intCustPaymentsId AS NVARCHAR(50))
									,[intPaymentId]							= NULL									-- Payment Id(Insert new Invoice if NULL, else Update existing) 
									,[intEntityCustomerId]					= CCP.intCustomerId
									,[intCompanyLocationId]					= @intCompanyLocationId --ST.intCompanyLocationId
									,[intCurrencyId]						= @intCurrencyId
									,[dtmDatePaid]							= @dtmCheckoutDate
									,[intPaymentMethodId]					= CCP.intPaymentMethodID
									,[strPaymentMethod]						= PM.strPaymentMethod
									,[strPaymentInfo]						= CCP.strCheckNo
									,[strNotes]								= 'Store Payment ' + CCP.strComment
									,[intAccountId]							= NULL		-- Account Id ([tblGLAccount].[intAccountId])
									,[intBankAccountId]						= NULL		-- Bank Account Id ([tblCMBankAccount].[intBankAccountId])
									,[intWriteOffAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])	
									,[dblAmountPaid]						= CCP.dblPaymentAmount
									,[intExchangeRateTypeId]				= NULL		-- Forex Rate Type Key Value from tblSMCurrencyExchangeRateType
									,[dblExchangeRate]						= NULL
									,[strReceivePaymentType]				= 'Cash Receipts'
									,[strPaymentOriginalId]					= CCP.intCustPaymentsId		-- Reference to the original/parent record
																										-- This will also be used to create separate RCV for all rows in Customer Payments tab
									,[ysnUseOriginalIdAsPaymentNumber]		= NULL		-- Indicate whether [strInvoiceOriginId] will be used as Invoice Number
									,[ysnApplytoBudget]						= 0
									,[ysnApplyOnAccount]					= 0
									,[ysnInvoicePrepayment]					= 0
									,[ysnImportedFromOrigin]				= NULL
									,[ysnImportedAsPosted]					= NULL
									,[ysnAllowPrepayment]					= 0
									,[ysnPost]								= 1			-- 1. Post, 0. UnPost
									,[ysnRecap]								= @ysnRecap
									,[ysnUnPostAndUpdate]					= NULL
									,[intEntityId]							= @intCurrentUserId
									--Detail																																															
									,[intPaymentDetailId]					= NULL		-- Payment Detail Id(Insert new Payment Detail if NULL, else Update existing)
									,[intInvoiceId]							= NULL --@intCreatedInvoiceId		-- Use Main Checkout intInvoiceId
									,[strTransactionType]					= NULL
									,[intBillId]							= NULL		-- Key Value from tblARInvoice ([tblAPBill].[intBillId]) 
									,[strTransactionNumber]					= NULL		-- Transaction Number 
									,[intTermId]							= NULL		-- Term Id(If NULL, customer's default will be used) 
									,[intInvoiceAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])
									,[ysnApplyTermDiscount]					= 0
									,[dblDiscount]							= 0.000000		-- Discount
									,[dblDiscountAvailable]					= NULL		-- Discount 
									,[dblInterest]							= 0.000000		-- Interest
									,[dblPayment]							= CCP.dblPaymentAmount		-- Payment	
									,[strInvoiceReportNumber]				= NULL		-- Transaction Number
									,[intCurrencyExchangeRateTypeId]		= NULL		-- Invoice Forex Rate Type Key Value from tblARInvoicedetail.intCurrencyExchangeRateTypeId - TOP 1
									,[intCurrencyExchangeRateId]			= NULL		-- Invoice Detail Forex Rate Key Value from tblARInvoicedetail.intCurrencyExchangeRateId - Top 1
									,[dblCurrencyExchangeRate]				= NULL		-- Average Invoice Detail Forex Rate - tblARInvoice.dblCurrencyExchangeRate 
									,[ysnAllowOverpayment]					= 0
									,[ysnFromAP]							= NULL 
								FROM tblSTCheckoutCustomerPayments CCP
								JOIN tblSTCheckoutHeader CH 
									ON CCP.intCheckoutId = CH.intCheckoutId
								JOIN tblSTStore ST 
									ON CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC 
									ON CCP.intCustomerId = vC.intEntityId
								LEFT JOIN tblSMPaymentMethod PM	
									ON CCP.intPaymentMethodID = PM.intPaymentMethodID
								WHERE CCP.intCheckoutId = @intCheckoutId
									AND CCP.dblPaymentAmount > 0
								ORDER BY
									[intId]
					END
				----------------------------------------------------------------------
				----------------------- END CUSTOMER PAYMENTS ------------------------
				----------------------------------------------------------------------
				-- END CREATE RECIEVE PAYMENTS from Customer Payments


				-- Invoice Payment for Consignment
				----------------------------------------------------------------------
				-------------------------- Invoice Payment for Consignment -------------------------
				----------------------------------------------------------------------
				IF @ysnConsignmentStore = 1 AND @strInvoiceTransactionTypeMain = 'Invoice' AND @strConsInvoiceType <> 'CSFuelInvoice'
					BEGIN
							-- Use Recieve Payment UDP
							INSERT INTO @PaymentsForInsert(
									[intId]
									,[strSourceTransaction]
									,[intSourceId]
									,[strSourceId]
									,[intPaymentId]
									,[intEntityCustomerId]
									,[intCompanyLocationId]
									,[intCurrencyId]
									,[dtmDatePaid]
									,[intPaymentMethodId]
									,[strPaymentMethod]
									,[strPaymentInfo]
									,[strNotes]
									,[intAccountId]
									,[intBankAccountId]
									,[intWriteOffAccountId]		
									,[dblAmountPaid]
									,[intExchangeRateTypeId]
									,[dblExchangeRate]
									,[strReceivePaymentType]
									,[strPaymentOriginalId]
									,[ysnUseOriginalIdAsPaymentNumber]
									,[ysnApplytoBudget]
									,[ysnApplyOnAccount]
									,[ysnInvoicePrepayment]
									,[ysnImportedFromOrigin]
									,[ysnImportedAsPosted]
									,[ysnAllowPrepayment]		
									,[ysnPost]
									,[ysnRecap]
									,[ysnUnPostAndUpdate]
									,[intEntityId]
									--Detail																																															
									,[intPaymentDetailId]
									,[intInvoiceId]
									,[strTransactionType]
									,[intBillId]
									,[strTransactionNumber]
									,[intTermId]
									,[intInvoiceAccountId]
									,[ysnApplyTermDiscount]
									,[dblDiscount]
									,[dblDiscountAvailable]
									,[dblInterest]
									,[dblPayment]
									,[strInvoiceReportNumber]
									,[intCurrencyExchangeRateTypeId]
									,[intCurrencyExchangeRateId]
									,[dblCurrencyExchangeRate]
									,[ysnAllowOverpayment]
									,[ysnFromAP]
									)								
								SELECT
										[intId]								= @intCheckoutId -- ROW_NUMBER() OVER(ORDER BY CCP.intCustPaymentsId ASC)
									,[strSourceTransaction]					= 'Invoice'
									,[intSourceId]							= @intCheckoutId
									,[strSourceId]							= CAST(@intCheckoutId AS NVARCHAR(50)) --CAST(@intCheckoutId AS NVARCHAR(50))	--CAST(CCP.intCustPaymentsId AS NVARCHAR(50))
									,[intPaymentId]							= NULL									-- Payment Id(Insert new Invoice if NULL, else Update existing) 
									,[intEntityCustomerId]					= @intEntityCustomerId
									,[intCompanyLocationId]					= @intCompanyLocationId --ST.intCompanyLocationId
									,[intCurrencyId]						= @intCurrencyId
									,[dtmDatePaid]							= @dtmCheckoutDate
									,[intPaymentMethodId]					= (SELECT intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH')
									,[strPaymentMethod]						= 'ACH'
									,[strPaymentInfo]						= ''
									,[strNotes]								= 'Consignment Store Payment'
									,[intAccountId]							= NULL		-- Account Id ([tblGLAccount].[intAccountId])
									,[intBankAccountId]						= (SELECT intBankAccountId FROM tblSMCompanyLocation a
																				INNER JOIN tblCMBankAccount b ON
																				a.intCashAccount = b.intGLAccountId
																				WHERE intCompanyLocationId = @intCompanyLocationId)
									,[intWriteOffAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])	
									,[dblAmountPaid]						= (SELECT dblInvoiceTotal FROM tblARInvoice WHERE intInvoiceId = @intCreatedInvoiceId)
									,[intExchangeRateTypeId]				= NULL		-- Forex Rate Type Key Value from tblSMCurrencyExchangeRateType
									,[dblExchangeRate]						= NULL
									,[strReceivePaymentType]				= 'Cash Receipts'
									,[strPaymentOriginalId]					= @intCheckoutId	-- Reference to the original/parent record
																										-- This will also be used to create separate RCV for all rows in Customer Payments tab
									,[ysnUseOriginalIdAsPaymentNumber]		= NULL		-- Indicate whether [strInvoiceOriginId] will be used as Invoice Number
									,[ysnApplytoBudget]						= 0
									,[ysnApplyOnAccount]					= 0
									,[ysnInvoicePrepayment]					= 0
									,[ysnImportedFromOrigin]				= NULL
									,[ysnImportedAsPosted]					= NULL
									,[ysnAllowPrepayment]					= 0
									,[ysnPost]								= 1			-- 1. Post, 0. UnPost
									,[ysnRecap]								= @ysnRecap
									,[ysnUnPostAndUpdate]					= NULL
									,[intEntityId]							= @intCurrentUserId
									--Detail																																															
									,[intPaymentDetailId]					= NULL		-- Payment Detail Id(Insert new Payment Detail if NULL, else Update existing)
									,[intInvoiceId]							= @intCreatedInvoiceId --@intCreatedInvoiceId		-- Use Main Checkout intInvoiceId
									,[strTransactionType]					= NULL
									,[intBillId]							= NULL		-- Key Value from tblARInvoice ([tblAPBill].[intBillId]) 
									,[strTransactionNumber]					= NULL		-- Transaction Number 
									,[intTermId]							= NULL		-- Term Id(If NULL, customer's default will be used) 
									,[intInvoiceAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])
									,[ysnApplyTermDiscount]					= 0
									,[dblDiscount]							= 0.000000		-- Discount
									,[dblDiscountAvailable]					= NULL		-- Discount 
									,[dblInterest]							= 0.000000		-- Interest
									,[dblPayment]							= (SELECT dblInvoiceTotal FROM tblARInvoice WHERE intInvoiceId = @intCreatedInvoiceId)		-- Payment	
									,[strInvoiceReportNumber]				= NULL		-- Transaction Number
									,[intCurrencyExchangeRateTypeId]		= NULL		-- Invoice Forex Rate Type Key Value from tblARInvoicedetail.intCurrencyExchangeRateTypeId - TOP 1
									,[intCurrencyExchangeRateId]			= NULL		-- Invoice Detail Forex Rate Key Value from tblARInvoicedetail.intCurrencyExchangeRateId - Top 1
									,[dblCurrencyExchangeRate]				= NULL		-- Average Invoice Detail Forex Rate - tblARInvoice.dblCurrencyExchangeRate 
									,[ysnAllowOverpayment]					= 0
									,[ysnFromAP]							= NULL 
								FROM tblSTCheckoutHeader CH
								WHERE CH.intCheckoutId = @intCheckoutId
					END
				----------------------------------------------------------------------
				----------------------- END Invoice Payment for Consignment ------------------------
				----------------------------------------------------------------------
				-- END CREATE RECEIVE PAYMENTS from Invoice Payment for Consignment

				IF EXISTS(SELECT * FROM @PaymentsForInsert)
					BEGIN

						-- POST Recieve Payments
						EXEC [dbo].[uspARProcessPayments]
								@PaymentEntries	    = @PaymentsForInsert
								,@UserId			= @intCurrentUserId
								,@GroupingOption	= 8 --6
								,@RaiseError		= 0
								,@ErrorMessage		= @ErrorMessage OUTPUT
								,@LogId				= @intIntegrationLogId OUTPUT

						IF EXISTS(SELECT intIntegrationLogId FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId) AND ISNULL(@ErrorMessage, '') = ''
							BEGIN

								IF NOT EXISTS(SELECT intIntegrationLogId FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId AND ysnPosted = CAST(0 AS BIT))
									BEGIN
										-- Posting to Recieve Payments is successfull
										UPDATE tblSTCheckoutHeader
										SET intReceivePaymentsIntegrationLogId = @intIntegrationLogId
										WHERE intCheckoutId = @intCheckoutId
									END
									ELSE
									BEGIN

										-- SELECT * FROM tblARPaymentIntegrationLogDetail
										SET @ErrorMessage = (SELECT TOP 1 ISNULL(strPostingMessage, strMessage) FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId AND ysnPosted = CAST(0 AS BIT))
										SET @strStatusMsg = 'Receive Payments was not Posted correctly. ' + ISNULL(@ErrorMessage, '')

										-- ROLLBACK
										GOTO ExitWithRollback
								-- -- RETURN
									END
							END
						ELSE
							BEGIN
								SET @strStatusMsg = 'Post Recieve Payments error: ' + @ErrorMessage

								-- ROLLBACK
								GOTO ExitWithRollback
								-- -- RETURN
							END
					END
				----------------------------------------------------------------------
				----------------- END POST TO AR RECIEVE PAYMENT ---------------------
				----------------------------------------------------------------------

				
				------------------------------------------------------
				----------------- LOTTERY COUNT  ---------------------
				------------------------------------------------------
				
				--SUBTRACT QTY ON LOTTERY BOOK--
				UPDATE tblSTLotteryBook 
				SET tblSTLotteryBook.intStartingNumber = tblSTCheckoutLotteryCount.intEndingCount,
				tblSTLotteryBook.dblQuantityRemaining = CASE WHEN strSoldOut = 'Yes' THEN 0 
														ELSE ABS(tblSTCheckoutLotteryCount.intEndingCount - tblSTLotteryBook.intEndingNumber) + 1
														END
				FROM tblSTCheckoutLotteryCount 
				WHERE tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
				AND tblSTCheckoutLotteryCount.intCheckoutId = @intCheckoutId
				AND tblSTLotteryBook.strStatus = 'Active'


				--SUBTRACT QTY ON RETURN LOTTERY PLACE HOLDER (INCASE OF DELETE)--
				UPDATE tblSTReturnLottery SET tblSTReturnLottery.dblOriginalQuantity = tblSTReturnLottery.dblOriginalQuantity - tblSTCheckoutLotteryCount.dblQuantitySold
				FROM tblSTCheckoutLotteryCount 
				WHERE tblSTCheckoutLotteryCount.intLotteryBookId = tblSTReturnLottery.intLotteryBookId
				AND tblSTCheckoutLotteryCount.intCheckoutId = @intCheckoutId
				AND ISNULL(tblSTReturnLottery.ysnPosted,0) = 0


				UPDATE tblSTLotteryBook 
				SET 
				strStatus = CASE WHEN (ISNULL(tblSTLotteryBook.dblQuantityRemaining,0) = 0) THEN 'Sold'ELSE tblSTLotteryBook.strStatus END
				,dtmSoldDate = CASE WHEN (ISNULL(tblSTLotteryBook.dblQuantityRemaining,0) = 0) THEN @dtmCheckoutDate ELSE NULL END
				FROM tblSTCheckoutLotteryCount 
				WHERE tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId 
				AND tblSTCheckoutLotteryCount.intCheckoutId = @intCheckoutId
				--AND tblSTCheckoutLotteryCount.strSoldOut = 'Yes'
				AND tblSTLotteryBook.strStatus = 'Active'

				------------------------------------------------------
				----------------- LOTTERY COUNT  ---------------------
				------------------------------------------------------				


				------------------------------------------------------
				----------------- RETURN LOTTERY  --------------------
				------------------------------------------------------

				BEGIN TRY 

				
					--IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
					--BEGIN 
					--	CREATE TABLE #tmpAddItemReceiptResult 
					--	(
					--		intSourceId INT,
					--		intInventoryReceiptId INT
					--	)
					--END 

					--DECLARE @intReturnLotteryId INT
					DECLARE @intRLInventoryReceiptId INT
					DECLARE @ReturnLotteryReceiptStagingTable ReceiptStagingTable
					,@returnLotteryOtherCharges ReceiptOtherChargesTableType
					,@returnLotteryDefaultCurrency INT
					,@strReturnLotteryReceiptType NVARCHAR(500)
					,@strReturnLotterySourceScreenName NVARCHAR(500)

					SELECT * INTO #tblSTTempReturnLottery  
					FROM tblSTReturnLottery WHERE intCheckoutId = @intCheckoutId

					SELECT * INTO #tblSTTempLoopReturnLottery  
					FROM tblSTReturnLottery WHERE intCheckoutId = @intCheckoutId

					DECLARE @intLotteryBook INT 
					DECLARE @dblTotalReturnQuantity INT
					DECLARE @dblTotalReceiveQuantity INT 
					DECLARE @dblTotalSoldQuantity INT
					DECLARE @ysnReturnLotteryHaveError BIT = 0

					IF((SELECT COUNT(*) FROM #tblSTTempReturnLottery) > 0)
					BEGIN
						
						DECLARE @intReturnLotteryLoopId INT 
						WHILE EXISTS(SELECT TOP 1 * FROM #tblSTTempLoopReturnLottery)
						BEGIN

							
							
							SET @intLotteryBook				 = 0
							SET @dblTotalReturnQuantity 	 = 0
							SET @dblTotalReceiveQuantity 	 = 0
							SET @dblTotalSoldQuantity		 = 0

							SELECT TOP 1 
							 @intReturnLotteryLoopId = intReturnLotteryId 
							,@intLotteryBook = intLotteryBookId
							,@dblTotalReturnQuantity = dblQuantity 
							FROM #tblSTTempLoopReturnLottery

							SELECT @dblTotalReceiveQuantity = SUM(intTicketPerPack) FROM tblSTReceiveLottery where intLotteryBookId = @intLotteryBook GROUP BY intLotteryBookId
							SELECT @dblTotalSoldQuantity = SUM(dblQuantitySold) FROM tblSTCheckoutLotteryCount where intLotteryBookId = @intLotteryBook GROUP BY intLotteryBookId

							SET @dblTotalReceiveQuantity = ISNULL(@dblTotalReceiveQuantity,0)
							SET @dblTotalSoldQuantity = ISNULL(@dblTotalSoldQuantity,0)
							SET @dblTotalReturnQuantity = ISNULL(@dblTotalReturnQuantity,0)

							IF(@dblTotalReceiveQuantity - @dblTotalSoldQuantity != @dblTotalReturnQuantity)
							BEGIN
			
								INSERT INTO @tblSTLotteryProcessError (
									 [intCheckoutId]				
									,[strBookNumber]				
									,[strGame]					
									,[strError]					
									,[strProcess]				
								)
								SELECT 
									@intCurrentUserId
									,tblSTLotteryBook.[strBookNumber]
									,tblSTLotteryGame.strGame
									,'Unable to Post | Returned Quantity for Book# ' + tblSTLotteryBook.[strBookNumber] + ' does not match Total Tickets of ' + CAST(@dblTotalReceiveQuantity AS NVARCHAR(MAX))+ ' - Total Sales of ' + CAST(@dblTotalSoldQuantity AS NVARCHAR(MAX)) + ' = ' + CAST(@dblTotalReceiveQuantity - @dblTotalSoldQuantity AS NVARCHAR(MAX))
									,'Posting return lottery'
								FROM tblSTReturnLottery 
								INNER JOIN tblSTLotteryBook
								ON tblSTLotteryBook.intLotteryBookId =  tblSTReturnLottery.intLotteryBookId 
								INNER JOIN tblSTLotteryGame 
								ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
								WHERE intReturnLotteryId = @intReturnLotteryLoopId

								SELECT 
									@intCurrentUserId
									,tblSTLotteryBook.[strBookNumber]
									,tblSTLotteryGame.strGame
									,'Unable to Post | Returned Quantity for Book# ' + tblSTLotteryBook.[strBookNumber] + ' does not match Total Tickets of ' + CAST(@dblTotalReceiveQuantity AS NVARCHAR(MAX))+ ' - Total Sales of ' + CAST(@dblTotalSoldQuantity AS NVARCHAR(MAX)) + ' = ' + CAST(@dblTotalReceiveQuantity - @dblTotalSoldQuantity AS NVARCHAR(MAX))
									,'Posting return lottery'
								FROM tblSTReturnLottery 
								INNER JOIN tblSTLotteryBook
								ON tblSTLotteryBook.intLotteryBookId =  tblSTReturnLottery.intLotteryBookId 
								INNER JOIN tblSTLotteryGame 
								ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
								WHERE intReturnLotteryId = @intReturnLotteryLoopId


								SET @ysnReturnLotteryHaveError = 1 

								--SELECT * FROM @tblSTLotteryProcessError
								
							END


							DELETE FROM #tblSTTempLoopReturnLottery WHERE intReturnLotteryId = @intReturnLotteryLoopId
							--SELECT TOP 1 'x',* FROM #tblSTTempLoopReturnLottery

						END

						IF(@ysnReturnLotteryHaveError = 1)
						BEGIN
							SET @ysnSuccess = CAST(0 as BIT)
							SET @strStatusMsg = 'Posting Return Lottery | Validation error.'
							GOTO ExitWithRollback
						END

						--UPDATE LOTTERY BOOK--
						UPDATE tblSTLotteryBook
						SET 
						intBinNumber = NULL
						,dblQuantityRemaining = 0 -- SHOULD ALWAYS BE 0 FOR RETURN
						,strStatus = 'Returned'
						WHERE intLotteryBookId IN (SELECT intLotteryBookId FROM tblSTReturnLottery WHERE intCheckoutId = @intCheckoutId)

						
						SET @strReceiptType = 'Direct'
						SET @strSourceScreenName = 'Lottery Module'


						--CREATE RETURN RECEIPT--
						INSERT INTO @ReturnLotteryReceiptStagingTable(
							 strReceiptType
							,strSourceScreenName
							,intEntityVendorId
							,intShipFromId
							,intLocationId
							,intItemId
							,intItemLocationId
							,intItemUOMId
							,intCostUOMId
							,strBillOfLadding
							,intContractHeaderId
							,intContractDetailId
							,dtmDate
							,intShipViaId
							,dblQty
							,dblCost
							,intCurrencyId
							,dblExchangeRate
							,intLotId
							,intSubLocationId
							,intStorageLocationId
							,ysnIsStorage
							,dblFreightRate
							,intSourceId	
							,intSourceType		 	
							,dblGross
							,dblNet
							,intInventoryReceiptId
							,dblSurcharge
							,ysnFreightInPrice
							,strActualCostId
							,intTaxGroupId
							,strVendorRefNo
							,strSourceId			
							,intPaymentOn
							,strChargesLink
							,dblUnitRetail
							,intSort
							,strDataSource
						)	
						SELECT strReceiptType	= @strReceiptType
						,strSourceScreenName	= @strSourceScreenName
						,intEntityVendorId		= tblICItemLocation.intVendorId
						,intShipFromId			= (SELECT TOP 1 intShipFromId FROM tblAPVendor WHERE intEntityId = tblICItemLocation.intVendorId)
						,intLocationId			= tblSTStore.intCompanyLocationId
						,intItemId				= tblSTLotteryGame.intItemId
						,intItemLocationId		= tblICItemLocation.intItemLocationId
						,intItemUOMId			= tblICItemUOM.intItemUOMId
						, intCostUOMId			= tblICItemUOM.intUnitMeasureId
						,strBillOfLadding		= ''
						,intContractHeaderId	= NULL
						,intContractDetailId	= NULL
						,dtmDate				= tblSTReturnLottery.dtmReturnDate
						,intShipViaId			= NULL
						,dblQty					= tblSTReturnLottery.dblQuantity * -1
						,dblCost				= tblSTLotteryGame.dblInventoryCost 
						,intCurrencyId			= @defaultCurrency
						,dblExchangeRate		= 1
						,intLotId				= NULL
						,intSubLocationId		= NULL
						,intStorageLocationId	= NULL
						,ysnIsStorage			= 0
						,dblFreightRate			= 0
						,intSourceId			= tblSTReturnLottery.intReturnLotteryId
						,intSourceType		 	= 7
						,dblGross				= NULL
						,dblNet					= NULL
						,intInventoryReceiptId	= tblSTReturnLottery.intInventoryReceiptId 
						,dblSurcharge			= NULL
						,ysnFreightInPrice		= NULL
						,strActualCostId		= NULL
						,intTaxGroupId			= NULL
						,strVendorRefNo			= tblSMCompanyLocation.strVendorRefNoPrefix + ISNULL(tblSTLotteryGame.strGame,'') + ISNULL(tblSTLotteryBook.strBookNumber,'') + 'R'
						,strSourceId			= NULL
						,intPaymentOn			= NULL
						,strChargesLink			= NULL
						,dblUnitRetail			= NULL
						,intSort				= NULL
						,strDataSource			= @strSourceScreenName
						FROM tblSTReturnLottery
						INNER JOIN tblSTLotteryBook
						ON tblSTReturnLottery.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
						INNER JOIN tblSTLotteryGame 
						ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
						INNER JOIN tblSTStore 
						ON tblSTLotteryBook.intStoreId = tblSTStore.intStoreId
						INNER JOIN tblICItemLocation 
							ON tblICItemLocation.intLocationId = tblSTStore.intCompanyLocationId 
							AND tblSTLotteryGame.intItemId = tblICItemLocation.intItemId
						INNER JOIN tblICItemPricing
							ON tblICItemPricing.intItemLocationId = tblICItemLocation.intItemLocationId
							AND tblICItemPricing.intItemId = tblICItemLocation.intItemId
						LEFT JOIN tblAPVendor 
						ON tblAPVendor.intEntityId = tblICItemLocation.intVendorId
						LEFT JOIN tblICItemUOM 
						ON tblICItemUOM.intItemUOMId = tblICItemLocation.intIssueUOMId
						LEFT JOIN tblSMCompanyLocation
						ON tblSTStore.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
						WHERE tblSTReturnLottery.intReturnLotteryId IN (SELECT intReturnLotteryId FROM tblSTReturnLottery WHERE intCheckoutId = @intCheckoutId)


						EXEC dbo.uspICAddItemReceipt 
							 @ReturnLotteryReceiptStagingTable
							,@OtherCharges
							,@intCurrentUserId;
		
						UPDATE tblSTReturnLottery SET intInventoryReceiptId = tblResult.intInventoryReceiptId FROM #tmpAddItemReceiptResult as tblResult WHERE tblSTReturnLottery.intReturnLotteryId = tblResult.intSourceId
						--SELECT * FROM #tmpAddItemReceiptResult

						DECLARE @loopPostReturnInventoryReceiptId INT 
						DECLARE @loopReturnLotteryId INT
						DECLARE @returnReceiptNumber NVARCHAR(100)
						WHILE EXISTS(SELECT TOP 1 * FROM #tmpAddItemReceiptResult)
						BEGIN
							SELECT TOP 1 
							@loopPostReturnInventoryReceiptId = intInventoryReceiptId ,
							@loopReturnLotteryId = intSourceId
							FROM #tmpAddItemReceiptResult
						
							SELECT	@returnReceiptNumber = strReceiptNumber 
							FROM	tblICInventoryReceipt 
							WHERE	intInventoryReceiptId = @loopPostReturnInventoryReceiptId
		
							EXEC dbo.uspICPostInventoryReceipt 1, 0, @returnReceiptNumber, @intCurrentUserId;		
			
							UPDATE tblSTReturnLottery SET ysnPosted = 1 WHERE intReturnLotteryId = @loopReturnLotteryId	

							DELETE FROM #tmpAddItemReceiptResult WHERE intInventoryReceiptId = @loopPostReturnInventoryReceiptId

						END
					END

				END TRY 
				BEGIN CATCH
					
				-- Flag Success
					SET @strStatusMsg = ERROR_MESSAGE()
					GOTO ExitWithRollback

				END CATCH 
			
				------------------------------------------------------
				----------------- RETURN LOTTERY  --------------------
				------------------------------------------------------



			END
		ELSE IF(@ysnPost = 0)
			BEGIN
				------------------------------------------------------
				---------- TRANSFER TANK READINGS TO TM  -------------
				------------------------------------------------------
				DELETE FROM tblTMTankReading WHERE intCheckoutId = @intCheckoutId
				------------------------------------------------------
				---------- TRANSFER TANK READINGS TO TM  -------------
				------------------------------------------------------

				----------------------------------------------------------------------
				--------------- START UN-POST RECEIVE PAYMENTS -----------------------
				----------------------------------------------------------------------
				-- Check if Checkout has value on column 'intReceivePaymentsIntegrationLogId'
				IF EXISTS(SELECT intReceivePaymentsIntegrationLogId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId AND intReceivePaymentsIntegrationLogId IS NOT NULL)
					BEGIN

						SET @intIntegrationLogId = (
														SELECT intReceivePaymentsIntegrationLogId 
														FROM tblSTCheckoutHeader 
														WHERE intCheckoutId = @intCheckoutId 
														AND intReceivePaymentsIntegrationLogId IS NOT NULL
												   )

						IF EXISTS(SELECT intIntegrationLogId FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId AND ysnPosted = 1)
							BEGIN
									-- List of Received Payments
									INSERT INTO @PaymentsForInsert(
											[intId]
											,[strSourceTransaction]
											,[intSourceId]
											,[strSourceId]
											,[intPaymentId]
											,[intEntityCustomerId]
											,[intCompanyLocationId]
											,[intCurrencyId]
											,[dtmDatePaid]
											,[intPaymentMethodId]
											,[strPaymentMethod]
											,[strPaymentInfo]
											,[strNotes]
											,[intAccountId]
											,[intBankAccountId]
											,[intWriteOffAccountId]		
											,[dblAmountPaid]
											,[intExchangeRateTypeId]
											,[dblExchangeRate]
											,[strReceivePaymentType]
											,[strPaymentOriginalId]
											,[ysnUseOriginalIdAsPaymentNumber]
											,[ysnApplytoBudget]
											,[ysnApplyOnAccount]
											,[ysnInvoicePrepayment]
											,[ysnImportedFromOrigin]
											,[ysnImportedAsPosted]
											,[ysnAllowPrepayment]		
											,[ysnPost]
											,[ysnRecap]
											,[ysnUnPostAndUpdate]
											,[intEntityId]
											--Detail																																															
											,[intPaymentDetailId]
											,[intInvoiceId]
											,[strTransactionType]
											,[intBillId]
											,[strTransactionNumber]
											,[intTermId]
											,[intInvoiceAccountId]
											,[ysnApplyTermDiscount]
											,[dblDiscount]
											,[dblDiscountAvailable]
											,[dblInterest]
											,[dblPayment]
											,[strInvoiceReportNumber]
											,[intCurrencyExchangeRateTypeId]
											,[intCurrencyExchangeRateId]
											,[dblCurrencyExchangeRate]
											,[ysnAllowOverpayment]
											,[ysnFromAP]
										)								
										SELECT --DISTINCT		-- Use idistinct to eliminate duplicates 		 	
											 [intId]								= CCP.intCustPaymentsId --ROW_NUMBER() OVER(ORDER BY CCP.intCustPaymentsId ASC)
											,[strSourceTransaction]					= 'Invoice'
											,[intSourceId]							= CCP.intCustPaymentsId --@intCheckoutId						--CCP.intCustPaymentsId
											,[strSourceId]							= CAST(CCP.intCustPaymentsId AS NVARCHAR(50)) --CAST(@intCheckoutId AS NVARCHAR(50))	--CAST(CCP.intCustPaymentsId AS NVARCHAR(50))
											,[intPaymentId]							= Payment.intPaymentId									-- Payment Id(Insert new Invoice if NULL, else Update existing) 
											,[intEntityCustomerId]					= CCP.intCustomerId
											,[intCompanyLocationId]					= @intCompanyLocationId --ST.intCompanyLocationId
											,[intCurrencyId]						= @intCurrencyId
											,[dtmDatePaid]							= @dtmCheckoutDate
											,[intPaymentMethodId]					= CCP.intPaymentMethodID
											,[strPaymentMethod]						= PM.strPaymentMethod
											,[strPaymentInfo]						= CCP.strCheckNo
											,[strNotes]								= 'Store Payment ' + CCP.strComment
											,[intAccountId]							= NULL		-- Account Id ([tblGLAccount].[intAccountId])
											,[intBankAccountId]						= NULL		-- Bank Account Id ([tblCMBankAccount].[intBankAccountId])
											,[intWriteOffAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])	
											,[dblAmountPaid]						= CCP.dblPaymentAmount
											,[intExchangeRateTypeId]				= NULL		-- Forex Rate Type Key Value from tblSMCurrencyExchangeRateType
											,[dblExchangeRate]						= NULL
											,[strReceivePaymentType]				= 'Cash Receipts'
											,[strPaymentOriginalId]					= NULL		-- Reference to the original/parent record
											,[ysnUseOriginalIdAsPaymentNumber]		= NULL		-- Indicate whether [strInvoiceOriginId] will be used as Invoice Number
											,[ysnApplytoBudget]						= 0
											,[ysnApplyOnAccount]					= 0
											,[ysnInvoicePrepayment]					= 1 -- TEST
											,[ysnImportedFromOrigin]				= NULL
											,[ysnImportedAsPosted]					= NULL
											,[ysnAllowPrepayment]					= 1  -- TEST
											,[ysnPost]								= @ysnPost			-- 1. Post, 0. UnPost
											,[ysnRecap]								= @ysnRecap
											,[ysnUnPostAndUpdate]					= 1 -- To UNPOST
											,[intEntityId]							= @intCurrentUserId

											--Detail																																															
											,[intPaymentDetailId]					= PaymentDetail.intPaymentDetailId --ILD.intPaymentDetailId		-- Payment Detail Id(Insert new Payment Detail if NULL, else Update existing)
											,[intInvoiceId]							= PaymentDetail.intInvoiceId --TEST		--@intCreatedInvoiceId		-- Use Main Checkout intInvoiceId
											,[strTransactionType]					= NULL
											,[intBillId]							= NULL		-- Key Value from tblARInvoice ([tblAPBill].[intBillId]) 
											,[strTransactionNumber]					= NULL		-- Transaction Number 
											,[intTermId]							= NULL		-- Term Id(If NULL, customer's default will be used) 
											,[intInvoiceAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])
											,[ysnApplyTermDiscount]					= 0
											,[dblDiscount]							= 0.000000		-- Discount
											,[dblDiscountAvailable]					= NULL		-- Discount 
											,[dblInterest]							= 0.000000		-- Interest
											,[dblPayment]							= CCP.dblPaymentAmount		-- Payment	
											,[strInvoiceReportNumber]				= NULL		-- Transaction Number
											,[intCurrencyExchangeRateTypeId]		= NULL		-- Invoice Forex Rate Type Key Value from tblARInvoicedetail.intCurrencyExchangeRateTypeId - TOP 1
											,[intCurrencyExchangeRateId]			= NULL		-- Invoice Detail Forex Rate Key Value from tblARInvoicedetail.intCurrencyExchangeRateId - Top 1
											,[dblCurrencyExchangeRate]				= NULL		-- Average Invoice Detail Forex Rate - tblARInvoice.dblCurrencyExchangeRate 
											,[ysnAllowOverpayment]					= 1 -- TEST
											,[ysnFromAP]							= NULL 
										FROM tblSTCheckoutCustomerPayments CCP
										JOIN tblSTCheckoutHeader CH 
											ON CCP.intCheckoutId = CH.intCheckoutId
										JOIN tblARPaymentIntegrationLogDetail ILD
											ON CH.intReceivePaymentsIntegrationLogId = ILD.intIntegrationLogId
											AND CCP.intCustPaymentsId = ILD.intSourceId
										JOIN tblARPayment Payment
											ON ILD.intPaymentId = Payment.intPaymentId
										INNER JOIN tblARPaymentDetail PaymentDetail
											ON Payment.intPaymentId = PaymentDetail.intPaymentId
										INNER JOIN tblARInvoice Inv
											ON PaymentDetail.intInvoiceId = Inv.intInvoiceId
										JOIN tblSTStore ST 
											ON CH.intStoreId = ST.intStoreId
										JOIN vyuEMEntityCustomerSearch vC 
											ON CCP.intCustomerId = vC.intEntityId
										LEFT JOIN tblSMPaymentMethod PM	
											ON CCP.intPaymentMethodID = PM.intPaymentMethodID
										WHERE CCP.intCheckoutId = @intCheckoutId
											AND CCP.dblPaymentAmount > 0
											AND Inv.ysnPosted = 1
											--AND UOM.ysnStockUnit = CAST(1 AS BIT)
										ORDER BY
											[intId]


									IF @ysnConsignmentStore = 1 AND @strInvoiceTransactionTypeMain = 'Invoice' AND @strConsInvoiceType <> 'CSFuelInvoice'
									BEGIN
											-- Use Recieve Payment UDP
											INSERT INTO @PaymentsForInsert(
													[intId]
													,[strSourceTransaction]
													,[intSourceId]
													,[strSourceId]
													,[intPaymentId]
													,[intEntityCustomerId]
													,[intCompanyLocationId]
													,[intCurrencyId]
													,[dtmDatePaid]
													,[intPaymentMethodId]
													,[strPaymentMethod]
													,[strPaymentInfo]
													,[strNotes]
													,[intAccountId]
													,[intBankAccountId]
													,[intWriteOffAccountId]		
													,[dblAmountPaid]
													,[intExchangeRateTypeId]
													,[dblExchangeRate]
													,[strReceivePaymentType]
													,[strPaymentOriginalId]
													,[ysnUseOriginalIdAsPaymentNumber]
													,[ysnApplytoBudget]
													,[ysnApplyOnAccount]
													,[ysnInvoicePrepayment]
													,[ysnImportedFromOrigin]
													,[ysnImportedAsPosted]
													,[ysnAllowPrepayment]		
													,[ysnPost]
													,[ysnRecap]
													,[ysnUnPostAndUpdate]
													,[intEntityId]
													--Detail																																															
													,[intPaymentDetailId]
													,[intInvoiceId]
													,[strTransactionType]
													,[intBillId]
													,[strTransactionNumber]
													,[intTermId]
													,[intInvoiceAccountId]
													,[ysnApplyTermDiscount]
													,[dblDiscount]
													,[dblDiscountAvailable]
													,[dblInterest]
													,[dblPayment]
													,[strInvoiceReportNumber]
													,[intCurrencyExchangeRateTypeId]
													,[intCurrencyExchangeRateId]
													,[dblCurrencyExchangeRate]
													,[ysnAllowOverpayment]
													,[ysnFromAP]
													)								
												SELECT
													 [intId]								= @intCheckoutId -- ROW_NUMBER() OVER(ORDER BY CCP.intCustPaymentsId ASC)
													,[strSourceTransaction]					= 'Invoice'
													,[intSourceId]							= @intCheckoutId
													,[strSourceId]							= CAST(@intCheckoutId AS NVARCHAR(50)) --CAST(@intCheckoutId AS NVARCHAR(50))	--CAST(CCP.intCustPaymentsId AS NVARCHAR(50))
													,[intPaymentId]							= Payment.intPaymentId										-- Payment Id(Insert new Invoice if NULL, else Update existing) 
													,[intEntityCustomerId]					= @intEntityCustomerId
													,[intCompanyLocationId]					= @intCompanyLocationId --ST.intCompanyLocationId
													,[intCurrencyId]						= @intCurrencyId
													,[dtmDatePaid]							= @dtmCheckoutDate
													,[intPaymentMethodId]					= (SELECT intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH')
													,[strPaymentMethod]						= 'ACH'
													,[strPaymentInfo]						= ''
													,[strNotes]								= 'Consignment Store Payment'
													,[intAccountId]							= NULL		-- Account Id ([tblGLAccount].[intAccountId])
													,[intBankAccountId]						= (SELECT intBankAccountId FROM tblSMCompanyLocation a
																								INNER JOIN tblCMBankAccount b ON
																								a.intCashAccount = b.intGLAccountId
																								WHERE intCompanyLocationId = @intCompanyLocationId)
													,[intWriteOffAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])	
													,[dblAmountPaid]						= (SELECT dblInvoiceTotal FROM tblARInvoice WHERE intInvoiceId  = (SELECT intInvoiceId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId))
													,[intExchangeRateTypeId]				= NULL		-- Forex Rate Type Key Value from tblSMCurrencyExchangeRateType
													,[dblExchangeRate]						= NULL
													,[strReceivePaymentType]				= 'Cash Receipts'
													,[strPaymentOriginalId]					= NULL	-- Reference to the original/parent record
																														-- This will also be used to create separate RCV for all rows in Customer Payments tab
													,[ysnUseOriginalIdAsPaymentNumber]		= NULL		-- Indicate whether [strInvoiceOriginId] will be used as Invoice Number
													,[ysnApplytoBudget]						= 0
													,[ysnApplyOnAccount]					= 0
													,[ysnInvoicePrepayment]					= 0
													,[ysnImportedFromOrigin]				= NULL
													,[ysnImportedAsPosted]					= NULL
													,[ysnAllowPrepayment]					= 0
													,[ysnPost]								= @ysnPost			-- 1. Post, 0. UnPost
													,[ysnRecap]								= @ysnRecap
													,[ysnUnPostAndUpdate]					= 1 -- To UNPOST
													,[intEntityId]							= @intCurrentUserId
													--Detail																																															
													,[intPaymentDetailId]					= PaymentDetail.intPaymentDetailId		-- Payment Detail Id(Insert new Payment Detail if NULL, else Update existing)
													,[intInvoiceId]							= PaymentDetail.intInvoiceId --@intCreatedInvoiceId		-- Use Main Checkout intInvoiceId
													,[strTransactionType]					= NULL
													,[intBillId]							= NULL		-- Key Value from tblARInvoice ([tblAPBill].[intBillId]) 
													,[strTransactionNumber]					= NULL		-- Transaction Number 
													,[intTermId]							= NULL		-- Term Id(If NULL, customer's default will be used) 
													,[intInvoiceAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])
													,[ysnApplyTermDiscount]					= 0
													,[dblDiscount]							= 0.000000		-- Discount
													,[dblDiscountAvailable]					= NULL		-- Discount 
													,[dblInterest]							= 0.000000		-- Interest
													,[dblPayment]							= (SELECT dblInvoiceTotal FROM tblARInvoice WHERE intInvoiceId  = (SELECT intInvoiceId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId))		-- Payment	
													,[strInvoiceReportNumber]				= NULL		-- Transaction Number
													,[intCurrencyExchangeRateTypeId]		= NULL		-- Invoice Forex Rate Type Key Value from tblARInvoicedetail.intCurrencyExchangeRateTypeId - TOP 1
													,[intCurrencyExchangeRateId]			= NULL		-- Invoice Detail Forex Rate Key Value from tblARInvoicedetail.intCurrencyExchangeRateId - Top 1
													,[dblCurrencyExchangeRate]				= NULL		-- Average Invoice Detail Forex Rate - tblARInvoice.dblCurrencyExchangeRate 
													,[ysnAllowOverpayment]					= 0
													,[ysnFromAP]							= NULL 
												FROM tblSTCheckoutHeader CH
												JOIN tblARPaymentIntegrationLogDetail ILD
													ON CH.intReceivePaymentsIntegrationLogId = ILD.intIntegrationLogId
												JOIN tblARPayment Payment
													ON ILD.intPaymentId = Payment.intPaymentId
												INNER JOIN tblARPaymentDetail PaymentDetail
													ON Payment.intPaymentId = PaymentDetail.intPaymentId
												INNER JOIN tblARInvoice Inv
													ON PaymentDetail.intInvoiceId = Inv.intInvoiceId
												WHERE CH.intCheckoutId = @intCheckoutId
													AND Inv.ysnPosted = 1
													AND ILD.intPaymentDetailId IS NOT NULL
									END


									IF @ysnConsignmentStore = 1 AND @strInvoiceTransactionTypeMain = 'Invoice'
									BEGIN
											-- Use Recieve Payment UDP
											INSERT INTO @PaymentsForInsert(
													[intId]
													,[strSourceTransaction]
													,[intSourceId]
													,[strSourceId]
													,[intPaymentId]
													,[intEntityCustomerId]
													,[intCompanyLocationId]
													,[intCurrencyId]
													,[dtmDatePaid]
													,[intPaymentMethodId]
													,[strPaymentMethod]
													,[strPaymentInfo]
													,[strNotes]
													,[intAccountId]
													,[intBankAccountId]
													,[intWriteOffAccountId]		
													,[dblAmountPaid]
													,[intExchangeRateTypeId]
													,[dblExchangeRate]
													,[strReceivePaymentType]
													,[strPaymentOriginalId]
													,[ysnUseOriginalIdAsPaymentNumber]
													,[ysnApplytoBudget]
													,[ysnApplyOnAccount]
													,[ysnInvoicePrepayment]
													,[ysnImportedFromOrigin]
													,[ysnImportedAsPosted]
													,[ysnAllowPrepayment]		
													,[ysnPost]
													,[ysnRecap]
													,[ysnUnPostAndUpdate]
													,[intEntityId]
													--Detail																																															
													,[intPaymentDetailId]
													,[intInvoiceId]
													,[strTransactionType]
													,[intBillId]
													,[strTransactionNumber]
													,[intTermId]
													,[intInvoiceAccountId]
													,[ysnApplyTermDiscount]
													,[dblDiscount]
													,[dblDiscountAvailable]
													,[dblInterest]
													,[dblPayment]
													,[strInvoiceReportNumber]
													,[intCurrencyExchangeRateTypeId]
													,[intCurrencyExchangeRateId]
													,[dblCurrencyExchangeRate]
													,[ysnAllowOverpayment]
													,[ysnFromAP]
													)								
												SELECT
													 [intId]								= @intCheckoutId -- ROW_NUMBER() OVER(ORDER BY CCP.intCustPaymentsId ASC)
													,[strSourceTransaction]					= 'Invoice'
													,[intSourceId]							= @intCheckoutId
													,[strSourceId]							= CAST(@intCheckoutId AS NVARCHAR(50)) --CAST(@intCheckoutId AS NVARCHAR(50))	--CAST(CCP.intCustPaymentsId AS NVARCHAR(50))
													,[intPaymentId]							= Payment.intPaymentId										-- Payment Id(Insert new Invoice if NULL, else Update existing) 
													,[intEntityCustomerId]					= @intEntityCustomerId
													,[intCompanyLocationId]					= @intCompanyLocationId --ST.intCompanyLocationId
													,[intCurrencyId]						= @intCurrencyId
													,[dtmDatePaid]							= @dtmCheckoutDate
													,[intPaymentMethodId]					= (SELECT intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH')
													,[strPaymentMethod]						= 'ACH'
													,[strPaymentInfo]						= ''
													,[strNotes]								= 'Consignment Store Payment'
													,[intAccountId]							= NULL		-- Account Id ([tblGLAccount].[intAccountId])
													,[intBankAccountId]						= (SELECT intBankAccountId FROM tblSMCompanyLocation a
																								INNER JOIN tblCMBankAccount b ON
																								a.intCashAccount = b.intGLAccountId
																								WHERE intCompanyLocationId = @intCompanyLocationId)
													,[intWriteOffAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])	
													,[dblAmountPaid]						= (SELECT dblInvoiceTotal FROM tblARInvoice WHERE intInvoiceId  = (SELECT intInvoiceId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId))
													,[intExchangeRateTypeId]				= NULL		-- Forex Rate Type Key Value from tblSMCurrencyExchangeRateType
													,[dblExchangeRate]						= NULL
													,[strReceivePaymentType]				= 'Cash Receipts'
													,[strPaymentOriginalId]					= NULL	-- Reference to the original/parent record
																														-- This will also be used to create separate RCV for all rows in Customer Payments tab
													,[ysnUseOriginalIdAsPaymentNumber]		= NULL		-- Indicate whether [strInvoiceOriginId] will be used as Invoice Number
													,[ysnApplytoBudget]						= 0
													,[ysnApplyOnAccount]					= 0
													,[ysnInvoicePrepayment]					= 0
													,[ysnImportedFromOrigin]				= NULL
													,[ysnImportedAsPosted]					= NULL
													,[ysnAllowPrepayment]					= 0
													,[ysnPost]								= @ysnPost			-- 1. Post, 0. UnPost
													,[ysnRecap]								= @ysnRecap
													,[ysnUnPostAndUpdate]					= 1 -- To UNPOST
													,[intEntityId]							= @intCurrentUserId
													--Detail																																															
													,[intPaymentDetailId]					= PaymentDetail.intPaymentDetailId		-- Payment Detail Id(Insert new Payment Detail if NULL, else Update existing)
													,[intInvoiceId]							= PaymentDetail.intInvoiceId --@intCreatedInvoiceId		-- Use Main Checkout intInvoiceId
													,[strTransactionType]					= NULL
													,[intBillId]							= NULL		-- Key Value from tblARInvoice ([tblAPBill].[intBillId]) 
													,[strTransactionNumber]					= NULL		-- Transaction Number 
													,[intTermId]							= NULL		-- Term Id(If NULL, customer's default will be used) 
													,[intInvoiceAccountId]					= NULL		-- Account Id ([tblGLAccount].[intAccountId])
													,[ysnApplyTermDiscount]					= 0
													,[dblDiscount]							= 0.000000		-- Discount
													,[dblDiscountAvailable]					= NULL		-- Discount 
													,[dblInterest]							= 0.000000		-- Interest
													,[dblPayment]							= (SELECT dblInvoiceTotal FROM tblARInvoice WHERE intInvoiceId  = (SELECT intInvoiceId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId))		-- Payment	
													,[strInvoiceReportNumber]				= NULL		-- Transaction Number
													,[intCurrencyExchangeRateTypeId]		= NULL		-- Invoice Forex Rate Type Key Value from tblARInvoicedetail.intCurrencyExchangeRateTypeId - TOP 1
													,[intCurrencyExchangeRateId]			= NULL		-- Invoice Detail Forex Rate Key Value from tblARInvoicedetail.intCurrencyExchangeRateId - Top 1
													,[dblCurrencyExchangeRate]				= NULL		-- Average Invoice Detail Forex Rate - tblARInvoice.dblCurrencyExchangeRate 
													,[ysnAllowOverpayment]					= 0
													,[ysnFromAP]							= NULL 
												FROM tblSTCheckoutHeader CH
												JOIN tblARPaymentIntegrationLogDetail ILD
													ON CH.intReceivePaymentsIntegrationLogId = ILD.intIntegrationLogId
												JOIN tblARPayment Payment
													ON ILD.intPaymentId = Payment.intPaymentId
												INNER JOIN tblARPaymentDetail PaymentDetail
													ON Payment.intPaymentId = PaymentDetail.intPaymentId
												INNER JOIN tblARInvoice Inv
													ON PaymentDetail.intInvoiceId = Inv.intInvoiceId
												WHERE CH.intCheckoutId = @intCheckoutId
													AND Inv.ysnPosted = 1
													AND ILD.intPaymentDetailId IS NOT NULL
									END

									IF EXISTS(SELECT TOP 1 1 FROM @PaymentsForInsert)
										BEGIN

											BEGIN TRY

												-- http://jira.irelyserver.com/browse/ST-1053
												EXEC [dbo].[uspARProcessPayments]
														@PaymentEntries	    = @PaymentsForInsert
														,@UserId			= @intCurrentUserId
														,@GroupingOption	= 6
														,@RaiseError		= 0
														,@ErrorMessage		= @ErrorMessage OUTPUT
														,@LogId				= @intIntegrationLogId OUTPUT
											END TRY
											BEGIN CATCH
												SET @ysnSuccess = CAST(0 AS BIT)
												SET @strStatusMsg = 'Unposting Recieve Payments error: ' + ERROR_MESSAGE()
												SET @ErrorMessage = @ErrorMessage

												-- ROLLBACK
												GOTO ExitWithRollback
											END CATCH
											

											-- After Un-Posting is successfull delete the recieve payment record
											IF(@ErrorMessage IS NULL) --AND EXISTS(SELECT intIntegrationLogId FROM tblARPaymentIntegrationLogDetail WHERE intIntegrationLogId = @intIntegrationLogId))
												BEGIN
													
													-- Handle more than one 
													DECLARE @tempRCVPaymentsDetails TABLE
													(
														intRCVPaymentsId INT,
														ysnRCVPosted BIT,
														intCPPInvoiceId INT
													)


													-- GET RCV Payment Id
													INSERT INTO @tempRCVPaymentsDetails
													(
														intRCVPaymentsId,
														ysnRCVPosted,
														intCPPInvoiceId
													)
													SELECT DISTINCT 
														Payment.intPaymentId,
														Payment.ysnPosted,
														PaymentDetail.intInvoiceId
													FROM tblARPaymentIntegrationLogDetail LogDetail
													INNER JOIN tblARPayment Payment
														ON LogDetail.intPaymentId = Payment.intPaymentId
													INNER JOIN tblARPaymentDetail PaymentDetail
														ON Payment.intPaymentId = PaymentDetail.intPaymentId
													WHERE LogDetail.intIntegrationLogId = (
																								SELECT intReceivePaymentsIntegrationLogId
																								FROM tblSTCheckoutHeader
																								WHERE intCheckoutId = @intCheckoutId
																						  )


  												    -- LOOP Here
													DECLARE @intCPPInvoiceIdLoop AS INT
													      , @intRCVPaymentIdLoop AS INT
													WHILE EXISTS(SELECT TOP (1) intRCVPaymentsId FROM @tempRCVPaymentsDetails)
														BEGIN
															SELECT TOP (1) 
																@intCPPInvoiceIdLoop = intCPPInvoiceId,
																@intRCVPaymentIdLoop = intRCVPaymentsId
															FROM @tempRCVPaymentsDetails


															BEGIN TRY
																IF EXISTS(SELECT intPaymentId FROM tblARPayment WHERE intPaymentId = @intRCVPaymentIdLoop AND ysnPosted = 0)
																	BEGIN
																		IF(@ErrorMessage IS NULL)
																			BEGIN
																				IF @ysnConsignmentStore = 1 AND @strInvoiceTransactionTypeMain = 'Invoice' AND @strConsInvoiceType <> 'CSFuelInvoice'
																				BEGIN
																					DECLARE @RCVId AS Id
																				
																					INSERT INTO @RCVId (intId)
																					VALUES (@intRCVPaymentIdLoop)
																				
																					-- DELETE RCV
																					EXEC [dbo].[uspARDeletePayment]
																							@PaymentIds	= @RCVId,
																							@intEntityUserId		= @intCurrentUserId
																					--SELECT ''
																				END
																				ELSE
																				BEGIN
																					-- Delete Recieve Payments
																					EXEC [dbo].[uspARProcessPaymentFromInvoice]
																						 @InvoiceId						= @intCPPInvoiceIdLoop -- Invoice Id of CPP
																						,@EntityId						= 1			
																						,@RaiseError					= 0				
																						,@PaymentId						= @intRCVPaymentIdLoop OUTPUT
																						,@ErrorMessage					= @ErrorMessage OUTPUT

																					-- DELETE CPP here
																					EXEC [dbo].[uspARDeleteInvoice]
																							@InvoiceId	= @intCPPInvoiceIdLoop,
																							@UserId		= @intCurrentUserId
																				END
																			END
																	END
																ELSE 
																	BEGIN
																		SET @ysnSuccess = CAST(0 AS BIT)
																		SET @strStatusMsg = 'RCV should be UnPosted before deleting'
																		SET @ErrorMessage = @ErrorMessage

																		-- ROLLBACK
																		GOTO ExitWithRollback
																	END

														
															END TRY
															BEGIN CATCH
																SET @ysnSuccess = CAST(0 AS BIT)
																SET @strStatusMsg = 'Deleting Recieve Payments error: ' + ERROR_MESSAGE()
																SET @ErrorMessage = @ErrorMessage

																-- ROLLBACK
																GOTO ExitWithRollback
															END CATCH
													

															IF(@ErrorMessage IS NOT NULL)
														BEGIN
															-- DELETE Failed

															SET @strStatusMsg = 'Delete Receive Payments error: ' + @ErrorMessage

															-- ROLLBACK
															GOTO ExitWithRollback
															-- RETURN
														END




															DELETE TOP (1) FROM @tempRCVPaymentsDetails
														END

													
												END
											ELSE
												BEGIN
													SET @strStatusMsg = 'Unpost Receive Payments error: ' + @ErrorMessage

													-- ROLLBACK
													GOTO ExitWithRollback
													-- RETURN
												END

											-- ROLLBACK Transaction if theres error on UnPosting from Receive Payments
										END
							END
					END
				----------------------------------------------------------------------
				---------------- END UN-POST RECEIVE PAYMENTS ------------------------
				----------------------------------------------------------------------


				----------------------------------------------------------------------
				--------------- START UN-POST SALES INVOICE --------------------------
				----------------------------------------------------------------------
--PRINT 'START UN-POST SALES INVOICE'
				SET @strCurrentAllInvoiceIdList = NULL

				-- Insert to Temp Table
				DELETE FROM @tblTempInvoiceIds

				INSERT INTO @tblTempInvoiceIds
				(
					intInvoiceId,
					intEntityId,
					ysnPosted,
					strTransactionType
				)
				SELECT DISTINCT 
					Inv.intInvoiceId,
					Inv.intEntityCustomerId,
					Inv.ysnPosted,
					LogDetail.strTransactionType
				FROM tblARInvoiceIntegrationLogDetail LogDetail
				INNER JOIN tblARInvoice Inv
					ON LogDetail.intInvoiceId = Inv.intInvoiceId
				WHERE intIntegrationLogId = (
												SELECT intSalesInvoiceIntegrationLogId
												FROM tblSTCheckoutHeader
												WHERE intCheckoutId =  @intCheckoutId
											)
				ORDER BY Inv.intInvoiceId DESC

				INSERT INTO @tblTempInvoiceIds
				(
					intInvoiceId,
					intEntityId,
					ysnPosted,
					strTransactionType
				)
				SELECT DISTINCT 
					Inv.intInvoiceId,
					Inv.intEntityCustomerId,
					Inv.ysnPosted,
					LogDetail.strTransactionType
				FROM tblARInvoiceIntegrationLogDetail LogDetail
				INNER JOIN tblARInvoice Inv
					ON LogDetail.intInvoiceId = Inv.intInvoiceId
				WHERE intIntegrationLogId = (
												SELECT intCreditMemoIntegrationLogId
												FROM tblSTCheckoutHeader
												WHERE intCheckoutId =  @intCheckoutId
											)
				ORDER BY Inv.intInvoiceId DESC



				--IF(@strCurrentAllInvoiceIdList IS NOT NULL AND @strCurrentAllInvoiceIdList != '')
				IF EXISTS(SELECT TOP 1 intInvoiceId FROM @tblTempInvoiceIds)
					BEGIN -- 01

						SET @ysnSuccess = 1

						DECLARE @intInvoiceIdLoop AS INT
								, @ysnPostedLoop AS BIT
						WHILE EXISTS(SELECT TOP (1) intInvoiceId FROM @tblTempInvoiceIds)
							BEGIN -- while
								
								SELECT TOP (1)
									@intInvoiceIdLoop	=	intInvoiceId,
									@ysnPostedLoop		=	ysnPosted
								FROM @tblTempInvoiceIds

								IF(@ysnPostedLoop = 1)
									BEGIN
										BEGIN TRY
											EXEC [dbo].[uspARPostInvoice]
													@batchId			= NULL,
													@post				= 0, -- 0 = UnPost
													@recap				= @ysnRecap,
													@param				= @intInvoiceIdLoop,
													@userId				= @intCurrentUserId,
													@beginDate			= NULL,
													@endDate			= NULL,
													@beginTransaction	= NULL,
													@endTransaction		= NULL,
													@exclude			= NULL,
													@successfulCount	= @intSuccessfullCount OUTPUT,
													@invalidCount		= @intInvalidCount OUTPUT,
													@success			= @ysnSuccess OUTPUT,
													@batchIdUsed		= @strBatchIdUsed OUTPUT,
													@transType			= N'all',
													@raiseError			= 1
				
												-- Check if Recap
												IF(@ysnRecap = CAST(1 AS BIT))
													BEGIN

														IF(@strBatchIdUsed IS NOT NULL)
															BEGIN

																IF EXISTS(SELECT strBatchId FROM tblGLPostRecap WHERE strBatchId = @strBatchIdUsed)
																	BEGIN
																		SET @strCreateGuidBatch = NEWID();

																		-- GET POST PREVIEW on GL Entries
																		INSERT INTO @GLEntries (
																							[dtmDate] 
																							,[strBatchId]
																							,[intAccountId]
																							,[dblDebit]
																							,[dblCredit]
																							,[dblDebitUnit]
																							,[dblCreditUnit]
																							,[strDescription]
																							,[strCode]
																							,[strReference]
																							,[intCurrencyId]
																							,[dblExchangeRate]
																							,[dtmDateEntered]
																							,[dtmTransactionDate]
																							,[strJournalLineDescription]
																							,[intJournalLineNo]
																							,[ysnIsUnposted]
																							,[intUserId]
																							,[intEntityId]
																							,[strTransactionId]
																							,[intTransactionId]
																							,[strTransactionType]
																							,[strTransactionForm]
																							,[strModuleName]
																							,[intConcurrencyId]
																							,[dblDebitForeign]	
																							--,[dblDebitReport]	
																							,[dblCreditForeign]	
																							--,[dblCreditReport]	
																							--,[dblReportingRate]	
																							--,[dblForeignRate]
																							,[strRateType]
																					)
																				SELECT [dtmDate] 
																							,[strBatchId] = @strCreateGuidBatch
																							,[intAccountId]
																							,[dblDebit]
																							,[dblCredit]
																							,[dblDebitUnit]
																							,[dblCreditUnit]
																							,[strDescription]
																							,[strCode]
																							,[strReference]
																							,[intCurrencyId]
																							,[dblExchangeRate]
																							,[dtmDateEntered]
																							,[dtmTransactionDate]
																							,[strJournalLineDescription]
																							,[intJournalLineNo]
																							,[ysnIsUnposted]
																							,[intUserId]
																							,[intEntityId]
																							,[strTransactionId]
																							,[intTransactionId]
																							,[strTransactionType]
																							,[strTransactionForm]
																							,[strModuleName]
																							,[intConcurrencyId]
																							,[dblDebitForeign]	
																							--,[dblDebitReport]	
																							,[dblCreditForeign]	
																							--,[dblCreditReport]	
																							--,[dblReportingRate]	
																							--,[dblForeignRate]
																							,[strRateType]
																					FROM tblGLPostRecap
																					WHERE strBatchId = @strBatchIdUsed

																		IF @@TRANCOUNT > 0
																		BEGIN
																			ROLLBACK TRANSACTION
																		END


																		IF @@TRANCOUNT = 0
																		BEGIN
																			BEGIN TRANSACTION
																		END

																			EXEC dbo.uspGLPostRecap 
																					@GLEntries
																					,@intCurrentUserId
																	
																			SET @strBatchIdForNewPostRecap = @strCreateGuidBatch

																		GOTO ExitWithCommit
																	END
																ELSE
																	GOTO ExitWithRollback
															END
													END
										END TRY

										BEGIN CATCH
											SET @ysnUpdateCheckoutStatus = CAST(0 AS BIT)
											SET @ysnSuccess = CAST(0 AS BIT)
											SET @strStatusMsg = 'Unpost Sales Invoice error: ' + ERROR_MESSAGE()

											-- ROLLBACK
											GOTO ExitWithRollback
											-- -- RETURN

										END CATCH
									END


								-- Example OutPut params
								-- @intSuccessfullCount: 1
								-- @intInvalidCount: 0
								-- @ysnSuccess: 1
								-- @strBatchIdUsed: BATCH-722

								IF(@ysnSuccess = CAST(1 AS BIT))
									BEGIN
										-----------------------------------------------------------------------
										------------------- START DELETE Invoice  -----------------------------
										-----------------------------------------------------------------------

										-- Update tblSTCheckoutHeader to remove Invoice Id constraints
										UPDATE tblSTCheckoutHeader
										SET intInvoiceId = NULL, strAllInvoiceIdList = NULL
										WHERE intCheckoutId = @intCheckoutId

										-- Update tblSTCheckoutCustomerCharges
										UPDATE tblSTCheckoutCustomerCharges
										SET intCustomerChargesInvoiceId = NULL
										WHERE intCheckoutId = @intCheckoutId

										-- DELETE Invoice
										BEGIN TRY	
											EXEC [dbo].[uspARDeleteInvoice]
													@InvoiceId	= @intInvoiceIdLoop,
													@UserId		= @intCurrentUserId
										END TRY

										BEGIN CATCH
											SET @ysnUpdateCheckoutStatus = CAST(0 AS BIT)
											SET @ysnSuccess = CAST(0 AS BIT)
											SET @strStatusMsg = 'Deleting Sales Invoice Error: ' + ERROR_MESSAGE()

											-- ROLLBACK
											GOTO ExitWithRollback
										END CATCH

										-----------------------------------------------------------------------
										-------------------- END DELETE Invoice -------------------------------
										-----------------------------------------------------------------------




										SET @ysnInvoiceStatus = 0
										-----------------------------------------------------------------------
										------------- START UNPOST MArk Up / Down -----------------------------
										-----------------------------------------------------------------------
										IF EXISTS(SELECT * FROM tblSTCheckoutMarkUpDowns WHERE intCheckoutId = @intCheckoutId)
											BEGIN
												-- UNPOST	
												BEGIN TRY
													IF (@strAllowMarkUpDown = 'I' OR @strAllowMarkUpDown = 'D')
														BEGIN
															EXEC uspSTMarkUpDownCheckoutPosting
																	@intCheckoutId
																	,@intCurrentUserId
																	,0 -- UNPOST
																	,@strMarkUpDownPostingStatusMsg OUTPUT
																	,@strBatchId OUTPUT
																	,@ysnIsPosted OUTPUT
														END
												END TRY

												BEGIN CATCH
													SET @ysnUpdateCheckoutStatus = CAST(0 AS BIT)
													SET @ysnSuccess = CAST(0 AS BIT)
													SET @strStatusMsg = 'Unpost Mark Up/Down error: ' + ERROR_MESSAGE()

													-- ROLLBACK
													GOTO ExitWithRollback
													-- RETURN

												END CATCH

												IF(@strMarkUpDownPostingStatusMsg = '')
													BEGIN
														SET @strStatusMsg = 'Success' -- Should return to 'Success'
													END
												ELSE
													BEGIN
														SET @strStatusMsg = @strMarkUpDownPostingStatusMsg
													END
										
											END
										-----------------------------------------------------------------------
										------------- END UNPOST MArk Up / Down -------------------------------
										-----------------------------------------------------------------------
									END



								DELETE TOP (1) FROM @tblTempInvoiceIds
						END -- while

						
					END -- 01
				ELSE 
					BEGIN
						SET @strStatusMsg = 'There are no Invoice to Unpost'

						-- ROLLBACK
						GOTO ExitWithRollback
						-- RETURN
					END
				----------------------------------------------------------------------
				---------------- END UN-POST SALES INVOICE ---------------------------
				----------------------------------------------------------------------


				------------------------------------------------------
				----------------- LOTTERY COUNT  ---------------------
				------------------------------------------------------
				
				UPDATE tblSTLotteryBook 
				SET tblSTLotteryBook.dblQuantityRemaining = ISNULL(tblSTLotteryBook.dblQuantityRemaining,0) + ISNULL(tblSTCheckoutLotteryCount.dblQuantitySold,0),
				tblSTLotteryBook.intStartingNumber = CASE WHEN (tblSTLotteryBook.strCountDirection = 'Low to High')
															THEN ISNULL(tblSTLotteryBook.intStartingNumber,0) - ISNULL(tblSTCheckoutLotteryCount.dblQuantitySold,0)
														ELSE ISNULL(tblSTLotteryBook.intStartingNumber,0) + ISNULL(tblSTCheckoutLotteryCount.dblQuantitySold,0)
													END
				FROM tblSTCheckoutLotteryCount 
				WHERE tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
				AND tblSTCheckoutLotteryCount.intCheckoutId = @intCheckoutId


				UPDATE tblSTLotteryBook 
				SET strStatus = CASE WHEN (ISNULL(tblSTLotteryBook.dblQuantityRemaining,0) != 0) THEN 'Active'ELSE tblSTLotteryBook.strStatus END
				, dtmSoldDate = CASE WHEN (ISNULL(tblSTLotteryBook.dblQuantityRemaining,0) != 0) THEN  NULL ELSE tblSTLotteryBook.dtmSoldDate END
				FROM tblSTCheckoutLotteryCount 
				WHERE tblSTCheckoutLotteryCount.intLotteryBookId = tblSTLotteryBook.intLotteryBookId 
				AND tblSTCheckoutLotteryCount.intCheckoutId = @intCheckoutId
				AND tblSTLotteryBook.strStatus != 'Returned'

				------------------------------------------------------
				----------------- LOTTERY COUNT  ---------------------
				------------------------------------------------------



				------------------------------------------------------
				----------------- RECEIVE LOTTERY---------------------
				------------------------------------------------------

				IF EXISTS(SELECT TOP 1 intInventoryReceiptId FROM tblSTReceiveLottery WHERE intCheckoutId = @intCheckoutId)
				BEGIN

					DECLARE	@intIRLotteryUnpostProcessReturnValue int = 0,
							@strIRLotteryUnpostBatchId nvarchar(40)

					--UNPOST IR--
					DECLARE @strIRTransactionId NVARCHAR(MAX) 
					--SELECT @strIRTransactionIds = COALESCE(@strIRTransactionIds + ', ' + strReceiptNumber, strReceiptNumber) FROM tblICInventoryReceipt WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM tblSTReceiveLottery WHERE intCheckoutId = @intCheckoutId) 

					INSERT INTO @tblInventoryReceiptIds 
					SELECT strReceiptNumber AS strReceiptId FROM tblICInventoryReceipt WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM tblSTReceiveLottery WHERE intCheckoutId = @intCheckoutId)
					
					WHILE EXISTS (SELECT TOP 1 strReceiptId FROM @tblInventoryReceiptIds)
					BEGIN

						SELECT TOP 1 @strIRTransactionId = strReceiptId FROM @tblInventoryReceiptIds
						
						EXEC	@intIRLotteryUnpostProcessReturnValue = [dbo].[uspICPostInventoryReceipt]
								@ysnPost = 0,
								@ysnRecap = 0,
								@strTransactionId = @strIRTransactionId,
								@intEntityUserSecurityId = @intCurrentUserId,
								@strBatchId = @strIRLotteryUnpostBatchId OUTPUT
								
						DELETE FROM @tblInventoryReceiptIds WHERE strReceiptId = @strIRTransactionId
					END
							

					IF(@intIRLotteryUnpostProcessReturnValue = 0)
					BEGIN

						UPDATE tblSTReceiveLottery SET ysnPosted = 0 WHERE intCheckoutId = @intCheckoutId
						-- SELECT * INTO #tblTempUnpostLotteryIR FROM tblSTReceiveLottery WHERE intCheckoutId = @intCheckoutId
						-- DECLARE @intLoopDeleteLotteryIRId INT
						-- DECLARE @intLoopDeleteLotteryBookId INT
						-- WHILE EXISTS(SELECT TOP 1 * FROM #tblTempUnpostLotteryIR)
						-- BEGIN
						-- 	SELECT TOP 1 @intLoopDeleteLotteryIRId = intInventoryReceiptId, @intLoopDeleteLotteryBookId = intLotteryBookId  FROM #tblTempUnpostLotteryIR

						-- 	EXEC [dbo].[uspICDeleteInventoryReceipt]=@InventoryReceiptId = @intLoopDeleteLotteryIRId,=@intEntityUserSecurityId = @intCurrentUserId


						-- 	-- DELETE FROM tblSTLotteryBook WHERE intLotteryBookId = @intLoopDeleteLotteryBookId
						-- 	DELETE FROM #tblTempUnpostLotteryIR WHERE intInventoryReceiptId = @intLoopDeleteLotteryIRId

						-- END

					END


				END


				
				------------------------------------------------------
				----------------- RECEIVE LOTTERY---------------------
				------------------------------------------------------

				------------------------------------------------------
				----------------- RETURN LOTTERY---------------------
				------------------------------------------------------

				IF EXISTS(SELECT TOP 1 intInventoryReceiptId FROM tblSTReturnLottery WHERE intCheckoutId = @intCheckoutId)
				BEGIN

					--UNPOST IR--
					DECLARE @strReturnIRTransactionIds NVARCHAR(MAX) 
					SELECT @strReturnIRTransactionIds = COALESCE(@strReturnIRTransactionIds + ', ' + strReceiptNumber, strReceiptNumber) FROM tblICInventoryReceipt WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM tblSTReturnLottery WHERE intCheckoutId = @intCheckoutId) 
					Select @strReturnIRTransactionIds


					DECLARE	@intReturnIRLotteryUnpostProcessReturnValue int,
							@strReturnIRLotteryUnpostBatchId nvarchar(40)

					EXEC	@intReturnIRLotteryUnpostProcessReturnValue = [dbo].[uspICPostInventoryReceipt]
							@ysnPost = 0,
							@ysnRecap = 0,
							@strTransactionId = @strReturnIRTransactionIds,
							@intEntityUserSecurityId = @intCurrentUserId,
							@strBatchId = @strReturnIRLotteryUnpostBatchId OUTPUT
							


					IF(@intReturnIRLotteryUnpostProcessReturnValue = 0)
					BEGIN

						UPDATE tblSTReturnLottery SET ysnPosted = 0 WHERE intCheckoutId = @intCheckoutId
						SELECT * INTO #tblTempUnpostReturnLotteryIR FROM tblSTReturnLottery WHERE intCheckoutId = @intCheckoutId
						DECLARE @intLoopDeleteLotteryIRId INT
						DECLARE @intLoopDeleteLotteryBookId INT
						DECLARE @intLoopDeleteReturnLotteryId INT
						 WHILE EXISTS(SELECT TOP 1 * FROM #tblTempUnpostReturnLotteryIR)
						 BEGIN
						 	SELECT TOP 1 
							 @intLoopDeleteLotteryIRId = intInventoryReceiptId
							,@intLoopDeleteLotteryBookId = intLotteryBookId  
							,@intLoopDeleteReturnLotteryId = intReturnLotteryId
							FROM #tblTempUnpostReturnLotteryIR



						 	--EXEC [dbo].[uspICDeleteInventoryReceipt]=@InventoryReceiptId = @intLoopDeleteLotteryIRId,=@intEntityUserSecurityId = @intCurrentUserId

							UPDATE tblSTLotteryBook 
							SET 
								dblQuantityRemaining = dblQuantityRemaining + dblQuantity,
								strStatus = 'Inactive'
							FROM 
							tblSTReturnLottery
							WHERE intReturnLotteryId = @intLoopDeleteReturnLotteryId AND tblSTReturnLottery.intLotteryBookId = tblSTLotteryBook.intLotteryBookId

						 	-- DELETE FROM tblSTLotteryBook WHERE intLotteryBookId = @intLoopDeleteLotteryBookId
						 	DELETE FROM #tblTempUnpostReturnLotteryIR 
							WHERE intInventoryReceiptId = @intLoopDeleteLotteryIRId
							AND @intLoopDeleteLotteryBookId = intLotteryBookId  
							AND @intLoopDeleteReturnLotteryId = intReturnLotteryId

						 END

					END


				END


				
				------------------------------------------------------
				----------------- RETURN LOTTERY---------------------
				------------------------------------------------------





			END
		----------------------------------------------------------------------
		----------------------- END POST / UNPOST ----------------------------
		----------------------------------------------------------------------
		

		IF(@ysnUpdateCheckoutStatus = 1)
			BEGIN
				-- Determine Status
				IF(@strDirection = 'Post')
					BEGIN
						SET @strNewCheckoutStatus = 'Posted'
					END
				ELSE IF (@strDirection = 'UnPost')
					BEGIN
						SET @strNewCheckoutStatus = 'Manager Verified'
					END
				ELSE IF (@strDirection = 'SendToOffice')
					BEGIN
						SET @strNewCheckoutStatus = 'Manager Verified'
					END
				ELSE IF (@strDirection = 'SendBackToStore')
					BEGIN
						SET @strNewCheckoutStatus = 'Open'
					END

				IF(@ysnPost IS NULL)
					BEGIN

						UPDATE dbo.tblSTCheckoutHeader 
						SET strCheckoutStatus = @strNewCheckoutStatus
						WHERE intCheckoutId = @intCheckoutId
					END
				ELSE IF(@ysnPost = 1) -- POST
					BEGIN

						IF (@strAllCreatedInvoiceIdList IS NOT NULL AND @strAllCreatedInvoiceIdList != '')
							BEGIN

								-- First time to Post
								-- New created invoice will be made
								IF @ysnConsignmentStore = 1
								BEGIN
									IF @ysnConsignmentStore = 1
									BEGIN
									IF @strConsInvoiceType = 'CSFuelInvoice'
										BEGIN
											UPDATE dbo.tblSTCheckoutHeader 
											SET strCheckoutStatus = @strNewCheckoutStatus
												, intConsCreditMemoId = @intCreatedInvoiceId 
												, intInvoiceId = @intConsInvoiceId
												, strAllInvoiceIdList = @strAllCreatedInvoiceIdList -- New Invoice Id
											WHERE intCheckoutId = @intCheckoutId
										END
										ELSE
										BEGIN
											UPDATE dbo.tblSTCheckoutHeader 
											SET strCheckoutStatus = @strNewCheckoutStatus
												, intInvoiceId = @intCreatedInvoiceId
												, strAllInvoiceIdList = @strAllCreatedInvoiceIdList -- New Invoice Id
											WHERE intCheckoutId = @intCheckoutId
										END												
									END
								END
								ELSE
								BEGIN
									UPDATE dbo.tblSTCheckoutHeader 
									SET strCheckoutStatus = @strNewCheckoutStatus
										, intInvoiceId = @intCreatedInvoiceId 
										, strAllInvoiceIdList = @strAllCreatedInvoiceIdList -- New Invoice Id
									WHERE intCheckoutId = @intCheckoutId
								END

								IF EXISTS (SELECT TOP 1 1 FROM @tblTempInvoiceIds WHERE strTransactionType != @strInvoiceTransactionTypeMain) --#tmpCustomerInvoiceIdList)
									BEGIN
										-- Update customer charges invoices on table tblSTCheckoutCustomerCharges
										UPDATE CC
											SET intCustomerChargesInvoiceId = CCX.intInvoiceId
										FROM tblSTCheckoutCustomerCharges CC
										JOIN
										(
											SELECT 
												intCustChargeId,
												inv.intInvoiceId
											FROM tblSTCheckoutCustomerCharges C
											JOIN @tblTempInvoiceIds inv 
												ON C.intCustomerId = inv.intEntityId
											WHERE C.intCheckoutId = @intCheckoutId
												AND C.dblAmount > 0
												-- AND UOM.ysnStockUnit = CAST(1 AS BIT) http://jira.irelyserver.com/browse/ST-1316

										) CCX ON CC.intCustChargeId = CCX.intCustChargeId
									END
								
							END
					END
				ELSE IF(@ysnPost = 0) -- UNPOST
					BEGIN
						UPDATE dbo.tblSTCheckoutHeader 
						SET strCheckoutStatus = @strNewCheckoutStatus
						WHERE intCheckoutId = @intCheckoutId
					END
			END
			--DROP
			-- IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NOT NULL  
			-- 	BEGIN
			-- 		DROP TABLE #tmpCustomerInvoiceIdList
			-- 	END

			-- COMMIT
			GOTO ExitWithCommit
	END TRY

	BEGIN CATCH
		--DROP
		-- IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NOT NULL  
		-- 	BEGIN
		-- 		DROP TABLE #tmpCustomerInvoiceIdList
		-- 	END

		SET @strStatusMsg = 'Script Error: ' + ERROR_MESSAGE()

		-- ROLLBACK
		GOTO ExitWithRollback
	END CATCH
END

ExitWithCommit:
	
	-- Add 'Unposted/Posted' to AuditLog
	-- ==========================================================================
	-- [START] - AUDIT LOG - Mark as Created
	-- ==========================================================================
	DECLARE @strPostDirectionAuditLog AS NVARCHAR(50)
	IF(@ysnPost = 1)
		BEGIN
			SET @strPostDirectionAuditLog = 'Posted'
		END
	ELSE
		BEGIN
			SET @strPostDirectionAuditLog = 'Unposted'
		END

	EXEC dbo.uspSMAuditLog 
			@screenName			=		'Store.view.CheckoutHeader'			-- Screen Namespace
			,@keyValue			=		@intCheckoutId						-- Primary Key Value of the Voucher. 
			,@entityId			=		@intCurrentUserId					-- Entity Id.
			,@actionType		=		@strPostDirectionAuditLog			-- Action Type
			,@actionIcon		=		'small-new-plus'					-- 'small-menu-maintenance', 'small-new-plus', 'small-new-minus',
			,@changeDescription	=		''									-- Description
			,@fromValue			=		''									-- Previous Value
			,@toValue			=		''									-- New Value
	-- ==========================================================================
	-- [START] - AUDIT LOG - Mark as Created
	-- ==========================================================================


	-- Commit Transaction

	
	IF @@TRANCOUNT > 0
		BEGIN
			-- PRINT 'Will Rollback'
			COMMIT TRANSACTION
		END
	GOTO ExitPost
	

ExitWithRollback:

    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			-- PRINT 'Will Rollback'
			ROLLBACK TRANSACTION 
		END

	--UPDATE tblSTCheckoutHeader SET intCheckoutCurrentProcess = 0 WHERE intCheckoutId = @intCheckoutId

	--DELETE FROM tblSTLotteryProcessError WHERE intCheckoutId = @intCurrentUserId
	--SELECT 'x',* FROM @tblSTLotteryProcessError
	INSERT INTO tblSTLotteryProcessError (
		 intCheckoutId
		,strBookNumber
		,strGame
		,strError
		,strProcess
	)
	SELECT 
		intCheckoutId
		,strBookNumber
		,strGame
		,strError
		,strProcess
	FROM
	@tblSTLotteryProcessError
	GOTO ExitPost
		
ExitPost:
	
	IF(@ysnSetToReady = CAST(1 AS BIT))
		BEGIN
			
			UPDATE tblSTCheckoutHeader
			SET intCheckoutCurrentProcess = 0,
				dtmCheckoutProcessDate = NULL
			WHERE intCheckoutId = @intCheckoutId  

		END
	ELSE
		BEGIN
			SELECT 'ExitPost'
		END