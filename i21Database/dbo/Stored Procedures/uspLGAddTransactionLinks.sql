CREATE PROCEDURE [dbo].[uspLGAddTransactionLinks]
	@intTransactionId INT, /* intLoadId or intWeightClaimId */
	@intTransactionType INT, /* 1 = Load Schedule, 2 = Weight Claims */
	@ysnAddLinks BIT = 1
AS
BEGIN
	DECLARE @TransactionLinks udtICTransactionLinks
		,@intLoadShippingInstructionId INT
		,@intSourceId INT
		,@strSourceNo NVARCHAR(100)
		,@strSourceType NVARCHAR(100)
		,@strSourceModule NVARCHAR(100)
		,@intDestinationId INT
		,@strDestinationNo NVARCHAR(100)
		,@strDestinationType NVARCHAR(100)
		,@strDestinationModule NVARCHAR(100)
		,@intPContractDetailId INT

	IF (@intTransactionType = 1) 
	/* Load Shipment */
	BEGIN
		IF EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadId = @intTransactionId AND intLoadShippingInstructionId IS NOT NULL)
		BEGIN
			/* If LS is processed from Shipping Instructions - Link: SI to LS */
			INSERT INTO @TransactionLinks (
				intSrcId
				,strSrcTransactionNo
				,strSrcTransactionType
				,strSrcModuleName
				,intDestId
				,strDestTransactionNo
				,strDestTransactionType
				,strDestModuleName
				,strOperation)
			SELECT 
				intSrcId = LSI.intLoadId
				,strSrcTransactionNo = LSI.strLoadNumber
				,strSrcTransactionType = 'Shipping Instructions'
				,strSrcModuleName = 'Logistics'
				,intDestId = L.intLoadId
				,strDestTransactionNo = L.strLoadNumber 
				,strDestTransactionType = 'Load Shipment'
				,strDestModuleName = 'Logistics'
				,strOperation = 'Process'
			FROM tblLGLoad L
				INNER JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			WHERE L.intLoadId = @intTransactionId 
		END
		ELSE
		BEGIN
			/* Creating New LS or Shipping Instruction - Link: CT(s) to LS/SI */
			INSERT INTO @TransactionLinks (
				intSrcId
				,strSrcTransactionNo
				,strSrcTransactionType
				,strSrcModuleName
				,intDestId
				,strDestTransactionNo
				,strDestTransactionType
				,strDestModuleName
				,strOperation)
			SELECT 
				intSrcId = CH.intContractHeaderId
				,strSrcTransactionNo = CH.strContractNumber
				,strSrcTransactionType = 'Contract'
				,strSrcModuleName = 'Contracts'
				,intDestId = L.intLoadId
				,strDestTransactionNo = strLoadNumber
				,strDestTransactionType = CASE WHEN (L.intShipmentType = 2) THEN 'Shipping Instructions' ELSE 'Load Shipment' END
				,strDestModuleName = 'Logistics'
				,strOperation = 'Process'
			FROM 
				tblCTContractDetail CD
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				INNER JOIN tblLGLoadDetail LD ON CD.intContractDetailId IN (LD.intPContractDetailId, LD.intSContractDetailId)
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			WHERE LD.intLoadId = @intTransactionId
		END
	END
	ELSE IF (@intTransactionType = 2) 
	/* Weight Claims */
	BEGIN
		IF EXISTS(SELECT 1 FROM tblLGWeightClaim WC INNER JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId 
					WHERE L.intPurchaseSale = 1 AND WC.intWeightClaimId = @intTransactionId)
		BEGIN
			/* If Weight Claims is processed from Inbound Shipment - Link: IR(s) to WC */
			INSERT INTO @TransactionLinks (
				intSrcId
				,strSrcTransactionNo
				,strSrcTransactionType
				,strSrcModuleName
				,intDestId
				,strDestTransactionNo
				,strDestTransactionType
				,strDestModuleName
				,strOperation)
			SELECT
				intSrcId = IR.intInventoryReceiptId
				,strSrcTransactionNo = IR.strReceiptNumber
				,strSrcTransactionType = 'Inventory Receipt'
				,strSrcModuleName = 'Inventory'
				,intDestId = WC.intWeightClaimId
				,strDestTransactionNo = WC.strReferenceNumber
				,strDestTransactionType = 'Weight Claim'
				,strDestModuleName = 'Logistics'
				,strOperation = 'Create'
			FROM tblLGWeightClaim WC
				INNER JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
				CROSS APPLY (SELECT TOP 1 IR.intInventoryReceiptId, IR.strReceiptNumber
								FROM tblICInventoryReceipt IR
								INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
								INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = IRI.intSourceId AND LD.intPContractDetailId = IRI.intLineNo AND L.intLoadId = LD.intLoadId
								LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimId = WC.intWeightClaimId 
									AND (WCD.intLoadContainerId IS NULL OR ISNULL(IRI.intContainerId, -1) = ISNULL(WCD.intLoadContainerId, -1))
								WHERE WCD.intWeightClaimId = WC.intWeightClaimId) IR
			WHERE L.intPurchaseSale = 1 
				AND WC.intWeightClaimId = @intTransactionId
		END
		ELSE
		BEGIN
			/* If Weight Claims is processed from Outbound or Drop Shipment - Link: LS to WC */
			INSERT INTO @TransactionLinks (
				intSrcId
				,strSrcTransactionNo
				,strSrcTransactionType
				,strSrcModuleName
				,intDestId
				,strDestTransactionNo
				,strDestTransactionType
				,strDestModuleName
				,strOperation)
			SELECT
				intSrcId = L.intLoadId
				,strSrcTransactionNo = L.strLoadNumber
				,strSrcTransactionType = 'Load Shipment'
				,strSrcModuleName = 'Logistics'
				,intDestId = WC.intWeightClaimId
				,strDestTransactionNo = WC.strReferenceNumber
				,strDestTransactionType = 'Weight Claim'
				,strDestModuleName = 'Logistics'
				,strOperation = 'Create'
			FROM tblLGWeightClaim WC
				INNER JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
			WHERE L.intPurchaseSale IN (2, 3) 
				AND WC.intWeightClaimId = @intTransactionId
		END
	END

	/* Add/Delete Transaction Links */
	IF EXISTS(SELECT 1 FROM @TransactionLinks)
	BEGIN
		IF (@ysnAddLinks = 0) 
			DELETE TL FROM tblICTransactionLinks TL 
				INNER JOIN @TransactionLinks T ON T.intSrcId = TL.intSrcId 
					AND T.strSrcTransactionNo = TL.strSrcTransactionNo
					AND T.strSrcModuleName = TL.strSrcModuleName
					AND T.intDestId = TL.intDestId 
					AND T.strDestTransactionNo = TL.strDestTransactionNo
					AND T.strDestModuleName = TL.strDestModuleName
					AND T.strOperation = TL.strOperation
			--EXEC uspICDeleteTransactionLinks @TransactionLinks
		ELSE
			EXEC uspICAddTransactionLinks @TransactionLinks
	END
END
GO
