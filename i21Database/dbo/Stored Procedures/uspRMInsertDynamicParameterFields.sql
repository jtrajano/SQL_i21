
-- Create date: <Create Date,,11/12/2013>
-- Description:	<Description,,This SP insert dynamic fields for report field list and field selection manager base on GL account structure>

CREATE PROCEDURE uspRMInsertDynamicParameterFields
	
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

	--GET REPORT Id'S
	INSERT INTO @ReportIds
	SELECT report.intReportId
	FROM tblRMDatasource datasource
	INNER JOIN tblRMReport report
	ON report.intReportId = datasource.intReportId
	WHERE datasource.strQuery LIKE '%tempDASTable%' 
	or datasource.strQuery LIKE '%tblGLTempCOASegment%' 

	--CREATE DYNAMIC ACCOUNT STRUCTURE
	EXEC uspGLBuildTempCOASegment

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
		IF EXISTS (SELECT * FROM tblRMCriteriaFieldSelection WHERE strSource = 'tempDASTable' or strSource = 'tblGLTempCOASegment' or strSource IS NULL)
			BEGIN
				
				--STORE CFS Id's 
				INSERT INTO @CFS
				SELECT intCriteriaFieldSelectionId 
				FROM tblRMCriteriaFieldSelection
				WHERE strSource = 'tempDASTable' 
				or strSource = 'tblGLTempCOASegment'
				or strSource IS NULL
			
				WHILE EXISTS (SELECT TOP 1 1 FROM @CFS)
				BEGIN
					SELECT @CFSId = Id FROM @CFS
					
					--DELETE CF and CFS WITH tblGLTempCOASegment
					DELETE tblRMCriteriaField WHERE intCriteriaFieldSelectionId = @CFSId
					DELETE tblRMCriteriaFieldSelection WHERE intCriteriaFieldSelectionId = @CFSId
					
					DELETE @CFS WHERE Id = @CFSId
				END
				
			END

	--INSERT DATA
		WHILE EXISTS (SELECT TOP 1 1 FROM @DynamicColumns)
			BEGIN
				--INSERT CRITERIA FIELDSELECTION
				SET @CFSSource = 'tblGLTempCOASegment'
				SELECT TOP 1 @CFSConnectionId = intConnectionId FROM tblRMConnection
				SELECT @CFSFieldName = AccntStrcture FROM @DynamicColumns
				IF (@CFSFieldName != 'intAccountId' AND @CFSFieldName != 'strAccountId')
					BEGIN
						INSERT INTO tblRMCriteriaFieldSelection
						(strName,intConnectionId,strFieldName,strCaption,strValueField,strDisplayField,ysnDistinct,strSource,intFieldSourceType)
						VALUES (@CFSFieldName,@CFSConnectionId,@CFSFieldName,@CFSFieldName,@CFSFieldName,@CFSFieldName,'True',@CFSSource,0)
					END
				
				--STORE NEWLY SAVE CFS
				INSERT INTO @NewCFS
				SELECT intCriteriaFieldSelectionId,strName
				FROM tblRMCriteriaFieldSelection
				WHERE strSource = 'tempDASTable' 
				or strSource = 'tblGLTempCOASegment'
		
				--DELETE CURRENT AccntStrcture TO AVOId ENDLESSLOOP
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
							INSERT INTO tblRMCriteriaField
							(intReportId,intCriteriaFieldSelectionId,strFieldName,strDataType,strDescription,strConditions,ysnIsRequired,ysnShow,ysnAllowSort,ysnEditCondition)
							VALUES (@CurrentReportId,@NCFSId,@NCFSName,'String',@NCFSName,null,0,1,1,1)
						
							SET @Counter = @Counter + 1
						END
					
					DELETE @NewCFS WHERE Id = @NCFSId
				END
END