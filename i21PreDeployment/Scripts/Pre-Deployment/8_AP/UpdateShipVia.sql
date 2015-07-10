--THIS WILL UPDATE tblAPBill.intShipViaId
IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intShipViaID' and object_id = OBJECT_ID(N'tblSMShipVia')))
BEGIN
	UPDATE A
		SET A.intShipViaId = ISNULL(B.intShipViaID, A.intShipViaId)
	FROM tblAPBill A
	INNER JOIN tblSMShipVia B ON A.intShipViaId = B.intShipViaID
END