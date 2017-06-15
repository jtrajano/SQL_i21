CREATE PROCEDURE [dbo].[uspGRReportCanadianPrimaryElevatorReceipt]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strCompanyName NVARCHAR(500)
		,@strAddress NVARCHAR(500)
		,@strCounty NVARCHAR(500)
		,@strCity NVARCHAR(500)
		,@strState NVARCHAR(500)
		,@strZip NVARCHAR(500)
		,@strCountry NVARCHAR(500)
		,@xmlDocumentId INT
		,@intScaleTicketId INT
		,@strReceiptNumber NVARCHAR(20)

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

	SELECT @intScaleTicketId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intScaleTicketId'

	IF EXISTS (SELECT 1 FROM tblSCCpeReceipt WHERE intScaleTicketId = @intScaleTicketId )
	BEGIN
		SELECT @strReceiptNumber = strElevatorReceiptNumber
		FROM tblSCCpeReceipt
		WHERE intScaleTicketId = @intScaleTicketId
	END
	ELSE
	BEGIN
		SELECT @strReceiptNumber = [dbo].[fnAddZeroPrefixes](intNumber, 5)
		FROM tblSMStartingNumber
		WHERE [strTransactionType] = N'CPE Receipt'

		UPDATE tblSMStartingNumber
		SET intNumber = intNumber + 1
		WHERE [strTransactionType] = N'CPE Receipt'

		INSERT INTO tblSCCpeReceipt 
		(
			 intScaleTicketId
			,strElevatorReceiptNumber
		)
		SELECT @intScaleTicketId,@strReceiptNumber
	END

	SELECT @strCompanyName = 
			CASE 
				WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL
				ELSE LTRIM(RTRIM(strCompanyName))
			END
		,@strAddress = 
		 CASE 
			WHEN LTRIM(RTRIM(strAddress)) = ''THEN NULL
			ELSE LTRIM(RTRIM(strAddress))
		 END
		,@strCounty = 
		 CASE 
			WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL
			ELSE LTRIM(RTRIM(strCounty))
		 END
		,@strCity = 
		  CASE 
			WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL
			ELSE LTRIM(RTRIM(strCity))
		  END
		,@strState = 
		 CASE 
			WHEN LTRIM(RTRIM(strState)) = '' THEN NULL
			ELSE LTRIM(RTRIM(strState))
		 END
		,@strZip = 
		 CASE 
			WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL
			ELSE LTRIM(RTRIM(strZip))
		 END
		,@strCountry = 
		 CASE 
			WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL
			ELSE LTRIM(RTRIM(strCountry))
		 END
	FROM tblSMCompanySetup

	SELECT DISTINCT
		   @strCompanyName + ', ' 
		  + CHAR(13) + CHAR(10) 
		  + ISNULL(@strAddress, '') + ', ' 
		  + CHAR(13) + CHAR(10) 
		  + ISNULL(@strCity, '') + ISNULL(', ' + @strState, '') + ISNULL(', ' + @strZip, '') + ISNULL(', ' + @strCountry, '') 
	   AS strCompanyAddress
		,LTRIM(RTRIM(EY.strEntityName)) + ', ' 
		+ CHAR(13) + CHAR(10) 
		+ ISNULL(LTRIM(RTRIM(EY.strEntityAddress)), '') + ', ' 
		+ CHAR(13) + CHAR(10) 
		+ ISNULL(LTRIM(RTRIM(EY.strEntityCity)), '') + ISNULL(', ' 
		+ CASE 
				WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL
				ELSE LTRIM(RTRIM(EY.strEntityState))
		  END, '') 
		  + ISNULL(', ' 
		  + CASE 
				WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL
				ELSE LTRIM(RTRIM(EY.strEntityZipCode))
			END, '') 
			+ ISNULL(', ' 
			+ CASE 
				WHEN LTRIM(RTRIM(EY.strEntityCountry)) = ''THEN NULL
				ELSE LTRIM(RTRIM(EY.strEntityCountry))
			  END, '') 
		AS strEntityAddress
		,@strReceiptNumber AS strReceiptNumer
		,LTRIM(Year(SC.dtmTicketDateTime)) AS strYear
		,LTRIM(Month(SC.dtmTicketDateTime)) AS strMonth
		,LTRIM(Day(SC.dtmTicketDateTime)) AS strDay
		,[dbo].[fnRemoveTrailingZeroes](SC.dblGrossWeight) AS dblGrossWeight
		,[dbo].[fnRemoveTrailingZeroes](SC.dblTareWeight) AS dblTareWeight
		,[dbo].[fnRemoveTrailingZeroes]((SC.dblGrossWeight-SC.dblTareWeight)) AS strUnloadedGrain
		,[dbo].[fnRemoveTrailingZeroes](ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(SC.intItemId,ItemUOM.intUnitMeasureId,SS.intUnitMeasureId,SC.dblShrink),6)) AS dblDockage
		,[dbo].[fnRemoveTrailingZeroes](ROUND((SC.dblShrink*100.0/(SC.dblGrossWeight-SC.dblTareWeight)),6)) AS dblDockagePercent
		,[dbo].[fnRemoveTrailingZeroes](((SC.dblGrossWeight-SC.dblTareWeight)-dbo.fnCTConvertQuantityToTargetItemUOM(SC.intItemId,ItemUOM.intUnitMeasureId,SS.intUnitMeasureId,SC.dblShrink))) AS dblNetWeight	
		,Item.strItemNo
		,1 AS strGrade
		,EY.strVendorAccountNum		
		,SS.strStationShortDescription
		,SS.strStationDescription
		,SS.strPhone
		,SC.strBinNumber
		,NULL AS strBoxNoOfSample
		,[dbo].[fnGRConvertNumberToWords](SC.dblGrossWeight-SC.dblTareWeight) 
		+ ' point ' 
		+ [dbo].[fnGRConvertDecimalPartToWords]([dbo].[fnRemoveTrailingZeroes](SC.dblGrossWeight-SC.dblTareWeight)) 
		+ ' Bushel' AS strGrainUnloadedInWords
		,[dbo].[fnGRConvertNumberToWords](SC.dblGrossWeight-SC.dblTareWeight-dbo.fnCTConvertQuantityToTargetItemUOM(SC.intItemId,ItemUOM.intUnitMeasureId,SS.intUnitMeasureId,SC.dblShrink)) 
		+ ' point ' 
		+ [dbo].[fnGRConvertDecimalPartToWords]([dbo].[fnRemoveTrailingZeroes](SC.dblGrossWeight-SC.dblTareWeight-dbo.fnCTConvertQuantityToTargetItemUOM(SC.intItemId,ItemUOM.intUnitMeasureId,SS.intUnitMeasureId,SC.dblShrink)))
		+ ' Bushel' AS strNetWeightInWords
	FROM tblSCTicket SC
	JOIN vyuCTEntity EY ON EY.intEntityId = SC.intEntityId
	JOIN tblICItem Item ON Item.intItemId = SC.intItemId
	JOIN tblSCScaleSetup SS ON SS.intScaleSetupId = SC.intScaleSetupId
	JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId=SC.intItemUOMIdTo
	WHERE SC.intTicketId = @intScaleTicketId
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH

