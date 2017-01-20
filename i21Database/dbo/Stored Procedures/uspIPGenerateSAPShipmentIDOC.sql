CREATE PROCEDURE [dbo].[uspIPGenerateSAPShipmentIDOC]
AS

Declare @intMinHeader				INT,
		@intMinDetail				INT,
		@intMinContainer			INT,
		@intLoadStgId				INT ,
		@intLoadId					INT,
		@strTransactionType			NVARCHAR(100),
		@strLoadNumber				NVARCHAR(100),
		@strCommodityCode			NVARCHAR(100) ,
		@strCommodityDesc			NVARCHAR(100) ,
		@strContractBasis			NVARCHAR(100) ,--INCOTERMS1
		@strContractBasisDesc		NVARCHAR(500) ,--INCOTERMS2
		@strBillOfLading			NVARCHAR(100) , 
		@strShippingLine			NVARCHAR(100) , 
		@strExternalDeliveryNumber	NVARCHAR(100) , 
		@dtmScheduledDate			DATETIME,
		@strRowState				NVARCHAR(50) ,
		@strFeedStatus				NVARCHAR(50) ,
		@strXml						NVARCHAR(MAX),
		@strDocType					NVARCHAR(50),
		@strInstructionIDOCHeader	NVARCHAR(MAX),
		@strAdviceIDOCHeader		NVARCHAR(MAX),
		@strCompCode				NVARCHAR(100)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strContractFeedIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
)

Select @strInstructionIDOCHeader=dbo.fnIPGetSAPIDOCHeader('SHIPMENT INSTRUCTION')
Select @strAdviceIDOCHeader=dbo.fnIPGetSAPIDOCHeader('SHIPMENT ADVICE')
Select @strCompCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL','COMP_CODE')

Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where ISNULL(strFeedStatus,'')=''

While(@intMinHeader is not null)
Begin
	Select 
		@intLoadStgId				=	intLoadStgId ,
		@intLoadId					=	intLoadId,
		@strTransactionType			=	strTransactionType,
		@strLoadNumber				=	strLoadNumber,
		@strContractBasis			=	strContractBasis ,--INCOTERMS1
		@strContractBasisDesc		=	strContractBasisDesc ,--INCOTERMS2
		@strBillOfLading			=	strBillOfLading , 
		@strShippingLine			=	strShippingLine , 
		@strExternalDeliveryNumber	=	strExternalDeliveryNumber , 
		@dtmScheduledDate			=   dtmScheduledDate,
		@strRowState				=	strRowState ,
		@strFeedStatus				=	strFeedStatus
	From tblLGLoadStg Where intLoadStgId=@intMinHeader

	If UPPER(@strRowState)='ADDED'
	Begin
		Set @strXml =  '<DELVRY07>'
		Set @strXml += '<IDOC BEGIN="1">'

		--IDOC Header
		Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
		Set @strXml +=	@strInstructionIDOCHeader
		Set @strXml +=	'</EDI_DC40>'
		
		Set @strXml +=	'<DESADV SEGMENT="1">'

		--Header
		Set @strXml += '<E1ELD20 SEGMENT="1">'
		Set @strXml += '<INCO1>'	+ ISNULL(@strContractBasis,'')			+ '</INCO1>'
		Set @strXml += '<INCO2>'	+ ISNULL(@strContractBasisDesc,'')		+ '</INCO2>'
		Set @strXml += '<BOLNR>'	+ ISNULL(@strBillOfLading,'')			+ '</BOLNR>'
		Set @strXml += '<TRAID>'	+ ISNULL(@strShippingLine,'')			+ '</TRAID>'
		Set @strXml += '<VBELN>'	+ ISNULL(@strExternalDeliveryNumber,'')	+ '</VBELN>'
		Set @strXml += '<LIFEX>'	+ ISNULL(@strLoadNumber,'')				+ '</LIFEX>'
		Set @strXml +=	'</E1ELD20>'

		Set @strXml += '<E1EDL18>'
		Set @strXml += '<QUALF>'	+ 'ORI'			+ '</QUALF>'
		Set @strXml +=	'</E1EDL18>'

		Set @strXml += '<E1EDL13>'
		Set @strXml += '<QUALF>'	+ '015'			+ '</QUALF>'
		Set @strXml += '<NATANF>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmScheduledDate,112),'')		+ '</NATANF>'
		Set @strXml +=	'</E1EDL13>'
	End

	Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where intLoadStgId>@intMinHeader
End

Select * From @tblOutput ORDER BY intRowNo