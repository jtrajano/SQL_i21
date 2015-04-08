CREATE PROCEDURE [dbo].[uspSMUpdateStageListing]  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRANSACTION  
	-- Create a table for storing updated screens
	DECLARE @newScreens TABLE (intScreenStageId int);

	-- Set change to Added to all new screen(s)
	UPDATE A
	SET A.strChange = 'Added'
	OUTPUT INSERTED.intScreenStageId INTO @newScreens
	FROM tblSMScreenStage A
		LEFT OUTER JOIN tblSMScreen B ON A.strNamespace = B.strNamespace
	WHERE ISNULL(B.strScreenName, '') = '' 

	-- Set change to Added to all control(s) inside of new screen(s)
	UPDATE A 
	SET A.strChange = 'Added'
	FROM tblSMControlStage A
		INNER JOIN @newScreens B ON B.intScreenStageId = A.intScreenStageId;

	-- Add entry to deleted screen(s)
	INSERT INTO tblSMScreenStage (
		strScreenId, 
		strScreenName, 
		strNamespace, 
		strModule, 
		strChange, 
		intConcurrencyId
	)
	SELECT A.strScreenId, 
		A.strScreenName, 
		A.strNamespace, 
		A.strModule, 
		'Deleted', 
		0 
	FROM tblSMScreen A 
		LEFT OUTER JOIN tblSMScreenStage B ON A.strNamespace = B.strNamespace
	WHERE ISNULL(B.strScreenName, '') = '' 

	-- Set change to Added to all new control(s)
	UPDATE A
	SET A.strChange = 'Added'
	FROM (
		SELECT tblSMControlStage.strControlId, 
			tblSMControlStage.strControlName, 
			tblSMControlStage.strControlType, 
			tblSMScreenStage.strNamespace,
			tblSMControlStage.strChange  
		FROM tblSMControlStage 
		INNER JOIN tblSMScreenStage 
			ON tblSMControlStage.intScreenStageId = tblSMScreenStage.intScreenStageId
		WHERE tblSMControlStage.intScreenStageId IN (SELECT intScreenStageId FROM tblSMScreenStage WHERE ISNULL(strChange, '') = '')
	) A
	LEFT OUTER JOIN (
		SELECT tblSMControl.strControlId, 
			tblSMControl.strControlName, 
			tblSMControl.strControlType, 
			tblSMScreen.strNamespace 
		FROM tblSMControl 
		INNER JOIN tblSMScreen
			ON tblSMControl.intScreenId = tblSMScreen.intScreenId
		WHERE tblSMControl.intScreenId 
		IN (SELECT intScreenId FROM tblSMScreen 
			WHERE strNamespace
			IN (SELECT strNamespace FROM tblSMScreenStage 
				WHERE ISNULL(strChange, '') = '')
		)
	) B
	ON A.strControlId = B.strControlId AND A.strNamespace = B.strNamespace
	WHERE ISNULL(B.strControlName, '') = '' 

	-- Add entry to deleted control(s)
	INSERT INTO tblSMControlStage (
		strControlId, 
		strControlName, 
		strControlType, 
		strContainer, 
		intScreenStageId, 
		strChange, 
		intConcurrencyId)
	SELECT 
		A.strControlId, 
		A.strControlName, 
		A.strControlType, 
		'' As strContainer, 
		(SELECT TOP 1 intScreenStageId FROM tblSMScreenStage WHERE strNamespace = A.strNamespace) AS intScreenStageId,
		'Deleted' AS strChange,
		0
	FROM (
		SELECT tblSMControl.strControlId, 
			tblSMControl.strControlName, 
			tblSMControl.strControlType, 
			tblSMScreen.strNamespace 
		FROM tblSMControl 
		INNER JOIN tblSMScreen 
			ON tblSMControl.intScreenId = tblSMScreen.intScreenId
		WHERE tblSMControl.intScreenId 
		IN (SELECT intScreenId FROM tblSMScreen 
			WHERE strNamespace
			IN (SELECT strNamespace FROM tblSMScreenStage 
				WHERE ISNULL(strChange, '') = '')
		)
	) A
	LEFT OUTER JOIN (
		SELECT tblSMControlStage.strControlId, 
			tblSMControlStage.strControlName, 
			tblSMControlStage.strControlType, 
			tblSMScreenStage.strNamespace,
			tblSMControlStage.strChange,
			tblSMControlStage.intScreenStageId  
		FROM tblSMControlStage 
		INNER JOIN tblSMScreenStage 
			ON tblSMControlStage.intScreenStageId = tblSMScreenStage.intScreenStageId
		WHERE tblSMControlStage.intScreenStageId IN (SELECT intScreenStageId FROM tblSMScreenStage WHERE ISNULL(strChange, '') = '')
	) B
	ON A.strControlId = B.strControlId AND A.strNamespace = B.strNamespace
	WHERE ISNULL(B.strControlName, '') = '' 

	-- Delete control(s) staging that doesn't have conflicts
	DELETE FROM tblSMControlStage WHERE ISNULL(strChange, '') = ''
	
	-- Delete screen(s) staging that doesn't have conflicts
	DELETE FROM tblSMScreenStage
	WHERE ISNULL(
			(SELECT COUNT(*) 
				FROM tblSMControlStage 
				WHERE tblSMControlStage.intScreenStageId = tblSMScreenStage.intScreenStageId), 0) = 0
	AND ISNULL(tblSMScreenStage.strChange, '') = ''

COMMIT TRANSACTION