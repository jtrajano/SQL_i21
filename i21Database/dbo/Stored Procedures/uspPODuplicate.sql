﻿CREATE PROCEDURE [dbo].[uspPODuplicate]
	@poId int,
	@userId int,
	@poIdCreated int OUTPUT,
	@intDuplicateType int
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @transCount int = @@TRANCOUNT;
	DECLARE @newPOId INT;

	IF @transCount = 0
	BEGIN TRANSACTION

		DECLARE @generatedPurchaseRecordId nvarchar(50);
		DECLARE @startingNumId int = (SELECT TOP 1
			intStartingNumberId
		FROM tblSMStartingNumber
		WHERE strTransactionType = 'Purchase Order')
		EXEC uspSMGetStartingNumber @startingNumId,
									@generatedPurchaseRecordId OUT

		IF OBJECT_ID('tempdb..#tmpDuplicatePO') IS NOT NULL
			DROP TABLE #tmpDuplicatePO

		SELECT
			* INTO #tmpDuplicatePO
		FROM tblPOPurchase
		WHERE intPurchaseId = @poId
		ALTER TABLE #tmpDuplicatePO DROP COLUMN intPurchaseId

		UPDATE A
		SET intOrderStatusId = 1,
			strPurchaseOrderNumber = @generatedPurchaseRecordId,
			intEntityId = @userId,
			strReference = A.strReference + ' Duplicate of ' + A.strPurchaseOrderNumber,
			ysnApproved = 0
			--,ysnForApproval = CASE WHEN A.ysnForApprovalSubmitted = 1 OR dtmApprovalDate IS NOT NULL THEN 1 ELSE 0 END
			,
			A.ysnForApprovalSubmitted = 0,
			dtmApprovalDate = NULL
		FROM #tmpDuplicatePO A

		INSERT INTO tblPOPurchase
			SELECT *
			FROM #tmpDuplicatePO

		SET @newPOId = SCOPE_IDENTITY();

		IF @intDuplicateType = 2 OR @intDuplicateType = 3
		BEGIN
			--DUPLICATE tblAPBillDetail
			IF OBJECT_ID('tempdb..#tmpDuplicatePurchaseDetail') IS NOT NULL
				DROP TABLE #tmpDuplicatePurchaseDetail

			DECLARE @purchaseDetailTaxes TABLE (
				intCreatedPurchaseDetailId int,
				originalPurchaseDetailId int
			)
			
			SELECT A.* 
			INTO #tmpDuplicatePurchaseDetail
			FROM tblPOPurchaseDetail A
			INNER JOIN tblPOPurchase A2
				ON A.intPurchaseId = A2.intPurchaseId
			LEFT JOIN tblCTContractDetail B
				ON A.intContractDetailId = B.intContractDetailId
			WHERE A.intPurchaseId = @poId
				AND 1 = (CASE
							WHEN A2.intOrderStatusId NOT IN (4, 6) --Make sure PO is not short closed or cancelled if it is contract
								AND B.intContractDetailId IS NOT NULL AND
							((B.dblBalance - B.dblScheduleQty) <= 0)
							THEN 0
							ELSE 1
						END) --Exclude the contract if no available balance

			--ALTER TABLE #tmpDuplicateBillDetail DROP COLUMN intBillDetailId

			UPDATE A
			SET A.intPurchaseId = @newPOId,
				A.dblQtyReceived = 0,
				A.dblQtyOrdered =	(CASE
										WHEN @intDuplicateType = 2 
											THEN 0
										WHEN @intDuplicateType = 3 AND B.intContractDetailId IS NOT NULL AND ((B.dblBalance - B.dblScheduleQty) < A.dblQtyOrdered)
											THEN (B.dblBalance - B.dblScheduleQty)
										ELSE A.dblQtyOrdered
									END),
				A.dblTotal =(CASE
								WHEN @intDuplicateType = 2 
									THEN 0
								WHEN @intDuplicateType = 3 AND B.intContractDetailId IS NOT NULL AND ((B.dblBalance - B.dblScheduleQty) < A.dblQtyOrdered)
									THEN ((B.dblBalance - B.dblScheduleQty) * A.dblCost)
								ELSE A.dblTotal
							END)
			FROM #tmpDuplicatePurchaseDetail A
			LEFT JOIN tblCTContractDetail B
				ON A.intContractDetailId = B.intContractDetailId
			MERGE INTO tblPOPurchaseDetail
			USING #tmpDuplicatePurchaseDetail A
			ON 1 = 0
			WHEN NOT MATCHED THEN
			INSERT (
			[intPurchaseId],
			[intItemId],
			[intUnitOfMeasureId],
			[intAccountId],
			[intStorageLocationId],
			[intSubLocationId],
			[intLocationId],
			[intContractDetailId],
			[intContractHeaderId],
			[intTaxGroupId],
			[dblQtyOrdered],
			[dblQtyContract],
			[dblQtyReceived],
			[dblVolume],
			[dblWeight],
			[dblDiscount],
			[dblCost],
			[dblTotal],
			[dblTax],
			[strMiscDescription],
			[strPONumber],
			[dtmExpectedDate],
			[intLineNo],
			[intConcurrencyId]
			)
			VALUES
			(
			[intPurchaseId],
			[intItemId],
			[intUnitOfMeasureId],
			[intAccountId],
			[intStorageLocationId],
			[intSubLocationId],
			[intLocationId],
			[intContractDetailId],
			[intContractHeaderId],
			[intTaxGroupId],
			[dblQtyOrdered],
			[dblQtyContract],
			[dblQtyReceived],
			[dblVolume],
			[dblWeight],
			[dblDiscount],
			[dblCost],
			[dblTotal],
			[dblTax],
			[strMiscDescription],
			[strPONumber],
			[dtmExpectedDate],
			[intLineNo],
			[intConcurrencyId]
			)
			OUTPUT INSERTED.intPurchaseDetailId, A.intPurchaseDetailId INTO @purchaseDetailTaxes (intCreatedPurchaseDetailId, originalPurchaseDetailId); --get the new and old purchase detail id

			IF OBJECT_ID('tempdb..#tmpDuplicatePurchaseDetailTaxes') IS NOT NULL
				DROP TABLE #tmpDuplicatePurchaseDetailTaxes

			SELECT A.* 
			INTO #tmpDuplicatePurchaseDetailTaxes
			FROM tblPOPurchaseDetailTax A
			INNER JOIN tblPOPurchaseDetail B
				ON A.intPurchaseDetailId = B.intPurchaseDetailId
			WHERE B.intPurchaseId = @poId

			ALTER TABLE #tmpDuplicatePurchaseDetailTaxes DROP COLUMN intPurchaseDetailTaxId

			UPDATE A
			SET A.intPurchaseDetailId = B.intCreatedPurchaseDetailId
			FROM #tmpDuplicatePurchaseDetailTaxes A
			INNER JOIN @purchaseDetailTaxes B
				ON A.intPurchaseDetailId = B.originalPurchaseDetailId

			INSERT INTO tblPOPurchaseDetailTax
				SELECT *
				FROM #tmpDuplicatePurchaseDetailTaxes

			--UPDATE CONTRACT
			CREATE TABLE #poContractDetails (
				intContractDetailId int,
				intPurchaseDetailId int,
				dblQtyOrdered numeric(18, 6)
			);

			INSERT INTO #poContractDetails
				SELECT
					intContractDetailId,
					intPurchaseDetailId,
					dblQtyOrdered
				FROM #tmpDuplicatePurchaseDetail
				WHERE intContractDetailId IS NOT NULL

			WHILE EXISTS (SELECT
				1
				FROM #poContractDetails)
			BEGIN
				DECLARE @contractDetailId int;
				DECLARE @purchaseDetailId int;
				DECLARE @qty numeric(18, 6);
				SELECT TOP 1
					@contractDetailId = intContractDetailId,
					@purchaseDetailId = intPurchaseDetailId,
					@qty = dblQtyOrdered
				FROM #poContractDetails;

				IF (@contractDetailId IS NOT NULL
					AND @contractDetailId > 0)
				EXEC uspCTUpdateScheduleQuantity	@contractDetailId,
													@qty,
													@userId,
													@purchaseDetailId,
													'Purchase Order'

				DELETE FROM #poContractDetails
				WHERE intPurchaseDetailId = @purchaseDetailId
			END

			EXEC uspPOUpdateOnOrder @newPOId,
									0
		END

		SET @poIdCreated = @newPOId;
		DECLARE @poDetailsId AS Id
		INSERT INTO @poDetailsId
		SELECT
			A.intPurchaseDetailId
		FROM tblPOPurchaseDetail A
		WHERE A.intPurchaseId = @newPOId;
		IF EXISTS(SELECT 1 FROM @poDetailsId)
		BEGIN
			EXEC uspPOUpdateVoucherPayable @poDetailIds = @poDetailsId
		END
	
		IF @transCount = 0
		COMMIT TRANSACTION

END TRY

BEGIN CATCH
	DECLARE @ErrorSeverity int,
			@ErrorNumber int,
			@ErrorMessage nvarchar(4000),
			@ErrorState int,
			@ErrorLine int,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber = ERROR_NUMBER()
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @ErrorState = ERROR_STATE()
	SET @ErrorLine = ERROR_LINE()
	SET @ErrorProc = ERROR_PROCEDURE()
	SET @ErrorMessage = 'Problem duplicating po.' + CHAR(13) +
	'SQL Server Error Message is: ' + CAST(@ErrorNumber AS varchar(10)) +
	' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS varchar(10)) + ' Error text: ' + @ErrorMessage
	-- Not all errors generate an error state, to set to 1 if it's zero
	IF @ErrorState = 0
		SET @ErrorState = 1
	-- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
	IF @transCount = 0
		AND XACT_STATE() <> 0
		ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH