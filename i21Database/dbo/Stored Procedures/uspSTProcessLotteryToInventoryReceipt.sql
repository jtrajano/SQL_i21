﻿CREATE PROCEDURE [dbo].[uspSTProcessLotteryToInventoryReceipt]
	@Id INT,
	@UserId INT,
	@ProcessType INT,
	@Success BIT OUTPUT,
	@StatusMsg NVARCHAR(1000) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @intEntityId int;




DECLARE  @tblSTTempLotteryProcessError TABLE (
    [intCheckoutId]				 INT            NULL,
    [strBookNumber]				 NVARCHAR(MAX)  NULL,
    [strGame]					 NVARCHAR(MAX)  NULL,
    [strError]					 NVARCHAR(MAX)  NULL,
    [strProcess]				 NVARCHAR(MAX)  NULL
);


BEGIN TRY

	--IF (@@TRANCOUNT > 0)
	--BEGIN 
		BEGIN TRANSACTION
	--END

	DECLARE @ReceiptStagingTable ReceiptStagingTable
		,@OtherCharges ReceiptOtherChargesTableType
		,@defaultCurrency INT
		,@strReceiptType NVARCHAR(500)
		,@strSourceScreenName NVARCHAR(500)

	DECLARE @receiptNumber NVARCHAR(100)
	DECLARE @receiveLotteryId INT
	DECLARE @inventoryReceiptid INT
	DECLARE @storeId INT
	DECLARE @checkoutId INT
	DECLARE @lotterySetupMode BIT
	DECLARE @lotteryGame NVARCHAR(MAX)
	DECLARE @lotteryBook NVARCHAR(MAX)
	
	
	SELECT TOP 1 @defaultCurrency = intDefaultCurrencyId
	FROM tblSMCompanyPreference
	WHERE intCompanyPreferenceId = 1


	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
	BEGIN 
		CREATE TABLE #tmpAddItemReceiptResult 
		(
			intSourceId INT,
			intInventoryReceiptId INT
		)
	END 

	--	Add = 1,
	--  Update = 2,
	--  Delete = 3,
	--  Post = 4,
	--  Return = 5,
	--  DeleteReturn = 6

	IF(@ProcessType = 1 OR @ProcessType = 2 )  --ADD OR UPDATE OR RETURN--
	BEGIN

		SELECT TOP 1  
		@receiveLotteryId =  intReceiveLotteryId,
		@inventoryReceiptid = intInventoryReceiptId,
		@storeId = intStoreId
		FROM tblSTReceiveLottery WHERE intReceiveLotteryId = @Id

		IF (ISNULL(@receiveLotteryId,0) = 0)
		BEGIN
			SET @Success = CAST(0 AS BIT)
			SET @StatusMsg = 'There are no records to process.'

			INSERT INTO @tblSTTempLotteryProcessError
			(
				 [intCheckoutId]
				,[strError]		
				,[strProcess]	
			)
			SELECT 
				 @UserId
				,'There are no records to process.'
				,(CASE WHEN @ProcessType = 1 THEN 'Create IR' ELSE 'Update IR' END)
			

			GOTO EXITWITHROLLBACK
			RETURN
		END

		SELECT TOP 1 @lotterySetupMode = ISNULL(ysnLotterySetupMode,0)
		FROM tblSTStore WHERE intStoreId = @storeId

		IF (ISNULL(@lotterySetupMode,0) = 1)
		BEGIN
			SET @Success = CAST(1 AS BIT)
			SET @StatusMsg = 'Lottery Setup Mode - No need to create IR.'

			INSERT INTO @tblSTTempLotteryProcessError
			(
				 [intCheckoutId]
				,[strError]			
				,[strProcess]	
			)
			SELECT 
			 @UserId
			,@StatusMsg
			,(CASE WHEN @ProcessType = 1 THEN 'Create IR' ELSE 'Update IR' END)

			GOTO EXITWITHROLLBACK
			RETURN
		END

		SET @strReceiptType = 'Direct'
		SET @strSourceScreenName = 'Lottery Module'

		-- Validate if there is Item UOM setup
		IF EXISTS(SELECT TOP 1 1 FROM tblSTReceiveLottery RL
			INNER JOIN tblSTStore S ON S.intStoreId = RL.intStoreId
			INNER JOIN tblSTLotteryGame LG ON LG.intLotteryGameId = RL.intLotteryGameId
			LEFT JOIN tblICItemLocation IL ON IL.intLocationId = S.intCompanyLocationId
				AND IL.intItemId = LG.intItemId
			LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = IL.intIssueUOMId
			WHERE RL.intReceiveLotteryId = @Id
			AND IU.intItemUOMId IS NULL)
		BEGIN
			SET @Success = CAST(0 AS BIT)
			SET @StatusMsg = 'Missing UOM setup on Item Location.'

			INSERT INTO @tblSTTempLotteryProcessError
			(
				 [intCheckoutId]
				,[strError]			
				,[strProcess]	
			)
			SELECT 
				@UserId
				,@StatusMsg
				,'Processing IR for receive lottery'

			GOTO EXITWITHROLLBACK
			RETURN
		END
	
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
		,strVendorRefNo			= (CAST(ISNULL(tblSTStore.intStoreNo,'') as nvarchar(100)) + '-' + ISNULL(tblSTLotteryGame.strGame,'') + ISNULL(tblSTReceiveLottery.strBookNumber,''))
		,strSourceId			= NULL
		,intPaymentOn			= NULL
		,strChargesLink			= NULL
		,dblUnitRetail			= NULL
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
		WHERE tblSTReceiveLottery.intReceiveLotteryId = @Id


		EXEC dbo.uspICAddItemReceipt 
			  @ReceiptStagingTable
			, @OtherCharges
			, @UserId;
		
		UPDATE tblSTReceiveLottery SET intInventoryReceiptId = tblResult.intInventoryReceiptId FROM #tmpAddItemReceiptResult as tblResult WHERE tblSTReceiveLottery.intReceiveLotteryId = tblResult.intSourceId
		SELECT * FROM #tmpAddItemReceiptResult

		-- Flag Success
		SET @Success = CAST(1 AS BIT)
		SET @StatusMsg = ''
		

	END
	ELSE IF(@ProcessType = 3) --DELETE--
	BEGIN

		IF(ISNULL(@Id,0) != 0)
		BEGIN
			DELETE FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @Id
			SET @Success = CAST(1 AS BIT)
			SET @StatusMsg = 'Successfully deleted inventory receipt'
		END
		ELSE
		BEGIN
			SET @Success = CAST(1 AS BIT)
			SET @StatusMsg = 'No inventory receipt associated in lottery'
		END
	END
	ELSE IF(@ProcessType = 4) --POST--
	BEGIN
		
		SELECT TOP 1 @inventoryReceiptid = intInventoryReceiptId FROM tblSTReceiveLottery WHERE intReceiveLotteryId = @Id
		IF(ISNULL(@inventoryReceiptid,0) != 0)
		BEGIN
			BEGIN TRY
				SELECT	@receiptNumber = strReceiptNumber 
				FROM	tblICInventoryReceipt 
				WHERE	intInventoryReceiptId = @inventoryReceiptid
		
				EXEC dbo.uspICPostInventoryReceipt 1, 0, @receiptNumber, @UserId;		
			
				 UPDATE tblSTReceiveLottery SET ysnPosted = 1 WHERE intReceiveLotteryId = @Id	

				SET @Success = CAST(1 AS BIT)
				SET @StatusMsg = ''
			END TRY
			BEGIN CATCH
			
				UPDATE tblSTReceiveLottery SET ysnPosted = 0 WHERE intReceiveLotteryId = @Id	 

				SET @StatusMsg = ERROR_MESSAGE()
				SET @Success = CAST(0 AS BIT)
			END CATCH
		END
		ELSE
		BEGIN
			SET @Success = CAST(1 AS BIT)
			SET @StatusMsg = 'No inventory receipt to post'

			INSERT INTO @tblSTTempLotteryProcessError
			(
				 [intCheckoutId]
				,[strError]			
				,[strProcess]	
			)
			SELECT 
				@UserId
				,@StatusMsg
				,'Post IR'

			GOTO EXITWITHROLLBACK
		END
		
	END
	ELSE IF(@ProcessType = 5 OR @ProcessType = 11) --CREATE RETURN RECEIPT--
	BEGIN

		DECLARE @intReturnLotteryId INT = @Id
		DECLARE @intLotteryBookId INT 
		DECLARE @intInventoryReceiptId INT

		SELECT TOP 1 @intLotteryBookId = intLotteryBookId FROM tblSTReturnLottery where intReturnLotteryId = @intReturnLotteryId

		IF ((SELECT COUNT(1) FROM tblSTLotteryBook WHERE intLotteryBookId = @intLotteryBookId) <= 0)
		BEGIN
			SET @Success = CAST(0 AS BIT)
			SET @StatusMsg = 'There are no records to process.'

			INSERT INTO @tblSTTempLotteryProcessError
			(
				 [intCheckoutId]
				,[strError]			
				,[strProcess]	
			)
			SELECT 
				@UserId
				,@StatusMsg
				,'Processing IR for return'

			RETURN
		END

		DECLARE @dblUnpostedQuantitySold NUMERIC(18,6)

		SELECT @dblUnpostedQuantitySold = ISNULL(SUM(ISNULL(dblQuantitySold,0)),0)
		FROM tblSTCheckoutLotteryCount
		INNER JOIN tblSTCheckoutHeader 
		ON tblSTCheckoutLotteryCount.intCheckoutId = tblSTCheckoutHeader.intCheckoutId
		WHERE ISNULL(LOWER(tblSTCheckoutHeader.strCheckoutStatus),'') != 'posted' AND tblSTCheckoutLotteryCount.intLotteryBookId = @intLotteryBookId

		--INSERT RETURN LOTTERY ENTRY--
		-- INSERT INTO tblSTReturnLottery
		-- (
		-- 	intLotteryBookId
		-- 	,dtmReturnDate
		-- 	,dblQuantity
		-- 	,dblOriginalQuantity
		-- 	,ysnPosted
		-- 	,ysnReadyForPosting
		-- )
		-- SELECT TOP 1 
		-- 	 intLotteryBookId
		-- 	,GETDATE()
		-- 	,dblQuantityRemaining - @dblUnpostedQuantitySold
		-- 	,dblQuantityRemaining
		-- 	,0
		-- 	,CASE WHEN @dblUnpostedQuantitySold = 0 THEN 1 ELSE 0 END
		-- FROM tblSTLotteryBook WHERE intLotteryBookId = @intLotteryBookId
		-- SET @intReturnLotteryId = SCOPE_IDENTITY()


		DECLARE @intLotteryBook INT 
		
		DECLARE @dblTotalReturnQuantity INT
		DECLARE @dblTotalReceiveQuantity INT 
		DECLARE @dblTotalSoldQuantity INT
		SELECT TOP 1 
		@intLotteryBook = intLotteryBookId,
		@dblTotalReturnQuantity = dblQuantity 
		FROM tblSTReturnLottery WHERE intReturnLotteryId = @intReturnLotteryId

		SELECT @dblTotalReceiveQuantity = SUM(intTicketPerPack) FROM tblSTReceiveLottery where intLotteryBookId = @intLotteryBook GROUP BY intLotteryBookId
		SELECT @dblTotalSoldQuantity = SUM(dblQuantitySold) FROM tblSTCheckoutLotteryCount where intLotteryBookId = @intLotteryBook GROUP BY intLotteryBookId


		--IF(@ProcessType = 11)
		--BEGIN
		--	UPDATE tblSTLotteryBook
		--	SET dblQuantityRemaining = dblQuantityRemaining + (SELECT TOP 1 dblOriginalQuantity FROM tblSTReturnLottery WHERE intReturnLotteryId = @intReturnLotteryId) 
		--	WHERE intLotteryBookId = @intLotteryBookId
		--END

		--UPDATE tblSTReturnLottery 
		--SET dblOriginalQuantity = dblQuantity  
		--WHERE intReturnLotteryId = @intReturnLotteryId


		----UPDATE LOTTERY BOOK--
		--UPDATE tblSTLotteryBook
		--SET 
		--intBinNumber = NULL
		--,dblQuantityRemaining = dblQuantityRemaining - @dblTotalReturnQuantity
		--,strStatus = 'Returned'
		--WHERE intLotteryBookId = @intLotteryBookId

		SET @dblTotalReceiveQuantity = ISNULL(@dblTotalReceiveQuantity,0)
		SET @dblTotalSoldQuantity = ISNULL(@dblTotalSoldQuantity,0)
		SET @dblTotalReturnQuantity = ISNULL(@dblTotalReturnQuantity,0)

		IF(@dblTotalReceiveQuantity - @dblTotalSoldQuantity != @dblTotalReturnQuantity)
		BEGIN
			
			INSERT INTO tblSTLotteryProcessError (
				 [intCheckoutId]				
				,[strBookNumber]				
				,[strGame]					
				,[strError]					
				,[strProcess]				
			)
			SELECT 
				@UserId
				,tblSTLotteryBook.[strBookNumber]
				,tblSTLotteryGame.strGame
				,'Returned Quantity for Book# ' + tblSTLotteryBook.[strBookNumber] + ' does not match Total Tickets of ' + CAST(@dblTotalReceiveQuantity AS NVARCHAR(MAX))+ ' - Total Sales of ' + CAST(@dblTotalSoldQuantity AS NVARCHAR(MAX)) + ' = ' + CAST(@dblTotalReceiveQuantity - @dblTotalSoldQuantity AS NVARCHAR(MAX))
				,'Processing return lottery'
			FROM tblSTReturnLottery 
			INNER JOIN tblSTLotteryBook
			ON tblSTLotteryBook.intLotteryBookId =  tblSTReturnLottery.intLotteryBookId 
			INNER JOIN tblSTLotteryGame 
			ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
			WHERE intReturnLotteryId = @intReturnLotteryId


			UPDATE tblSTReturnLottery 
			SET ysnReadyForPosting = 0
			WHERE intReturnLotteryId = @intReturnLotteryId
		END
		ELSE
		BEGIN
			UPDATE tblSTReturnLottery 
			SET ysnReadyForPosting = 1
			WHERE intReturnLotteryId = @intReturnLotteryId
		END
	
		--handled in posting-- 
		--SET @strReceiptType = 'Direct'
		--SET @strSourceScreenName = 'Lottery Module'


		----CREATE RETURN RECEIPT--
		--INSERT INTO @ReceiptStagingTable(
		--	 strReceiptType
		--	,strSourceScreenName
		--	,intEntityVendorId
		--	,intShipFromId
		--	,intLocationId
		--	,intItemId
		--	,intItemLocationId
		--	,intItemUOMId
		--	,intCostUOMId
		--	,strBillOfLadding
		--	,intContractHeaderId
		--	,intContractDetailId
		--	,dtmDate
		--	,intShipViaId
		--	,dblQty
		--	,dblCost
		--	,intCurrencyId
		--	,dblExchangeRate
		--	,intLotId
		--	,intSubLocationId
		--	,intStorageLocationId
		--	,ysnIsStorage
		--	,dblFreightRate
		--	,intSourceId	
		--	,intSourceType		 	
		--	,dblGross
		--	,dblNet
		--	,intInventoryReceiptId
		--	,dblSurcharge
		--	,ysnFreightInPrice
		--	,strActualCostId
		--	,intTaxGroupId
		--	,strVendorRefNo
		--	,strSourceId			
		--	,intPaymentOn
		--	,strChargesLink
		--	,dblUnitRetail
		--	,intSort
		--	,strDataSource
		--)	
		--SELECT strReceiptType	= @strReceiptType
		--,strSourceScreenName	= @strSourceScreenName
		--,intEntityVendorId		= tblICItemLocation.intVendorId
		--,intShipFromId			= (SELECT TOP 1 intShipFromId FROM tblAPVendor WHERE intEntityId = tblICItemLocation.intVendorId)
		--,intLocationId			= tblSTStore.intCompanyLocationId
		--,intItemId				= tblSTLotteryGame.intItemId
		--,intItemLocationId		= tblICItemLocation.intItemLocationId
		--,intItemUOMId			= tblICItemUOM.intItemUOMId
		--, intCostUOMId			= tblICItemUOM.intUnitMeasureId
		--,strBillOfLadding		= ''
		--,intContractHeaderId	= NULL
		--,intContractDetailId	= NULL
		--,dtmDate				= tblSTReturnLottery.dtmReturnDate
		--,intShipViaId			= NULL
		--,dblQty					= tblSTReturnLottery.dblQuantity * -1
		--,dblCost				= tblSTLotteryGame.dblInventoryCost 
		--,intCurrencyId			= @defaultCurrency
		--,dblExchangeRate		= 1
		--,intLotId				= NULL
		--,intSubLocationId		= NULL
		--,intStorageLocationId	= NULL
		--,ysnIsStorage			= 0
		--,dblFreightRate			= 0
		--,intSourceId			= tblSTReturnLottery.intReturnLotteryId
		--,intSourceType		 	= 7
		--,dblGross				= NULL
		--,dblNet					= NULL
		--,intInventoryReceiptId	= tblSTReturnLottery.intInventoryReceiptId 
		--,dblSurcharge			= NULL
		--,ysnFreightInPrice		= NULL
		--,strActualCostId		= NULL
		--,intTaxGroupId			= NULL
		--,strVendorRefNo			= (CAST(ISNULL(tblSTStore.intStoreNo,'') as nvarchar(100)) + '-' + ISNULL(tblSTLotteryGame.strGame,'') + ISNULL(tblSTLotteryBook.strBookNumber,'')) + 'R'
		--,strSourceId			= NULL
		--,intPaymentOn			= NULL
		--,strChargesLink			= NULL
		--,dblUnitRetail			= NULL
		--,intSort				= NULL
		--,strDataSource			= @strSourceScreenName
		--FROM tblSTReturnLottery
		--INNER JOIN tblSTLotteryBook
		--ON tblSTReturnLottery.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
		--INNER JOIN tblSTLotteryGame 
		--ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
		--INNER JOIN tblSTStore 
		--ON tblSTLotteryBook.intStoreId = tblSTStore.intStoreId
		--INNER JOIN tblICItemLocation 
		--	ON tblICItemLocation.intLocationId = tblSTStore.intCompanyLocationId 
		--	AND tblSTLotteryGame.intItemId = tblICItemLocation.intItemId
		--INNER JOIN tblICItemPricing
		--	ON tblICItemPricing.intItemLocationId = tblICItemLocation.intItemLocationId
		--	AND tblICItemPricing.intItemId = tblICItemLocation.intItemId
		--LEFT JOIN tblAPVendor 
		--ON tblAPVendor.intEntityId = tblICItemLocation.intVendorId
		--LEFT JOIN tblICItemUOM 
		--ON tblICItemUOM.intItemUOMId = tblICItemLocation.intIssueUOMId
		--WHERE tblSTReturnLottery.intReturnLotteryId = @intReturnLotteryId


		--EXEC dbo.uspICAddItemReceipt 
		--	 @ReceiptStagingTable
		--	,@OtherCharges
		--	,@UserId;
		
		--UPDATE tblSTReturnLottery SET intInventoryReceiptId = tblResult.intInventoryReceiptId FROM #tmpAddItemReceiptResult as tblResult WHERE tblSTReturnLottery.intReturnLotteryId = tblResult.intSourceId
		--SELECT * FROM #tmpAddItemReceiptResult

		-- Flag Success
		SET @Success = CAST(1 AS BIT)
		SET @StatusMsg = ''

	END
	ELSE IF(@ProcessType = 6) --DELETE RETURN--
	BEGIN

	

		-- SELECT TOP 1 @Id = intLotteryBookId FROM tblSTReturnLottery where intReturnLotteryId = @intReturnLotteryId

		--UPDATE tblSTLotteryBook 
		--SET 
		--	dblQuantityRemaining = dblQuantityRemaining + dblQuantity,
		--	strStatus = 'Inactive'
		--FROM 
		--tblSTReturnLottery
		--WHERE intReturnLotteryId = @Id AND tblSTReturnLottery.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
		
		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId FROM tblSTReturnLottery WHERE intReturnLotteryId = @Id

		-- DELETE FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId

		IF(ISNULL(@intInventoryReceiptId,0) != 0)
		BEGIN
			EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId = @intInventoryReceiptId,@intEntityUserSecurityId = @UserId
			DELETE FROM tblSTReturnLottery WHERE intReturnLotteryId = @Id
		END
		ELSE
		BEGIN
			DELETE FROM tblSTReturnLottery WHERE intReturnLotteryId = @Id
		END

		SET @Success = CAST(1 AS BIT)
		SET @StatusMsg = ''
	END
	ELSE IF(@ProcessType = 7) --POST RETURN--
	BEGIN

		BEGIN TRY
			
			SELECT TOP 1 @inventoryReceiptid = intInventoryReceiptId FROM tblSTReturnLottery WHERE intReturnLotteryId = @Id
		
			SELECT	@receiptNumber = strReceiptNumber 
			FROM	tblICInventoryReceipt 
			WHERE	intInventoryReceiptId = @inventoryReceiptid
		
			EXEC dbo.uspICPostInventoryReceipt 1, 0, @receiptNumber, @UserId;		
			
			 UPDATE tblSTReturnLottery SET ysnPosted = 1 WHERE intReturnLotteryId = @Id	

			SET @Success = CAST(1 AS BIT)
			SET @StatusMsg = ''
		END TRY
		BEGIN CATCH
			
			UPDATE tblSTReturnLottery SET ysnPosted = 0 WHERE intReturnLotteryId = @Id	 

			SET @StatusMsg = ERROR_MESSAGE()
			SET @Success = CAST(0 AS BIT)
		END CATCH
		
	END
	--8 = new | 9 = update--
	ELSE IF(@ProcessType = 8 OR @ProcessType = 9)  
	BEGIN

		SET @strReceiptType = 'Direct'
		SET @strSourceScreenName = 'Lottery Module'

		SELECT TOP 1  
		@receiveLotteryId =  intReceiveLotteryId,
		@inventoryReceiptid = intInventoryReceiptId,
		@storeId = intStoreId,
		@lotteryGame = strGame,
		@checkoutId = intCheckoutId,
		@lotteryBook =strBookNumber
		FROM tblSTReceiveLottery 
		INNER JOIN tblSTLotteryGame
		ON tblSTReceiveLottery.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
		WHERE intReceiveLotteryId = @Id

		IF (ISNULL(@receiveLotteryId,0) = 0)
		BEGIN
			
			INSERT INTO tblSTLotteryProcessError (
				 [intCheckoutId]				
				,[strBookNumber]				
				,[strGame]					
				,[strError]					
				,[strProcess]				
			)
			SELECT 
				@UserId,
				@lotteryBook,
				@lotteryGame,
				'There are no records to process.',
				'Processing IR for receive lottery'
			GOTO EXITWITHROLLBACK
		END

		--CREATE LOTTERY BOOK--
		IF(@ProcessType = 8)
		BEGIN
			INSERT INTO tblSTLotteryBook
			(
				intStoreId
				,strBookNumber
				,strCountDirection
				,intLotteryGameId
				,dtmReceiptDate
				,intStartingNumber
				,intEndingNumber
				,dblQuantityRemaining
				,intItemUOMId
				,strStatus
				,intConcurrencyId
			)
			SELECT TOP 1 
			RL.intStoreId,
			RL.strBookNumber,
			'Low to High',
			RL.intLotteryGameId,
			RL.dtmReceiptDate,
			LG.intStartingNumber,
			LG.intEndingNumber,
			RL.intTicketPerPack,
			RL.intItemUOMId,
			'Inactive',
			1
			FROM tblSTReceiveLottery RL
			JOIN tblSTLotteryGame LG
				ON RL.intLotteryGameId = LG.intLotteryGameId
			WHERE intReceiveLotteryId = @Id

			DECLARE @lotteryBookPK INT
			SET @lotteryBookPK = SCOPE_IDENTITY() 

			UPDATE tblSTReceiveLottery SET intLotteryBookId = @lotteryBookPK WHERE intReceiveLotteryId = @Id
		END
		ELSE IF(@ProcessType = 9)
		BEGIN
			
			UPDATE tblSTLotteryBook
			SET  tblSTLotteryBook.intStoreId				= tblSTReceiveLottery.intStoreId			
				,tblSTLotteryBook.strBookNumber				= tblSTReceiveLottery.strBookNumber			
				,tblSTLotteryBook.intLotteryGameId			= tblSTReceiveLottery.intLotteryGameId		
				,tblSTLotteryBook.intStartingNumber			= LG.intStartingNumber		
				,tblSTLotteryBook.intEndingNumber			= LG.intEndingNumber		
				,tblSTLotteryBook.dtmReceiptDate			= tblSTReceiveLottery.dtmReceiptDate		
				,tblSTLotteryBook.dblQuantityRemaining		= tblSTReceiveLottery.intTicketPerPack
			FROM 
			tblSTLotteryBook
			INNER JOIN tblSTReceiveLottery
			ON tblSTLotteryBook.intLotteryBookId = tblSTReceiveLottery.intLotteryBookId
			JOIN tblSTLotteryGame LG
				ON tblSTReceiveLottery.intLotteryGameId = LG.intLotteryGameId
			WHERE tblSTReceiveLottery.intReceiveLotteryId = @Id
			
		END

		SET @Success = CAST(1 AS BIT)
		SET @StatusMsg = ''

		--CREATE LOTTERY BOOK--

		-- SELECT TOP 1 @lotterySetupMode = ISNULL(ysnLotterySetupMode,0)
		-- FROM tblSTStore WHERE intStoreId = @storeId

		-- IF (ISNULL(@lotterySetupMode,0) = 1)
		-- BEGIN
		-- 	INSERT INTO tblSTLotteryProcessError (
		-- 		[intCheckoutId]				
		-- 		,[strBookNumber]				
		-- 		,[strGame]					
		-- 		,[strError]					
		-- 		,[strProcess]				
		-- 	)
		-- 	SELECT 
		-- 		@checkoutId,
		-- 		@lotteryBook,
		-- 		@lotteryGame,
		-- 		'[Lottery Setup Mode is On] - No need to create IR | Lottery Book is created',
		-- 		'Creating Inventory Receipt'
		-- 	GOTO EXITWITHCOMMIT
		-- END

		-- -- Validate if there is Item UOM setup
		-- IF EXISTS(SELECT TOP 1 1 FROM tblSTReceiveLottery RL
		-- 	INNER JOIN tblSTStore S ON S.intStoreId = RL.intStoreId
		-- 	INNER JOIN tblSTLotteryGame LG ON LG.intLotteryGameId = RL.intLotteryGameId
		-- 	LEFT JOIN tblICItemLocation IL ON IL.intLocationId = S.intCompanyLocationId
		-- 		AND IL.intItemId = LG.intItemId
		-- 	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = IL.intIssueUOMId
		-- 	WHERE RL.intReceiveLotteryId = @Id
		-- 	AND IU.intItemUOMId IS NULL)
		-- BEGIN
		-- 	SET @Success = CAST(0 AS BIT)
		-- 	SET @StatusMsg = 'Missing UOM setup on Item Location.'
		-- 	INSERT INTO tblSTLotteryProcessError (
		-- 		[intCheckoutId]				
		-- 		,[strBookNumber]				
		-- 		,[strGame]					
		-- 		,[strError]					
		-- 		,[strProcess]				
		-- 	)
		-- 	SELECT 
		-- 		@checkoutId,
		-- 		@lotteryBook,
		-- 		@lotteryGame,
		-- 		'Missing UOM setup on Item Location.',
		-- 		'Creating Inventory Receipt'
		-- 	GOTO EXITWITHROLLBACK
		-- END

	
		-- INSERT INTO @ReceiptStagingTable(
		-- 	 strReceiptType
		-- 	,strSourceScreenName
		-- 	,intEntityVendorId
		-- 	,intShipFromId
		-- 	,intLocationId
		-- 	,intItemId
		-- 	,intItemLocationId
		-- 	,intItemUOMId
		-- 	,intCostUOMId
		-- 	,strBillOfLadding
		-- 	,intContractHeaderId
		-- 	,intContractDetailId
		-- 	,dtmDate
		-- 	,intShipViaId
		-- 	,dblQty
		-- 	,dblCost
		-- 	,intCurrencyId
		-- 	,dblExchangeRate
		-- 	,intLotId
		-- 	,intSubLocationId
		-- 	,intStorageLocationId
		-- 	,ysnIsStorage
		-- 	,dblFreightRate
		-- 	,intSourceId	
		-- 	,intSourceType		 	
		-- 	,dblGross
		-- 	,dblNet
		-- 	,intInventoryReceiptId
		-- 	,dblSurcharge
		-- 	,ysnFreightInPrice
		-- 	,strActualCostId
		-- 	,intTaxGroupId
		-- 	,strVendorRefNo
		-- 	,strSourceId			
		-- 	,intPaymentOn
		-- 	,strChargesLink
		-- 	,dblUnitRetail
		-- 	,intSort
		-- 	,strDataSource
		-- )	
		-- SELECT strReceiptType	= @strReceiptType
		-- ,strSourceScreenName	= @strSourceScreenName
		-- ,intEntityVendorId		= tblICItemLocation.intVendorId
		-- ,intShipFromId			= (SELECT TOP 1 intShipFromId FROM tblAPVendor WHERE intEntityId = tblICItemLocation.intVendorId)
		-- ,intLocationId			= tblSTStore.intCompanyLocationId
		-- ,intItemId				= tblSTLotteryGame.intItemId
		-- ,intItemLocationId		= tblICItemLocation.intItemLocationId
		-- ,intItemUOMId			= tblICItemUOM.intItemUOMId
		-- , intCostUOMId			= tblICItemUOM.intUnitMeasureId
		-- ,strBillOfLadding		= ''
		-- ,intContractHeaderId	= NULL
		-- ,intContractDetailId	= NULL
		-- ,dtmDate				= tblSTReceiveLottery.dtmReceiptDate
		-- ,intShipViaId			= NULL
		-- ,dblQty					= tblSTReceiveLottery.intTicketPerPack
		-- ,dblCost				= tblSTLotteryGame.dblInventoryCost 
		-- ,intCurrencyId			= @defaultCurrency
		-- ,dblExchangeRate		= 1
		-- ,intLotId				= NULL
		-- ,intSubLocationId		= NULL
		-- ,intStorageLocationId	= NULL
		-- ,ysnIsStorage			= 0
		-- ,dblFreightRate			= 0
		-- ,intSourceId			= tblSTReceiveLottery.intReceiveLotteryId
		-- ,intSourceType		 	= 7
		-- ,dblGross				= NULL
		-- ,dblNet					= NULL
		-- ,intInventoryReceiptId	= tblSTReceiveLottery.intInventoryReceiptId 
		-- ,dblSurcharge			= NULL
		-- ,ysnFreightInPrice		= NULL
		-- ,strActualCostId		= NULL
		-- ,intTaxGroupId			= NULL
		-- ,strVendorRefNo			= (CAST(ISNULL(tblSTStore.intStoreNo,'') as nvarchar(100)) + '-' + ISNULL(tblSTLotteryGame.strGame,'') + ISNULL(tblSTReceiveLottery.strBookNumber,''))
		-- ,strSourceId			= NULL
		-- ,intPaymentOn			= NULL
		-- ,strChargesLink			= NULL
		-- ,dblUnitRetail			= NULL
		-- ,intSort				= NULL
		-- ,strDataSource			= @strSourceScreenName
		-- FROM tblSTReceiveLottery
		-- INNER JOIN tblSTStore 
		-- ON tblSTReceiveLottery.intStoreId = tblSTStore.intStoreId
		-- INNER JOIN tblSTLotteryGame 
		-- ON tblSTReceiveLottery.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
		-- INNER JOIN tblICItemLocation 
		-- ON tblICItemLocation.intLocationId = tblSTStore.intCompanyLocationId
		-- 	AND tblSTLotteryGame.intItemId = tblICItemLocation.intItemId
		-- INNER JOIN tblICItemPricing
		-- 	ON tblICItemPricing.intItemLocationId = tblICItemLocation.intItemLocationId
		-- 	AND tblICItemPricing.intItemId = tblICItemLocation.intItemId
		-- LEFT JOIN tblAPVendor 
		-- ON tblAPVendor.intEntityId = tblICItemLocation.intVendorId
		-- LEFT JOIN tblICItemUOM 
		-- ON tblICItemUOM.intItemUOMId = tblICItemLocation.intIssueUOMId
		-- WHERE tblSTReceiveLottery.intReceiveLotteryId = @Id


		-- EXEC dbo.uspICAddItemReceipt @ReceiptStagingTable
		-- 	, @OtherCharges
		-- 	, @UserId;
		
		-- UPDATE tblSTReceiveLottery SET intInventoryReceiptId = tblResult.intInventoryReceiptId FROM #tmpAddItemReceiptResult as tblResult WHERE tblSTReceiveLottery.intReceiveLotteryId = tblResult.intSourceId
		-- SELECT * FROM #tmpAddItemReceiptResult

		-- Flag Success
		
		

	END
	ELSE IF(@ProcessType = 10)
	BEGIN
		IF(ISNULL(@Id,0) != 0)
		BEGIN

			DECLARE @P10LotteryBookId INT
			SELECT TOP 1 @P10LotteryBookId = intLotteryBookId FROM tblSTReceiveLottery where intReceiveLotteryId = @Id 

			IF(ISNULL(@P10LotteryBookId,0) = 0)
			BEGIN
				DELETE FROM tblSTReceiveLottery WHERE intReceiveLotteryId = @Id 
					
				SET @Success = CAST(1 AS BIT)
				SET @StatusMsg = ''
				--RETURN
			END
			ELSE
			BEGIN
				DECLARE @P10LotteryBookTransactions INT = 0
				SELECT @P10LotteryBookTransactions += ISNULL(COUNT(*),0) FROM tblSTCheckoutLotteryCount WHERE intLotteryBookId = @P10LotteryBookId
				SELECT @P10LotteryBookTransactions += ISNULL(COUNT(*),0) FROM tblSTReturnLottery WHERE intLotteryBookId = @P10LotteryBookId
				IF(@P10LotteryBookTransactions > 0)
				BEGIN
					INSERT INTO tblSTLotteryProcessError (
								[intCheckoutId]				
							,[strBookNumber]				
							,[strGame]					
							,[strError]					
							,[strProcess]				
						)
						SELECT 
							@UserId
							,tblSTLotteryBook.[strBookNumber]
							,tblSTLotteryGame.strGame
							,'Unable to delete lottry book with existing transaction/s'
							,'Deleting receive lottery'
						FROM tblSTReceiveLottery 
						INNER JOIN tblSTLotteryBook
						ON tblSTLotteryBook.intLotteryBookId =  tblSTReceiveLottery.intLotteryBookId 
						INNER JOIN tblSTLotteryGame 
						ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
						WHERE intReceiveLotteryId = @Id
							
						SET @Success = CAST(1 AS BIT)
						SET @StatusMsg = ''
						--RETURN
				END
				ELSE
				BEGIN
					DECLARE @P10InventoryReceiptId INT 
					SELECT TOP 1 @P10InventoryReceiptId = intInventoryReceiptId FROM tblSTReceiveLottery WHERE intReceiveLotteryId = @Id
					IF(ISNULL(@P10InventoryReceiptId,0) != 0)
					BEGIN
						EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId = @P10InventoryReceiptId,@intEntityUserSecurityId = @UserId
					END
						
					DELETE FROM tblSTLotteryBook WHERE intLotteryBookId = @P10LotteryBookId
					DELETE FROM tblSTReceiveLottery WHERE intReceiveLotteryId = @Id 

					SET @Success = CAST(1 AS BIT)
					SET @StatusMsg = ''
					--RETURN
				END
			END

		END
		ELSE
		BEGIN
			INSERT INTO tblSTLotteryProcessError (
				 [intCheckoutId]				
				,[strBookNumber]				
				,[strGame]					
				,[strError]					
				,[strProcess]				
			)
			SELECT 
				@UserId
				,'[Unhandled Exception]'
				,'[Unhandled Exception]'
				,'Unable to find receive lottery'
				,'Deleting receive lottery'

			SET @Success = CAST(1 AS BIT)
			SET @StatusMsg = ''
		END
	END

	
	--IF (@@TRANCOUNT > 0) 

	EXITWITHCOMMIT:
	COMMIT TRANSACTION
	RETURN
	
	
