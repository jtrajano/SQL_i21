CREATE PROCEDURE [dbo].[uspICUpdateWarrantlot]
  @intLotId INT 
  ,@intUserId INT
  ,@strWarrantStatus NVARCHAR(100) = ''
  ,@strWarrantNo NVARCHAR(100) = ''
  ,@intTradeFinanceId INT = NULL
  ,@strClearField NVARCHAR(25) = ''
AS

BEGIN

    DECLARE @strOldWarrantStatus NVARCHAR(100) = ''
	DECLARE @strOldWarrantNo NVARCHAR(100) = ''
	DECLARE @strOldTradeFinanceNumber NVARCHAR(100) = ''
	DECLARE @_intInventoryReceiptId INT
	DECLARE @_strReceiptNumber NVARCHAR(100) = ''
	DECLARE @_logDescription NVARCHAR(MAX) = ''
	DECLARE @intWarrantStatus INT
	DECLARE @strTradeFinanceNumber NVARCHAR(100) = ''
	DECLARE @intOldWarrantStatus INT
	DECLARE @intOldTradeFinanceId INT


	--GEt  Old data
	SELECT TOP 1
		@strOldWarrantStatus = ISNULL(B.strWarrantStatus,'')
		,@strOldWarrantNo = A.strWarrantNo
		,@strOldTradeFinanceNumber = C.strTradeFinanceNumber
		,@intOldWarrantStatus = A.intWarrantStatus
		,@intOldTradeFinanceId = A.intTradeFinanceId 
	FROM tblICLot A
	LEFT JOIN tblICWarrantStatus B
		ON A.intWarrantStatus  = B.intWarrantStatus
	LEFT JOIN tblTRFTradeFinance C
		ON A.intTradeFinanceId = C.intTradeFinanceId
	WHERE intLotId = @intLotId

	
	--Get Warrant Status Id
	SELECT TOP 1
		@intWarrantStatus = intWarrantStatus
	FROM tblICWarrantStatus
	WHERE strWarrantStatus =  @strWarrantStatus

	----GEt Trade Finance name
	SET @strTradeFinanceNumber = ISNULL((SELECT TOP 1
												strTradeFinanceNumber
											FROM tblTRFTradeFinance
											WHERE intTradeFinanceId = @intTradeFinanceId),'')


	----Check for clear field
	IF(ISNULL(@strClearField,'') = '')
	BEGIN
		DECLARE @LotsToRelease AS LotReleaseTableType 
		---UPDATE released quantity to 0 pledged status 
		IF(@intWarrantStatus = 1)
		BEGIN
			
			INSERT INTO @LotsToRelease (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[intLotId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[dblQty] 
				,[intTransactionId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intOwnershipTypeId] 
				,[dtmDate] 
			)
			SELECT 
				[intItemId] = lot.intItemId
				,[intItemLocationId] = lot.intItemLocationId
				,[intItemUOMId] = lot.intItemUOMId
				,[intLotId] = lot.intLotId
				,[intSubLocationId] = lot.intSubLocationId
				,[intStorageLocationId] = lot.intStorageLocationId
				,[dblQty] = 0
				,[intTransactionId] = lot.intLotId -- Use the lot id. 
				,[strTransactionId] = lot.strLotNumber -- Use the lot number. 
				,[intTransactionTypeId] = 61 -- Use 61 for a release coming from the Warrant screen. 
				,[intOwnershipTypeId] = lot.intOwnershipType
				,[dtmDate] = GETDATE()
			FROM tblICLot lot
			WHERE intLotId = @intLotId
				AND lot.dblReleasedQty <> 0
		END

		---UPDATE released quantity to the lot quantity if released status 
		IF(@intWarrantStatus = 3)
		BEGIN
			
			INSERT INTO @LotsToRelease (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[intLotId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[dblQty] 
				,[intTransactionId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intOwnershipTypeId] 
				,[dtmDate] 
			)
			SELECT 
				[intItemId] = lot.intItemId
				,[intItemLocationId] = lot.intItemLocationId
				,[intItemUOMId] = lot.intItemUOMId
				,[intLotId] = lot.intLotId
				,[intSubLocationId] = lot.intSubLocationId
				,[intStorageLocationId] = lot.intStorageLocationId
				,[dblQty] = lot.dblQty
				,[intTransactionId] = lot.intLotId -- Use the lot id. 
				,[strTransactionId] = lot.strLotNumber -- Use the lot number. 
				,[intTransactionTypeId] = 61 -- Use 61 for a release coming from the Warrant screen. 
				,[intOwnershipTypeId] = lot.intOwnershipType
				,[dtmDate] = GETDATE()
			FROM tblICLot lot
			WHERE intLotId = @intLotId
				AND lot.dblReleasedQty <> 0
		END

		EXEC [uspICCreateLotRelease]
			@LotsToRelease = @LotsToRelease 
			,@intTransactionId = 0 -- Since warrant does not have a transaction id, you can use the lot id. 
			,@intTransactionTypeId = 61 -- Use 61 for Warrant. 
			,@intUserId = @intUserId
		
		
		
		IF(ISNULL(@strWarrantNo,'') = '')
		BEGIN
			SET @strWarrantNo = @strOldWarrantNo
		END
		IF(ISNULL(@strWarrantStatus,'') = '')
		BEGIN
			SET @strWarrantStatus = @strOldWarrantStatus
			SET @intWarrantStatus = @intOldWarrantStatus
		END
		IF(ISNULL(@intTradeFinanceId ,0) = 0)
		BEGIN
			SET @intTradeFinanceId = @intOldTradeFinanceId
			SET @strTradeFinanceNumber = @strOldTradeFinanceNumber
		END
	END
	ELSE
	BEGIN

		SET @strWarrantNo = @strOldWarrantNo
		SET @strWarrantStatus = @strOldWarrantStatus
		SET	@strTradeFinanceNumber = @strOldTradeFinanceNumber
		SET @intWarrantStatus = @intOldWarrantStatus
		SET @intTradeFinanceId = @intOldTradeFinanceId
		
		IF(@strClearField = 'Trade Finance No')
		BEGIN
			SET @strTradeFinanceNumber = ''
			SET @intTradeFinanceId = NULL
		END
		ELSE IF(@strClearField = 'Warrant No')
		BEGIN
			SET @strWarrantNo = ''
		END
		ELSE IF(@strClearField = 'Warrant Status')
		BEGIN
			SET @strWarrantStatus = ''
			SET @intWarrantStatus = NULL
		END
	END


	--update data
	UPDATE tblICLot
	SET strWarrantNo = @strWarrantNo
		,intWarrantStatus = @intWarrantStatus
		,intTradeFinanceId =  @intTradeFinanceId 
	WHERE intLotId = @intLotId


	--Audit Log for Warrant Status
	IF(@strWarrantStatus <> @strOldWarrantStatus )
	BEGIN
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intLotId					-- Primary Key Value of the Ticket. 
			,@screenName		= 'Inventory.view.Warrant'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Updated'					-- Action Type
			,@changeDescription	= 'Warrant Status'		-- Description
			,@fromValue			= @strOldWarrantStatus						-- Old Value
			,@toValue			= @strWarrantStatus			-- New Value
			,@details			= '';
	END

	--Audit Log for Warrant No
	IF(@strWarrantNo <> @strOldWarrantNo)
	BEGIN
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intLotId					-- Primary Key Value of the Ticket. 
			,@screenName		= 'Inventory.view.Warrant'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Updated'					-- Action Type
			,@changeDescription	= 'Warrant No'		-- Description
			,@fromValue			= @strOldWarrantNo						-- Old Value
			,@toValue			= @strWarrantNo			-- New Value
			,@details			= '';
	END

	SET @strTradeFinanceNumber = ISNULL(@strTradeFinanceNumber,'')
	SET @strOldTradeFinanceNumber = ISNULL(@strOldTradeFinanceNumber,'')
	
	--Audit Log for Warrant No
	IF(@strTradeFinanceNumber <> @strOldTradeFinanceNumber)
	BEGIN
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intLotId					-- Primary Key Value of the Ticket. 
			,@screenName		= 'Inventory.view.Warrant'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Updated'					-- Action Type
			,@changeDescription	= 'Trade Finance Number'		-- Description
			,@fromValue			= @strOldTradeFinanceNumber						-- Old Value
			,@toValue			= @strTradeFinanceNumber		-- New Value
			,@details			= '';
	END

	---- Update IR trade finance
	-- IF OBJECT_ID('tempdb..#tmpReceiptList') IS NOT NULL  					
	-- 	DROP TABLE #tmpReceiptList	

	-- SELECT DISTINCT
	-- 	C.intInventoryReceiptId
	-- 	,C.strTradeFinanceNumber
	-- 	,C.strReceiptNumber
	-- INTO #tmpReceiptList
	-- FROM tblICInventoryReceiptItemLot A
	-- INNER JOIN tblICInventoryReceiptItem B
	-- 	ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	-- INNER JOIN tblICInventoryReceipt C
	-- 	ON B.intInventoryReceiptId = C.intInventoryReceiptId
	-- WHERE A.intLotId = @intLotId
	-- ORDER BY C.intInventoryReceiptId

	-- SELECT TOP 1 
	-- 	@_intInventoryReceiptId = intInventoryReceiptId
	-- FROM #tmpReceiptList
	-- ORDER BY intInventoryReceiptId

	-- WHILE ISNULL(@_intInventoryReceiptId,0) > 0
	-- BEGIN
	-- 	SELECT TOP 1
	-- 		@_strOldTradeFinanceNumber = strTradeFinanceNumber
	-- 		,@_strReceiptNumber = strReceiptNumber
	-- 	FROM #tmpReceiptList
	-- 	WHERE intInventoryReceiptId = @_intInventoryReceiptId

	-- 	IF(ISNULL(@_strOldTradeFinanceNumber,'') <> @strTradeFinanceNumber)
	-- 	BEGIN
	-- 		UPDATE tblICInventoryReceipt
	-- 		SET strTradeFinanceNumber = @strTradeFinanceNumber
	-- 		WHERE intInventoryReceiptId = @_intInventoryReceiptId

	-- 		SET @_logDescription = 'Trade Finance Number for ' + @_strReceiptNumber
	-- 		EXEC dbo.uspSMAuditLog 
	-- 		@keyValue			= @intLotId					-- Primary Key Value of the Ticket. 
	-- 		,@screenName		= 'Inventory.view.Warrant'		-- Screen Namespace
	-- 		,@entityId			= @intUserId				-- Entity Id.
	-- 		,@actionType		= 'Updated'					-- Action Type
	-- 		,@changeDescription	= @_logDescription		-- Description
	-- 		,@fromValue			= @_strOldTradeFinanceNumber						-- Old Value
	-- 		,@toValue			= @strTradeFinanceNumber			-- New Value
	-- 		,@details			= '';
	-- 	END

	-- 	SET @_intInventoryReceiptId = (
	-- 									SELECT TOP 1 
	-- 										intInventoryReceiptId
	-- 									FROM #tmpReceiptList
	-- 									WHERE intInventoryReceiptId > @_intInventoryReceiptId
	-- 									ORDER BY intInventoryReceiptId
	-- 								)
	-- END
	

END