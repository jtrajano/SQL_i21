PRINT '*** Update Entity Location Tax Code Id ***'

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' AND [COLUMN_NAME] = 'intTaxCodeId') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxCode' AND [COLUMN_NAME] = 'intTaxCodeId') 
BEGIN
	PRINT '*** Begin Updatting Entity Location Tax Code Id***'	
	EXEC('update tblEMEntityLocation set intTaxCodeId = null where intTaxCodeId not in( select intTaxCodeId from tblSMTaxCode )')
END

PRINT '*** EndUpdate Entity Location Tax Code Id ***'

