PRINT N'BEGIN DOCUMENT SOURCE'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMDocumentSourceFolder WHERE strName = 'Printed')
	BEGIN
		DECLARE @contractId INT
		SELECT @contractId = intScreenId FROM tblSMScreen WHERE strScreenName = 'Contract' AND strModule = 'Contract Management'

		INSERT INTO tblSMDocumentSourceFolder([intScreenId], [strName], [intSort], [intConcurrencyId])	
		VALUES(@contractId, 'Printed', 0, 1)
	END
	PRINT N'END DOCUMENT SOURCE'
GO