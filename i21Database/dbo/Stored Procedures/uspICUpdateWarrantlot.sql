CREATE PROCEDURE [dbo].[uspICUpdateWarrantlot]
  @intLotId INT 
  ,@intUserId INT
  ,@strWarrantStatus NVARCHAR(100) = ''
  ,@strWarrantNo NVARCHAR(100) = ''
  ,@strTradeFinanceNumber NVARCHAR(100) = ''
AS

BEGIN

    DECLARE @strOldWarrantStatus NVARCHAR(100) = ''
	DECLARE @strOldWarrantNo NVARCHAR(100) = ''
	DECLARE @_strOldTradeFinanceNumber NVARCHAR(100) = ''
	DECLARE @_intInventoryReceiptId INT
	DECLARE @_strReceiptNumber NVARCHAR(100) = ''
	DECLARE @_logDescription NVARCHAR(MAX) = ''
	DECLARE @intWarrantStatus INT


	--GEt  Old data
	SELECT TOP 1
		@strOldWarrantStatus = ISNULL(B.strWarrantStatus,'')
		,@strOldWarrantNo = A.strWarrantNo
	FROM tblICLot A
	LEFT JOIN tblICWarrantStatus B
		ON A.intWarrantStatus  = B.intWarrantStatus
	WHERE intLotId = @intLotId

	
	--Get Warrant Status Id
	SELECT TOP 1
		@intWarrantStatus = intWarrantStatus
	FROM tblICWarrantStatus
	WHERE strWarrantStatus =  @strWarrantStatus

	--update data
	UPDATE tblICLot
	SET strWarrantNo = @strWarrantNo
		,intWarrantStatus = ISNULL(@intWarrantStatus,intWarrantStatus)
	WHERE intLotId = @intLotId


	--Audit Log for Warrant Status
	IF(ISNULL(@intWarrantStatus,0) > 0 AND @strWarrantStatus <> @strOldWarrantStatus )
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

	---- Update IR trade finance
	IF OBJECT_ID('tempdb..#tmpReceiptList') IS NOT NULL  					
		DROP TABLE #tmpReceiptList	

	SELECT DISTINCT
		C.intInventoryReceiptId
		,C.strTradeFinanceNumber
		,C.strReceiptNumber
	INTO #tmpReceiptList
	FROM tblICInventoryReceiptItemLot A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt C
		ON B.intInventoryReceiptId = C.intInventoryReceiptId
	WHERE A.intLotId = @intLotId
	ORDER BY C.intInventoryReceiptId

	SELECT TOP 1 
		@_intInventoryReceiptId = intInventoryReceiptId
	FROM #tmpReceiptList
	ORDER BY intInventoryReceiptId

	WHILE ISNULL(@_intInventoryReceiptId,0) > 0
	BEGIN
		SELECT TOP 1
			@_strOldTradeFinanceNumber = strTradeFinanceNumber
			,@_strReceiptNumber = strReceiptNumber
		FROM #tmpReceiptList
		WHERE intInventoryReceiptId = @_intInventoryReceiptId

		IF(ISNULL(@_strOldTradeFinanceNumber,'') <> @strTradeFinanceNumber)
		BEGIN
			UPDATE tblICInventoryReceipt
			SET strTradeFinanceNumber = @strTradeFinanceNumber
			WHERE intInventoryReceiptId = @_intInventoryReceiptId

			SET @_logDescription = 'Trade Finance Number for ' + @_strReceiptNumber
			EXEC dbo.uspSMAuditLog 
			@keyValue			= @intLotId					-- Primary Key Value of the Ticket. 
			,@screenName		= 'Inventory.view.Warrant'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Updated'					-- Action Type
			,@changeDescription	= @_logDescription		-- Description
			,@fromValue			= @_strOldTradeFinanceNumber						-- Old Value
			,@toValue			= @strTradeFinanceNumber			-- New Value
			,@details			= '';
		END

		SET @_intInventoryReceiptId = (
										SELECT TOP 1 
											intInventoryReceiptId
										FROM #tmpReceiptList
										WHERE intInventoryReceiptId > @_intInventoryReceiptId
										ORDER BY intInventoryReceiptId
									)
	END
	

END