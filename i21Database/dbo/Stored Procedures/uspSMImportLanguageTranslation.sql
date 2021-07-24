CREATE PROCEDURE [dbo].[uspSMImportLanguageTranslation]  
	@intLanguageId INT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRANSACTION  

	MERGE INTO [tblSMLanguageTranslation] A
	USING [tblSMLanguageTranslationStaging] B ON (A.strLabel = B.strLabel AND A.intLanguageId = @intLanguageId)
	--When records are matched, update the records if there is any change
	WHEN MATCHED AND A.strTranslation <> B.strTranslation
	THEN UPDATE SET A.strTranslation = RTRIM(LTRIM(B.strTranslation)), A.intConcurrencyId = A.intConcurrencyId + 1
	--When no records are matched, insert the incoming records from source table to target table
	WHEN NOT MATCHED BY TARGET 
	THEN INSERT (strLabel, strTranslation, intLanguageId) 
	VALUES (RTRIM(LTRIM(B.strLabel)), RTRIM(LTRIM(B.strTranslation)), @intLanguageId);

	IF NOT EXISTS (SELECT 1 FROM [tblSMLanguageTranslationHistory] WHERE intLanguageId = @intLanguageId)
		BEGIN
			INSERT INTO [tblSMLanguageTranslationHistory] (intLanguageId, strUnique, dtmUpdated, intConcurrencyId)
			SELECT @intLanguageId, NEWID(), GETUTCDATE(), 1
		END
	ELSE 
		BEGIN
			UPDATE [tblSMLanguageTranslationHistory]
			SET strUnique = NEWID(), dtmUpdated = GETUTCDATE()
			WHERE intLanguageId = @intLanguageId
		END

	-- Delete screen(s) staging that doesn't have conflicts
	DELETE FROM [tblSMLanguageTranslationStaging]

COMMIT TRANSACTION