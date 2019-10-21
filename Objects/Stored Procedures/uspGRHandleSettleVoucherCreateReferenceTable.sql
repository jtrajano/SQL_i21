CREATE PROCEDURE [dbo].[uspGRHandleSettleVoucherCreateReferenceTable]
	@strBatchId AS NVARCHAR(40)
	,@SettleVoucherCreate AS SettleVoucherCreate READONLY
AS
	


	MERGE	
	INTO	dbo.[tblGRSettleVoucherCreateReferenceTable] 
	WITH	(HOLDLOCK) 
	AS		RefTable	
	USING (
			SELECT	
			strBatchId = @strBatchId
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
			from
			@SettleVoucherCreate
	) AS Source_Query  
		ON RefTable.intItemId = Source_Query.intItemId
		and RefTable.strBatchId = Source_Query.strBatchId
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
		)		
	;
	
RETURN 0

