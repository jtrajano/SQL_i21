CREATE PROCEDURE [dbo].[uspGRReportStorageStatement]
	
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
			@intStorageScheduleId	INT,
			@strLicenseNumber		NVARCHAR(100),
			@xmlDocumentId			INT,
			@strPrefix              Nvarchar(100),
			@intNumber				INT,
			@strFormNumber			NVARCHAR(100),
			@IsNewMode				BIT=0
						
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
    
	SELECT	@intEntityId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intEntityId'

	SELECT @intItemId=[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intItemId'
	
	SELECT @intStorageTypeId=[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intStorageTypeId'

	SELECT @intStorageScheduleId=[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intStorageScheduleRuleId'

	SELECT  @strFormNumber=[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strFormNumber'
		
	IF ISNULL(@intEntityId,0) >0 AND ISNULL(@intItemId,0) >0 AND ISNULL(@intStorageTypeId,0) >0 AND ISNULL(@intStorageScheduleId,0) >0
	BEGIN
		SET @IsNewMode=1
		SELECT @strItemNo=strItemNo FROM tblICItem WHERE intItemId=@intItemId
		SELECT @strStorageType=strStorageTypeDescription FROM tblGRStorageType WHERE intStorageScheduleTypeId=@intStorageTypeId
		SELECT @strLicenseNumber=[strLicenseNumber] FROM [tblGRCompanyPreference]
		--SELECT @strPrefix=[strPrefix],@intNumber=intNumber+1 FROM tblSMStartingNumber WHERE [strTransactionType] = N'Storage Statement FormNo'
		--SET @strPrefix=NULL
		SET @intNumber = 0
	END
	ELSE
	BEGIN
		
		SELECT @intEntityId=intEntityId,@intItemId=intItemId,@intStorageTypeId=intStorageTypeId,@intStorageScheduleId=intStorageScheduleId
		FROM tblGRCustomerStorage Where intCustomerStorageId=(SELECT Top 1 intCustomerStorageId FROM tblGRStorageStatement WHERE strFormNumber=@strFormNumber)
		SELECT Top 1 @strLicenseNumber=strLicenceNumber FROM tblGRStorageStatement WHERE strFormNumber=@strFormNumber
		SELECT @strItemNo=strItemNo FROM tblICItem WHERE intItemId=@intItemId
		SELECT @strStorageType=strStorageTypeDescription FROM tblGRStorageType WHERE intStorageScheduleTypeId=@intStorageTypeId
		--SET @strPrefix=NULL
		 SET @intNumber=1
	END

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

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
		@strStorageType AS strStorageType,			
		@strLicenseNumber AS strLicenseNumber,			
		CASE WHEN @IsNewMode=1 THEN @intEntityId ELSE 0 END AS intEntityId,
		CASE WHEN @IsNewMode=1 THEN @intItemId ELSE 0 END  AS intItemId,
		CASE WHEN @IsNewMode=1 THEN @intStorageTypeId ELSE 0 END AS intStorageTypeId,
		CASE WHEN @IsNewMode=1 THEN @intStorageScheduleId ELSE 0 END  AS intStorageScheduleId,
		@strFormNumber AS strFormNumber,
		@strPrefix AS strPrefix,
		@intNumber AS intNumber
	FROM vyuCTEntity EY	WHERE EY.intEntityId=@intEntityId		

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
