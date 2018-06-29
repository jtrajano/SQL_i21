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
		,@dblGrossWeight DECIMAL(24,10) 
		,@dblTareWeight DECIMAL(24,10)
		,@dblUnloadedGrain DECIMAL(24,10)
		,@dblDockage DECIMAL(24,10)
		,@dblDockagePercent DECIMAL(24,10)
		,@dblNetWeight DECIMAL(24,10)
		,@GrainUnloadedDecimal DECIMAL(24,10)
		,@NetWeightDecimal DECIMAL(24,10)
		,@strItemStockUOM NVARCHAR(30)

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
	WHERE [fieldname] = 'intTicketId'

	IF EXISTS (SELECT 1 FROM tblSCTicket WHERE intTicketId = @intScaleTicketId  AND strElevatorReceiptNumber IS NOT NULL)
	BEGIN
		SELECT @strReceiptNumber = strElevatorReceiptNumber
		FROM tblSCTicket
		WHERE intTicketId = @intScaleTicketId
	END
	ELSE
	BEGIN
		SELECT @strReceiptNumber = [dbo].[fnAddZeroPrefixes](intNumber, 5)
		FROM tblSMStartingNumber
		WHERE [strTransactionType] = N'CPE Receipt'

		UPDATE tblSMStartingNumber
		SET intNumber = intNumber + 1
		WHERE [strTransactionType] = N'CPE Receipt'

		UPDATE tblSCTicket
		SET strElevatorReceiptNumber=@strReceiptNumber
		WHERE intTicketId = @intScaleTicketId
				
	END

	SELECT 
	@strItemStockUOM = UnitMeasure.strUnitMeasure,
	@dblGrossWeight  =  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,SC.dblGrossWeight),3),
	@dblTareWeight =  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,SC.dblTareWeight),3),
	@dblUnloadedGrain =  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight)),3),
	@dblDockage = ROUND(SC.dblShrink,3),
	@dblDockagePercent = ROUND((SC.dblShrink*100.0/(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight)))),2),
	@dblNetWeight=ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight))-SC.dblShrink,3)
	FROM   tblICUnitMeasure UnitMeasure
	JOIN   tblICItemUOM ItemUOM ON ItemUOM.intUnitMeasureId=UnitMeasure.intUnitMeasureId
	JOIN   tblSCTicket SC ON SC.intItemUOMIdTo=ItemUOM.intItemUOMId
	JOIN   tblSCScaleSetup SS ON SS.intScaleSetupId = SC.intScaleSetupId
	JOIN   tblICItemUOM ItemUOM1 ON ItemUOM1.intUnitMeasureId=SS.intUnitMeasureId AND  ItemUOM1.intItemId=SC.intItemId
	WHERE  SC.intTicketId=@intScaleTicketId
	
	SET @GrainUnloadedDecimal=ROUND(@dblUnloadedGrain-FLOOR(@dblUnloadedGrain),3)
	SET @NetWeightDecimal=ROUND(@dblNetWeight-FLOOR(@dblNetWeight),3)

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
	FROM tblSMCompanySetup

	SELECT DISTINCT
		   @strCompanyName + 
		  + CHAR(13) + CHAR(10) 
		  + ISNULL(@strAddress, '') + 
		  + CHAR(13) + CHAR(10) 
		  + ISNULL(@strCity, '') + ISNULL(', ' + @strState, '') +' '+ISNULL(@strZip, '')
	   AS strCompanyAddress
		,LTRIM(RTRIM(EY.strEntityName)) + 
		+ CHAR(13) + CHAR(10) 
		+ ISNULL(LTRIM(RTRIM(EY.strEntityAddress)), '') +
		+ CHAR(13) + CHAR(10) 
		+ ISNULL(LTRIM(RTRIM(EY.strEntityCity)), '') 
		+ ISNULL(', ' 
					+ CASE 
							WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL
							ELSE LTRIM(RTRIM(EY.strEntityState))
					  END, 
			     '') 
		  + ISNULL(' ' 
					  + CASE 
							WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL
							ELSE LTRIM(RTRIM(EY.strEntityZipCode))
						END, 
				   '') 			
		  AS strEntityAddress
		,@strReceiptNumber AS strReceiptNumer
		,LTRIM(Year(SC.dtmTicketDateTime)) AS strYear
		,LTRIM(Month(SC.dtmTicketDateTime)) AS strMonth
		,LTRIM(Day(SC.dtmTicketDateTime)) AS strDay
		,[dbo].[fnRemoveTrailingZeroes](@dblGrossWeight) AS dblGrossWeight
		,[dbo].[fnRemoveTrailingZeroes](@dblTareWeight) AS dblTareWeight
		,[dbo].[fnRemoveTrailingZeroes](@dblUnloadedGrain) AS strUnloadedGrain
		,[dbo].[fnRemoveTrailingZeroes](@dblDockage) AS dblDockage
		,[dbo].[fnRemoveTrailingZeroes](@dblDockagePercent) AS dblDockagePercent
		,[dbo].[fnRemoveTrailingZeroes](@dblNetWeight) AS dblNetWeight	
		,Item.strItemNo
		,Attribute.strDescription AS strGrade
		,EY.strVendorAccountNum		
		,SS.strStationShortDescription
		,SS.strStationDescription
		,SS.strPhone
		,SC.strBinNumber
		,NULL AS strBoxNoOfSample
		,' Scale record in '+ @strItemStockUOM AS ScaleLabel
		,[dbo].[fnGRConvertNumberToWords](@dblUnloadedGrain) 
		+ CASE 
			WHEN @GrainUnloadedDecimal >0 THEN ' point ' + [dbo].[fnGRConvertDecimalPartToWords](@dblUnloadedGrain)
			ELSE ''
		  END		 
		+ ' '+@strItemStockUOM AS strGrainUnloadedInWords
		,[dbo].[fnGRConvertNumberToWords](@dblNetWeight) 
		+CASE 
			 WHEN @NetWeightDecimal >0 THEN + ' point ' + [dbo].[fnGRConvertDecimalPartToWords](@dblNetWeight)
			 ELSE ''
		 END	 		
		+ ' '+@strItemStockUOM AS strNetWeightInWords
		,'On surrender of this receipt and the payment or tender of all lawful charges in respect of the grain described, the identical grain will be delivered either'		 
		 +CHAR(13) +CHAR(10)+'(a) by the discharge of the grain into a railway car or other conveyance made available for loading at this elevator; or'		 
		 +CHAR(13) +CHAR(10)+'(b) by the substitution for this and like receipts, together covering a quantity not less than a carload lot, of an elevator receipt for grain of the identical quantity'
		 +CHAR(13) +CHAR(10)+'and grade, and subject only to the dockage above specified, issued in the prescribed form by a terminal, process or transfer elevator to which shipment of the said grain,'		 
		 +CHAR(13) +CHAR(10)+'upon notice or otherwise, is authorized by the Canada Grain Act.' 
		 AS strSpecialText

		,'Upon the surrender of this receipt after delivery of the Commission report as to the grade and dockage of the above sample, there shall be issued in lieu of this receipt'
		+ CHAR(13) + CHAR(10)+'a Primary Elevator Receipt or Cash Purchase Ticket for grain of the grade reported by the inspecting officer,subject to the dockage specified.'		
		 AS strInterimText

		,'Upon surrender of this receipt and the payment or tender of all lawful charges in respect of the grain described, either a cash purchase ticket shall be issued for the'
		+ CHAR(13) + CHAR(10)+'net weight of grain of the grade specified or like grain described on this receipt will be delivered to the holder of this receipt'		
		+ CHAR(13) + CHAR(10)+'(a) by the discharge of the grain into a railway car or other conveyance made available for loading at  this elevator; or'		
		+ CHAR(13) + CHAR(10)+'(b) by the substitution for this and like receipts, together covering a quantity not less than a carload lot, of an elevator receipt for grain of the same quantity'
		+ CHAR(13) + CHAR(10)+'and grade, and subject only to the dockage above specified, issued in the prescribed form by a terminal, process or transfer elevator to which shipment of the grain,'
		+ CHAR(13) + CHAR(10)+'upon notice or otherwise, is authorized by the Canada Grain Act.'
		 AS strPrimaryText

		,'WARNING: The right of the holder of this receipt to obtain delivery of the grain described in the receipt may be altered by the issuer by notice'
		 + CHAR(13) + CHAR(10)+'altered by the issuer by notice to the last holder known to the issuer. Every holder of a receipt should immediately notify the issuer of their name and address'
		 AS strWarning

	FROM tblSCTicket SC
	JOIN vyuCTEntity EY ON EY.intEntityId = SC.intEntityId
	JOIN tblICItem Item ON Item.intItemId = SC.intItemId
	JOIN tblSCScaleSetup SS ON SS.intScaleSetupId = SC.intScaleSetupId
	LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
	WHERE SC.intTicketId = @intScaleTicketId
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH

