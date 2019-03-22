IF EXISTS(SELECT TOP 1 1 FROM [tblEMEntityLocation] WHERE intTermsId IS NULL)
BEGIN
	PRINT '*** Fixing null tblEMEntityLocation intTermsId ***'
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTerm' and [COLUMN_NAME] = 'strTerm')
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Fix null tblEMEntityLocation intTermsId')

	BEGIN
		PRINT '*** Check Due on Receipt Terms ***'
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTerm WHERE strTerm = 'Due on Receipt')
		BEGIN
			PRINT '*** Add Due on Receipt Terms ***'
			DECLARE @counter INT 
			SET @counter = 0

			WHILE EXISTS(SELECT TOP 1 1 FROM tblSMTerm WHERE strTermCode = CAST(@counter AS VARCHAR))
			BEGIN
				SET @counter = @counter + 1
			END

			INSERT INTO tblSMTerm(strTerm, strType, strTermCode, dblDiscountEP, intBalanceDue, intDiscountDay, dblAPR, intDayofMonthDue, intDueNextMonth, ysnActive,intSort )
			VALUES('Due on Receipt','Standard', CAST(@counter AS VARCHAR),0 ,0 ,0 ,0,0 ,0, 1, 0)

		END

		DECLARE @TermsId INT
	
		SELECT TOP 1 @TermsId = intTermID FROM tblSMTerm WHERE strTerm = 'Due on Receipt'
	
		PRINT '*** Update Due on Receipt Terms ***'	

		UPDATE [tblEMEntityLocation] SET intTermsId = @TermsId WHERE intTermsId IS NULL


		INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
		VALUES('Fix null tblEMEntityLocation intTermsId' , '1' )

	END
	PRINT '*** End Fixing null tblEMEntityLocation intTermsId ***'
END