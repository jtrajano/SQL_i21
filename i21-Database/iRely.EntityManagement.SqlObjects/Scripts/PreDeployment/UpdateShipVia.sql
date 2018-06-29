--THIS WILL UPDATE tblAPBill.intShipViaId


IF(EXISTS(SELECT 1 FROM sys.objects WHERE name = 'tblAPBill'))
BEGIN
	IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intShipViaID' and object_id = OBJECT_ID(N'tblSMShipVia')))
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
	ELSE
	BEGIN
	--intShipViaID has been removed from tblSMShipVia
		IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intEntityShipViaId' and object_id = OBJECT_ID(N'tblSMShipVia')))
		BEGIN
			EXEC('
				UPDATE A
					SET A.intShipViaId = NULL
				FROM tblAPBill A
				WHERE A.intShipViaId NOT IN (SELECT intEntityShipViaId FROM tblSMShipVia)
			')

			EXEC('
				UPDATE A
					SET A.intShipViaId = NULL
				FROM tblPOPurchase A
				WHERE A.intShipViaId NOT IN (SELECT intEntityShipViaId FROM tblSMShipVia)
			')
		END
		ELSE IF EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intEntityId' and object_id = OBJECT_ID(N'tblSMShipVia'))
		BEGIN
			EXEC('
				UPDATE A
					SET A.intShipViaId = NULL
				FROM tblAPBill A
				WHERE A.intShipViaId NOT IN (SELECT intEntityId FROM tblSMShipVia)
			')

			EXEC('
				UPDATE A
					SET A.intShipViaId = NULL
				FROM tblPOPurchase A
				WHERE A.intShipViaId NOT IN (SELECT intEntityId FROM tblSMShipVia)
			')
		END
		
	END
END