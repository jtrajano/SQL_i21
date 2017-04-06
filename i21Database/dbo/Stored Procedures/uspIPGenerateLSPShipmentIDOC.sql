CREATE PROCEDURE [dbo].[uspIPGenerateLSPShipmentIDOC]
	@ysnUpdateFeedStatusOnRead bit=0
AS

Declare @intMinHeader				INT,
		@intMinDetail				INT,
		@intMinContainer			INT,
		@intLoadStgId				INT ,
		@intLoadId					INT,
		@intLoadDetailId			INT,
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
		@strIDOCHeader				NVARCHAR(MAX),
		@strCompCode				NVARCHAR(100),
		@strHeaderRowState			NVARCHAR(50),
		@strDeliveryItemNo			NVARCHAR(100),
		@strDeliverySubItemNo		NVARCHAR(100),
		@strItemNo					NVARCHAR(100),
		@strSubLocation				NVARCHAR(50),
		@strStorageLocation			NVARCHAR(50),
		@strContainerNo				NVARCHAR(50),
		@dblQuantity				NUMERIC(38,20),
		@strUOM						NVARCHAR(50),
		@strPONo					NVARCHAR(100),
		@strPOLineItemNo			NVARCHAR(100),
		@strShipItemRefNo			NVARCHAR(100),
		@strItemXml					NVARCHAR(MAX),
		@strLoadStgIds				NVARCHAR(MAX),
		@strContainerSizeCode		NVARCHAR(100),
		@intLoadContainerId			INT,
		@strContainerXml			NVARCHAR(MAX),
		@strContainerItemXml		NVARCHAR(MAX),
		@ysnBatchSplit				BIT,
		@strVendorAccountNo			NVARCHAR(50),
		@dblGrossWeight				NUMERIC(38,20),
		@dblNetWeight				NUMERIC(38,20),
		@strWeightUOM				NVARCHAR(50),
		@dtmETAPOL					DATETIME,
		@dtmETAPOD					DATETIME,
		@strAddressXml				NVARCHAR(MAX),
		@strHeaderSubLocation		NVARCHAR(50),
		@strHeaderUOM				NVARCHAR(50),
		@dblTotalGross				NUMERIC(38,20),
		@dblTotalNet				NUMERIC(38,20),
		@strLocation				NVARCHAR(50),
		@strItemDesc				NVARCHAR(250),
		@strCertificates			NVARCHAR(MAX),
		@intNoOfContainer			INT,
		@strPackingDesc				NVARCHAR(50),
		@dtmETSPOL					DATETIME,
		@strLSPPartnerNo			NVARCHAR(100),
		@strWarehouseVendorAccNo	NVARCHAR(100),
		@strMVessel					NVARCHAR(200),
		@strMVoyageNumber			NVARCHAR(200),
		@intPositionId				INT,
		@strPositionType			NVARCHAR(50),
		@str10Zeros					NVARCHAR(50)='0000000000'

Declare @tblDetail AS Table
(
	intRowNo INT IDENTITY(1,1),
	intLoadStgId INT,
	intLGLoadDetailStgId INT,
	intLoadId INT,
	intLoadDetailId INT,
	strDeliveryItemNo NVARCHAR(100),
	strDeliverySubItemNo NVARCHAR(100),
	strItemNo NVARCHAR(100),
	strItemDesc	NVARCHAR(250),
	strSubLocation NVARCHAR(50),
	strStorageLocation NVARCHAR(50),
	strContainerNo NVARCHAR(50),
	dblQuantity NUMERIC(38,20),
	strUOM NVARCHAR(50),
	strPONo NVARCHAR(100),
	strPOLineItemNo NVARCHAR(100),
	strShipItemRefNo NVARCHAR(100),
	strRowState NVARCHAR(50),
	strCommodityCode NVARCHAR(50),
	dblGrossWeight	NUMERIC(38,20),
	dblNetWeight	NUMERIC(38,20),
	strWeightUOM	NVARCHAR(50)
)

Declare @tblContainer AS Table
(
	intRowNo INT IDENTITY(1,1),
	intLoadContainerId	INT,
	strContainerNo NVARCHAR(100),
	strContainerSizeCode NVARCHAR(100),
	strExternalContainerId NVARCHAR(100),
	dblNetWt NUMERIC(38,20),
	strWeightUOM NVARCHAR(50)
)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strLoadStgIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX),
	strShipmentNo NVARCHAR(100)
)

