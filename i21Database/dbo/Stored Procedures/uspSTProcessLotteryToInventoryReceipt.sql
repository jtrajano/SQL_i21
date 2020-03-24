CREATE PROCEDURE [dbo].[uspSTProcessLotteryToInventoryReceipt]
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

BEGIN TRY

	IF (@@TRANCOUNT > 0)
	BEGIN 
		BEGIN TRANSACTION
	END

	DECLARE @ReceiptStagingTable ReceiptStagingTable
		,@OtherCharges ReceiptOtherChargesTableType
		,@defaultCurrency INT
		,@strReceiptType NVARCHAR(500)
		,@strSourceScreenName NVARCHAR(500)

	DECLARE @receiptNumber NVARCHAR(100)
	
	

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

		DECLARE @receiveLotteryId INT
		DECLARE @inventoryReceiptid INT
		DECLARE @storeId INT
		DECLARE @lotterySetupMode BIT

		SELECT TOP 1  
		@receiveLotteryId =  intReceiveLotteryId,
		@inventoryReceiptid = intInventoryReceiptId,
		@storeId = intStoreId
		FROM tblSTReceiveLottery WHERE intReceiveLotteryId = @Id

		IF (ISNULL(@receiveLotteryId,0) = 0)
		BEGIN
			SET @Success = CAST(0 AS BIT)
			SET @StatusMsg = 'There are no records to process.'
			GOTO EXITWITHROLLBACK
			RETURN
		END

		SELECT TOP 1 @lotterySetupMode = ISNULL(ysnLotterySetupMode,0)
		FROM tblSTStore WHERE intStoreId = @storeId

		IF (ISNULL(@lotterySetupMode,0) = 1)
		BEGIN
			SET @Success = CAST(1 AS BIT)
			SET @StatusMsg = 'Lottery Setup Mode - No need to create IR.'
			GOTO EXITWITHROLLBACK
			RETURN
		END

		SET @strReceiptType = 'Direct'
		SET @strSourceScreenName = 'Lottery Module'
	
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
			GOTO EXITWITHROLLBACK
		END
		
	END
	ELSE IF(@ProcessType = 5) --CREATE RETURN RECEIPT--
	BEGIN

		DECLARE @intReturnLotteryId INT
		DECLARE @intInventoryReceiptId INT

		IF ((SELECT COUNT(1) FROM tblSTLotteryBook WHERE intLotteryBookId = @Id) <= 0)
		BEGIN
			SET @Success = CAST(0 AS BIT)
			SET @StatusMsg = 'There are no records to process.'
			RETURN
		END

		DECLARE @dblUnpostedQuantitySold NUMERIC(18,6)

		SELECT @dblUnpostedQuantitySold = ISNULL(SUM(ISNULL(dblQuantitySold,0)),0)
		FROM tblSTCheckoutLotteryCount
		INNER JOIN tblSTCheckoutHeader 
		ON tblSTCheckoutLotteryCount.intCheckoutId = tblSTCheckoutHeader.intCheckoutId
		WHERE ISNULL(tblSTCheckoutHeader.ysnPosted,0) = 0 AND tblSTCheckoutLotteryCount.intLotteryBookId = @Id

		--INSERT RETURN LOTTERY ENTRY--
		INSERT INTO tblSTReturnLottery
		(
			intLotteryBookId
			,dtmReturnDate
			,dblQuantity
			,dblOriginalQuantity
			,ysnPosted
			,ysnReadyForPosting
		)
		SELECT TOP 1 
			 intLotteryBookId
			,GETDATE()
			,dblQuantityRemaining - @dblUnpostedQuantitySold
			,dblQuantityRemaining
			,0
			,CASE WHEN @dblUnpostedQuantitySold = 0 THEN 1 ELSE 0 END
		FROM tblSTLotteryBook WHERE intLotteryBookId = @Id
		SET @intReturnLotteryId = SCOPE_IDENTITY()

		--UPDATE LOTTERY BOOK--
		UPDATE tblSTLotteryBook
		SET 
		intBinNumber = NULL
		,dblQuantityRemaining = 0
		,strStatus = 'Returned'
		WHERE intLotteryBookId = @Id
	

		SET @strReceiptType = 'Direct'
		SET @strSourceScreenName = 'Lottery Module'


		--CREATE RETURN RECEIPT--
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
		,strVendorRefNo			= (CAST(ISNULL(tblSTStore.intStoreNo,'') as nvarchar(100)) + '-' + ISNULL(tblSTLotteryGame.strGame,'') + ISNULL(tblSTLotteryBook.strBookNumber,'')) + 'R'
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
		WHERE tblSTReturnLottery.intReturnLotteryId = @intReturnLotteryId


		EXEC dbo.uspICAddItemReceipt 
			 @ReceiptStagingTable
			,@OtherCharges
			,@UserId;
		
		UPDATE tblSTReturnLottery SET intInventoryReceiptId = tblResult.intInventoryReceiptId FROM #tmpAddItemReceiptResult as tblResult WHERE tblSTReturnLottery.intReturnLotteryId = tblResult.intSourceId
		SELECT * FROM #tmpAddItemReceiptResult

		-- Flag Success
		SET @Success = CAST(1 AS BIT)
		SET @StatusMsg = ''

	END
	ELSE IF(@ProcessType = 6) --DELETE RETURN--
	BEGIN

		UPDATE tblSTLotteryBook 
		SET 
			dblQuantityRemaining = dblOriginalQuantity,
			strStatus = 'Inactive'
		FROM 
		tblSTReturnLottery
		WHERE intReturnLotteryId = @Id AND tblSTReturnLottery.intLotteryBookId = tblSTLotteryBook.intLotteryBookId
		
		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId FROM tblSTReturnLottery WHERE intReturnLotteryId = @Id

		DELETE FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId
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



	
	IF (@@TRANCOUNT > 0) COMMIT TRANSACTION
	
	
END TRY

BEGIN CATCH
	
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();


		IF(@ErrorMessage = 'Cannot insert the value NULL into column ''intShipFromId'', table ''@ReceiptStagingTable''; column does not allow nulls. INSERT fails.')
		BEGIN
			SET @ErrorMessage = 'Invalid vendor ship from location'
		END

		SET @StatusMsg = @ErrorMessage
		SET @Success = CAST(0 AS BIT)
	

	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 


	IF(@ProcessType = 1)  --ADD 
	BEGIN
		--DELETE LOTTERY BOOK
		DELETE FROM tblSTLotteryBook WHERE intLotteryBookId = (SELECT TOP 1 intLotteryBookId FROM tblSTReceiveLottery WHERE intReceiveLotteryId = @Id)	 
	END

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);

	RETURN 
END CATCH



EXITWITHROLLBACK: 
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 