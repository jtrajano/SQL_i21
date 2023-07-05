﻿CREATE PROCEDURE [dbo].[uspAPRemoveVoucherPayableTransaction]
	@intInventoryReceiptId INT = NULL,
	@intInventoryShipmentId INT = NULL,
	@intInventoryReceiptChargeId INT = NULL,
	@intLoadShipmentId INT = NULL,
	@intLoadShipmentCostId INT = NULL,
	@intUserId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

BEGIN TRY
	IF @intInventoryReceiptId IS NOT NULL OR @intInventoryShipmentId IS NOT NULL OR @intInventoryReceiptChargeId IS NOT NULL OR @intLoadShipmentId IS NOT NULL OR @intLoadShipmentCostId IS NOT NULL
	BEGIN

		--DELETING TRANSACTIONS FOR RECEIPTS WITHOUT RECORDS ON tblAPVoucherPayableCompleted, WE ARE FORCED TO ADD 
		--WHAT WE HAVE ON tblAPBillDetail, IN THIS WAY USER WOULD ABLE TO CREATE VOUCHER VIA 'ADD PAYABLES'
		--IN THAT WAY, WE DON'T HAVE INFORMATION FOR strSourceNumber
		--IN THIS CASE, tblAPVoucherPayable.strSourceNumber IS BLANK

		--GET intId and strId OF WILL BE DELETED PAYABLE
		DECLARE @intPayableIds AS TABLE (
			intVoucherPayableId INT NOT NULL
			,strReceiptNumber VARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
			,dblQuantityToBill DECIMAL
			--START PAYABLE LINKS TO VOUCHER
			,intEntityVendorId INT NULL
			,intPurchaseDetailId INT NULL
			,intContractDetailId INT NULL
			,intScaleTicketId INT NULL
			,intInventoryReceiptChargeId INT NULL
			,intInventoryReceiptItemId INT NULL
			,intInventoryShipmentChargeId INT NULL
			,intLoadShipmentDetailId INT NULL
			,intLoadShipmentCostId INT NULL
			,intLoadHeaderId INT NULL
			,intWeightClaimDetailId INT NULL
			,intCustomerStorageId INT NULL
			,intSettleStorageId INT NULL
			,intItemId INT NULL
			,intTransactionType INT NOT NULL
		);

		--ADD RECEIPT ITEM
		INSERT INTO @intPayableIds
		SELECT P.intVoucherPayableId, IR.strReceiptNumber, P.dblQuantityToBill
			--START PAYABLE LINKS TO VOUCHER
			,P.intEntityVendorId
			,P.intPurchaseDetailId
			,P.intContractDetailId
			,P.intScaleTicketId
			,P.intInventoryReceiptChargeId
			,P.intInventoryReceiptItemId
			,P.intInventoryShipmentChargeId
			,P.intLoadShipmentDetailId
			,P.intLoadShipmentCostId
			,P.intLoadHeaderId
			,P.intWeightClaimDetailId
			,P.intCustomerStorageId
			,P.intSettleStorageId
			,P.intItemId
			,P.intTransactionType
		FROM tblAPVoucherPayable P 
		INNER JOIN (tblICInventoryReceipt IR INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId)
			ON P.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		WHERE IR.intInventoryReceiptId = @intInventoryReceiptId AND P.intInventoryReceiptChargeId IS NULL

		--ADD RECEIPT CHARGE
		INSERT INTO @intPayableIds
		SELECT P.intVoucherPayableId, IR.strReceiptNumber, P.dblQuantityToBill
			--START PAYABLE LINKS TO VOUCHER
			,P.intEntityVendorId
			,P.intPurchaseDetailId
			,P.intContractDetailId
			,P.intScaleTicketId
			,P.intInventoryReceiptChargeId
			,P.intInventoryReceiptItemId
			,P.intInventoryShipmentChargeId
			,P.intLoadShipmentDetailId
			,P.intLoadShipmentCostId
			,P.intLoadHeaderId
			,P.intWeightClaimDetailId
			,P.intCustomerStorageId
			,P.intSettleStorageId
			,P.intItemId
			,P.intTransactionType
		FROM tblAPVoucherPayable P 
		INNER JOIN (tblICInventoryReceipt IR INNER JOIN tblICInventoryReceiptCharge IRCharge ON IR.intInventoryReceiptId = IRCharge.intInventoryReceiptId)
			ON P.intInventoryReceiptChargeId = IRCharge.intInventoryReceiptChargeId
		WHERE (IR.intInventoryReceiptId = @intInventoryReceiptId AND @intInventoryReceiptChargeId IS NULL AND P.intInventoryReceiptChargeId > 0) OR
		(P.intInventoryReceiptChargeId = @intInventoryReceiptChargeId)

		--ADD INVENTORY SHIPMENT CHARGE
		INSERT INTO @intPayableIds
		SELECT P.intVoucherPayableId, IIS.strShipmentNumber, P.dblQuantityToBill
		--START PAYABLE LINKS TO VOUCHER
		,P.intEntityVendorId
		,P.intPurchaseDetailId
		,P.intContractDetailId
		,P.intScaleTicketId
		,P.intInventoryReceiptChargeId
		,P.intInventoryReceiptItemId
		,P.intInventoryShipmentChargeId
		,P.intLoadShipmentDetailId
		,P.intLoadShipmentCostId
		,P.intLoadHeaderId
		,P.intWeightClaimDetailId
		,P.intCustomerStorageId
		,P.intSettleStorageId
		,P.intItemId
		,P.intTransactionType
		FROM tblAPVoucherPayable P
		INNER JOIN (tblICInventoryShipment IIS INNER JOIN tblICInventoryShipmentCharge ISC ON IIS.intInventoryShipmentId = ISC.intInventoryShipmentId)
			ON P.intInventoryShipmentChargeId = ISC.intInventoryShipmentChargeId
		WHERE IIS.intInventoryShipmentId = @intInventoryShipmentId AND P.intInventoryShipmentChargeId > 0

		--ADD LOAD SHIPMENT DETAIL
		INSERT INTO @intPayableIds
		SELECT P.intVoucherPayableId, L.strLoadNumber, P.dblQuantityToBill
			--START PAYABLE LINKS TO VOUCHER
			,P.intEntityVendorId
			,P.intPurchaseDetailId
			,P.intContractDetailId
			,P.intScaleTicketId
			,P.intInventoryReceiptChargeId
			,P.intInventoryReceiptItemId
			,P.intInventoryShipmentChargeId
			,P.intLoadShipmentDetailId
			,P.intLoadShipmentCostId
			,P.intLoadHeaderId
			,P.intWeightClaimDetailId
			,P.intCustomerStorageId
			,P.intSettleStorageId
			,P.intItemId
			,P.intTransactionType
		FROM tblAPVoucherPayable P 
		INNER JOIN (tblLGLoad L INNER JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId)
			ON P.intLoadShipmentDetailId = LD.intLoadDetailId
		WHERE L.intLoadId = @intLoadShipmentId AND P.intLoadShipmentCostId IS NULL

		--ADD LOAD SHIPMENT DETAIL COST
		INSERT INTO @intPayableIds
		SELECT P.intVoucherPayableId, L.strLoadNumber, P.dblQuantityToBill
			--START PAYABLE LINKS TO VOUCHER
			,P.intEntityVendorId
			,P.intPurchaseDetailId
			,P.intContractDetailId
			,P.intScaleTicketId
			,P.intInventoryReceiptChargeId
			,P.intInventoryReceiptItemId
			,P.intInventoryShipmentChargeId
			,P.intLoadShipmentDetailId
			,P.intLoadShipmentCostId
			,P.intLoadHeaderId
			,P.intWeightClaimDetailId
			,P.intCustomerStorageId
			,P.intSettleStorageId
			,P.intItemId
			,P.intTransactionType
		FROM tblAPVoucherPayable P 
		INNER JOIN tblLGLoad L ON L.intLoadId = P.intLoadShipmentId
		WHERE (L.intLoadId = @intLoadShipmentId AND @intLoadShipmentCostId IS NULL AND P.intLoadShipmentCostId > 0) OR
		(P.intLoadShipmentCostId = @intLoadShipmentCostId)
		
		--VALIDATE IF PAYABLE IS ALREADY VOUCHERED
		DECLARE @vouchers AS TABLE(
			strBillId NVARCHAR(50)
			,intEntityVendorId INT NULL
			,intPurchaseDetailId INT NULL
			,intContractDetailId INT NULL
			,intScaleTicketId INT NULL
			,intInventoryReceiptChargeId INT NULL
			,intInventoryReceiptItemId INT NULL
			,intInventoryShipmentChargeId INT NULL
			,intLoadShipmentDetailId INT NULL
			,intLoadShipmentCostId INT NULL
			,intLoadHeaderId INT NULL
			,intWeightClaimDetailId INT NULL
			,intCustomerStorageId INT NULL
			,intSettleStorageId INT NULL
			,intItemId INT NULL
			,intTransactionType INT NOT NULL
		)

		INSERT INTO @vouchers
		SELECT TOP 10
			A.strBillId
			,A.intEntityVendorId
			,B.intPurchaseDetailId
			,B.intContractDetailId
			,B.intScaleTicketId
			,B.intInventoryReceiptChargeId
			,B.intInventoryReceiptItemId
			,B.intInventoryShipmentChargeId
			,B.intLoadDetailId
			,B.intLoadShipmentCostId
			,B.intLoadHeaderId
			,B.intWeightClaimDetailId
			,B.intCustomerStorageId
			,B.intSettleStorageId
			,B.intItemId
			,A.intTransactionType
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN @intPayableIds C
			ON 	C.intTransactionType = A.intTransactionType
			AND	ISNULL(C.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			AND ISNULL(C.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			AND ISNULL(C.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadDetailId,-1)
			AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(B.intLoadShipmentCostId,-1)
			AND ISNULL(C.intLoadHeaderId,-1) = ISNULL(B.intLoadHeaderId,-1)
			AND ISNULL(C.intWeightClaimDetailId,-1) = ISNULL(B.intWeightClaimDetailId,-1)
			AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
			AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
			AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(B.intLoadShipmentCostId,-1)
			AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(B.intCustomerStorageId,-1)
			AND ISNULL(C.intSettleStorageId,-1) = ISNULL(B.intSettleStorageId,-1)
			AND ISNULL(C.intItemId,-1) = ISNULL(B.intItemId,-1)
		WHERE C.dblQuantityToBill <> 0

		IF EXISTS(SELECT 1 FROM @vouchers)
		BEGIN
			RAISERROR('Unable to delete payable. Payable is already Vouchered', 16, 1);
			RETURN;
		END
		ELSE
		BEGIN
			--DELETE VOUCHER PAYABLE AND TAX STAGING
			DELETE P
			FROM tblAPVoucherPayable P
			WHERE P.intVoucherPayableId IN (SELECT intVoucherPayableId FROM @intPayableIds)

			DELETE T
			FROM tblAPVoucherPayableTaxStaging T
			WHERE T.intVoucherPayableId IN (SELECT intVoucherPayableId FROM @intPayableIds)
		END
	END
END TRY

BEGIN CATCH	

	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	RETURN 0	

END CATCH		

RETURN 1		                     
							
END