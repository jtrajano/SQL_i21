CREATE PROCEDURE [dbo].[uspAPCreateVoucherForClearing]  
	@vendorId INT  
	,@intItemId INT  
	,@intInventoryReceiptItemId INT = NULL  
	,@intInventoryReceiptChargeId INT = NULL  
	,@intInventoryShipmentChargeId INT = NULL  
	,@intLoadDetailId INT = NULL  
	,@intCustomerStorageId INT = NULL  
	,@userId INT  
	,@voucherId INT OUT  
AS  
  
BEGIN  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRY  
  
DECLARE @billCreated INT;  
DECLARE @transCount INT = @@TRANCOUNT;  
IF @transCount = 0 BEGIN TRANSACTION;  
  
--RECEIPT ITEM  
IF @intInventoryReceiptItemId > 0 AND @intInventoryReceiptChargeId IS NULL  
BEGIN  
	DECLARE @voucherDetailReceiptItem AS VoucherDetailReceipt  

	INSERT INTO @voucherDetailReceiptItem(intInventoryReceiptType,intInventoryReceiptItemId,dblQtyReceived,dblCost,intTaxGroupId)  
	SELECT  
		[intInventoryReceiptType]  = CASE   
			WHEN B.strReceiptType = 'Direct' THEN 1   
			WHEN B.strReceiptType = 'Purchase Contract' THEN 2  
			WHEN B.strReceiptType = 'Purchase Order' THEN 3  
			WHEN B.strReceiptType = 'Inventory Return' THEN 4  
			END  
		,[intInventoryReceiptItemId] = A.intInventoryReceiptItemId  
		,[dblQtyReceived]    = A.dblOpenReceive - A.dblBillQty     
		,[dblCost]      = A.dblUnitCost   
		,[intTaxGroupId]    = NULLIF(A.intTaxGroupId,0)  
	FROM tblICInventoryReceiptItem A  
	INNER JOIN tblICInventoryReceipt B  
	ON A.intInventoryReceiptId = B.intInventoryReceiptId  
	WHERE 
		A.intInventoryReceiptItemId = @intInventoryReceiptItemId  
	AND B.intEntityVendorId = @vendorId

	EXEC uspAPCreateBillData @vendorId = @vendorId, @userId = @userId, @voucherDetailReceipt = @voucherDetailReceiptItem, @billId = @billCreated OUT  

	SET @voucherId = @billCreated  
END  
ELSE IF @intInventoryReceiptChargeId > 0  
BEGIN  
	DECLARE @voucherDetailReceiptCharge AS VoucherDetailReceiptCharge  
	INSERT INTO @voucherDetailReceiptCharge(intInventoryReceiptChargeId,dblQtyReceived,dblCost,intTaxGroupId)  
	SELECT  
		[intInventoryReceiptChargeId] = A.intInventoryReceiptChargeId  
		,[dblQtyReceived]    = A.dblQuantityToBill  
		,[dblCost]      = A.dblUnitCost   
		,[intTaxGroupId]    = NULLIF(A.intTaxGroupId,0)  
	FROM vyuICChargesForBilling A  
	WHERE A.intInventoryReceiptChargeId = @intInventoryReceiptChargeId AND A.intEntityVendorId = @vendorId

	EXEC uspAPCreateBillData @vendorId = @vendorId, @userId = @userId, @voucherDetailReceiptCharge = @voucherDetailReceiptCharge, @billId = @billCreated OUT  

	SET @voucherId = @billCreated  
