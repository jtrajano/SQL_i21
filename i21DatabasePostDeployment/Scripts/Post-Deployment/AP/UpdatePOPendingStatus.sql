--THIS WILL FIXED THOSE PO PENDING STATUS

IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE intOrderStatusId = 7)
BEGIN
		UPDATE  A
		SET A.intOrderStatusId = (SELECT (CASE	WHEN 
													--PO is closed when all the dblQtyReceived is greater than or equal to dblQtyOrdered
													NOT EXISTS(SELECT 1 FROM 
																	(
																		SELECT 
																			CASE WHEN dblQtyReceived >= dblQtyOrdered THEN 1 ELSE 0 END AS ysnFull
																		 FROM tblPOPurchaseDetail WHERE intPurchaseId = A.intPurchaseId
																	) PODetails WHERE ysnFull = 0
																)
													THEN 3 --Closed

												WHEN dbo.fnPOHasItemReceipt(A.intPurchaseId, NULL) = 0 AND dbo.fnPOHasBill(A.intPurchaseId, NULL) = 0
												THEN 1 --Open

												WHEN dbo.fnPOHasItemReceipt(A.intPurchaseId, 1) = 1 OR dbo.fnPOHasBill(A.intPurchaseId, 1) = 1
													THEN 2 --Partial
												ELSE NULL
										END))
		FROM tblPOPurchase A 
		WHERE A.intOrderStatusId = 7
END