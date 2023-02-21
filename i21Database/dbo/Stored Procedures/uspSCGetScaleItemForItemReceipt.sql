CREATE PROCEDURE [dbo].[uspSCGetScaleItemForItemReceipt]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (13,3)
	,@dblCost AS DECIMAL (9,5)
	,@intEntityId AS INT
	,@intContractId INT
	,@strDistributionOption AS NVARCHAR(3)
	,@LineItems ScaleTransactionTableType  ReadOnly
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrMsg NVARCHAR(MAX)
		,@intDirectType AS INT = 3

BEGIN TRY
		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		BEGIN
			BEGIN 
				SELECT	intItemId = ScaleTicket.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
						,dblQty = LI.dblUnitsDistributed 
						,dblUOMQty = ISNULL(ScaleTicket.dblScheduleQty,0.0)
						,dblCost = LI.dblCost
						,dblSalesPrice = 0
						,intCurrencyId = ISNULL(LI.intCurrencyId,ScaleTicket.intCurrencyId)
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = ScaleTicket.intTicketId
						,intTransactionDetailId = LI.intContractDetailId
						,strTransactionId = ScaleTicket.strTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsStorage = 0
						,strSourceTransactionId = @strDistributionOption
						,intStorageScheduleTypeId = ScaleTicket.intStorageScheduleTypeId
						,ysnAllowVoucher = CASE WHEN(CTD.intPricingTypeId = 2) THEN 0 ELSE 1 END--CASE WHEN LI.dblCost = 0 THEN 0 ELSE 1 END
						,intSourceTransactionId  = CASE WHEN @strDistributionOption = 'LOD' THEN ScaleTicket.intLoadDetailId ELSE NULL END
				FROM	@LineItems LI 
				INNER JOIN dbo.tblSCTicket ScaleTicket On ScaleTicket.intTicketId = LI.intTicketId
				INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemUOMIdTo = ItemUOM.intItemUOMId
				INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
				INNER JOIN tblCTContractDetail CTD ON LI.intContractDetailId = CTD.intContractDetailId
				WHERE LI.intTicketId = @intTicketId
			END
		END
		ELSE
		BEGIN 
			SELECT	intItemId = ScaleTicket.intItemId
					,intLocationId = ItemLocation.intItemLocationId 
					,intItemUOMId = ItemUOM.intItemUOMId
					,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
					,dblQty = @dblNetUnits 
					,dblUOMQty = ItemUOM.dblUnitQty
					,dblCost =  CASE 
							WHEN ISNULL(@dblCost , 0) > 0 THEN @dblCost
							ELSE
							ISNULL(
								(SELECT dbo.fnCTConvertQtyToTargetItemUOM(ScaleTicket.intItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice) + ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(ScaleTicket.intItemUOMIdTo,basisUOM.intItemUOMId,dblBasis), 0)
								FROM dbo.fnRKGetFutureAndBasisPrice (
									1 -- intTicketType
									,ScaleTicket.intCommodityId -- intCommodityId
									,right(convert(varchar, ScaleTicket.dtmTicketDateTime, 106),8) -- strSeqMonth
									,3 -- intSequenceTypeId
									,NULL -- intFutureMarketId
									,NULL -- intFutureMonthId
									,ScaleTicket.intProcessingLocationId -- intLocationId
									,NULL -- intMarketZoneId
									,0 -- dblBasisCost
									,ScaleTicket.intItemId -- intItemId
									,ScaleTicket.intCurrencyId -- intCurrencyId
								)
								LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId AND futureUOM.intItemId = ScaleTicket.intItemId
								LEFT JOIN tblICItemUOM basisUOM ON basisUOM.intUnitMeasureId = intBasisUOMId AND basisUOM.intItemId = ScaleTicket.intItemId),0
							)
							END
					,dblSalesPrice = 0
					,intCurrencyId = ScaleTicket.intCurrencyId
					,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
					,intTransactionId = ScaleTicket.intTicketId
					,intTransactionDetailId = NULL
					,strTransactionId = ScaleTicket.strTicketNumber
					,intTransactionTypeId = @intDirectType 
					,intLotId = NULL 
					,intSubLocationId = ScaleTicket.intSubLocationId
					,intStorageLocationId = ScaleTicket.intStorageLocationId
					,ysnIsStorage = 0
					,strSourceTransactionId = @strDistributionOption
					,intStorageScheduleTypeId = ScaleTicket.intStorageScheduleTypeId
					,ysnAllowVoucher = CASE WHEN @dblCost = 0 THEN 0 ELSE 1 END
					,intSourceTransactionId = CASE WHEN @strDistributionOption = 'LOD' THEN ScaleTicket.intLoadDetailId ELSE NULL END
			FROM	dbo.tblSCTicket ScaleTicket
					INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemUOMIdTo = ItemUOM.intItemUOMId
					INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
			WHERE	ScaleTicket.intTicketId = @intTicketId
		END
END TRY

BEGIN CATCH

       SET @ErrMsg = 'uspSCGetScaleItemForItemReceipt - ' + ERROR_MESSAGE()  
       RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
       
END CATCH

-- TODO: IF @strSourceType = @@ReceiptType_TransferOrder
-- TODO: IF @strSourceType = @@ReceiptType_TransferOrder