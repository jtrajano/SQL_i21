CREATE PROCEDURE [dbo].[uspSMCommitListing]  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRANSACTION  
	
	-- INSERT Screens
	INSERT INTO tblSMScreen (
		strScreenId,
		strScreenName,
		strModule,
		strNamespace,
		intConcurrencyId
	)
	SELECT '',
		strScreenName,
		strModule,
		strNamespace,
		intConcurrencyId
	FROM tblSMScreenStage
	WHERE ISNULL(strChange, '') = 'Added'

	
	-- DELETE Screens
	DELETE FROM tblSMScreen 
	WHERE strNamespace IN (SELECT strNamespace FROM tblSMScreenStage WHERE strChange = 'Deleted') AND strNamespace <> 'ContractManagement.view.ContractAmendment' 
	
	-- INSERT Controls
	INSERT INTO tblSMControl (
		strControlId,
		strControlName,
		strControlType,
		strContainer,
		intScreenId,
		intConcurrencyId
	)
	SELECT 
		A.strControlId,
		A.strControlName,
		A.strControlType,
		A.strContainer,
		C.intScreenId,
		A.intConcurrencyId
	FROM tblSMControlStage A
	 INNER JOIN tblSMScreenStage B ON A.intScreenStageId = B.intScreenStageId
	 INNER JOIN tblSMScreen C ON B.strNamespace = C.strNamespace
	WHERE ISNULL(A.strChange, '') = 'Added'
	
	-- DELETE Controls
	DELETE tblSMControl 
	FROM tblSMControlStage A
			INNER JOIN tblSMScreenStage B  ON A.intScreenStageId = B.intScreenStageId
			INNER JOIN tblSMScreen C ON B.strNamespace = C.strNamespace			
			INNER JOIN tblSMControl D ON D.strControlId = A.strControlId	
	WHERE ISNULL(A.strChange, '') = 'Deleted'


	-- DELETE Stage
	DELETE FROM tblSMScreenStage

	-- UPDATE Company Setup
	UPDATE tblSMCompanySetup 
	SET ysnScreenControlListingUpdated = 1

COMMIT TRANSACTION
