CREATE PROCEDURE [dbo].[uspCTAddPurchaseContractToInventoryReceipt]
	@PurchaseContractId AS INT
	,@intEntityUserSecurityId AS INT
	,@InventoryReceiptId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;
DECLARE @ReceiptNumber AS NVARCHAR(20)

DECLARE @ReceiptType_PurchaseContract AS NVARCHAR(100) = 'Purchase Contract'

IF @PurchaseContractId IS NULL 
BEGIN 
    -- Raise the error:
    -- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Contract to Inventory Receipt.
	EXEC uspICRaiseError 80043; 
    GOTO _Exit
END

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 

-- Insert the Inventory Receipt header 
INSERT INTO dbo.tblICInventoryReceipt (
		strReceiptNumber
		,dtmReceiptDate
		,intEntityVendorId
		,strReceiptType
		,intSourceType
		,intBlanketRelease
		,intLocationId
		,strVendorRefNo
		,strBillOfLading
		,intShipViaId
		,intShipFromId
		,intReceiverId
		,intCurrencyId
		,strVessel
		,intFreightTermId
		,intShiftNumber
		,dblInvoiceAmount
		,ysnInvoicePaid
		,intCheckNo
		,dtmCheckDate
		,intTrailerTypeId
		,dtmTrailerArrivalDate
		,dtmTrailerArrivalTime
		,strSealNo
		,strSealStatus
		,dtmReceiveTime
		,dblActualTempReading
		,intConcurrencyId
		,intEntityId
		,ysnPosted
)
SELECT 	strReceiptNumber		= @ReceiptNumber
		,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
		,intEntityVendorId		= Contract.intEntityId
		,strReceiptType			= @ReceiptType_PurchaseContract
		,intSourceType			= 0
		,intBlanketRelease		= NULL
		,intLocationId			= NULL -- We need this populated
		,strVendorRefNo			= NULL
		,strBillOfLading		= NULL
		,intShipViaId			= NULL
		,intShipFromId			= NULL
		,intReceiverId			= @intEntityUserSecurityId 
		,intCurrencyId			= NULL
		,strVessel				= NULL
		,intFreightTermId		= NULL
		,intShiftNumber			= NULL 
		,dblInvoiceAmount		= 0
		,ysnInvoicePaid			= 0 
		,intCheckNo				= NULL 
		,dteCheckDate			= NULL 
		,intTrailerTypeId		= NULL 
		,dteTrailerArrivalDate	= NULL 
		,dteTrailerArrivalTime	= NULL 
		,strSealNo				= NULL 
		,strSealStatus			= NULL 
		,dteReceiveTime			= NULL 
		,dblActualTempReading	= NULL 
		,intConcurrencyId		= 1
		,intEntityId			= @intEntityUserSecurityId
		,ysnPosted				= 0
FROM	dbo.tblCTContractHeader Contract
WHERE	Contract.intContractHeaderId = @PurchaseContractId

-- Get the identity value from tblICInventoryReceipt
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

--IF @InventoryReceiptId IS NULL 
--BEGIN 
--	-- Raise the error:
--	-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
--	RAISERROR(80004, 11, 1);
--	GOTO _Exit
--END

INSERT INTO dbo.tblICInventoryReceiptItem (
	intInventoryReceiptId
    ,intLineNo
	,intOrderId
    ,intItemId
	,intSubLocationId
	,dblOrderQty
	,dblOpenReceive
	,dblReceived
    ,intUnitMeasureId
	,intWeightUOMId
    ,dblUnitCost
	,dblLineTotal
    ,intSort
    ,intConcurrencyId
)
SELECT	intInventoryReceiptId	= @InventoryReceiptId
		,intLineNo				= ContractDetail.intContractDetailId
		,intOrderId				= @PurchaseContractId
		,intItemId				= ContractDetail.intItemId
		,intSubLocationId		= NULL
		,dblOrderQty			= ISNULL(ContractDetail.dblQuantity, 0)
		,dblOpenReceive			= ISNULL(ContractDetail.dblBalance, 0)
		,dblReceived			= ISNULL(ContractDetail.dblQuantity, 0) - ISNULL(ContractDetail.dblBalance, 0)
		,intUnitMeasureId		= ItemUOM.intItemUOMId
		,intWeightUOMId			=	(
										SELECT	TOP 1 
												tblICItemUOM.intItemUOMId 
										FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
													ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
										WHERE	tblICItemUOM.intItemId = ContractDetail.intItemId 
												AND tblICItemUOM.ysnStockUnit = 1 
												AND tblICUnitMeasure.strUnitType = 'Weight'
												AND dbo.fnGetItemLotType(ContractDetail.intItemId) <> 0 
									)
		,dblUnitCost			= ContractDetail.dblCashPrice
		,dblLineTotal			= ISNULL(ContractDetail.dblBalance, 0) * ContractDetail.dblCashPrice
		,intSort				= ContractDetail.intContractSeq
		,intConcurrencyId		= 1
FROM	dbo.tblCTContractDetail ContractDetail
		INNER JOIN dbo.tblICItemUOM ItemUOM			
			ON ItemUOM.intItemId = ContractDetail.intItemId
			AND ItemUOM.intItemUOMId = ContractDetail.intItemUOMId
		INNER JOIN dbo.tblICUnitMeasure UOM
			ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
WHERE	ContractDetail.intContractHeaderId = @PurchaseContractId
		AND dbo.fnIsStockTrackingItem(ContractDetail.intItemId) = 1

INSERT INTO tblICInventoryReceiptCharge
(
		intInventoryReceiptId,
		intChargeId,
		ysnInventoryCost,
		strCostMethod,
		dblRate,
		intCostUOMId,
		intEntityVendorId,
		dblAmount,
		strAllocateCostBy,
--		strCostBilledBy,
		intSort,
		intConcurrencyId
)
SELECT	@InventoryReceiptId, 
		CC.intItemId,
		0,
		CC.strCostMethod,
		SUM(CC.dblRate),
		CC.intItemUOMId,
		CC.intVendorId,
		NULL,
		NULL,
--		'Vendor',
		NULL,
		1
FROM	tblCTContractCost CC
JOIN	tblCTContractDetail CD ON CC.intContractDetailId = CC.intContractDetailId AND CD.intContractHeaderId = @PurchaseContractId
GROUP 
BY		CC.intItemId,
		CC.intVendorId,
		CC.strCostMethod,
		CC.intItemUOMId

--Re-update the total cost 
UPDATE	Receipt
SET		dblInvoiceAmount = (
			SELECT	ISNULL(SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0)) , 0)
			FROM	dbo.tblICInventoryReceiptItem ReceiptItem
			WHERE	ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		)
FROM	dbo.tblICInventoryReceipt Receipt 
WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId



_Exit: 
