﻿PRINT('CT - 174To181 Started')

GO
UPDATE  CH SET CH.intWarehouseId =  CH.intINCOLocationTypeId 
FROM	tblCTContractHeader CH
JOIN	tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
WHERE   strINCOLocationType = 'Warehouse' AND CH.intINCOLocationTypeId IS NOT NULL
GO

GO
UPDATE  CH SET CH.intINCOLocationTypeId =  NULL
FROM	tblCTContractHeader CH
JOIN	tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
WHERE	strINCOLocationType = 'Warehouse' AND CH.intINCOLocationTypeId IS NOT NULL
GO

PRINT('CT - 174To181 End')

------------183----------

GO
PRINT('Udate existing sequence History')
 
EXEC uspCTUpdateExistingSequenceHistory
 
PRINT('End Udate existing sequence History')
 GO

GO
PRINT('Udate Original Quantity')
 
UPDATE CD SET CD.dblOriginalQty = t.dblQuantity
FROM tblCTContractDetail CD
JOIN (
select intContractDetailId,dblQuantity,
ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY intSequenceHistoryId ASC) intRowNum 
from tblCTSequenceHistory 
)t ON t.intContractDetailId = CD.intContractDetailId
WHERE t.intRowNum = 1 AND CD.dblOriginalQty IS NULL
 
UPDATE tblCTContractDetail SET dblOriginalQty = dblQuantity WHERE dblOriginalQty IS NULL

PRINT('End Udate Original Quantity')
GO

GO
DECLARE @tblToProcess TABLE
(
	intContractDetailId INT
)
DECLARE @APARDetails TABLE
(
	intDetailId INT,
	intHeaderId INT,
	dblQtyAPAR  NUMERIC(18,6)
)
DECLARE @intContractDetailId INT, 
		@intPriceFixationDetailId INT,
		@intItemUOMId INT,@intDetailId INT,@intHeaderId INT,
		@dblPriceFxdQty NUMERIC(18,6),
		@dblQtyAPAR NUMERIC(18,6),
		@intContractTypeId INT

INSERT INTO @tblToProcess
SELECT DISTINCT PF.intContractDetailId
FROm tblCTPriceFixation PF
JOIN tblCTPriceFixationDetail FD ON FD.intPriceFixationId = PF.intPriceFixationId
WHERE FD.intPriceFixationDetailId NOT IN (select ISNULL(intPriceFixationDetailId,0) from tblCTPriceFixationDetailAPAR)
AND FD.intInvoiceId IS NOT NULL

SELECT @intContractDetailId = MIN(intContractDetailId) FROM @tblToProcess 

