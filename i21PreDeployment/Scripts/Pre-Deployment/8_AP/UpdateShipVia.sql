--THIS WILL UPDATE tblAPBill.intShipViaId
IF(EXISTS(SELECT 1 FROM tblAPBill
WHERE intShipViaId NOT IN (SELECT intEntityShipViaId FROM tblSMShipVia)))
BEGIN
	UPDATE A
		SET A.intShipViaId = (SELECT intEntityId FROM tblEntity WHERE strName = 'DHL')
	FROM tblAPBill A
	WHERE A.intShipViaId NOT IN (SELECT intEntityShipViaId FROM tblSMShipVia)
END