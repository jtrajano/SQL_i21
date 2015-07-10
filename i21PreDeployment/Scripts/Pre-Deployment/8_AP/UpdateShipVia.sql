--THIS WILL UPDATE tblAPBill.intShipViaId
IF(EXISTS(SELECT 1 FROM tblAPBill
WHERE intShipViaId NOT IN (SELECT intEntityShipViaId FROM tblSMShipVia)))
BEGIN
	UPDATE A
		SET A.intShipViaId = ISNULL((SELECT TOP 1 intEntityId FROM tblEntity WHERE strName = 'DHL'), A.intShipViaId)
	FROM tblAPBill A
	WHERE A.intShipViaId NOT IN (SELECT intEntityShipViaId FROM tblSMShipVia)
END