PRINT N'BEGIN - IC Data Fix for 18.1. #12'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.1)
BEGIN 
	UPDATE	gl
	SET		gl.intEntityId = r.intEntityVendorId 
			,gl.intUserId = r.intEntityId
	FROM	tblICInventoryReceipt r INNER JOIN tblGLDetail gl
				ON r.strReceiptNumber = gl.strTransactionId
	WHERE	r.intEntityVendorId <> ISNULL(gl.intEntityId, 0) 

	UPDATE	gl
	SET		gl.intEntityId = s.intEntityCustomerId
			,gl.intUserId = s.intEntityId
	FROM	tblICInventoryShipment s INNER JOIN tblGLDetail gl
				ON s.strShipmentNumber = gl.strTransactionId
	WHERE	s.intEntityCustomerId <> ISNULL(gl.intEntityId, 0) 
END 

GO

PRINT N'END - IC Data Fix for 18.1. #12'