WHILE ISNULL(@intContractDetailId,0) > 0
BEGIN
	
	SELECT	@intItemUOMId = intItemUOMId,
	@intContractTypeId = CH.intContractTypeId
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE intContractDetailId = @intContractDetailId
	
	DELETE FROM @APARDetails

	IF @intContractTypeId = 1
	BEGIN
		INSERT INTO @APARDetails
		SELECT intBillDetailId,intBillId,dbo.fnCTConvertQtyToTargetItemUOM(intUnitOfMeasureId,@intItemUOMId,dblQtyReceived) 
		FROM tblAPBillDetail WHERE intContractDetailId = @intContractDetailId AND intInventoryReceiptChargeId IS NULL

		SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId)
		FROM  tblCTPriceFixation PF
		JOIN  tblCTPriceFixationDetail FD ON FD.intPriceFixationId = PF.intPriceFixationId
		WHERE PF.intContractDetailId = @intContractDetailId


		WHILE ISNULL(@intPriceFixationDetailId,0) > 0
		BEGIN
				SELECT	@dblPriceFxdQty		=	FD.dblQuantity
				FROM	tblCTPriceFixationDetail	FD
				WHERE	intPriceFixationDetailId = @intPriceFixationDetailId
	
			
				SELECT @intDetailId = MIN(intDetailId) FROM @APARDetails 			

				WHILE ISNULL(@intDetailId,0) > 0 AND ISNULL(@dblPriceFxdQty,0) > 0
				BEGIN

					SELECT @dblQtyAPAR = dblQtyAPAR,@intHeaderId = intHeaderId FROM @APARDetails WHERE intDetailId = @intDetailId				

					IF @dblQtyAPAR <= @dblPriceFxdQty
					BEGIN
						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intBillId,intBillDetailId,intConcurrencyId)
						SELECT @intPriceFixationDetailId,@intHeaderId,@intDetailId,1
						SELECT @dblPriceFxdQty = @dblPriceFxdQty - @dblQtyAPAR
						DELETE FROM  @APARDetails WHERE intDetailId = @intDetailId
					END
					ELSE
					BEGIN
						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intBillId,intBillDetailId,intConcurrencyId)
						SELECT @intPriceFixationDetailId,@intHeaderId,@intDetailId,1
						UPDATE @APARDetails SET dblQtyAPAR = dblQtyAPAR - @dblPriceFxdQty WHERE intDetailId = @intDetailId
						SELECT @dblPriceFxdQty = 0
					END

					SELECT @intDetailId = MIN(intDetailId) FROM @APARDetails WHERE intDetailId > @intDetailId
				END

				SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId)
				FROM  tblCTPriceFixation PF
				JOIN  tblCTPriceFixationDetail FD ON FD.intPriceFixationId = PF.intPriceFixationId
				WHERE PF.intContractDetailId = @intContractDetailId
				AND FD.intPriceFixationDetailId > @intPriceFixationDetailId
		END
	END
	-------------------
	IF @intContractTypeId = 2
	BEGIN
		INSERT INTO @APARDetails
		SELECT intInvoiceDetailId,intInvoiceId,dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,@intItemUOMId,dblQtyShipped) 
		FROM tblARInvoiceDetail WHERE intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

		SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId)
		FROM  tblCTPriceFixation PF
		JOIN  tblCTPriceFixationDetail FD ON FD.intPriceFixationId = PF.intPriceFixationId
		WHERE PF.intContractDetailId = @intContractDetailId


		WHILE ISNULL(@intPriceFixationDetailId,0) > 0
		BEGIN
				SELECT	@dblPriceFxdQty		=	FD.dblQuantity
				FROM	tblCTPriceFixationDetail	FD
				WHERE	intPriceFixationDetailId = @intPriceFixationDetailId
	
			
				SELECT @intDetailId = MIN(intDetailId) FROM @APARDetails 			

				WHILE ISNULL(@intDetailId,0) > 0 AND ISNULL(@dblPriceFxdQty,0) > 0
				BEGIN

					SELECT @dblQtyAPAR = dblQtyAPAR,@intHeaderId = intHeaderId FROM @APARDetails WHERE intDetailId = @intDetailId				

					IF @dblQtyAPAR <= @dblPriceFxdQty
					BEGIN
						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
						SELECT @intPriceFixationDetailId,@intHeaderId,@intDetailId,1
						SELECT @dblPriceFxdQty = @dblPriceFxdQty - @dblQtyAPAR
						DELETE FROM  @APARDetails WHERE intDetailId = @intDetailId
					END
					ELSE
					BEGIN
						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
						SELECT @intPriceFixationDetailId,@intHeaderId,@intDetailId,1
						UPDATE @APARDetails SET dblQtyAPAR = dblQtyAPAR - @dblPriceFxdQty WHERE intDetailId = @intDetailId
						SELECT @dblPriceFxdQty = 0
					END

					SELECT @intDetailId = MIN(intDetailId) FROM @APARDetails WHERE intDetailId > @intDetailId
				END

				SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId)
				FROM  tblCTPriceFixation PF
				JOIN  tblCTPriceFixationDetail FD ON FD.intPriceFixationId = PF.intPriceFixationId
				WHERE PF.intContractDetailId = @intContractDetailId
				AND FD.intPriceFixationDetailId > @intPriceFixationDetailId
		END
	END
	SELECT @intContractDetailId = MIN(intContractDetailId) FROM @tblToProcess WHERE intContractDetailId > @intContractDetailId
END
GO