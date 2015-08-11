CREATE PROCEDURE [dbo].[uspPOUpdateContract]
	@poId INT,
	@userId INT,
	@negate INT
AS

DECLARE @contractDetails TABLE(intContractDetailId INT, intPurchaseDetailId INT, dblQtyOrdered NUMERIC(18,6));

INSERT INTO @contractDetails
SELECT intContractDetailId, intPurchaseDetailId, CASE WHEN @negate = 1 THEN dblQtyOrdered * -1 ELSE dblQtyOrdered END FROM tblPOPurchaseDetail WHERE intPurchaseId = @poId

WHILE EXISTS(SELECT 1 FROM @contractDetails)
BEGIN

	DECLARE @contractDetailId INT;
	DECLARE @purchaseDetailId INT;
	DECLARE @qty NUMERIC(18,6);
	 SELECT TOP 1 
		@contractDetailId = intContractDetailId 
		,@purchaseDetailId = intPurchaseDetailId
		,@qty = dblQtyOrdered
	FROM @contractDetails;

	EXEC uspCTUpdateScheduleQuantity @contractDetailId, @qty, @userId, @purchaseDetailId, 'Purchase Order'

	DELETE FROM @contractDetails WHERE intContractDetailId = @contractDetailId
END