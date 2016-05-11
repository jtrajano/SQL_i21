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

	IF (@ForDelete = 1)
	BEGIN

		-- Delete Receipts associated to this deleted Transport Load
		INSERT INTO @tblToProcess(intTransactionId, strTransactionType, intActivity, dblQuantity)

		SELECT DISTINCT intSourceId
			, @SourceType_InventoryReceipt
			, 3 -- Delete
			, 0.00
		FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_InventoryReceipt

		UNION ALL

		-- Delete Transfers associated to this deleted Transport Load
		SELECT DISTINCT intSourceId
			, @SourceType_InventoryTransfer 
			, 3 -- Delete
			, 0.00
		FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_InventoryTransfer

		UNION ALL
		-- Delete Invoices associated to this deleted Transport Load
		SELECT DISTINCT intSourceId
			, @SourceType_Invoice 
			, 3 -- Delete
			, 0.00
		FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_Invoice
			
	END
	ELSE
	BEGIN

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
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
			LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = LR.intInventoryReceiptId
			LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = LR.intSupplyPointId
		WHERE LH.intLoadHeaderId = @LoadHeaderId
			AND ISNULL(LR.intInventoryReceiptId, '') <> ''
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
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
			LEFT JOIN tblICInventoryTransfer IT ON IT.intInventoryTransferId = LR.intInventoryTransferId
			LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = LR.intSupplyPointId
		WHERE LH.intLoadHeaderId = @LoadHeaderId
			AND ISNULL(LR.intInventoryTransferId, '') <> ''
		UNION ALL
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = @LoadHeaderId
			, intTransactionDetailId = DH.intLoadDistributionHeaderId
			, strSourceType = @SourceType_Invoice
			, intSourceId = DH.intInvoiceId
			, dblQuantity = DD.dblUnits
			, intItemId = NULL
			, intItemUOMId = NULL
			, DD.intContractDetailId
		FROM tblTRLoadDistributionHeader DH
			LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
		WHERE DH.intLoadHeaderId = @LoadHeaderId
			AND ISNULL(DH.intInvoiceId, '') <> ''

		-- Check and Delete Deleted Inventory Receipt line items
		INSERT INTO @tblToProcess(intTransactionId, strTransactionType, intActivity, dblQuantity, intContractDetailId)

		SELECT DISTINCT previousSnapshot.intSourceId
			, @SourceType_InventoryReceipt
			, 3 -- Delete
			, previousSnapshot.dblQuantity * -1
			, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_InventoryReceipt
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInventoryReceiptId
													FROM tblTRLoadReceipt 
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInventoryReceiptId, '') <> '')

		UNION ALL

		-- Check and Delete Deleted Inventory Transfer line items
		SELECT DISTINCT previousSnapshot.intSourceId
			, @SourceType_InventoryTransfer
			, 3 -- Delete
			, previousSnapshot.dblQuantity * -1
			, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_InventoryTransfer
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInventoryTransferId
													FROM tblTRLoadReceipt 
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInventoryTransferId, '') <> '')

		UNION ALL

		-- Check and Delete Deleted Invoice line items
		SELECT DISTINCT previousSnapshot.intSourceId
			, @SourceType_Invoice
			, 3 -- Delete
			, previousSnapshot.dblQuantity * -1
			, previousSnapshot.intContractDetailId
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_Invoice
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInvoiceId
													FROM tblTRLoadDistributionHeader
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInvoiceId, '') <> '')
		
		UNION ALL 

		-- Check Added Receipts
		SELECT currentSnapshot.intSourceId
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
		SELECT currentSnapshot.intSourceId
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
		SELECT currentSnapshot.intSourceId
			, currentSnapshot.strSourceType
			, 1 --Add
			, currentSnapshot.dblQuantity
			, currentSnapshot.intContractDetailId
		FROM @tmpCurrentSnapshot currentSnapshot
		WHERE currentSnapshot.strSourceType = @SourceType_Invoice
			AND currentSnapshot.intTransactionDetailId NOT IN (SELECT intTransactionDetailId FROM #tmpPreviousSnapshot
																WHERE strSourceType = @SourceType_Invoice)
        
        
      --  foreach (var loadHeader in loadHeaders)
      --  {
            
      --      foreach (var receipt in receitps)
      --      {
      --          
      --          else
      --          {
      --              var oldreceipt = oldLoadHeader.tblTRLoadReceipts.Where(x => x.intLoadReceiptId == receipt.intLoadReceiptId).FirstOrDefault();
      --              decimal? dblOldQuantity = 0;
      --              decimal? dblNewQuantity = 0;
      --              if (receipt.strGrossOrNet == "Gross")
      --              {
      --                  dblOldQuantity = oldreceipt.dblGross * -1;
      --              }
      --              else
      --              {
      --                  dblOldQuantity = oldreceipt.dblNet * -1;
      --              }

      --              if (receipt.strGrossOrNet == "Gross")
      --              {
      --                  dblNewQuantity = receipt.dblGross;
      --              }
      --              else
      --              {
      --                  dblNewQuantity = receipt.dblNet;
      --              }

      --              if (Math.Abs(dblOldQuantity ?? 0) != Math.Abs(dblNewQuantity ?? 0))
      --              {
      --                  if (oldreceipt.intContractDetailId != null)
      --                  {
      --                      EXEC uspCTUpdateScheduleQuantity @intContractDetailId =  oldreceipt.intContractDetailId 
						--	, @dblQuantityToUpdate= dblOldQuantity 
						--	, @intUserId= userId 
						--	, @intExternalId= receipt.intLoadReceiptId 
						--	, @strScreenName= "Transport Purchase"

      --                  }
      --                  if (receipt.intContractDetailId != null)
      --                  {
      --                      EXEC uspCTUpdateScheduleQuantity @intContractDetailId =  receipt.intContractDetailId 
						--	, @dblQuantityToUpdate= dblNewQuantity 
						--	, @intUserId= userId 
						--	, @intExternalId= receipt.intLoadReceiptId 
						--	, @strScreenName= "Transport Purchase"

      --                  }
      --              }
      --          }
      --      }
      --      var distibutionHeaders = loadHeader.tblTRLoadDistributionHeaders;
      --      foreach (var distibutionHeader in distibutionHeaders)
      --      {
      --          var distibutionDetails = distibutionHeader.tblTRLoadDistributionDetails;
      --          foreach (var distibutionDetail in distibutionDetails)
      --          {
      --              
      --              {
      --                  var olddistribuitonHeader = oldLoadHeader.tblTRLoadDistributionHeaders.Where(x => x.intLoadDistributionHeaderId == distibutionDetail.intLoadDistributionHeaderId).FirstOrDefault();
      --                  var olddistribuitonDetail = olddistribuitonHeader.tblTRLoadDistributionDetails.Where(x => x.intLoadDistributionDetailId == distibutionDetail.intLoadDistributionDetailId).FirstOrDefault();
      --                  decimal? dblOldQuantity = olddistribuitonDetail.dblUnits;
      --                  decimal? dblNewQuantity = 0;
      --                  dblOldQuantity = dblOldQuantity * -1;

      --                  dblNewQuantity = distibutionDetail.dblUnits;

      --                  if (Math.Abs(dblOldQuantity ?? 0) != Math.Abs(dblNewQuantity ?? 0))
      --                  {
      --                      if (olddistribuitonDetail.intContractDetailId != null)
      --                      {
      --                          EXEC uspCTUpdateScheduleQuantity @intContractDetailId = olddistribuitonDetail.intContractDetailId 
						--		, @dblQuantityToUpdate= dblOldQuantity 
						--		, @intUserId= userId 
						--		, @intExternalId= distibutionDetail.intLoadDistributionDetailId 
						--		, @strScreenName= "Transport Sale"

      --                      }
      --                      if (distibutionDetail.intContractDetailId != null)
      --                      {
      --                          EXEC uspCTUpdateScheduleQuantity @intContractDetailId = distibutionDetail.intContractDetailId 
						--		, @dblQuantityToUpdate= dblNewQuantity 
						--		, @intUserId= userId 
						--		, @intExternalId= distibutionDetail.intLoadDistributionDetailId 
						--		, @strScreenName= "Transport Sale"

      --                      }
      --                  }

      --              }
      --          }

      --      }

	END

	-- Iterate and process records
	DECLARE @Id					INT = NULL
		, @intTransactionId		INT = NULL
		, @strTransactionType	NVARCHAR(50)
		, @intActivity			INT
		, @dblQuantity			NUMERIC(18, 6)
		, @intContractDetailId	INT
		, @strScreenName		NVARCHAR(50)

	WHILE EXISTS(SELECT TOP 1 1 FROM @tblToProcess)
	BEGIN
		SELECT TOP 1  @Id		=	intKeyId
			, @intTransactionId =	intTransactionId
			, @strTransactionType = strTransactionType
			, @intActivity = intActivity
			, @dblQuantity = dblQuantity
			, @intContractDetailId = intContractDetailId
		FROM	@tblToProcess 

		IF (@intActivity = 1)
		BEGIN
			IF (@strTransactionType = @SourceType_InventoryReceipt OR @strTransactionType = @SourceType_InventoryTransfer)
				SET @strScreenName = 'Transport Purchase'
			ELSE IF (@strTransactionType = @SourceType_Invoice)
				SET @strScreenName = 'Transport Sale'

			IF (@intContractDetailId != NULL)
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId 
					, @dblQuantityToUpdate = @dblQuantity 
					, @intUserId = @UserId 
					, @intExternalId = @intTransactionId 
					, @strScreenName = 'Transport Purchase'
			END
		END
		--ELSE IF (@intActivity = 2)
		--BEGIN
			
		--END
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

			IF (@intContractDetailId != NULL)
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

	--UPDATE tblLGLoad
	--SET intLoadHeaderId = NULL
	--WHERE intLoadHeaderId = @LoadHeaderId

END