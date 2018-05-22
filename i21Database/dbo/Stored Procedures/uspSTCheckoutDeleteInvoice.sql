CREATE PROCEDURE [dbo].[uspSTCheckoutDeleteInvoice]
@intCurrentUserId INT,
@intCheckoutId INT,
@intInvoiceId INT,
@intCustomerChargesInvoiceId INT,
@intStoreId INT,
@intShiftNo INT,
@dtmCheckoutDate DATE,
@strStatusMsg NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY

		SET @strStatusMsg = 'Success'

		---- Values for deleting from table tblSTMarkUpDown
		--DECLARE @intStoreId INT = NULL 
		--DECLARE @intShiftNo INT = NULL
		--DECLARE @dtmCheckoutDate DATE = NULL

		-- Values for deleting from tblSTCheckoutHeader, UnPosting Sales Invoice
		DECLARE @strInvoiceId NVARCHAR(50) = ''
		DECLARE @ysnInvoiceIsPosted BIT = NULL
		DECLARE @intSuccessfullCount INT
		DECLARE @intInvalidCount INT
		DECLARE @ysnSuccess BIT
		DECLARE @strBatchIdUsed NVARCHAR(40)
		DECLARE @ysnError BIT = 1

		--IF EXISTS(SELECT intCheckoutId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
		--	BEGIN
		--		SELECT @intStoreId = intStoreId
		--			   , @intShiftNo = intShiftNo
		--			   , @dtmCheckoutDate = dtmCheckoutDate
		--			   , @intInvoiceId = intInvoiceId
		--		FROM tblSTCheckoutHeader 
		--		WHERE intCheckoutId = @intCheckoutId
		--	END
		--ELSE
		--	BEGIN
		--		SET @strStatusMsg = 'Checkout does not exist'
		--	END

		----------------------------------------------------------------------------------
		------------------------ Delete From tblSTMarkUpDown -----------------------------
		----------------------------------------------------------------------------------
		IF EXISTS(SELECT intMarkUpDownId FROM tblSTMarkUpDown 
				  WHERE CONVERT(DATE, dtmMarkUpDownDate) = @dtmCheckoutDate 
				  AND intShiftNo = @intShiftNo 
				  AND intStoreId = @intStoreId)
			BEGIN
				DELETE FROM tblSTMarkUpDown 
				WHERE CONVERT(DATE, dtmMarkUpDownDate) = @dtmCheckoutDate 
				AND intShiftNo = @intShiftNo 
				AND intStoreId = @intStoreId
			END
		----------------------------------------------------------------------------------
		---------------------- End Delete From tblSTMarkUpDown ---------------------------
		----------------------------------------------------------------------------------


		IF(@intInvoiceId IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId)
					BEGIN
							SELECT @ysnInvoiceIsPosted = ysnPosted 
							FROM tblARInvoice 
							WHERE intInvoiceId = @intInvoiceId 
							AND ISNULL(ysnPosted,0) = 1


							IF(@ysnInvoiceIsPosted = 1)
								BEGIN
									------------------------------------------------------------------
									------------------------ UnPost Invoice --------------------------
									------------------------------------------------------------------

									SET @strInvoiceId = CAST(@intInvoiceId AS NVARCHAR(50))

									EXEC [dbo].[uspARPostInvoice]
											@batchId			= NULL,
											@post				= 0, -- 0 = UnPost
											@recap				= 0,
											@param				= @strInvoiceId,
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
											@raiseError			= @ysnError

										-- Example OutPut params
										-- @intSuccessfullCount: 1
										-- @intInvalidCount: 0
										-- @ysnSuccess: 1
										-- @strBatchIdUsed: BATCH-722
										------------------------------------------------------------------
										--------------------- End UnPost Invoice -------------------------
										------------------------------------------------------------------
								END
								

								------------------------------------------------------------------
								------------------------ Delete Invoice --------------------------
								------------------------------------------------------------------

								EXEC [dbo].[uspARDeleteInvoice]
									 @InvoiceId	= @intInvoiceId,
									 @UserId	= @intCurrentUserId

								------------------------------------------------------------------
								---------------------- End Delete Invoice ------------------------
								------------------------------------------------------------------
							END
					END

			IF(@intCustomerChargesInvoiceId IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId = @intCustomerChargesInvoiceId)
					BEGIN
							SELECT @ysnInvoiceIsPosted = ysnPosted 
							FROM tblARInvoice 
							WHERE intInvoiceId = @intCustomerChargesInvoiceId 
							AND ISNULL(ysnPosted,0) = 1


							IF(@ysnInvoiceIsPosted = 1)
								BEGIN
									------------------------------------------------------------------
									------------------------ UnPost Invoice --------------------------
									------------------------------------------------------------------

									SET @strInvoiceId = CAST(@intCustomerChargesInvoiceId AS NVARCHAR(50))

									EXEC [dbo].[uspARPostInvoice]
											@batchId			= NULL,
											@post				= 0, -- 0 = UnPost
											@recap				= 0,
											@param				= @strInvoiceId,
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
											@raiseError			= @ysnError

										-- Example OutPut params
										-- @intSuccessfullCount: 1
										-- @intInvalidCount: 0
										-- @ysnSuccess: 1
										-- @strBatchIdUsed: BATCH-722
										------------------------------------------------------------------
										--------------------- End UnPost Invoice -------------------------
										------------------------------------------------------------------
								END
								

								------------------------------------------------------------------
								------------------------ Delete Invoice --------------------------
								------------------------------------------------------------------

								EXEC [dbo].[uspARDeleteInvoice]
									 @InvoiceId	= @intCustomerChargesInvoiceId,
									 @UserId	= @intCurrentUserId

								------------------------------------------------------------------
								---------------------- End Delete Invoice ------------------------
								------------------------------------------------------------------
							END
					END
	END TRY

	BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END