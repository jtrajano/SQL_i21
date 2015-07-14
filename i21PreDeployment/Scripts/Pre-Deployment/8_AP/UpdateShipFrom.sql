--THIS WILL UPDATE ALL tblAPBill.intShipFrom THAT HAS VALUE "0" to NULL
IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intShipFromId <= 0))
BEGIN
	UPDATE A
		SET A.intShipFromId = NULL
	FROM tblAPBill A
	WHERE intShipFromId <= 0

	--LOCATION HAS BEEN DELETED
	IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intShipFromId NOT IN (SELECT intEntityLocationId FROM tblEntityLocation)))
	BEGIN
		UPDATE A
			SET A.intShipFromId = ISNULL(Location.intEntityLocationId, NULL) --SET TO NULL IF NO LOCATION SPECIFIED
		FROM tblAPBill A
		INNER JOIN tblEntity B ON A.intEntityVendorId = B.intEntityId
		OUTER APPLY(
			SELECT 
				TOP 1 intEntityLocationId
			FROM tblEntityLocation C 
			WHERE C.intEntityId = B.intEntityId AND C.ysnDefaultLocation = 1
		) Location
		WHERE intShipFromId NOT IN (SELECT intEntityLocationId FROM tblEntityLocation)
	END
END