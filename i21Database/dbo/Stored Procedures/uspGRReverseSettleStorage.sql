CREATE PROCEDURE [dbo].[uspGRReverseSettleStorage]
	  @ItemId INT
	 ,@SourceNumberId INT
	 ,@Quantity	 DECIMAL(24,10)
	 ,@UserKey INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)	
	DECLARE @intContractDetailId INT
	DECLARE @intContractHeaderId INT	
	DECLARE @intUnitMeasureId INT
	DECLARE @intSourceItemUOMId INT
	
	--1. Updating Ticket Open Balance.
		UPDATE tblGRCustomerStorage
		SET dblOpenBalance = dblOpenBalance + @Quantity
		FROM tblGRCustomerStorage WHERE intCustomerStorageId = @SourceNumberId

		--2. DP Contract Quantity Increase.
		IF EXISTS (
				SELECT 1
				FROM tblGRStorageHistory
				WHERE intCustomerStorageId = @SourceNumberId
					AND intContractHeaderId IS NOT NULL
					AND strType IN ('From Scale','From Transfer')
				)
		BEGIN
		
			SELECT @intUnitMeasureId = a.intUnitMeasureId
			FROM tblICCommodityUnitMeasure a
			JOIN tblICItem b ON b.intCommodityId = a.intCommodityId
			WHERE b.intItemId = @ItemId AND a.ysnStockUnit = 1

			SELECT @intSourceItemUOMId = intItemUOMId
			FROM tblICItemUOM UOM
			WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId

			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblGRStorageHistory
			WHERE intCustomerStorageId = @SourceNumberId
				AND intContractHeaderId IS NOT NULL
				AND strType IN ('From Scale','From Transfer')

			SELECT @intContractDetailId = intContractDetailId
			FROM   vyuCTContractDetailView
			WHERE  intContractHeaderId = @intContractHeaderId
			
			SELECT @Quantity = dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,@Quantity)
							   FROM tblGRCustomerStorage CS
							   JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1
							   WHERE intCustomerStorageId = @SourceNumberId

			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				 @intContractDetailId = @intContractDetailId
				,@dblQuantityToUpdate = @Quantity
				,@intUserId = @UserKey
				,@intExternalId = @SourceNumberId
				,@strScreenName = 'Settle Storage'
				,@intSourceItemUOMId = @intSourceItemUOMId
		END

END TRY

BEGIN CATCH
	
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH