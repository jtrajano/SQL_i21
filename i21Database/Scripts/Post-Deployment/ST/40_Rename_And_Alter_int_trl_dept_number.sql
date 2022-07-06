﻿PRINT 'Checking tblSTTranslogRebates for intTrlDeptNumber'
IF(EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSTTranslogRebates'  and [COLUMN_NAME] = 'intTrlDeptNumber' ))
BEGIN
	PRINT 'EXECUTE'
	
	UPDATE tblSTTranslogRebates SET strTrlDeptNumber = CAST(intTrlDeptNumber AS NVARCHAR)

END
PRINT 'Done tblSTTranslogRebates for intTrlDeptNumber'