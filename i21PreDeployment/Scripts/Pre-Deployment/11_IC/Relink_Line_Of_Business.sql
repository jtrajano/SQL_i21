IF	EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID('FK_tblICCategory_tblICLineOfBusiness') AND [type] = 'F')
	AND EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID('tblSMLineOfBusiness') AND [type] = 'U')
BEGIN
	PRINT 'Begin: Re-link category to SM line of business'
	
	EXEC ('
		UPDATE	c
		SET		c.intLineOfBusinessId = sLOB.intLineOfBusinessId
		FROM	tblICCategory c LEFT JOIN tblICLineOfBusiness iLOB
					ON c.intLineOfBusinessId = iLOB.intLineOfBusinessId
				LEFT JOIN tblSMLineOfBusiness sLOB
					ON sLOB.strLineOfBusiness = iLOB.strLineOfBusiness
	')

	PRINT 'End: Re-link category to SM line of business'
END 
