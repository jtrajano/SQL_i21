GO
print 'Set to null Bill Contact id that does not exists anymore'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPBill' and [COLUMN_NAME] = 'intContactId')
	 AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'intEntityId')
	
BEGIN
	PRINT 'START'
	EXEC('UPDATE tblAPBill set intContactId = null where intContactId not in (select intEntityId from tblEMEntity)')	

	
	PRINT 'END'
END

print 'Set to null Bill Contact id that does not exists anymore'
