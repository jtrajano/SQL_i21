--CHECKS FOR PROFIT CENTER OR LOCATION IS PRESENT IN ACCOUNT STRUCTURE TABLE
GO
EXEC('IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE strType = ''Segment'' and (LOWER(strStructureName) like ''profit center%'' OR strStructureName = ''Location''))
	RAISERROR(N''Missing valid structure (i.e. location/profit center) in tblGLAccountStructure, Deployment Terminated.'', 16,1)')
GO