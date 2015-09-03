CREATE PROCEDURE [dbo].[uspSCFullSheetScaleTicket]
	@xmlParam NVARCHAR(MAX) = NULL 
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intTicketId	        INT,
			@xmlDocumentId			INT,
			@ysnCustomerCopy        BIT = 0 
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
	SELECT	@intTicketId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intTicketId'

	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500)

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

	SELECT	DISTINCT
			@strCompanyName + ', '  + CHAR(13)+CHAR(10) +
			ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')
			AS	strA,
			LTRIM(RTRIM(EY.strName)) + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EL.strAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EL.strCity)),'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EL.strState)) = '' THEN NULL ELSE LTRIM(RTRIM(EL.strState)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EL.strZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EL.strZipCode)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EL.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EL.strCountry)) END,'')
			AS	strB,
			CASE	WHEN	TIC.intTicketType  =	1	
					THEN	'INBOUND'
					WHEN	TIC.intTicketType  =	2
					THEN	'OUTBOUND'
			END		AS	strTicketType,
			CASE	WHEN	TIC.strTicketStatus  =	'O' and TIC.ysnTicketPrinted = 0	
					THEN	'Original'
					WHEN	TIC.strTicketStatus  =	'O' and TIC.ysnTicketPrinted = 1
					THEN	'Duplicate'
					WHEN	TIC.strTicketStatus  !=	'O'
					THEN	'Reprint'
			END		AS	strOriginal,
			CASE	WHEN	@ysnCustomerCopy  =	0	
					THEN	'Customer Copy'
					WHEN	@ysnCustomerCopy  =	1
					THEN	'Office Copy'
			END		AS	strCopy,
			TIC.intTicketNumber AS TicketNumber,
			TIC.intTicketId,
			SS.strStationShortDescription AS Station,
			TIC.strTruckName AS Truck,
			TIC.strCustomerReference AS CustomerReference,
			TIC.strDriverName AS Driver,
			EY.strNumber AS EntityNumber,
			SP.strSplitNumber AS Split,
			ITM.strItemNo AS Item,
			TIC.strScaleOperatorUser AS Weigher,
			LOC.strLocationNumber AS Location,
			TIC.intAxleCount AS Axles,
			CASE	WHEN	TIC.ysnDriverOff  =	0	
					THEN	'On'
					WHEN	TIC.ysnDriverOff  =	1
					THEN	'Off'
			END		AS	strOnOff,
			CASE	WHEN	TIC.ysnGrossManual  =	0	
					THEN	''
					WHEN	TIC.ysnGrossManual  =	1
					THEN	'MANUAL'
			END		AS	strGrossManual,
			CASE	WHEN	TIC.ysnTareManual  =	0	
					THEN	''
					WHEN	TIC.ysnTareManual  =	1
					THEN	'MANUAL'
			END		AS	strTareManual,
			TIC.dblGrossWeight AS GrossWeight,
			TIC.dblTareWeight AS TareWeight,
			CONVERT(VARCHAR, TIC.dtmGrossDateTime, 1) AS GrossDate,
			CONVERT(VARCHAR, TIC.dtmGrossDateTime, 108) AS GrossTime,
			CONVERT(VARCHAR, TIC.dtmTareDateTime, 1) AS TareDate,
			CONVERT(VARCHAR, TIC.dtmTareDateTime, 108) AS TareTime,
			TIC.dblGrossWeight - TIC.dblTareWeight AS NetWeight,
			TIC.dblGrossUnits AS GrossUnits,
			TIC.dblNetUnits AS NetUnits,
			TIC.dblGrossUnits - TIC.dblNetUnits AS ShrinkUnits,
			SS.strWeightDescription AS WgtDescription,
			ICU.strSymbol AS UOM
	FROM	
		tblSCTicket TIC
		LEFT JOIN vyuCTEntity EY	
		ON EY.intEntityId =	TIC.intEntityId
		LEFT JOIN tblEntityLocation	EL	
		ON EL.intEntityId = EY.intEntityId
		LEFT JOIN tblSCScaleSetup SS  
		ON TIC.intScaleSetupId = SS.intScaleSetupId
		LEFT JOIN tblARCustomerSplit SP 
		ON TIC.intSplitId = SP.intSplitId
		LEFT JOIN tblICItem ITM 
		ON TIC.intItemId = ITM.intItemId
		LEFT JOIN tblSMCompanyLocation LOC 
		ON TIC.intProcessingLocationId = LOC.intCompanyLocationId
		LEFT JOIN tblICCommodityUnitMeasure TCU 
		ON TCU.intCommodityId = TIC.intCommodityId AND TCU.ysnStockUnit = 1
		LEFT JOIN tblICUnitMeasure ICU 
		ON ICU.intUnitMeasureId = TCU.intUnitMeasureId	
	WHERE	
		intTicketId	=	@intTicketId

GO
