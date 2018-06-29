CREATE PROCEDURE [dbo].[uspSMCommitLabelListing]  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRANSACTION  
	
	-- INSERT Screens
	INSERT INTO tblSMScreenLabel (
		strLabel
	)
	SELECT DISTINCT A.strLabel
	FROM tblSMScreenLabelStage A LEFT JOIN tblSMScreenLabel B
		ON A.strLabel = B.strLabel
	WHERE ISNULL(B.strLabel, '') = '' AND A.strLabel <> 'Attachment' AND A.strLabel <> 'Audit Logs'
	
	-- DELETE Label Stage
	DELETE FROM tblSMScreenLabelStage

	-- UPDATE Company Setup
	UPDATE tblSMCompanySetup 
	SET ysnScreenLabelListingUpdated = 1

COMMIT TRANSACTION