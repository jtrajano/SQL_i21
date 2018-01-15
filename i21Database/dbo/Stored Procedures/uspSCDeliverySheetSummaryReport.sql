CREATE PROCEDURE [dbo].[uspSCDeliverySheetSummaryReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
		,@intDeliverySheetId INT
		,@intSplitId INT

	SET @xmlParam = '  
	<xmlparam>  
	 <filters>  
	  <filter>  
	   <fieldname>intDeliverySheetId</fieldname>  
	   <condition>Between</condition>  
	   <from>' +@xmlParam+ '</from>  
	   <to>' +@xmlParam+ '</to>  
	   <join>And</join>  
	   <begingroup>0</begingroup>  
	   <endgroup>0</endgroup>  
	   <datatype>Int</datatype>  
	  </filter>  
	 </filters>  
	 <options />  
	</xmlparam>'

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE 
	(
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
	(
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
	)

	SELECT @intDeliverySheetId = [from]
	FROM @temp_xml_table
	
	WHERE [fieldname] = 'intDeliverySheetId'
	EXEC uspSCDeliverySheetSummary @intDeliverySheetId
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH