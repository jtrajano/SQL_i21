﻿PRINT N'BEGIN COMPANY SETUP '
GO
	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[coctlmst]') AND type IN (N'U')) GOTO Check_Exit;

	IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanySetup)
	BEGIN
		--IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblSMCompanyPreference]'))
		--	IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 0)
				GOTO Check_Exit;

		--PRINT N'BEGIN UPDATING EXISTING COMPANY SETUP'
		--	UPDATE tblSMCompanySetup 
		--	SET strCompanyName = (SELECT TOP 1 coctl_co_name FROM [coctlmst])
		--PRINT N'END UPDATING EXISTING COMPANY SETUP'
	END
	ELSE
	BEGIN
		PRINT N'BEGIN INSERTING COMPANY SETUP FROM ORIGIN'
			INSERT INTO tblSMCompanySetup (strCompanyName)
			SELECT TOP 1 coctl_co_name FROM [coctlmst]	
		PRINT N'END INSERTING COMPANY SETUP FROM ORIGIN'
	END
	
	Check_Exit:

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMCompanySetup)
	BEGIN
		PRINT N'INSERTING A DEFAULT EMPTY ROW'
		INSERT INTO tblSMCompanySetup(strCompanyName, ysnScreenControlListingUpdated) VALUES('', 0)
	END

	PRINT N'BEGIN UPDATING SCREEN AND CONTROL LISTING FLAG'
		UPDATE tblSMCompanySetup 
		SET ysnScreenControlListingUpdated = 0
	PRINT N'END UPDATING SCREEN AND CONTROL LISTING FLAG'

GO

	PRINT N'END COMPANY SETUP '

GO