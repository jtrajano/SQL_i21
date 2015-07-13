﻿--THIS WILL UPDATE ALL tblAPBill.intShipToId THAT HAS VALUE "0" to NULL
IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intShipToId <= 0))
BEGIN
	UPDATE A
		SET A.intShipToId = NULL
	FROM tblAPBill A
	WHERE intShipToId <= 0

	--COMPANY LOCATION HAS BEEN DELETED
	IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intShipToId NOT IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation)))
	BEGIN
		--USE CURRENT COMPANY LOCATION EXISTS
		UPDATE A
		SET A.intShipToId = ISNULL((SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation), NULL) --IF NO COMPANY LOCATION EXISTS, SET IT TO NULL
		FROM tblAPBill A
		WHERE intShipToId NOT IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation)
	END
END