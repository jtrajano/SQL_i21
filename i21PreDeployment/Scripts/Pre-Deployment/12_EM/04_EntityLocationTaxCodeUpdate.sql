PRINT '*** Update Entity Location Tax Code Id ***'

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityLocation' AND [COLUMN_NAME] = 'intTaxCodeId') 
BEGIN
	PRINT '*** Begin Updatting Entity Location Tax Code Id***'	
	EXEC('update tblEntityLocation set intTaxCodeId = null where intTaxCodeId not in( select intTaxCodeId from tblSMTaxCode )')
END

PRINT '*** EndUpdate Entity Location Tax Code Id ***'

