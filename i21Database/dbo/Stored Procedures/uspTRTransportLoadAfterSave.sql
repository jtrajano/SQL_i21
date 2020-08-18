CREATE PROCEDURE [dbo].[uspTRTransportLoadAfterSave]
	@LoadHeaderId INT,
	@ForDelete BIT = 0,
	@UserId INT = NULL

AS

	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT ON  
	SET ANSI_WARNINGS OFF  

BEGIN

	DECLARE @TransactionType_TransportLoad NVARCHAR(50) = 'Transport Load'

	DECLARE @SourceType_InventoryReceipt NVARCHAR(50) = 'Inventory Receipt'
	DECLARE @SourceType_InventoryTransfer NVARCHAR(50) = 'Inventory Transfer'
	DECLARE @SourceType_Invoice NVARCHAR(50) = 'Invoice'

	DECLARE @tblToProcess TABLE
			(
				intKeyId				INT IDENTITY
				, intLoadHeaderId		INT
				, intTransactionId		INT
				, strTransactionType	NVARCHAR(50)
				, intActivity			INT
				, dblQuantity			NUMERIC(18,6)
				, intContractDetailId	INT
			)

	DECLARE @tmpCurrentSnapshot TABLE
	(
		[intTransactionDetailLogId] INT NOT NULL IDENTITY, 
		[strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionId] INT NOT NULL, 
		[intTransactionDetailId] INT NOT NULL, 
		[strSourceType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intSourceId] INT NULL, 
		[dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intItemId] INT NULL,
		[intItemUOMId] INT NULL,
		[intContractDetailId] INT NULL
	)

	-- Create snapshot of Transport Loads before Save
	SELECT strTransactionType
		, intTransactionId
		, intTransactionDetailId
		, strSourceType
		, intSourceId
		, dblQuantity
		, intItemId
		, intItemUOMId
		, intContractDetailId
	INTO #tmpPreviousSnapshot
	FROM tblTRTransactionDetailLog
	WHERE intTransactionId = @LoadHeaderId
		AND strTransactionType = @TransactionType_TransportLoad

	IF (@ForDelete = 1)
	BEGIN

		INSERT INTO @tblToProcess(intLoadHeaderId, intTransactionId, strTransactionType, intActivity, dblQuantity, intContractDetailId)
		-- Add another row if delete the TR
		SELECT previousSnapshot.intTransactionId
			, previousSnapshot.intTransactionDetailId
			, previousSnapshot.strSourceType
			, 2 --Update
			, previousSnapshot.dblQuantity * -1 
			, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		
		-- Delete Receipts associated to this deleted Transport Load
		INSERT INTO @tblToProcess(intLoadHeaderId, intTransactionId, strTransactionType, intActivity, dblQuantity)

		SELECT DISTINCT intTransactionId
			, intSourceId
			, @SourceType_InventoryReceipt
			, 3 -- Delete
			, 0.00
		FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_InventoryReceipt
			AND intSourceId IS NOT NULL

		UNION ALL

		-- Delete Transfers associated to this deleted Transport Load
		SELECT DISTINCT intTransactionId
			, intSourceId
			, @SourceType_InventoryTransfer 
			, 3 -- Delete
			, 0.00
		FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_InventoryTransfer
			AND intSourceId IS NOT NULL

		UNION ALL
		-- Delete Invoices associated to this deleted Transport Load
		SELECT DISTINCT intTransactionId
			, intSourceId
			, @SourceType_Invoice 
			, 3 -- Delete
			, 0.00
		FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_Invoice
			AND intSourceId IS NOT NULL

	END
	ELSE
	BEGIN

		-- Create snapshot of Transport Loads after Save
		INSERT INTO @tmpCurrentSnapshot(
			strTransactionType
			, intTransactionId
			, intTransactionDetailId
			, strSourceType
			, intSourceId
			, dblQuantity
			, intItemId
			, intItemUOMId
			, intContractDetailId)
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = @LoadHeaderId
			, intTransactionDetailId = LR.intLoadReceiptId
			, strSourceType = @SourceType_InventoryReceipt
			, intSourceId = LR.intInventoryReceiptId
			, dblQuantity = CASE WHEN (SP.strGrossOrNet = 'Gross') THEN LR.dblGross ELSE LR.dblNet END
			, intItemId = LR.intItemId
			, intItemUOMId = NULL
			, LR.intContractDetailId
		FROM tblTRLoadReceipt LR
			LEFT JOIN tblICItem IC ON IC.intItemId = LR.intItemId
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
			LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = LR.intInventoryReceiptId
			LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = LR.intSupplyPointId
		WHERE LH.intLoadHeaderId = @LoadHeaderId
			AND LR.strOrigin = 'Terminal'
			AND IC.strType != 'Non-Inventory'
		UNION ALL
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = @LoadHeaderId
			, intTransactionDetailId = LR.intLoadReceiptId
			, strSourceType = @SourceType_InventoryTransfer
			, intSourceId = LR.intInventoryTransferId
			, dblQuantity = CASE WHEN (SP.strGrossOrNet = 'Gross') THEN LR.dblGross ELSE LR.dblNet END
			, intItemId = LR.intItemId
			, intItemUOMId = NULL
			, LR.intContractDetailId
		FROM tblTRLoadReceipt LR
			LEFT JOIN tblICItem IC ON IC.intItemId = LR.intItemId
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
			LEFT JOIN tblICInventoryTransfer IT ON IT.intInventoryTransferId = LR.intInventoryTransferId
			LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = LR.intSupplyPointId
			LEFT JOIN tblTRLoadDistributionHeader DH ON LH.intLoadHeaderId = DH.intLoadHeaderId		
			LEFT JOIN tblTRLoadDistributionDetail DD ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId		
		WHERE LH.intLoadHeaderId = @LoadHeaderId
			AND IC.strType != 'Non-Inventory' 
			AND ((LR.strOrigin = 'Location' AND DH.strDestination = 'Location') 
				OR (LR.strOrigin = 'Terminal' AND DH.strDestination = 'Location' AND LR.intCompanyLocationId != DH.intCompanyLocationId)
				OR (LR.strOrigin = 'Location' AND DH.strDestination = 'Customer' AND LR.intCompanyLocationId != DH.intCompanyLocationId)
				OR (LR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' AND LR.intCompanyLocationId != DH.intCompanyLocationId AND (ISNULL(LR.dblUnitCost, 0) <> 0 OR ISNULL(LR.dblFreightRate, 0) <> 0 OR ISNULL(LR.dblPurSurcharge, 0) <> 0)))
		UNION ALL
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = @LoadHeaderId
			, intTransactionDetailId = DD.intLoadDistributionDetailId
			, strSourceType = @SourceType_Invoice
			, intSourceId = DH.intInvoiceId
			, dblQuantity = DD.dblUnits
			, intItemId = NULL
			, intItemUOMId = NULL
			, DD.intContractDetailId
		FROM tblTRLoadDistributionHeader DH
			LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
		WHERE DH.intLoadHeaderId = @LoadHeaderId
			AND DH.strDestination = 'Customer'
			AND ISNULL(DD.intLoadDistributionDetailId, '') <> ''

		-- Check and Delete Deleted Inventory Receipt line items
		INSERT INTO @tblToProcess(intLoadHeaderId, intTransactionId, strTransactionType, intActivity, dblQuantity, intContractDetailId)

		SELECT DISTINCT previousSnapshot.intTransactionId
			, previousSnapshot.intSourceId
			, @SourceType_InventoryReceipt
			, 3 -- Delete
			, previousSnapshot.dblQuantity * -1
			, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_InventoryReceipt
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND ISNULL(previousSnapshot.intSourceId, '') <> ''
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInventoryReceiptId
													FROM tblTRLoadReceipt 
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInventoryReceiptId, '') <> '')

		UNION ALL

		-- Check and Delete Deleted Inventory Transfer line items
		SELECT DISTINCT previousSnapshot.intTransactionId
			, previousSnapshot.intSourceId
			, @SourceType_InventoryTransfer
			, 3 -- Delete
			, previousSnapshot.dblQuantity * -1
			, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_InventoryTransfer
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND ISNULL(previousSnapshot.intSourceId, '') <> ''
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInventoryTransferId
													FROM tblTRLoadReceipt 
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInventoryTransferId, '') <> '')

		UNION ALL

		-- Check and Delete Deleted Invoice line items
		SELECT DISTINCT previousSnapshot.intTransactionId
			, previousSnapshot.intSourceId
			, @SourceType_Invoice
			, 3 -- Delete
			, previousSnapshot.dblQuantity * -1
			, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_Invoice
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND ISNULL(previousSnapshot.intSourceId, '') <> ''
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInvoiceId
													FROM tblTRLoadDistributionHeader
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInvoiceId, '') <> '')
		
		UNION ALL 

		-- Check Added Receipts
		SELECT currentSnapshot.intTransactionId
			, currentSnapshot.intTransactionDetailId
			, currentSnapshot.strSourceType
			, 1 --Add
			, currentSnapshot.dblQuantity
			, currentSnapshot.intContractDetailId
		FROM @tmpCurrentSnapshot currentSnapshot
		WHERE currentSnapshot.strSourceType = @SourceType_InventoryReceipt
			AND currentSnapshot.intTransactionDetailId NOT IN (SELECT intTransactionDetailId FROM #tmpPreviousSnapshot
																WHERE strSourceType = @SourceType_InventoryReceipt)
		
		UNION ALL 
		
		-- Check Added Transfers
		SELECT currentSnapshot.intTransactionId
			, currentSnapshot.intTransactionDetailId
			, currentSnapshot.strSourceType
			, 1 --Add
			, currentSnapshot.dblQuantity
			, currentSnapshot.intContractDetailId
		FROM @tmpCurrentSnapshot currentSnapshot
		WHERE currentSnapshot.strSourceType = @SourceType_InventoryTransfer
			AND currentSnapshot.intTransactionDetailId NOT IN (SELECT intTransactionDetailId FROM #tmpPreviousSnapshot
																WHERE strSourceType = @SourceType_InventoryTransfer)

		UNION ALL 
		
		-- Check Added Invoices
		SELECT currentSnapshot.intTransactionId
			, currentSnapshot.intTransactionDetailId
			, currentSnapshot.strSourceType
			, 1 --Add
			, currentSnapshot.dblQuantity
			, currentSnapshot.intContractDetailId
		FROM @tmpCurrentSnapshot currentSnapshot
		WHERE currentSnapshot.strSourceType = @SourceType_Invoice
			AND currentSnapshot.intTransactionDetailId NOT IN (SELECT intTransactionDetailId FROM #tmpPreviousSnapshot
																WHERE strSourceType = @SourceType_Invoice)
        
        UNION ALL

		-- Add another row if there was a change on Contract Detail Id used, for the old Contract Detail Id
		SELECT previousSnapshot.intTransactionId
			, previousSnapshot.intTransactionDetailId
			, previousSnapshot.strSourceType
			, 2 --Update
			, previousSnapshot.dblQuantity * -1 
			, previousSnapshot.intContractDetailId
		FROM @tmpCurrentSnapshot currentSnapshot
		INNER JOIN #tmpPreviousSnapshot previousSnapshot
			ON previousSnapshot.intTransactionDetailId = currentSnapshot.intTransactionDetailId
		WHERE ISNULL(currentSnapshot.intContractDetailId, 0) != ISNULL(previousSnapshot.intContractDetailId, 0)

		UNION ALL

		-- Add another row if there was a change on Contract Detail Id used, for the new Contract Detail Id
		SELECT currentSnapshot.intTransactionId
			, currentSnapshot.intTransactionDetailId
			, currentSnapshot.strSourceType
			, 1 --Add
			, currentSnapshot.dblQuantity
			, currentSnapshot.intContractDetailId
		FROM @tmpCurrentSnapshot currentSnapshot
		INNER JOIN #tmpPreviousSnapshot previousSnapshot
			ON previousSnapshot.intTransactionDetailId = currentSnapshot.intTransactionDetailId
		WHERE ISNULL(currentSnapshot.intContractDetailId, 0) != ISNULL(previousSnapshot.intContractDetailId, 0)


		UNION ALL 

		-- Add another row if there was change on qty, for the old Contract Detail Id
		SELECT previousSnapshot.intTransactionId
			, previousSnapshot.intTransactionDetailId
			, previousSnapshot.strSourceType
			, 2 --Update
			, previousSnapshot.dblQuantity * -1 
			, previousSnapshot.intContractDetailId
		FROM @tmpCurrentSnapshot currentSnapshot
		INNER JOIN #tmpPreviousSnapshot previousSnapshot
			ON previousSnapshot.intTransactionDetailId = currentSnapshot.intTransactionDetailId
		WHERE ISNULL(currentSnapshot.intContractDetailId, 0) = ISNULL(previousSnapshot.intContractDetailId, 0) 
		AND ISNULL(currentSnapshot.dblQuantity, 0) != ISNULL(previousSnapshot.dblQuantity, 0)

		UNION ALL

		-- Add another row if there was a change on qty, for the new Contract Detail Id
		SELECT currentSnapshot.intTransactionId
			, currentSnapshot.intTransactionDetailId
			, currentSnapshot.strSourceType
			, 1 --Add
			, currentSnapshot.dblQuantity
			, currentSnapshot.intContractDetailId
		FROM @tmpCurrentSnapshot currentSnapshot
		INNER JOIN #tmpPreviousSnapshot previousSnapshot
			ON previousSnapshot.intTransactionDetailId = currentSnapshot.intTransactionDetailId
		WHERE ISNULL(currentSnapshot.intContractDetailId, 0) = ISNULL(previousSnapshot.intContractDetailId, 0) 
		AND ISNULL(currentSnapshot.dblQuantity, 0) != ISNULL(previousSnapshot.dblQuantity, 0)

		UNION ALL		
		-- Add row if the distribution is deleted
		SELECT previousSnapshot.intTransactionId
		 	, previousSnapshot.intTransactionDetailId
		 	, previousSnapshot.strSourceType
		 	, 2 -- UPDATE
		 	, previousSnapshot.dblQuantity * -1
		 	, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		LEFT JOIN @tmpCurrentSnapshot currentSnapshot ON previousSnapshot.intTransactionId = currentSnapshot.intTransactionId
			AND previousSnapshot.strSourceType = currentSnapshot.strSourceType
		WHERE currentSnapshot.intTransactionDetailLogId IS NULL
		AND previousSnapshot.dblQuantity > 0
		AND previousSnapshot.strSourceType = @SourceType_Invoice
		AND previousSnapshot.intContractDetailId IS NOT NULL

		UNION ALL
		-- Add row if the receipt is deleted
		SELECT previousSnapshot.intTransactionId
		 	, previousSnapshot.intTransactionDetailId
		 	, previousSnapshot.strSourceType
		 	, 2 -- UPDATE
		 	, previousSnapshot.dblQuantity * -1
		 	, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		LEFT JOIN @tmpCurrentSnapshot currentSnapshot ON previousSnapshot.intTransactionId = currentSnapshot.intTransactionId
			AND previousSnapshot.strSourceType = currentSnapshot.strSourceType
		WHERE currentSnapshot.intTransactionDetailLogId IS NULL
		AND previousSnapshot.dblQuantity > 0
		AND previousSnapshot.strSourceType = @SourceType_InventoryReceipt
		AND previousSnapshot.intContractDetailId IS NOT NULL


		-- Check first instance of Load Schedule processed load
		IF EXISTS(SELECT TOP 1 1 FROM tblTRLoadHeader WHERE intLoadHeaderId = @LoadHeaderId AND ISNULL(intLoadId, '') <> '' AND intConcurrencyId <= 1)
		BEGIN
			EXEC uspTRLoadProcessLogisticsLoad @LoadHeaderId, 'Added', @UserId
		END

		---- Add Blend Ingredients if needed
		--EXEC uspTRUpdateLoadBlendIngredient @LoadHeaderId

	END

	-- Iterate and process records
	DECLARE @Id					INT = NULL
		, @intLoadHeaderId		INT = NULL
		, @intTransactionId		INT = NULL
		, @strTransactionType	NVARCHAR(50)
		, @intActivity			INT
		, @dblQuantity			NUMERIC(18, 6)
		, @intContractDetailId	INT
		, @strScreenName		NVARCHAR(50)

	WHILE EXISTS(SELECT TOP 1 1 FROM @tblToProcess)
	BEGIN
		SELECT TOP 1  @Id		=	intKeyId
			, @intLoadHeaderId	=	intLoadHeaderId
			, @intTransactionId =	intTransactionId
			, @strTransactionType = strTransactionType
			, @intActivity = intActivity
			, @dblQuantity = dblQuantity
			, @intContractDetailId = intContractDetailId
		FROM	@tblToProcess 

		IF (@intActivity = 1 OR @intActivity = 2)
		BEGIN
			IF (@strTransactionType = @SourceType_InventoryReceipt OR @strTransactionType = @SourceType_InventoryTransfer)
				SET @strScreenName = 'Transport Purchase'
			ELSE IF (@strTransactionType = @SourceType_Invoice)
				SET @strScreenName = 'Transport Sale'

			IF ((ISNULL(@intContractDetailId, '') <> '') AND (@strTransactionType <> @SourceType_InventoryTransfer))
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId 
					, @dblQuantityToUpdate = @dblQuantity 
					, @intUserId = @UserId 
					, @intExternalId = @intTransactionId 
					, @strScreenName = @strScreenName
			END
		END
		ELSE IF (@intActivity = 3)
		BEGIN
			IF (@strTransactionType = @SourceType_InventoryReceipt)
			BEGIN
				UPDATE tblTRLoadReceipt
				SET intInventoryReceiptId = NULL
				WHERE intInventoryReceiptId = @intTransactionId

				EXEC uspICDeleteInventoryReceipt @intTransactionId, @UserId

				SET @strScreenName = 'Transport Purchase'
			END
			ELSE IF (@strTransactionType = @SourceType_InventoryTransfer)
			BEGIN
				UPDATE tblTRLoadReceipt
				SET intInventoryTransferId = NULL
				WHERE intInventoryTransferId = @intTransactionId

				EXEC uspICDeleteInventoryTransfer @intTransactionId, @UserId

				SET @strScreenName = 'Transport Purchase'
			END
			ELSE IF (@strTransactionType = @SourceType_Invoice)
			BEGIN
				UPDATE tblTRLoadDistributionHeader
				SET intInvoiceId = NULL
				WHERE intInvoiceId = @intTransactionId

				EXEC uspARDeleteInvoice @intTransactionId, @UserId

				SET @strScreenName = 'Transport Sale'
			END

			IF (ISNULL(@intContractDetailId, '') <> '')
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
					, @dblQuantityToUpdate = @dblQuantity
					, @intUserId = @UserId
					, @intExternalId = @intTransactionId
					, @strScreenName = @strScreenName
			END
		END		

		DELETE FROM @tblToProcess WHERE intKeyId = @Id
	END

	DELETE FROM tblTRTransactionDetailLog
	WHERE intTransactionId = @LoadHeaderId
		AND strTransactionType = @TransactionType_TransportLoad
END