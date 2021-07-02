CREATE PROCEDURE [dbo].[uspSMImportLocalization]  
	@intLanguageId INT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRANSACTION  

	MERGE INTO tblSMLocalization A
	USING tblSMLocalizationStaging B ON (A.strLabel = B.strLabel AND A.intLanguageId = @intLanguageId)
	--When records are matched, update the records if there is any change
	WHEN MATCHED AND A.strTranslation <> B.strTranslation
	THEN UPDATE SET A.strTranslation = B.strTranslation, A.ysnEdited = 1
	--When no records are matched, insert the incoming records from source table to target table
	WHEN NOT MATCHED BY TARGET 
	THEN INSERT (strLabel, strTranslation, intLanguageId) 
	VALUES (B.strLabel, B.strTranslation, @intLanguageId);

	-- Delete screen(s) staging that doesn't have conflicts
	DELETE FROM tblSMLocalizationStaging

COMMIT TRANSACTION