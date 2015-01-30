CREATE PROCEDURE [dbo].[uspPOReceived]
	@purchaseId INT,
	@receivedNum DECIMAL(18,6),
	@itemId INT,
	@lineNo INT
AS
BEGIN

	--Validate
	IF(NOT EXISTS(SELECT 1 FROM tblPOPurchase WHERE intPurchaseId = @purchaseId))
	BEGIN
		RAISERROR(51033, 11, 1); --Not Exists
	END

	IF(NOT EXISTS(SELECT 1 FROM tblPOPurchaseDetail WHERE intPurchaseId = @purchaseId AND intItemId = @itemId AND intLineNo = @lineNo))
	BEGIN
		RAISERROR(51034, 11, 1); --PO item not exists
	END

	IF(EXISTS(SELECT 1 FROM tblPOPurchaseDetail WHERE intPurchaseId = @purchaseId AND intItemId = @itemId AND intLineNo = @lineNo AND (dblQtyReceived + @receivedNum) > dblQtyOrdered))
	BEGIN
		RAISERROR(51035, 11, 1); --received item exceeds
	END

	UPDATE A
		SET dblQtyReceived = (dblQtyReceived + @receivedNum)
	FROM tblPOPurchaseDetail A
	WHERE intPurchaseId = @purchaseId AND intItemId = @itemId AND intLineNo = @lineNo

	UPDATE A
		SET intOrderStatusId = CASE WHEN (SELECT SUM(dblQtyReceived) FROM tblPOPurchaseDetail WHERE intPurchaseId = @purchaseId) 
											= (SELECT SUM(dblQtyOrdered) FROM tblPOPurchaseDetail WHERE intPurchaseId = @purchaseId)
									THEN 3 ELSE 2 END
	FROM tblPOPurchase A
	WHERE intPurchaseId = @purchaseId

END
