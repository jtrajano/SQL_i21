CREATE PROCEDURE [dbo].[uspSCReverseInventoryShipmentInvoice]
	@intTicketId INT
	,@intUserId INT
	,@intInventoryShipmentId INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@jsonData NVARCHAR(MAX);

DECLARE @_intInvoiceId INT
DECLARE @_intInvoiceDetail INT
DECLARE @ysnPost BIT
DECLARE @intNewInvoiceId INT
DECLARE @strNewInvoiceNumber NVARCHAR(50)
DECLARE @intCreditMemoId INT
DECLARE @strCreditMemoNumber NVARCHAR(50)
DECLARE @strIvoiceNumber NVARCHAR(50)


--------------------------------
DECLARE @successfulCount INT
DECLARE	@invalidCount INT
DECLARE	@success INT
DECLARE	@batchIdUsed NVARCHAR(100)
DECLARE	@recapId INT
DECLARE @strInvoiceDetailIds NVARCHAR(50)



BEGIN TRY

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpSCCheckInvoiceForTicketResult'))
	BEGIN
		CREATE TABLE #tmpSCCheckInvoiceForTicketResult (
			intTicketId INT
			,intInventoryShipmentId INT
			,intInvoiceId INT
			,intCreditMemoId INT
		)
	END

	IF OBJECT_ID (N'tempdb.dbo.#tmpSCInvoiceDetail') IS NOT NULL DROP TABLE #tmpSCInvoiceDetail
	CREATE TABLE #tmpSCInvoiceDetail(
		intInvoiceId INT
		,intInvoiceDetailId INT
		,ysnPosted BIT
	)

	IF(ISNULL(@intInventoryShipmentId,0) > 0)
	BEGIN
		-- print 'has IS'

		---Check for regular credit memo
		BEGIN
			INSERT INTO #tmpSCInvoiceDetail(
				ysnPosted
				,intInvoiceId
				,intInvoiceDetailId
			)
			SELECT TOP 1
				A.ysnPosted
				,A.intInvoiceId
				,B.intInvoiceDetailId
			FROM tblARInvoiceDetail B
			INNER JOIN tblARInvoice A
				ON A.intInvoiceId = B.intInvoiceId
			INNER JOIN tblICInventoryShipmentItem C
				ON B.intInventoryShipmentItemId = C.intInventoryShipmentItemId
			INNER JOIN tblICInventoryShipment D
				ON C.intInventoryShipmentId = D.intInventoryShipmentId
			WHERE B.intTicketId = @intTicketId
				AND D.intInventoryShipmentId = @intInventoryShipmentId
				AND ISNULL(B.intOriginalInvoiceDetailId,0) = 0
				AND A.strTransactionType = 'Invoice'
				AND EXISTS(SELECT TOP 1 1 
								FROM tblARInvoiceDetail 
								WHERE ISNULL(intOriginalInvoiceDetailId,0) = B.intInvoiceDetailId
									AND ISNULL(ysnReversal,0) = 0 )
		
				--- Get the credit memo
				SET @strCreditMemoNumber = ''
				SELECT TOP 1
					@strCreditMemoNumber = B.strInvoiceNumber
				FROM tblARInvoiceDetail A
				INNER JOIN 	tblARInvoice B
					ON A.intInvoiceId = B.intInvoiceId
				WHERE A.intOriginalInvoiceDetailId IN (SELECT intInvoiceDetailId FROM #tmpSCInvoiceDetail)

				IF(ISNULL(@strCreditMemoNumber,'') <> '')
				BEGIN
					SET @ErrorMessage = 'Credit memo ''' + @strCreditMemoNumber +''' already been created.';
					RAISERROR(@ErrorMessage, 11, 1);
					GOTO _Exit
				END
			
		END



		INSERT INTO #tmpSCInvoiceDetail(
			ysnPosted
			,intInvoiceId
			,intInvoiceDetailId
		)
		SELECT 
			A.ysnPosted
			,A.intInvoiceId
			,B.intInvoiceDetailId
		FROM tblARInvoiceDetail B
		INNER JOIN tblARInvoice A
			ON A.intInvoiceId = B.intInvoiceId
		INNER JOIN tblICInventoryShipmentItem C
			ON B.intInventoryShipmentItemId = C.intInventoryShipmentItemId
		INNER JOIN tblICInventoryShipment D
			ON C.intInventoryShipmentId = D.intInventoryShipmentId
		WHERE B.intTicketId = @intTicketId
			AND D.intInventoryShipmentId = @intInventoryShipmentId
			AND ISNULL(B.intOriginalInvoiceDetailId,0) = 0
			AND A.strTransactionType = 'Invoice'
			AND NOT EXISTS(SELECT TOP 1 1 
							FROM tblARInvoiceDetail 
							WHERE ISNULL(intOriginalInvoiceDetailId,0) = B.intInvoiceDetailId)
	END
	ELSE
	BEGIN
		-- print 'direct invoice'

		-- credit memo checking
		BEGIN
			INSERT INTO #tmpSCInvoiceDetail(
				ysnPosted
				,intInvoiceId
				,intInvoiceDetailId
			)
			SELECT 
				A.ysnPosted
				,A.intInvoiceId
				,B.intInvoiceDetailId
			FROM tblARInvoiceDetail B
			INNER JOIN tblARInvoice A
				ON A.intInvoiceId = B.intInvoiceId
			WHERE intTicketId = @intTicketId
				AND A.strTransactionType = 'Invoice'
				AND ISNULL(B.intOriginalInvoiceDetailId,0) = 0
				AND EXISTS(SELECT TOP 1 1 
								FROM tblARInvoiceDetail 
								WHERE ISNULL(intOriginalInvoiceDetailId,0) = B.intInvoiceDetailId
									AND ISNULL(ysnReversal,0) = 0 )
		
				--- Get the credit memo
				SET @strCreditMemoNumber = ''
				SELECT TOP 1
					@strCreditMemoNumber = B.strInvoiceNumber
				FROM tblARInvoiceDetail A
				INNER JOIN 	tblARInvoice B
					ON A.intInvoiceId = B.intInvoiceId
				WHERE A.intOriginalInvoiceDetailId IN (SELECT intInvoiceDetailId FROM #tmpSCInvoiceDetail)

				IF(ISNULL(@strCreditMemoNumber,'') <> '')
				BEGIN
					SET @ErrorMessage = 'Credit memo ''' + @strCreditMemoNumber +''' already been created.';
					RAISERROR(@ErrorMessage, 11, 1);
					GOTO _Exit
				END
			
		END



		-- get the invoice detail for the ticket 
		INSERT INTO #tmpSCInvoiceDetail(
			ysnPosted
			,intInvoiceId
			,intInvoiceDetailId
		)
		SELECT 
			A.ysnPosted
			,A.intInvoiceId
			,B.intInvoiceDetailId
		FROM tblARInvoiceDetail B
		INNER JOIN tblARInvoice A
			ON A.intInvoiceId = B.intInvoiceId
		WHERE intTicketId = @intTicketId
			AND A.strTransactionType = 'Invoice'
			AND ISNULL(B.intOriginalInvoiceDetailId,0) = 0
			AND NOT EXISTS(SELECT TOP 1 1 
							FROM tblARInvoiceDetail 
							WHERE ISNULL(intOriginalInvoiceDetailId,0) = B.intInvoiceDetailId)
	END
	

	SELECT TOP 1 
		@_intInvoiceId = MIN (intInvoiceId) 
		,@ysnPost = ysnPosted
	FROM #tmpSCInvoiceDetail
	GROUP BY intInvoiceId,ysnPosted

	WHILE (ISNULL(@_intInvoiceId,0) > 0)
	BEGIN
		IF(ISNULL(@ysnPost,0) = 0)
		BEGIN
		
			---Check if there are multiple IS on the invoice.
			IF (SELECT TOP 1 COUNT(DISTINCT ISNULL(strDocumentNumber,''))
				FROM tblARInvoiceDetail
				WHERE intInvoiceId = @_intInvoiceId) > 1
			BEGIN
				--Delete invoice details
				BEGIN 
					SET @_intInvoiceDetail = 0
					SELECT TOP 1
						@_intInvoiceDetail = MIN(intInvoiceDetailId)
					FROM #tmpSCInvoiceDetail
					WHERE intInvoiceId = @_intInvoiceId

					---loop and delete invoice detail from invoice
					WHILE ISNULL(@_intInvoiceDetail,0) > 0
					BEGIN
						--Delete
						EXEC uspARDeleteInvoice @_intInvoiceId, @intUserId, @_intInvoiceDetail

						--------Loop Iterator
						BEGIN
							IF(EXISTS(SELECT TOP 1 1 FROM #tmpSCInvoiceDetail WHERE intInvoiceDetailId > @_intInvoiceDetail))
							BEGIN
								SELECT TOP 1
									@_intInvoiceDetail = MIN(intInvoiceDetailId)
								FROM #tmpSCInvoiceDetail
								WHERE intInvoiceDetailId > @_intInvoiceDetail
									AND intInvoiceId = @_intInvoiceId
							END
							ELSE
							BEGIN
								SET @_intInvoiceDetail = 0
							END
						END

					END
				END
			
				EXEC dbo.uspARUpdateInvoiceIntegrations @_intInvoiceId, 0, @intUserId
				EXEC dbo.uspARReComputeInvoiceTaxes @_intInvoiceId
				
			END
			ELSE
			BEGIN
				EXEC [dbo].[uspARDeleteInvoice] @_intInvoiceId, @intUserId
			END

			
		END
		ELSE
		BEGIN
			---Create credit memo
			BEGIN
				---Check if there are multiple IS on the invoice.
				IF (SELECT TOP 1 COUNT(DISTINCT ISNULL(strDocumentNumber,''))
					FROM tblARInvoiceDetail
					WHERE intInvoiceId = @_intInvoiceId) > 1
				BEGIN
					--reverse invoice details
					BEGIN 
						SET @_intInvoiceDetail = 0
						SELECT TOP 1
							@_intInvoiceDetail = MIN(intInvoiceDetailId)
						FROM #tmpSCInvoiceDetail
						WHERE intInvoiceId = @_intInvoiceId

						SET @strInvoiceDetailIds = (SELECT STUFF((SELECT ',' + CAST(intInvoiceDetailId AS NVARCHAR)
																	FROM #tmpSCInvoiceDetail
																	WHERE intInvoiceId = @_intInvoiceId
																	FOR XML PATH('')),1,1,''))

						EXEC uspARReturnInvoice @_intInvoiceId, @intUserId,@strInvoiceDetailIds, 1,  @intNewInvoiceId OUTPUT, NULL, 1	
					END
				END
				ELSE
				BEGIN
					EXEC uspARReturnInvoice @_intInvoiceId, @intUserId,null,1,@intNewInvoiceId	OUTPUT, NULL, 1	
				END
			END

			--Post credit memo and audit log entry
			IF(ISNULL(@intNewInvoiceId,0) > 0)
			BEGIN
				SELECT TOP 1
					@strNewInvoiceNumber = strInvoiceNumber
				FROM tblARInvoice
				WHERE intInvoiceId = @intNewInvoiceId

				EXEC [dbo].[uspARPostInvoice]
						@batchId			= NULL,
						@post				= 1,
						@recap				= 0,
						@param				= @intNewInvoiceId,
						@userId				= @intUserId,
						@beginDate			= NULL,
						@endDate			= NULL,
						@beginTransaction	= NULL,
						@endTransaction		= NULL,
						@exclude			= NULL,
						@successfulCount	= @successfulCount OUTPUT,
						@invalidCount		= @invalidCount OUTPUT,
						@success			= @success OUTPUT,
						@batchIdUsed		= @batchIdUsed OUTPUT,
						@recapId			= @recapId OUTPUT,
						@transType			= N'all',
						@accrueLicense		= 0,
						@raiseError			= 1

				-- Audit log Entry
				
					EXEC dbo.uspSMAuditLog 
						@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
						,@screenName		= 'Grain.view.Scale'				-- Screen Namespace
						,@entityId			= @intUserId						-- Entity Id.
						,@actionType		= 'Updated'							-- Action Type
						,@changeDescription	= 'Credit Memo' 				-- Description
						,@fromValue			= ''								-- Old Value
						,@toValue			= @strNewInvoiceNumber								-- New Value
						,@details			= '';
			END
		END

		
		--Loop Iterator
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM #tmpSCInvoiceDetail WHERE intInvoiceId > @_intInvoiceId)
			BEGIN
				SELECT TOP 1 
					@_intInvoiceId = MIN (intInvoiceId) 
					,@ysnPost = ysnPosted
				FROM #tmpSCInvoiceDetail
				WHERE intInvoiceId > @_intInvoiceId
				GROUP BY intInvoiceId,ysnPosted
			END
			ELSE
			BEGIN
				SET @_intInvoiceId = 0
			END
		END
		
	END

	_Exit:

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH


