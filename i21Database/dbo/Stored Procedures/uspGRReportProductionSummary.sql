﻿CREATE PROCEDURE [dbo].[uspGRReportProductionSummary]
	@xmlParam NVARCHAR(MAX) = NULL 
AS
BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@intEntityId			INT,
			@intItemId				INT,
			@strItemNo				NVARCHAR(100),
			@intStorageTypeId		INT,
			@strStorageType			NVARCHAR(100),						
			@xmlDocumentId			INT
			
						
	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT  @intStorageTypeId=[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intStorageTypeId'

	SELECT  @intItemId=[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intItemId'

	SELECT	@intEntityId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intEntityId'
	
	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

	SELECT @strItemNo=strItemNo FROM tblICItem WHERE intItemId=@intItemId
	SELECT @strStorageType=strStorageTypeDescription FROM tblGRStorageType WHERE intStorageScheduleTypeId=@intStorageTypeId

	SELECT	
	DISTINCT
		@strCompanyName + ', '  + CHAR(13)+CHAR(10) +
		ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
		ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')
		AS	strCompanyAddress,
		LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
		ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
		ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
		ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
		ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
		ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
		AS	strEntityAddress,			
		@strItemNo AS strItemNo,			
		@strStorageType+' Statement' AS strStorageType,
		@intEntityId AS intEntityId,
		@intItemId   AS intItemId,
		@intStorageTypeId AS intStorageTypeId,
		EY.strVendorAccountNum AS strVendorAccountNum
	FROM vyuCTEntity EY	
	WHERE EY.intEntityId=@intEntityId
					

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
