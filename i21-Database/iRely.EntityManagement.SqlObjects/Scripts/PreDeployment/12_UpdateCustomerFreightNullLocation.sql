PRINT '*** CHECKING CUSTOMER FREIGHT XREF ***'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerFreightXRef' and [COLUMN_NAME] = 'intEntityLocationId')
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' and [COLUMN_NAME] = 'intEntityLocationId')
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' and [COLUMN_NAME] = 'ysnDefaultLocation')
BEGIN
	PRINT '*** UPDATING CUSTOMER FREIGHT XREF ***'
	EXEC('update a set a.intEntityLocationId = b.intEntityLocationId from 
			tblARCustomerFreightXRef  a
				join tblEMEntityLocation b
					on a.intEntityCustomerId = b.intEntityId and b.ysnDefaultLocation = 1
						where a.intEntityLocationId is null')
END
PRINT '*** END CHECKING CUSTOMER FREIGHT XREF ***'