END TRY

BEGIN CATCH
	
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

		GOTO EXITWITHROLLBACK
	

	RETURN 
END CATCH



EXITWITHROLLBACK: 
--IF (@@TRANCOUNT > 0) 
--BEGIN 
	ROLLBACK TRANSACTION 
--END

GOTO WRITEVALIDATIONERRORLOGS

RETURN 


WRITEVALIDATIONERRORLOGS: 
INSERT INTO tblSTLotteryProcessError (
	 [intCheckoutId]				
	,[strBookNumber]				
	,[strGame]					
	,[strError]					
	,[strProcess]				
)
SELECT 
	 [intCheckoutId]				
	,[strBookNumber]				
	,[strGame]					
	,[strError]					
	,[strProcess]	
FROM @tblSTTempLotteryProcessError
GOTO WRITEUNHANDLEDEXCEPTION


WRITEUNHANDLEDEXCEPTION: 
IF(@ProcessType = 8 OR @ProcessType = 9 OR @ProcessType = 11 OR @ProcessType = 5)  
BEGIN
	IF(@ErrorMessage = 'Cannot insert the value NULL into column ''intShipFromId'', table ''@ReceiptStagingTable''; column does not allow nulls. INSERT fails.')
	BEGIN
		SET @ErrorMessage = 'Invalid vendor ship from location'
	END

	IF(@ProcessType = 8 OR @ProcessType = 9)
	BEGIN
		INSERT INTO tblSTLotteryProcessError (
		[intCheckoutId]				
		,[strBookNumber]				
		,[strGame]					
		,[strError]					
		,[strProcess]				
		)
		SELECT 
		 @UserId
		,tblSTReceiveLottery.strBookNumber,
		 tblSTLotteryGame.strGame,
		'[Unhandled Exception] ' + @ErrorMessage,
		'Processing IR for receive lottery'
		FROM tblSTReceiveLottery 
		INNER JOIN tblSTLotteryGame 
		ON tblSTReceiveLottery.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
		WHERE intReceiveLotteryId = @Id
		
		--IF(@ProcessType = 8)
		--BEGIN
		--	DELETE FROM tblSTReceiveLottery WHERE intReceiveLotteryId = @Id
		--END
	END

	IF(@ProcessType = 11 OR @ProcessType = 5)
	BEGIN
		INSERT INTO tblSTLotteryProcessError (
		[intCheckoutId]				
		,[strBookNumber]				
		,[strGame]					
		,[strError]					
		,[strProcess]				
		)
		SELECT 
		 @UserId
		,tblSTLotteryBook.[strBookNumber],
		 tblSTLotteryGame.strGame,
		'[Unhandled Exception] ' + @ErrorMessage,
		'Processing IR for receive lottery'
		FROM tblSTReturnLottery 
		INNER JOIN tblSTLotteryBook
		ON tblSTLotteryBook.intLotteryBookId =  tblSTReturnLottery.intLotteryBookId 
		INNER JOIN tblSTLotteryGame 
		ON tblSTLotteryBook.intLotteryGameId = tblSTLotteryGame.intLotteryGameId
		WHERE intReturnLotteryId = @Id

		--IF(@ProcessType = 5)
		--BEGIN
		--	DELETE FROM tblSTReturnLottery WHERE intReturnLotteryId = @Id
		--END
	END

END
ELSE
BEGIN 
	INSERT INTO tblSTLotteryProcessError (
	 [intCheckoutId]
	,[strError]					
	,[strProcess]				
	)
	SELECT 
	 @UserId
	,'[Unhandled Exception] ' + @ErrorMessage,
	'[Untracked]'
END


SET @Success = CAST(0 AS BIT)


RETURN