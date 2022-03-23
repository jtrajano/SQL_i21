CREATE PROCEDURE [dbo].[uspGRHandleSettleVoucherCreateReferenceTable]
	@strBatchId AS NVARCHAR(40)
	,@SettleVoucherCreate AS SettleVoucherCreate READONLY
	,@intSettleStorageId INT
AS
	MERGE	
	INTO	dbo.[tblGRSettleVoucherCreateReferenceTable] 
	WITH	(HOLDLOCK) 
	AS		RefTable	
	USING (
			SELECT	
			strBatchId = @strBatchId
			,a.strOrderType
			,a.intCustomerStorageId
			,a.intCompanyLocationId
			,a.intContractHeaderId
			,a.intContractDetailId
			,a.dblUnits
			,a.dblCashPrice
			,a.intItemId
			,a.intItemType
			,a.IsProcessed
			,a.intTicketDiscountId
			,a.intPricingTypeId
			,a.dblBasis
			,a.intContractUOMId
			,a.dblCostUnitQty
			,a.dblSettleContractUnits
			,a.ysnDiscountFromGrossWeight
			,ysnItemInventoryCost = isnull(a.ysnInventoryCost, b.ysnInventoryCost)
			,intTransactionId = @intSettleStorageId
			from
			@SettleVoucherCreate a
				join tblICItem b
					on a.intItemId = b.intItemId
	) AS Source_Query  
		ON RefTable.intItemId = Source_Query.intItemId
		and RefTable.strBatchId = Source_Query.strBatchId
		and RefTable.intTransactionId = Source_Query.intTransactionId
	WHEN NOT MATCHED THEN 
		INSERT (
			strBatchId
			,strOrderType
			,intCustomerStorageId
			,intCompanyLocationId
			,intContractHeaderId
			,intContractDetailId
			,dblUnits
			,dblCashPrice
			,intItemId
			,intItemType
			,IsProcessed
			,intTicketDiscountId
			,intPricingTypeId
			,dblBasis
			,intContractUOMId
			,dblCostUnitQty
			,dblSettleContractUnits
			,ysnDiscountFromGrossWeight
			,ysnItemInventoryCost
			,intTransactionId
		)
		VALUES (
			Source_Query.strBatchId
			,Source_Query.strOrderType
			,Source_Query.intCustomerStorageId
			,Source_Query.intCompanyLocationId
			,Source_Query.intContractHeaderId
			,Source_Query.intContractDetailId
			,Source_Query.dblUnits
			,Source_Query.dblCashPrice
			,Source_Query.intItemId
			,Source_Query.intItemType
			,Source_Query.IsProcessed
			,Source_Query.intTicketDiscountId
			,Source_Query.intPricingTypeId
			,Source_Query.dblBasis
			,Source_Query.intContractUOMId
			,Source_Query.dblCostUnitQty
			,Source_Query.dblSettleContractUnits
			,Source_Query.ysnDiscountFromGrossWeight
			,Source_Query.ysnItemInventoryCost
			,Source_Query.intTransactionId
		)		
	;
	
RETURN 0