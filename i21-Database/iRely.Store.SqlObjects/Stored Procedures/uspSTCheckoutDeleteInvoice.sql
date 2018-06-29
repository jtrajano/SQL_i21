CREATE PROCEDURE [dbo].[uspSTCheckoutDeleteInvoice]
@intCurrentUserId INT,
@intCheckoutId INT,
@intInvoiceId INT,
@strAllInvoiceIdList NVARCHAR(1000),
@intStoreId INT,
@intShiftNo INT,
@dtmCheckoutDate DATE,
@strStatusMsg NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY

		SET @strStatusMsg = 'Success'

		-- Values for deleting from tblSTCheckoutHeader, UnPosting Sales Invoice
		DECLARE @strInvoiceId NVARCHAR(50) = ''
		DECLARE @ysnInvoiceIsPosted BIT = NULL
		DECLARE @intMainCheckoutSuccessfullCountOut INT
		DECLARE @intInvalidCount INT
		DECLARE @ysnMainCheckoutSuccessOut BIT
		DECLARE @strBatchIdUsed NVARCHAR(40)
		DECLARE @ysnError BIT = 1

		DECLARE @ysnContinueToPostMainCheckout BIT
		DECLARE @intCurrentInvoiceLoop AS INT
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




		IF(@strAllInvoiceIdList IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN(SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strAllInvoiceIdList)))
					BEGIN
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

							-- Insert to temp table
							INSERT INTO #tmpCustomerInvoiceIdList(intInvoiceId)
							SELECT [intID] AS intInvoiceId 
							FROM [dbo].[fnGetRowsFromDelimitedValues](@strAllInvoiceIdList) ORDER BY [intID] ASC

							------------------------------------------------------------------
							------------------------ Delete Invoice --------------------------
							------------------------------------------------------------------

							
							WHILE EXISTS (SELECT TOP (1) 1 FROM #tmpCustomerInvoiceIdList)
							BEGIN
								SELECT TOP 1 @intCurrentInvoiceLoop = CAST([intInvoiceId] AS NVARCHAR(50)) FROM #tmpCustomerInvoiceIdList

								EXEC [dbo].[uspARDeleteInvoice]
										 @InvoiceId	= @intCurrentInvoiceLoop,
										 @UserId	= @intCurrentUserId

								DELETE TOP (1) FROM #tmpCustomerInvoiceIdList
							END


							------------------------------------------------------------------
							---------------------- End Delete Invoice ------------------------
							------------------------------------------------------------------

					END
			END
			
			--DROP
			IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NOT NULL  
				BEGIN
					DROP TABLE #tmpCustomerInvoiceIdList
				END
	END TRY

	BEGIN CATCH
		--DROP
		IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NOT NULL  
			BEGIN
					DROP TABLE #tmpCustomerInvoiceIdList
			END

		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END