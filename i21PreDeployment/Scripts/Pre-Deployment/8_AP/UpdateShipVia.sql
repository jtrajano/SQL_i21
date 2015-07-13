--THIS WILL UPDATE tblAPBill.intShipViaId
IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intShipViaID' and object_id = OBJECT_ID(N'tblSMShipVia'))
	AND EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intEntityShipViaId' and object_id = OBJECT_ID(N'tblSMShipVia')))
BEGIN
EXEC('
	UPDATE A
		SET A.intShipViaId = ISNULL(B.intEntityShipViaId, A.intShipViaId)
	FROM tblAPBill A
	INNER JOIN tblSMShipVia B ON A.intShipViaId = B.intShipViaID
	')

	EXEC('
	UPDATE A
		SET A.intShipViaId = ISNULL(B.intEntityShipViaId, A.intShipViaId)
	FROM tblPOPurchase A
	INNER JOIN tblSMShipVia B ON A.intShipViaId = B.intShipViaID
	')
END