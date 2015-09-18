CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionSalesInfoReport]
		@intReferenceNumber INT  
AS
BEGIN
SELECT 
	SICQ.intShippingInstructionId,
	SICQ.intContractDetailId,
	CT.strContractNumber,
	CT.intContractSeq,
	SICQ.dblQuantity,
	UOM.strUnitMeasure,
	CT.strItemDescription

FROM	tblLGShippingInstructionContractQty SICQ
JOIN	tblLGShippingInstruction SI ON SI.intShippingInstructionId = SICQ.intShippingInstructionId
JOIN	vyuCTContractDetailView CT ON CT.intContractDetailId = SICQ.intContractDetailId
JOIN	tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SICQ.intUnitMeasureId
WHERE 	SI.intReferenceNumber = @intReferenceNumber and SICQ.intPurchaseSale = 2
END

