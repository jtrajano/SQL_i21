PRINT 'Checking tblSTTranslogRebates for intTrlDeptNumber'

IF(EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSTTranslogRebates'  and [COLUMN_NAME] = 'intTrlDeptNumber' ))
BEGIN
	PRINT 'EXECUTE'
	IF EXISTS (SELECT TOP 1 1 FROM tblSTTranslogRebates WHERE strTrlDeptNumber IS NULL AND intTrlDeptNumber IS NOT NULL)
	BEGIN
		UPDATE tblSTTranslogRebates SET strTrlDeptNumber = CAST(intTrlDeptNumber AS NVARCHAR)
		WHERE strTrlDeptNumber IS NULL AND intTrlDeptNumber IS NOT NULL
	END

END

PRINT 'Done tblSTTranslogRebates for intTrlDeptNumber'