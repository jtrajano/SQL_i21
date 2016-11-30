CREATE PROCEDURE [dbo].[uspGRReverseSettleStorage]
	 @InventoryReceiptId INT
	,@UserKey INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intCustomerStorageId INT
	DECLARE @intSourceType INT
	DECLARE @dblLineItemQty DECIMAL(24, 10)
	DECLARE @intContractDetailId INT
	DECLARE @intContractHeaderId INT
	DECLARE @ItemId INT
	DECLARE @intUnitMeasureId INT
	DECLARE @intSourceItemUOMId INT

	SELECT TOP 1 @intSourceType = intSourceType
	FROM dbo.tblICTransactionDetailLog
	WHERE intTransactionId = @InventoryReceiptId

	IF @intSourceType = 4
	BEGIN
		
		SELECT TOP 1 @intCustomerStorageId = intSourceNumberId
		FROM dbo.tblICTransactionDetailLog
		WHERE intTransactionId = @InventoryReceiptId

		SELECT @dblLineItemQty = SUM(dblQuantity)
		FROM tblICTransactionDetailLog
		WHERE intTransactionId = @InventoryReceiptId

		--1. Updating Ticket Open Balance.
		UPDATE tblGRCustomerStorage
		SET dblOpenBalance = dblOpenBalance + @dblLineItemQty
		FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intCustomerStorageId

		--2. DP Contract Quantity Increase.
		IF EXISTS (
				SELECT 1
				FROM tblGRStorageHistory
				WHERE intCustomerStorageId = @intCustomerStorageId
					AND intContractHeaderId IS NOT NULL
					AND strType IN ('From Scale','From Transfer')
				)
		BEGIN
			SELECT TOP 1 @ItemId = intItemId
			FROM tblICTransactionDetailLog
			WHERE intTransactionId = @InventoryReceiptId

			SELECT @intUnitMeasureId = a.intUnitMeasureId
			FROM tblICCommodityUnitMeasure a
			JOIN tblICItem b ON b.intCommodityId = a.intCommodityId
			WHERE b.intItemId = @ItemId AND a.ysnStockUnit = 1

			SELECT @intSourceItemUOMId = intItemUOMId
			FROM tblICItemUOM UOM
			WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId

			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblGRStorageHistory
			WHERE intCustomerStorageId = @intCustomerStorageId
				AND intContractHeaderId IS NOT NULL
				AND strType IN ('From Scale','From Transfer')

			SELECT @intContractDetailId = intContractDetailId
			FROM   vyuCTContractDetailView
			WHERE  intContractHeaderId = @intContractHeaderId

			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				 @intContractDetailId = @intContractDetailId
				,@dblQuantityToUpdate = @dblLineItemQty
				,@intUserId = @UserKey
				,@intExternalId = @intCustomerStorageId
				,@strScreenName = 'Settle Storage'
				,@intSourceItemUOMId = @intSourceItemUOMId
		END
	END
END TRY

BEGIN CATCH
	
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH