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
	--When translation doesn't match update the records
	WHEN MATCHED 
	THEN UPDATE SET 
		A.strTranslation	= CASE WHEN A.strTranslation <> B.strTranslation THEN RTRIM(LTRIM(B.strTranslation)) ELSE A.strTranslation END, 
		A.intConcurrencyId	= CASE WHEN A.strTranslation <> B.strTranslation THEN A.intConcurrencyId + 1 ELSE A.intConcurrencyId END
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

	DELETE FROM [tblSMLanguageTranslationStaging]

COMMIT TRANSACTION