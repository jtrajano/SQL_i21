PRINT '********************** BEGIN Fix Customer Bill To and Ship To **********************'
GO
IF EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblARCustomer') AND EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblEMEntityLocation')
	BEGIN
        UPDATE CS
        SET intBillToId = ELDEFAULT.intEntityLocationId
        FROM tblARCustomer CS
        LEFT JOIN tblEMEntityLocation BILLTO ON CS.intBillToId = BILLTO.intEntityLocationId
        OUTER APPLY (
            SELECT TOP 1 intEntityLocationId
            FROM tblEMEntityLocation EL
            WHERE EL.intEntityId = CS.intEntityId
            AND EL.ysnActive = 1
        ) ELDEFAULT
        WHERE ELDEFAULT.intEntityLocationId IS NOT NULL
          AND ISNULL(BILLTO.intEntityLocationId, 0) = 0

        UPDATE CS
        SET intShipToId = ELDEFAULT.intEntityLocationId
        FROM tblARCustomer CS
        LEFT JOIN tblEMEntityLocation SHIPTO ON CS.intShipToId = SHIPTO.intEntityLocationId
        OUTER APPLY (
            SELECT TOP 1 intEntityLocationId
            FROM tblEMEntityLocation EL
            WHERE EL.intEntityId = CS.intEntityId
            AND EL.ysnActive = 1
        ) ELDEFAULT
        WHERE ELDEFAULT.intEntityLocationId IS NOT NULL
          AND ISNULL(SHIPTO.intEntityLocationId, 0) = 0   
	END
GO
PRINT ' ********************** END Fix Customer Bill To and Ship To **********************'