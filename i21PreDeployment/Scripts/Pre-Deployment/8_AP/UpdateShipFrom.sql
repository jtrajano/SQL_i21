﻿--THIS WILL UPDATE ALL tblAPBill.intShipFrom THAT HAS VALUE "0" to NULL
IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intShipFromId <= 0))
BEGIN
	UPDATE A
		SET A.intShipFromId = NULL
	FROM tblAPBill A
	WHERE intShipFromId <= 0
END