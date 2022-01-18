CREATE TABLE [dbo].[tblGRSettleVoucherCreateReferenceTable]
(
	intSettleVoucherCreateReferenceTableId INT IDENTITY(1, 1)
	,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intCustomerStorageId INT
	,intCompanyLocationId INT
	,intContractHeaderId INT NULL
	,intContractDetailId INT NULL
	,dblUnits DECIMAL(24, 10)
	,dblCashPrice DECIMAL(24, 10)
	,intItemId INT NULL
	,intItemType INT NULL
	,IsProcessed BIT
	,intTicketDiscountId INT NULL
	,intPricingTypeId INT
	,dblBasis DECIMAL(24, 10)
	,intContractUOMId INT NULL
	,dblCostUnitQty DECIMAL(24, 10) NULL
	,dblSettleContractUnits DECIMAL(24,10) NULL
	,ysnDiscountFromGrossWeight BIT NULL
	,ysnItemInventoryCost BIT NULL,
	,intTransactionId INT NULL
)
