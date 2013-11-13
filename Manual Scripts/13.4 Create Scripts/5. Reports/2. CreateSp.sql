
SET ANSI_NULLS ON
GO
DROP PROCEDURE InsertDynamicParameterFields

SET QUOTED_IDENTIFIER ON
GO

-- Create date: <Create Date,,11/12/2013>
-- Description:	<Description,,This SP insert dynamic fields for report field list and field selection manager base on GL account structure>

CREATE PROCEDURE InsertDynamicParameterFields
	
AS
BEGIN
	
	DECLARE @CurrentReportId INT
	DECLARE @DynamicColumns TABLE
	(
		AccntStrcture NVARCHAR(MAX)
	)
	DECLARE @ReportIds TABLE
	(
		Id int,
		Indexs int identity(1,1)
	)
	DECLARE @CFS TABLE
	(
		Id int
	)
	DECLARE @NewCFS TABLE
	(
		Id int,
		Name NVARCHAR(MAX)
	)

	--GET REPORT ID'S
	INSERT INTO @ReportIds
	SELECT report.intReportId
	FROM tblRMDatasources datasource
	INNER JOIN tblRMReports report
	ON report.intReportId = datasource.intReportId
	WHERE datasource.strQuery LIKE '%tempDASTable%' 
	or datasource.strQuery LIKE '%tblGLTempCOASegment%' 

	--CREATE DYNAMIC ACCOUNT STRUCTURE
	EXEC usp_BuildGLCOASegment

	--STORE DYNAMIC COLUMNS
	INSERT INTO @DynamicColumns
	SELECT COLUMN_NAME
	FROM   INFORMATION_SCHEMA.COLUMNS
	WHERE  table_name = 'tblGLTempCOASegment'

	--CRITERIA FIELDSELECTION VARIABLES
		DECLARE @CFSId NVARCHAR(MAX)
		DECLARE @CFSConnectionId INT
		DECLARE @CFSFieldName NVARCHAR(MAX)
		DECLARE @CFSSource NVARCHAR(MAX)
	--CRITERIA FIELDS VARIABLES
		DECLARE @CFId NVARCHAR(MAX)
		DECLARE @CFCFSId INT
		DECLARE @CFFieldName NVARCHAR(MAX)
		
		--CHECK IF THERE IS EXISTING CFS WITH tempDASTable or tblGLTempCOASegment
		IF EXISTS (SELECT * FROM tblRMCriteriaFieldSelections WHERE strSource = 'tempDASTable' or strSource = 'tblGLTempCOASegment' or strSource IS NULL)
			BEGIN
				
				--STORE CFS ID's 
				INSERT INTO @CFS
				SELECT intCriteriaFieldSelectionId 
				FROM tblRMCriteriaFieldSelections 
				WHERE strSource = 'tempDASTable' 
				or strSource = 'tblGLTempCOASegment'
				or strSource IS NULL
			
				WHILE EXISTS (SELECT TOP 1 1 FROM @CFS)
				BEGIN
					SELECT @CFSId = Id FROM @CFS
					
					--DELETE CF and CFS WITH tblGLTempCOASegment
					DELETE tblRMCriteriaFields WHERE intCriteriaFieldSelectionId = @CFSId
					DELETE tblRMCriteriaFieldSelections WHERE intCriteriaFieldSelectionId = @CFSId
					
					DELETE @CFS WHERE Id = @CFSId
				END
				
			END

	--INSERT DATA
		WHILE EXISTS (SELECT TOP 1 1 FROM @DynamicColumns)
			BEGIN
				--INSERT CRITERIA FIELDSELECTION
				SET @CFSSource = 'tblGLTempCOASegment'
				SELECT TOP 1 @CFSConnectionId = intConnectionId FROM tblRMConnections
				SELECT @CFSFieldName = AccntStrcture FROM @DynamicColumns
				IF (@CFSFieldName != 'intAccountID' AND @CFSFieldName != 'strAccountID')
					BEGIN
						INSERT INTO tblRMCriteriaFieldSelections
						(strName,intConnectionId,strFieldName,strCaption,strValueField,strDisplayField,ysnDistinct,strSource,intFieldSourceType)
						VALUES (@CFSFieldName,@CFSConnectionId,@CFSFieldName,@CFSFieldName,@CFSFieldName,@CFSFieldName,'True',@CFSSource,0)
					END
				
				--STORE NEWLY SAVE CFS
				INSERT INTO @NewCFS
				SELECT intCriteriaFieldSelectionId,strName
				FROM tblRMCriteriaFieldSelections 
				WHERE strSource = 'tempDASTable' 
				or strSource = 'tblGLTempCOASegment'
		
				--DELETE CURRENT AccntStrcture TO AVOID ENDLESSLOOP
				DELETE @DynamicColumns WHERE AccntStrcture = @CFSFieldName
			END
			
		WHILE EXISTS (SELECT TOP 1 1 FROM @NewCFS)
				BEGIN
					DECLARE @NCFSId int
					DECLARE @NCFSName NVARCHAR(MAX)
					DECLARE @Counter int
					DECLARE @Count int
					SET @Counter =1;
					SELECT @NCFSId = Id FROM @NewCFS
					SELECT @NCFSName = Name FROM @NewCFS
					SELECT @Count = COUNT(*) FROM @ReportIds;
					
					WHILE (@Counter <= @Count)
						BEGIN
							--INSERT CRITERIA FIELDS
							SELECT @CurrentReportId = Id FROM @ReportIds WHERE Indexs = @Counter
							INSERT INTO tblRMCriteriaFields
							(intReportId,intCriteriaFieldSelectionId,strFieldName,strDataType,strDescription,strConditions,ysnIsRequired,ysnShow,ysnAllowSort,ysnEditCondition)
							VALUES (@CurrentReportId,@NCFSId,@NCFSName,'String',@NCFSName,'Equal To',0,1,1,1)
						
							SET @Counter = @Counter + 1
						END
					
					DELETE @NewCFS WHERE Id = @NCFSId
				END
END
GO
