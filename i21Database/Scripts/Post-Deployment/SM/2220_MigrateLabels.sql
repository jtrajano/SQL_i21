
GO

PRINT N'START MIGRATE tblSMCustomLabel TO tblSMLanguageTranslation'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblSMCustomLabel')
	BEGIN

	    -- start tblSMCustomLabel refers only to english to english translation
		DECLARE @intLanguageId int; 
		SET @intLanguageId = (SELECT l.intLanguageId FROM dbo.tblSMLanguage l WHERE l.strLanguage = 'English');
		-- end tblSMCustomLabel refers only to english to english translation

		IF((SELECT COUNT(*) FROM dbo.tblSMCustomLabel)!=0)
			BEGIN

			INSERT INTO dbo.tblSMLanguageTranslation (intLanguageId, strLabel, strTranslation, intConcurrencyId)

			SELECT DISTINCT @intLanguageId, cl.strLabel, cl.strCustomLabel, 0 
			FROM dbo.tblSMCustomLabel cl

			-- start select only labels that are not present yet in tblSMLanguageTranslation
			WHERE NOT EXISTS (
			SELECT strLabel
			FROM dbo.tblSMLanguageTranslation
			WHERE intLanguageId = @intLanguageId);
		    -- end select only labels that are not present yet in tblSMLanguageTranslation
	END
		PRINT N'END MIGRATE tblSMCustomLabel TO tblSMLanguageTranslation'
END
