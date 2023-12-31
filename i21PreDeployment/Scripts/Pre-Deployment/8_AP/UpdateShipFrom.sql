﻿--THIS WILL UPDATE ALL tblAPBill.intShipFrom THAT HAS VALUE "0" to NULL

IF(EXISTS(SELECT 1 FROM sys.objects WHERE name = 'tblAPBill'))
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPBill' and [COLUMN_NAME] = 'intEntityVendorId')
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' and [COLUMN_NAME] = 'intEntityLocationId')
BEGIN
	EXEC('
		IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intShipFromId <= 0))
		BEGIN
			UPDATE A
				SET A.intShipFromId = NULL
			FROM tblAPBill A
			WHERE intShipFromId <= 0

			--LOCATION HAS BEEN DELETED
			IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intShipFromId NOT IN (SELECT intEntityLocationId FROM tblEMEntityLocation)))
			BEGIN
				UPDATE A
					SET A.intShipFromId = ISNULL(Location.intEntityLocationId, NULL) --SET TO NULL IF NO LOCATION SPECIFIED
				FROM tblAPBill A
				INNER JOIN tblEMEntity B ON A.intEntityVendorId = B.intEntityId
				OUTER APPLY(
					SELECT 
						TOP 1 intEntityLocationId
					FROM tblEMEntityLocation C 
					WHERE C.intEntityId = B.intEntityId AND C.ysnDefaultLocation = 1
				) Location
				WHERE intShipFromId NOT IN (SELECT intEntityLocationId FROM tblEMEntityLocation)
			END
		END
	')
END
