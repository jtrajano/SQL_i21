﻿GO
	PRINT N'BEGIN INSERT VERSION UPDATE'
GO
	INSERT INTO tblSMBuildNumber (strVersionNo, dtmLastUpdate)
	SELECT '19.1', getdate()
GO
	PRINT N'END INSERT VERSION UPDATE'
GO