END  
ELSE IF @intLoadDetailId > 0  
BEGIN  
	DECLARE @voucherDetailLoadNonInv AS VoucherDetailLoadNonInv  
	INSERT INTO @voucherDetailLoadNonInv (
		intContractHeaderId
		,intContractDetailId
		,intItemId
		,intAccountId
		,intLoadDetailId
		,dblQtyReceived
		,dblCost
		,intCostUOMId
		,intItemUOMId
		,dblUnitQty
		,dblCostUnitQty
		)
	SELECT 
		intContractHeaderId
		,intContractDetailId
		,intItemId
		,ISNULL(intAccountId, 0)
		,intLoadDetailId
		,dblQtyReceived
		,dblCost
		,intCostUOMId
		,intItemUOMId
		,dblUnitQty
		,dblCostUnitQty
	FROM
	(
		SELECT V.intEntityVendorId
			,LD.intLoadId
			,LD.intLoadDetailId
			,CH.intContractHeaderId
			,CD.intContractDetailId
			,V.intItemId
			,intAccountId = [dbo].[fnGetItemGLAccount](V.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
			,dblQtyReceived = CASE WHEN V.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
			,dblCost = CASE WHEN V.strCostMethod IN ('Amount','Percentage') THEN ISNULL(V.dblTotal, V.dblPrice) ELSE ISNULL(V.dblPrice, V.dblTotal) END 
			,V.intPriceItemUOMId AS intCostUOMId
			,V.intLoadCostId
			,I.ysnInventoryCost
			,LD.intItemUOMId
			,CASE WHEN V.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END AS dblUnitQty
			,CASE WHEN V.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(CostUOM.dblUnitQty,1) END AS dblCostUnitQty
		FROM vyuLGLoadCostForVendor V
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = V.intLoadDetailId
		JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN ISNULL(LD.intPContractDetailId, 0) = 0
					THEN LD.intSContractDetailId
				ELSE LD.intPContractDetailId
				END
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
			AND ItemLoc.intLocationId = CD.intCompanyLocationId
		JOIN tblICItem I ON I.intItemId = V.intItemId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
		LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = V.intPriceItemUOMId
		WHERE 
			LD.intLoadDetailId = @intLoadDetailId AND V.intEntityVendorId = @vendorId
		AND L.intPurchaseSale = 2 --Outbound type is the only type that have AP Clearing for cost, this is also driven by company config
		AND V.ysnAccrue = 1
		GROUP BY V.intEntityVendorId
			,CH.intContractHeaderId
			,CD.intContractDetailId
			,ItemLoc.intItemLocationId
			,V.intItemId
			,V.intLoadId
			,V.strLoadNumber
			,V.dblNet
			,LD.intLoadId
			,LD.intLoadDetailId
			,V.intLoadCostId
			,I.ysnInventoryCost
			,LD.intItemUOMId
			,V.intPriceItemUOMId
			,ItemUOM.dblUnitQty
			,CostUOM.dblUnitQty
			,LD.dblQuantity
			,V.strCostMethod
			,V.dblPrice
			,V.dblTotal
		UNION ALL
		SELECT LD.intVendorEntityId
			,L.intLoadId
			,LD.intLoadDetailId
			,CH.intContractHeaderId
			,CD.intContractDetailId
			,LD.intItemId
			,intAccountId = [dbo].[fnGetItemGLAccount](LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
			,dblQtyReceived = LD.dblQuantity
			,dblCost = CASE 
				WHEN AD.ysnSeqSubCurrency = 1
					THEN ISNULL(AD.dblSeqPrice, 0) / 100
				ELSE ISNULL(AD.dblSeqPrice, 0)
				END
			,AD.intSeqPriceUOMId
			,NULL
			,NULL
			,LD.intItemUOMId
			,ISNULL(ItemUOM.dblUnitQty,1)
			,ISNULL(CostUOM.dblUnitQty,1)
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
			AND ItemLoc.intLocationId = CD.intCompanyLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation SLCL ON SLCL.intCompanyLocationSubLocationId = LD.intPSubLocationId
			AND ItemLoc.intLocationId = SLCL.intCompanyLocationId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
		LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = CD.intPriceItemUOMId
		WHERE 
			LD.intLoadDetailId = @intLoadDetailId
		AND L.ysnPosted = 1
		AND L.intPurchaseSale IN (1,3) --Inbound/Drop Ship load shipment type only have AP Clearing GL Entries.
		AND L.intSourceType != 1 --Source Type should not be 'None'
		GROUP BY LD.intVendorEntityId
			,CH.intContractHeaderId
			,CD.intContractDetailId
			,LD.intItemId
			,ItemLoc.intItemLocationId
			,LD.dblNet
			,L.intLoadId
			,L.strLoadNumber
			,LD.intLoadDetailId
			,AD.ysnSeqSubCurrency
			,AD.dblQtyToPriceUOMConvFactor
			,AD.dblSeqPrice
			,LD.dblQuantity
			,LD.intItemUOMId
			,AD.intSeqPriceUOMId
			,ItemUOM.dblUnitQty
			,CostUOM.dblUnitQty
	) loadData

	EXEC uspAPCreateBillData @vendorId = @vendorId, @userId = @userId, @voucherDetailLoadNonInv = @voucherDetailLoadNonInv, @billId = @billCreated OUT  

	SET @voucherId = @billCreated  
END  
ELSE IF @intInventoryShipmentChargeId > 0  
BEGIN
	DECLARE @isVendor BIT = 1;

	CREATE TABLE #tmpBillId (
		[intBillId] [INT] PRIMARY KEY,
		[intInventoryShipmentId] [INT],
		[intEntityVendorId] [INT],
		[intCurrencyId] [INT]
	)

	DECLARE @shipmentId INT;
	DECLARE @shipmentChargeId INT;

	SELECT 
		@shipmentId = A.intInventoryShipmentId
		,@isVendor = CASE WHEN C.intEntityId IS NULL THEN 0 ELSE 1 END
	FROM tblICInventoryShipmentCharge A
	INNER JOIN tblICInventoryShipment B
		ON A.intInventoryShipmentId = B.intInventoryShipmentId
	LEFT JOIN tblAPVendor C
		ON B.intEntityCustomerId = C.intEntityId
	WHERE A.intInventoryShipmentChargeId = @intInventoryShipmentChargeId

	IF @isVendor = 0
	BEGIN
		RAISERROR('Customer is not configured as vendor type.', 16, 1);
		RETURN;
	END

	INSERT INTO #tmpBillId
	EXEC dbo.[uspAPCreateBillFromShipmentCharge] 
		@shipmentId = @shipmentId,
		@shipmentChargeId = @intInventoryShipmentChargeId,
		@userId = @userId

	SELECT TOP 1 @voucherId = intBillId FROM #tmpBillId
END
ELSE IF @intCustomerStorageId > 0  
BEGIN
	RAISERROR('You cannot create voucher for settle storage. Please use the settle storage screen.', 16, 1);
	RETURN;
END
  
IF @transCount = 0 COMMIT TRANSACTION;  
  
END TRY  
BEGIN CATCH  
	DECLARE @ErrorSeverity INT,  
		@ErrorNumber   INT,  
		@ErrorMessage nvarchar(4000),  
		@ErrorState INT,  
		@ErrorLine  INT,  
		@ErrorProc nvarchar(200);  
	-- Grab error information from SQL functions  
	SET @ErrorSeverity = ERROR_SEVERITY()  
	SET @ErrorNumber   = ERROR_NUMBER()  
	SET @ErrorMessage  = ERROR_MESSAGE()  
	SET @ErrorState    = ERROR_STATE()  
	SET @ErrorLine     = ERROR_LINE()  
	SET @ErrorProc     = ERROR_PROCEDURE()  

	-- SET @ErrorMessage  = 'Error creating voucher.' + CHAR(13) +   
	-- 'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) +   
	-- ' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage  

	IF (XACT_STATE()) = -1  
	BEGIN  
		ROLLBACK TRANSACTION  
	END  
	ELSE IF (XACT_STATE()) = 1 AND @transCount = 0  
	BEGIN  
		ROLLBACK TRANSACTION  
	END  

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)  
END CATCH  
  
RETURN 0  
END  