CREATE PROCEDURE [dbo].[uspSMDuplicateImportFileHeader]
	@ImportFileHeaderId INT,
	@NewImportFileHeaderId INT OUTPUT
AS
BEGIN
--SET @ImportFileHeaderId = 11
	--------------------------
	-- Generate New Import File Header Id --
	--------------------------
	DECLARE @LayoutTitle NVARCHAR(50),
		@NewLayoutTitle NVARCHAR(50),
		@NewLayoutTitleWithCounter NVARCHAR(50),
		@counter INT
	SELECT @LayoutTitle = strLayoutTitle, @NewLayoutTitle = 'DUP: ' + strLayoutTitle FROM tblSMImportFileHeader 
	WHERE intImportFileHeaderId = @ImportFileHeaderId
	IF EXISTS(SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @NewLayoutTitle)
	BEGIN
		SET @counter = 1
		SET @NewLayoutTitleWithCounter = @NewLayoutTitle + '(' + (CAST(@counter AS NVARCHAR(50))) + ')'
		WHILE EXISTS(SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @NewLayoutTitleWithCounter)
		BEGIN
			SET @counter += 1
			SET @NewLayoutTitleWithCounter = @NewLayoutTitle + '(' + (CAST(@counter AS NVARCHAR(50))) + ')'
		END
		SET @NewLayoutTitle = @NewLayoutTitleWithCounter
	END
	-----------------------------------
	-- End Generation of New Import File Header Id --
	-----------------------------------

	---------------------------------
	-- Duplicate Import File Header table --
	---------------------------------

	INSERT INTO [dbo].[tblSMImportFileHeader]
           ([strLayoutTitle]
           ,[strFileType]
           ,[strFieldDelimiter]
           ,[strXMLType]
           ,[strXMLInitiater]
           ,[ysnActive]
           ,[intConcurrencyId])
     SELECT @NewLayoutTitle
		  ,[strFileType]
		  ,[strFieldDelimiter]
		  ,[strXMLType]
		  ,[strXMLInitiater]
		  ,[ysnActive]
		  ,1
	  FROM [dbo].[tblSMImportFileHeader]
	  WHERE intImportFileHeaderId = @ImportFileHeaderId
	------------------------------------------
	-- End duplication of Import File Header table --
	------------------------------------------

	SET @NewImportFileHeaderId = SCOPE_IDENTITY()
	
	------------------------------
	-- Duplicate Import File Record Marker table --
	------------------------------
	INSERT INTO [dbo].[tblSMImportFileRecordMarker]
           ([intImportFileHeaderId]
           ,[strRecordMarker]
           ,[intRowsToSkip]
           ,[intPosition]
           ,[strCondition]
           ,[intSequence]
           ,[intConcurrencyId])
    SELECT @NewImportFileHeaderId
		  ,[strRecordMarker]
		  ,[intRowsToSkip]
		  ,[intPosition]
		  ,[strCondition]
		  ,[intSequence]
		  ,1
	  FROM [dbo].[tblSMImportFileRecordMarker]
	  WHERE intImportFileHeaderId = @ImportFileHeaderId
	------------------------------------------
	-- End duplication of Import Record Marker table --
	------------------------------------------
	
	------------------------------
	-- Duplicate Import File Record Marker table --
	------------------------------
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
           ([intImportFileHeaderId]
           ,[intImportFileRecordMarkerId]
           ,[intLevel]
           ,[intPosition]
           ,[strXMLTag]
           ,[strTable]
           ,[strColumnName]
           ,[strDataType]
           ,[intLength]
           ,[strDefaultValue]
           ,[ysnActive]
           ,[intConcurrencyId])
	SELECT @NewImportFileHeaderId
		  ,CASE WHEN [intImportFileRecordMarkerId] = NULL 
				THEN NULL 
				ELSE (Select top 1 intImportFileRecordMarkerId from dbo.tblSMImportFileRecordMarker 
					Where  strRecordMarker IN (Select strRecordMarker FROM tblSMImportFileRecordMarker 
					Where intImportFileHeaderId = @ImportFileHeaderId AND intImportFileRecordMarkerId = CD.intImportFileRecordMarkerId)
					ORDER BY intImportFileRecordMarkerId DESC )
			END [intImportFileRecordMarkerId]
		  ,[intLevel]
		  ,[intPosition]
		  ,[strXMLTag]
		  ,[strTable]
		  ,[strColumnName]
		  ,[strDataType]
		  ,[intLength]
		  ,[strDefaultValue]
		  ,[ysnActive]
		  ,1
	  FROM [dbo].[tblSMImportFileColumnDetail] CD
	  WHERE intImportFileHeaderId = @ImportFileHeaderId
	  
	------------------------------
	-- END Duplicate Import File Record Marker table --
	------------------------------
	
	------------------------------
	-- Duplicate Import XML Tag Attribute table --
	------------------------------
	INSERT INTO [dbo].[tblSMXMLTagAttribute]
           ([intImportFileColumnDetailId]
           ,[intSequence]
           ,[strTagAttribute]
           ,[strTable]
           ,[strColumnName]
           ,[strDefaultValue]
           ,[ysnActive]
           ,[intConcurrencyId])
     SELECT 
			(Select top 1 intImportFileColumnDetailId FROM dbo.tblSMImportFileColumnDetail 
			WHERE strXMLTag = CD.strXMLTag AND intLevel = CD.intLevel  AND intImportFileHeaderId = @NewImportFileHeaderId 
			order by intImportFileColumnDetailId desc) [intImportFileColumnDetailId]
		  ,X1.[intSequence]
		  ,X1.[strTagAttribute]
		  ,X1.[strTable]
		  ,X1.[strColumnName]
		  ,X1.[strDefaultValue]
		  ,X1.[ysnActive]
		  ,1
	  FROM [dbo].[tblSMXMLTagAttribute]  X1
	  JOIN dbo.tblSMImportFileColumnDetail CD ON X1.intImportFileColumnDetailId = CD.intImportFileColumnDetailId
	  WHERE CD.intImportFileHeaderId = @ImportFileHeaderId

	------------------------------
	-- END Duplicate Import XML Tag Attribute table --
	------------------------------
--SELECT @NewImportFileHeaderId

END