--Select @strIDOCHeader=dbo.fnIPGetSAPIDOCHeader('LSP SHIPMENT')
Select @strCompCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL','COMP_CODE')

Select @intMinHeader=Min(intLoadStgId) From tblLGLoadLSPStg Where ISNULL(strFeedStatus,'')=''

Set @strXml=''

While(@intMinHeader is not null) --Loop Header
Begin
	Select 
		@intLoadStgId				=	intLoadStgId ,
		@intLoadId					=	intLoadId,
		@strTransactionType			=	strTransactionType,
		@strLoadNumber				=	strLoadNumber,
		@strContractBasis			=	strContractBasis ,--INCOTERMS1
		@strContractBasisDesc		=	strContractBasisDesc ,--INCOTERMS2
		@strBillOfLading			=	strBillOfLading , 
		@strShippingLine			=	strShippingLineAccountNo , 
		@strExternalDeliveryNumber	=	strExternalShipmentNumber, 
		@dtmScheduledDate			=   dtmScheduledDate,
		@strFeedStatus				=	strFeedStatus,
		@dtmETAPOD					=	dtmETAPOD,
		@dtmETAPOL					=	dtmETAPOL,
		@strVendorAccountNo			=	strVendorAccNo,
		@strHeaderSubLocation		=	strSubLocation,
		@strHeaderUOM				=	strWeightUOM,
		@dblTotalGross				=	dblTotalGross,
		@dblTotalNet				=	dblTotalNet,
		@strLocation				=	strCompanyLocation,
		@dtmETSPOL					=	dtmETSPOL,
		@strWarehouseVendorAccNo	=	strWarehouseVendorAccNo,
		@strMVessel					=	strMVessel,
		@strMVoyageNumber			=	strMVoyageNumber,
		@strHeaderRowState			=	strRowState,
		@strSubLocation				=	strSubLocation
	From tblLGLoadLSPStg Where intLoadStgId=@intMinHeader

	Set @intPositionId=NULL

	Select TOP 1 @strPackingDesc=ct.strPackingDescription,@intPositionId=ch.intPositionId From tblCTContractDetail ct Join tblLGLoadDetail ld on ct.intContractDetailId=ld.intPContractDetailId 
	Join tblCTContractHeader ch on ch.intContractHeaderId=ct.intContractHeaderId
	Where ld.intLoadId=@intLoadId

	Set @strPositionType=''
	Select TOP 1 @strPositionType=strPositionType From tblCTPosition Where intPositionId=@intPositionId

	Set @strLSPPartnerNo=''
	Select TOP 1 @strLSPPartnerNo=strPartnerNo From tblIPLSPPartner Where strWarehouseVendorAccNo=@strWarehouseVendorAccNo

	If ISNULL(@strLSPPartnerNo,'') =''
	Begin
		Update tblLGLoadLSPStg Set strFeedStatus='NA',strMessage='Invalid LSP Partner' Where intLoadStgId=@intLoadStgId
		GOTO NEXT_SHIPMENT
	End

	If ISNULL(@strPositionType,'') ='Spot'
	Begin
		Update tblLGLoadLSPStg Set strFeedStatus='NA',strMessage='It is a Spot Contract' Where intLoadStgId=@intLoadStgId
		GOTO NEXT_SHIPMENT
	End

	If ISNULL(@strExternalDeliveryNumber,'')=''
	Begin
		Select @strExternalDeliveryNumber=strExternalShipmentNumber From tblLGLoad Where intLoadId=@intLoadId
		Update tblLGLoadLSPStg Set strExternalShipmentNumber=@strExternalDeliveryNumber Where intLoadStgId=@intLoadStgId
		If ISNULL(@strExternalDeliveryNumber,'')=''
			GOTO NEXT_SHIPMENT
	End

	Select @strIDOCHeader=dbo.fnIPGetSAPIDOCHeader('LSP SHIPMENT')

	Set @strXml =  '<ZE1EDL43_PH>'
	Set @strXml += '<IDOC BEGIN="1">'
	
	--IDOC Header
	Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
	Set @strXml +=	@strIDOCHeader
	Set @strXml += '<RCVPRN>'	+ ISNULL(@strLSPPartnerNo,'')	+ '</RCVPRN>'
	Set @strXml += '<CREDAT>'	+ ISNULL(CONVERT(VARCHAR(10),GETDATE(),112),'')	+ '</CREDAT>'
	Set @strXml += '<CRETIM>'	+ REPLACE(ISNULL(CONVERT(NVARCHAR(8),GETDATE(),114),''),':','')	+ '</CRETIM>'
	Set @strXml +=	'</EDI_DC40>'
	
	If UPPER(@strHeaderRowState)='DELETE'
	Begin
		Set @strXml += '<E1EDT20 SEGMENT="1">'
		Set @strXml += '<TKNUM>'	+ ISNULL(@strLoadNumber,'')	+ '</TKNUM>'

		Set @strXml += '<E1EDL20 SEGMENT="1">'
		Set @strXml += '<VBELN>'	+ ISNULL(@strExternalDeliveryNumber,'')	+ '</VBELN>'

		Set @strXml += '<E1EDL18 SEGMENT="1">'
		Set @strXml += '<QUALF>' + 'DEL' + '</QUALF>'
		Set @strXml +=	'</E1EDL18>'

		GOTO END_TAG
	End

	--Header
	Set @strXml += '<E1EDT20 SEGMENT="1">'
	Set @strXml += '<TKNUM>'	+ ISNULL(@strLoadNumber,'')	+ '</TKNUM>'
	Set @strXml += '<SHTYP>'	+ 'Z001'			+ '</SHTYP>'
	Set @strXml += '<EXTI1>'	+ dbo.fnEscapeXML(ISNULL(@strMVoyageNumber,''))	+ '</EXTI1>'
	Set @strXml += '<EXTI2>'	+ dbo.fnEscapeXML(ISNULL(@strMVessel,''))	+ '</EXTI2>'
	Set @strXml += '<SDABW>'	+ ISNULL(@strPackingDesc,'')	+ '</SDABW>'

	Set @strXml += '<E1EDT18 SEGMENT="1">'
	Set @strXml += '<QUALF>'	+ 'ORI'	+ '</QUALF>'
	Set @strXml +=	'</E1EDT18>'

	Set @strAddressXml=NULL
	Select @strAddressXml=COALESCE(@strAddressXml, '') 
		+ '<E1ADRM4 SEGMENT="1">'
		+ '<PARTNER_Q>'		+ 'SP'															+ '</PARTNER_Q>'
		+ '<PARTNER_ID>'	+ ISNULL(strForwardingAgentAccNo,'')							+ '</PARTNER_ID>'
		+ '<LANGUAGE>'		+ 'EN'															+ '</LANGUAGE>'
		+ '<NAME1>'			+ dbo.fnEscapeXML(ISNULL(strForwardingAgent,''))				+ '</NAME1>'
		+ '<STREET1>'		+ dbo.fnEscapeXML(ISNULL(strForwardingAgentAddress,''))			+ '</STREET1>'
		+ '<POSTL_COD1>'	+ dbo.fnEscapeXML(ISNULL(strForwardingAgentPostalCode,''))		+ '</POSTL_COD1>'
		+ '<CITY1>'			+ dbo.fnEscapeXML(ISNULL(strForwardingAgentCity,''))			+ '</CITY1>'
		+ '<TELEPHONE1>'	+ dbo.fnEscapeXML(ISNULL(strForwardingAgentTelePhoneNo,''))		+ '</TELEPHONE1>'
		+ '<TELEFAX>'		+ dbo.fnEscapeXML(ISNULL(strForwardingAgentTeleFaxNo,''))		+ '</TELEFAX>'
		+ '<COUNTRY1>'		+ ISNULL(strForwardingAgentCountry,'')							+ '</COUNTRY1>'
		+ '</E1ADRM4>'

		+ '<E1ADRM4 SEGMENT="1">'
		+ '<PARTNER_Q>'		+ 'TF'														+ '</PARTNER_Q>'
		+ '<PARTNER_ID>'	+ ISNULL(strShippingLineAccountNo,'')						+ '</PARTNER_ID>'
		+ '<LANGUAGE>'		+ 'EN'														+ '</LANGUAGE>'
		+ '<NAME1>'			+ dbo.fnEscapeXML(ISNULL(strShippingLine,''))				+ '</NAME1>'
		+ '<STREET1>'		+ dbo.fnEscapeXML(ISNULL(strShippingLineAddress,''))		+ '</STREET1>'
		+ '<POSTL_COD1>'	+ dbo.fnEscapeXML(ISNULL(strShippingLinePostalCode,''))		+ '</POSTL_COD1>'
		+ '<CITY1>'			+ dbo.fnEscapeXML(ISNULL(strShippingLineCity,''))			+ '</CITY1>'
		+ '<TELEPHONE1>'	+ dbo.fnEscapeXML(ISNULL(strShippingLineTelePhoneNo,''))	+ '</TELEPHONE1>'
		+ '<TELEFAX>'		+ dbo.fnEscapeXML(ISNULL(strShippingLineTeleFaxNo,''))		+ '</TELEFAX>'
		+ '<COUNTRY1>'		+ ISNULL(strShippingLineCountry,'')							+ '</COUNTRY1>'
		+ '</E1ADRM4>'

		+ '<E1EDK33 SEGMENT="1">'

		+ '<E1EDT44 SEGMENT="1">'
		+ '<QUALI>'		+ '001'	+ '</QUALI>'
		+ '<E1ADRM6 SEGMENT="1">'
		+ '<LANGUAGE>'		+ 'EN'	+ '</LANGUAGE>'
		+ '<NAME1>'			+ dbo.fnEscapeXML(ISNULL(strOriginName,''))				+ '</NAME1>'
		+ '<STREET1>'		+ dbo.fnEscapeXML(ISNULL(strOriginAddress,''))			+ '</STREET1>'
		+ '<POSTL_COD1>'	+ dbo.fnEscapeXML(ISNULL(strOriginPostalCode,''))		+ '</POSTL_COD1>'
		+ '<CITY1>'			+ dbo.fnEscapeXML(ISNULL(strOriginCity,''))				+ '</CITY1>'
		+ '<TELEPHONE1>'	+ dbo.fnEscapeXML(ISNULL(strOriginTelePhoneNo,''))		+ '</TELEPHONE1>'
		+ '<TELEFAX>'		+ dbo.fnEscapeXML(ISNULL(strOriginTeleFaxNo,''))		+ '</TELEFAX>'
		+ '<COUNTRY1>'		+ ISNULL(strOriginCountry,'')							+ '</COUNTRY1>'
		+ '</E1ADRM6>'
		+ '</E1EDT44>'

		+ '<E1EDT44 SEGMENT="1">'
		+ '<QUALI>'		+ '002'	+ '</QUALI>'
		+ '<E1ADRM6 SEGMENT="1">'
		+ '<LANGUAGE>'		+ 'EN'	+ '</LANGUAGE>'
		+ '<NAME1>'			+ dbo.fnEscapeXML(ISNULL(strDestinationName,''))			+ '</NAME1>'
		+ '<STREET1>'		+ dbo.fnEscapeXML(ISNULL(strDestinationAddress,''))			+ '</STREET1>'
		+ '<POSTL_COD1>'	+ dbo.fnEscapeXML(ISNULL(strDestinationPostalCode,''))		+ '</POSTL_COD1>'
		+ '<CITY1>'			+ dbo.fnEscapeXML(ISNULL(strDestinationCity,''))			+ '</CITY1>'
		+ '<TELEPHONE1>'	+ dbo.fnEscapeXML(ISNULL(strDestinationTelePhoneNo,''))		+ '</TELEPHONE1>'
		+ '<TELEFAX>'		+ dbo.fnEscapeXML(ISNULL(strDestinationTeleFaxNo,''))		+ '</TELEFAX>'
		+ '<COUNTRY1>'		+ ISNULL(strDestinationCountry,'')							+ '</COUNTRY1>'
		+ '</E1ADRM6>'
		+ '</E1EDT44>'

		+ '</E1EDK33>'
	From tblLGLoadLSPStg Where intLoadStgId=@intMinHeader

	Set @strXml += ISNULL(@strAddressXml,'')

	Set @strXml += '<E1EDL20 SEGMENT="1">'
	Set @strXml += '<VBELN>'	+ ISNULL(@strExternalDeliveryNumber,'')						+ '</VBELN>'
	Set @strXml += '<VSTEL>'	+ ISNULL(@strHeaderSubLocation,'')							+ '</VSTEL>'
	Set @strXml += '<INCO1>'	+ dbo.fnEscapeXML(ISNULL(@strContractBasis,''))				+ '</INCO1>'
	Set @strXml += '<INCO2>'	+ dbo.fnEscapeXML(ISNULL(@strContractBasisDesc,''))			+ '</INCO2>'
	Set @strXml += '<BTGEW>'	+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblTotalGross)),'')	+ '</BTGEW>'
	Set @strXml += '<NTGEW>'	+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblTotalNet)),'')		+ '</NTGEW>'
	Set @strXml += '<GEWEI>'	+ ISNULL(dbo.fnIPConverti21UOMToSAP(@strHeaderUOM),'')		+ '</GEWEI>'
	Set @strXml += '<BOLNR>'	+ ISNULL(@strBillOfLading,'')								+ '</BOLNR>'
	Set @strXml += '<TRAID>'	+ dbo.fnEscapeXML(ISNULL(@strShippingLine,''))				+ '</TRAID>'
	Set @strXml += '<LIFEX>'	+ ISNULL(@strLoadNumber,'')									+ '</LIFEX>'
	Set @strXml += '<PODAT>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmETAPOD,112),'')			+ '</PODAT>'

	Set @strXml += '<E1EDL22 SEGMENT="1">'
	Set @strXml += '<VSTEL_BEZ>'	+ ISNULL(@strLocation,'')								+ '</VSTEL_BEZ>'
	Set @strXml += '<INCO1_BEZ>'	+ dbo.fnEscapeXML(ISNULL(@strContractBasisDesc,''))		+ '</INCO1_BEZ>'
	Set @strXml +=	'</E1EDL22>'

	Set @strXml += '<E1EDT13 SEGMENT="1">'
	Set @strXml += '<QUALF>'	+ '007'			+ '</QUALF>'
	Set @strXml += '<NTANF>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmETAPOL,112),'')		+ '</NTANF>'
	Set @strXml += '<NTANZ>'	+ '000000'		+ '</NTANZ>'
	Set @strXml += '<NTEND>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmETAPOD,112),'')		+ '</NTEND>'
	Set @strXml += '<NTENZ>'	+ '000000'		+ '</NTENZ>'
	Set @strXml += '<ISDD>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmETSPOL,112),'')		+ '</ISDD>'
	Set @strXml +=	'</E1EDT13>'

	Delete From @tblDetail

	Insert Into @tblDetail(intLoadStgId,intLGLoadDetailStgId,intLoadId,intLoadDetailId,strDeliveryItemNo,strDeliverySubItemNo,strItemNo,strItemDesc,
		strSubLocation,strStorageLocation,strContainerNo,dblQuantity,strUOM,strPONo,strPOLineItemNo,strShipItemRefNo,strRowState,strCommodityCode,
		dblGrossWeight,dblNetWeight,strWeightUOM)
	Select sd.intLoadStgId,sd.intLGLoadDetailStgId,sd.intLoadId,sd.intLoadDetailId,
		(10 * ROW_NUMBER() OVER(ORDER BY intLGLoadDetailStgId ASC)) strDeliveryItemNo,
		'',sd.strItemNo,sd.strItemDesc,sd.strSubLocationName,sd.strStorageLocationName,
		(Select TOP 1 ISNULL(c.strContainerNumber,'') 
			From tblLGLoadContainer c Join tblLGLoadDetailContainerLink cl on c.intLoadContainerId=cl.intLoadContainerId Where cl.intLoadDetailId=sd.intLoadDetailId),
		sd.dblDeliveredQty,sd.strUnitOfMeasure,sd.strExternalPONumber,sd.strExternalPOItemNumber,sd.intSIDetailId,sd.strRowState,sd.strCommodityCode,
		sd.dblGrossWt,sd.dblNetWt,sd.strWeightUOM
		From tblLGLoadDetailLSPStg sd
		Where intLoadStgId=@intMinHeader

	Select TOP 1 @strCommodityCode=strCommodityCode From @tblDetail

	--Coffee Multiple Container/Batch Split
	Set @ysnBatchSplit=0
	If UPPER(@strCommodityCode)='COFFEE'
	Begin
		If Exists (Select 1 From tblLGLoadDetailContainerLink lc Join tblLGLoadDetail ld on lc.intLoadDetailId=ld.intLoadDetailId
		Where ld.intLoadId=@intLoadId Group By ld.intItemId Having COUNT(ld.intItemId)>1)
		Begin
			Set @ysnBatchSplit=1
		End
	End

	Set @strItemXml=''

	Select @intMinDetail=Min(intRowNo) From @tblDetail

	While(@intMinDetail is not null) --Loop Detail
	Begin
		Select 
			@intLoadDetailId			=	intLoadDetailId,
			@strDeliveryItemNo			=	strDeliveryItemNo,
			@strDeliverySubItemNo		=	strDeliverySubItemNo,
			@strItemNo					=	strItemNo,
			@strItemDesc				=	strItemDesc,
			--@strSubLocation				=	strSubLocation,
			@strStorageLocation			=	strStorageLocation,
			@strContainerNo				=	strContainerNo,
			@dblQuantity				=	dblQuantity,
			@strUOM						=	dbo.fnIPConverti21UOMToSAP(strUOM),
			@strPONo					=	strPONo,
			@strPOLineItemNo			=	strPOLineItemNo,
			@strShipItemRefNo			=	strShipItemRefNo,
			@dblGrossWeight				=	dblGrossWeight,
			@dblNetWeight				=	dblNetWeight,
			@strWeightUOM				=	dbo.fnIPConverti21UOMToSAP(strWeightUOM),
			@strRowState				=	strRowState
		From @tblDetail Where intRowNo=@intMinDetail

			Set @strItemXml += '<E1EDL24 SEGMENT="1">'
			Set @strItemXml += '<POSNR>'  +  ISNULL(@strDeliveryItemNo,'') + '</POSNR>' 
			Set @strItemXml += '<MATNR>'  +  ISNULL(@str10Zeros + @strItemNo,'') + '</MATNR>' 
			Set @strItemXml += '<ARKTX>'  +  ISNULL(@strItemDesc,'') + '</ARKTX>' 
			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
			Else
				Set @strItemXml += '<WERKS>'  +  '' + '</WERKS>' 
			Set @strItemXml += '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
			Set @strItemXml += '<CHARG>'  +  ISNULL(@strContainerNo,'') + '</CHARG>' 
			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblNetWeight)),'') + '</LFIMG>'
			Else
				Set @strItemXml += '<LFIMG>'  +  '' + '</LFIMG>'
			Set @strItemXml += '<VRKME>'  +  ISNULL(@strWeightUOM,'') + '</VRKME>' 

			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<LGMNG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblNetWeight)),'') + '</LGMNG>' 
			Else
				Set @strItemXml += '<LGMNG>'  +  '' + '</LGMNG>' 

			Set @strItemXml += '<MEINS>'  +  ISNULL(@strWeightUOM,'') + '</MEINS>' 
			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<NTGEW>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblNetWeight)),'') + '</NTGEW>' 
			Else
				Set @strItemXml += '<NTGEW>'  +  '' + '</NTGEW>' 

			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<BRGEW>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblNetWeight)),'') + '</BRGEW>' 
			Else
				Set @strItemXml += '<BRGEW>'  +  '' + '</BRGEW>' 

			Set @strItemXml += '<GEWEI>'  +  ISNULL(@strWeightUOM,'') + '</GEWEI>' 

			If ISNULL(@ysnBatchSplit,0)=1
				Set @strItemXml += '<HIPOS>'  +  ISNULL(@strDeliveryItemNo,'') + '</HIPOS>'

			Set @strItemXml += '<E1EDL19 SEGMENT="1">'
			Set @strItemXml += '<QUALF>'  +  'QUA' + '</QUALF>' 
			Set @strItemXml += '</E1EDL19>'

			Set @strItemXml += '<E1EDL43 SEGMENT="1">'
			Set @strItemXml += '<QUALF>'  +  'V' + '</QUALF>' 
			Set @strItemXml += '<BELNR>'  +  ISNULL(@strPONo,'') + '</BELNR>' 
			Set @strItemXml += '<POSNR>'  +  ISNULL(@strPOLineItemNo,'') + '</POSNR>' 

			--Certificate
			Set @strCertificates=NULL
			Select @strCertificates=COALESCE(@strCertificates, '') 
				+ '<ZE1EDL43_PH SEGMENT="1">'
				+ '<ZZCOFFEE>'  +  dbo.fnEscapeXML(ISNULL(strCertificationCode,'')) + '</ZZCOFFEE>' 
				+ '</ZE1EDL43_PH>'
			From tblCTContractCertification cc Join tblICCertification c on cc.intCertificationId=c.intCertificationId
			Where cc.intContractDetailId=(Select intPContractDetailId From tblLGLoadDetail Where intLoadDetailId=@intLoadDetailId)

			Set @strCertificates=LTRIM(RTRIM(ISNULL(@strCertificates,'')))

			If @strCertificates<>''
				Set @strItemXml += ISNULL(@strCertificates,'')
			Else
			Begin --Set 0 (For No Certificate)
				Set @strItemXml += '<ZE1EDL43_PH SEGMENT="1">'
				Set @strItemXml += '<ZZCOFFEE>'  + CASE WHEN UPPER(@strCommodityCode)='COFFEE' THEN '0' ELSE 'N' END + '</ZZCOFFEE>' 
				Set @strItemXml += '</ZE1EDL43_PH>'
			End

			Set @strItemXml += '</E1EDL43>'

			Set @strItemXml += '</E1EDL24>'

			--Batch Split for Coffee
			If UPPER(@strCommodityCode)='COFFEE' AND ISNULL(@ysnBatchSplit,0)=1
			Begin
				If (Select COUNT(1) From tblLGLoadDetailContainerLink lc Join tblLGLoadDetail ld on lc.intLoadDetailId=ld.intLoadDetailId
					Where ld.intLoadId=@intLoadId AND lc.intLoadDetailId=@intLoadDetailId)>1
				Begin
					Delete From @tblContainer

					Insert Into @tblContainer(strExternalContainerId,strContainerNo,dblNetWt,strWeightUOM)
					Select lc.strExternalContainerId,lc.strContainerNo,lc.dblNetWt,lc.strWeightUOM
					From tblLGLoadContainerLSPStg lc
					Join tblLGLoadDetailContainerLink cl on lc.intLoadContainerId=cl.intLoadContainerId
					Join tblLGLoadDetail ld on ld.intLoadDetailId=cl.intLoadDetailId
					Where lc.intLoadStgId=@intLoadStgId AND ld.intLoadId=@intLoadId AND ld.intLoadDetailId=@intLoadDetailId 
					Order By lc.strExternalContainerId

					Set @strContainerXml = ''
					Select @strContainerXml=@strContainerXml
							+ '<E1EDL24 SEGMENT="1">'
							+ '<POSNR>' +   ISNULL(lc.strExternalContainerId,'') + '</POSNR>' 
							+ '<MATNR>'  +  ISNULL(@str10Zeros + @strItemNo,'') + '</MATNR>' 
							+ '<ARKTX>'  +  ISNULL(@strItemDesc,'') + '</ARKTX>' 
							+ '<WERKS>'  +  '' + '</WERKS>' 
							+ '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
							+ '<CHARG>'  +  dbo.fnEscapeXML(ISNULL(lc.strContainerNo,'')) + '</CHARG>' 
							+ '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),lc.dblNetWt)),'') + '</LFIMG>' 
							+ '<VRKME>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(lc.strWeightUOM,'')) + '</VRKME>' 
							+ '<LGMNG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),lc.dblNetWt)),'') + '</LGMNG>' 
							+ '<MEINS>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(lc.strWeightUOM,'')) + '</MEINS>' 
							+ '<NTGEW>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),lc.dblNetWt)),'') + '</NTGEW>' 
							+ '<BRGEW>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),lc.dblNetWt)),'') + '</BRGEW>' 
							+ '<GEWEI>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(lc.strWeightUOM,'')) + '</GEWEI>' 
							+ '<HIPOS>' + ISNULL(@strDeliveryItemNo,'') + '</HIPOS>' 

							+ '<E1EDL19 SEGMENT="1">'
							+ '<QUALF>'  +  'QUA' + '</QUALF>' 
							+ '</E1EDL19>'

							+ '<E1EDL19 SEGMENT="1">'
							+ '<QUALF>'  +  'BAS' + '</QUALF>' 
							+ '</E1EDL19>'

							+ '</E1EDL24>'
					From @tblContainer lc

					Set @strItemXml += ISNULL(@strContainerXml,'')
				End
			End

		Select @intMinDetail=Min(intRowNo) From @tblDetail Where intRowNo>@intMinDetail
	End --Loop Detail End

	--For Tea
	If UPPER(@strCommodityCode)='TEA'
	Begin
			Set @strContainerXml=''
			Set @intNoOfContainer=1

			Delete From @tblContainer

			Insert Into @tblContainer(intLoadContainerId,strContainerNo,strContainerSizeCode)
			Select DISTINCT c.intLoadContainerId,c.strContainerNo,c.strContainerSizeCode
			From tblLGLoadContainerLSPStg c Where c.intLoadStgId=@intMinHeader

			Select @intMinContainer=Min(intRowNo) From @tblContainer

			While(@intMinContainer is not null) --Loop Container
			Begin
				Select @strContainerNo=strContainerNo,@strContainerSizeCode=strContainerSizeCode,@intLoadContainerId=intLoadContainerId
				From @tblContainer Where intRowNo=@intMinContainer

					Set @strContainerXml += '<E1EDL37 SEGMENT="1">'
					Set @strContainerXml += '<EXIDV>'  +  ISNULL(@strContainerNo,'') + '</EXIDV>' 
					Set @strContainerXml += '<VHILM>'  +  ISNULL(@strContainerSizeCode,'') + '</VHILM>' 
					Set @strContainerXml += '<VHART>'  +  '0002' + '</VHART>' 
					Set @strContainerXml += '<VHILM_KU>'  +  ISNULL(@strContainerSizeCode,'') + '</VHILM_KU>' 

					Set @strContainerItemXml=NULL
					Select @strContainerItemXml=COALESCE(@strContainerItemXml, '') 
					+ '<E1EDL44 SEGMENT="1">'
					+ '<POSNR>'  +  CASE WHEN ISNULL(cl.strExternalContainerId,'')='' THEN  ISNULL(CONVERT(VARCHAR,(10 * @intNoOfContainer * ROW_NUMBER() OVER(ORDER BY cl.intLoadDetailContainerLinkId ASC))),'') ELSE ISNULL(cl.strExternalContainerId,'') END + '</POSNR>'
					+ '<VEMNG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),cl.dblQuantity)),'') + '</VEMNG>'
					+ '<VEMEH>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(ld.strUnitOfMeasure,'')) + '</VEMEH>'
					+ '</E1EDL44>'			 
					From tblLGLoadDetailContainerLink cl Join tblLGLoadDetailLSPStg ld on cl.intLoadDetailId=ld.intLoadDetailId
					Where intLoadContainerId=@intLoadContainerId AND ld.intLoadStgId=@intLoadStgId

					Set @strContainerXml += ISNULL(@strContainerItemXml,'')
					Set @strContainerXml += '</E1EDL37>'

					--Get the total items so that POSNR value will sequence to next number for the new Container
					Select @intNoOfContainer= COUNT(cl.intLoadDetailContainerLinkId) + 1
					From tblLGLoadDetailContainerLink cl Join tblLGLoadDetailLSPStg ld on cl.intLoadDetailId=ld.intLoadDetailId
					Where intLoadContainerId=@intLoadContainerId

				Select @intMinContainer=Min(intRowNo) From @tblContainer Where intRowNo>@intMinContainer
			End --Loop Container End

			Set @strItemXml += ISNULL(@strContainerXml,'')
	End

	--Final Xml
	Set @strXml += ISNULL(@strItemXml,'')

	END_TAG:
	Set @strXml += '</E1EDL20>'
	Set @strXml += '</E1EDT20>'
	Set @strXml += '</IDOC>'
	Set @strXml +=  '</ZE1EDL43_PH>'

	If @ysnUpdateFeedStatusOnRead=1
		Update tblLGLoadLSPStg Set strFeedStatus='Awt Ack' Where intLoadStgId = @intMinHeader

	INSERT INTO @tblOutput(strLoadStgIds,strRowState,strXml,strShipmentNo)
	VALUES(@intMinHeader,'CREATE',@strXml,ISNULL(@strLoadNumber,''))

	NEXT_SHIPMENT:
	Select @intMinHeader=Min(intLoadStgId) From tblLGLoadLSPStg Where intLoadStgId>@intMinHeader AND ISNULL(strFeedStatus,'')=''
End --Loop Header End
Select * From @tblOutput ORDER BY intRowNo