﻿CREATE PROCEDURE [dbo].[uspSCDeliverySheetGradeReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
		,@intDeliverySheetId INT

	--DECLARE @xmlParam NVARCHAR(MAX) = NULL
	--SET @xmlParam = 20

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
	--IF NOT EXISTS(SELECT TOP 1 intDiscountScheduleCodeId FROM tblQMTicketDiscount WHERE intTicketFileId = @intDeliverySheetId AND strSourceType = 'Delivery Sheet')
	--BEGIN
		EXEC uspSCDeliverySheetGrade @intDeliverySheetId
	--END
	--ELSE
	--BEGIN
	--	SELECT QM.intTicketFileId AS intDeliverySheetId
	--	,IC.strItemNo AS Item
	--	,QM.dblGradeReading AS Amount
	--	,QM.dblDiscountAmount AS DiscountAmount
	--	,intDecimalPrecision = (SELECT TOP 1 intCurrencyDecimal FROM tblSMCompanyPreference)
	--	FROM tblQMTicketDiscount QM
	--	INNER JOIN tblGRDiscountScheduleCode GR ON GR.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	--	INNER JOIN tblICItem IC ON  IC.intItemId = GR.intItemId
	--	WHERE QM.intTicketFileId = @intDeliverySheetId 
	--	AND strSourceType = 'Delivery Sheet'
	--END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH