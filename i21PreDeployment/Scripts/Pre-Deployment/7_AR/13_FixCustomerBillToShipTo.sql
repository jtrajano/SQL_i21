PRINT '********************** BEGIN Fix Customer Bill To and Ship To **********************'
GO
IF EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblARCustomer') AND EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblEMEntityLocation')
	BEGIN
        UPDATE CS
        SET intBillToId = ELDEFAULT.intEntityLocationId
        FROM tblARCustomer CS
        LEFT JOIN tblEMEntityLocation ELBT ON CS.intBillToId = ELBT.intEntityLocationId
        OUTER APPLY (
            SELECT TOP 1 intEntityLocationId
            FROM tblEMEntityLocation EL
            WHERE EL.intEntityId = CS.intEntityId
            AND EL.ysnActive = 1
        ) ELDEFAULT
        WHERE ELDEFAULT.intEntityLocationId IS NOT NULL
          AND ISNULL(ELBT.intEntityLocationId, 0) = 0  
	END
GO
PRINT ' ********************** END Fix Customer Bill To and Ship To **********************'