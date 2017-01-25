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
		@strLoadStgIds				NVARCHAR(MAX)

Declare @tblDetail AS Table
(
	intLoadStgId INT,
	intLGLoadDetailStgId INT,
	intLoadId INT,
	intLoadDetailId INT,
	strDeliveryItemNo NVARCHAR(100),
	strDeliverySubItemNo NVARCHAR(100),
	strItemNo NVARCHAR(100),
	strSubLocation NVARCHAR(50),
	strStorageLocation NVARCHAR(50),
	strContainerNo NVARCHAR(50),
	dblQuantity NUMERIC(38,20),
	strUOM NVARCHAR(50),
	strPONo NVARCHAR(100),
	strPOLineItemNo NVARCHAR(100),
	strShipItemRefNo NVARCHAR(100),
	strRowState NVARCHAR(50),
	strCommodityCode NVARCHAR(50)
)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strLoadStgIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
)

Select @strInstructionIDOCHeader=dbo.fnIPGetSAPIDOCHeader('SHIPMENT')
Select @strAdviceIDOCHeader=dbo.fnIPGetSAPIDOCHeader('SHIPMENT')
Select @strCompCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL','COMP_CODE')

--Shipping Instruction

Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where ISNULL(strFeedStatus,'')='' AND strTransactionType='Shipping Instructions'

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
		@strShippingLine			=	strShippingLine , 
		@strExternalDeliveryNumber	=	strExternalDeliveryNumber , 
		@dtmScheduledDate			=   dtmScheduledDate,
		@strHeaderRowState			=	strRowState ,
		@strFeedStatus				=	strFeedStatus
	From tblLGLoadStg Where intLoadStgId=@intMinHeader

	Set @strXml =  '<DELVRY07>'
	Set @strXml += '<IDOC BEGIN="1">'
	
	--IDOC Header
	Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
	Set @strXml +=	@strInstructionIDOCHeader
	Set @strXml +=	'</EDI_DC40>'
		
	--Header
	Set @strXml += '<E1ELD20 SEGMENT="1">'
	Set @strXml += '<INCO1>'	+ ISNULL(@strContractBasis,'')			+ '</INCO1>'
	Set @strXml += '<INCO2>'	+ ISNULL(@strContractBasisDesc,'')		+ '</INCO2>'
	Set @strXml += '<BOLNR>'	+ ISNULL(@strBillOfLading,'')			+ '</BOLNR>'
	Set @strXml += '<TRAID>'	+ ISNULL(@strShippingLine,'')			+ '</TRAID>'
	Set @strXml += '<VBELN>'	+ ISNULL(@strExternalDeliveryNumber,'')	+ '</VBELN>'
	Set @strXml += '<LIFEX>'	+ ISNULL(@strLoadNumber,'')				+ '</LIFEX>'

	Set @strXml += '<E1EDL18 SEGMENT="1">'
	Set @strXml += '<QUALF>'	
					+ CASE WHEN UPPER(@strHeaderRowState)='ADDED' THEN 'ORI' ELSE 'CHG' END			
					+ '</QUALF>'
	Set @strXml +=	'</E1EDL18>'

	Set @strXml += '<E1EDL13 SEGMENT="1">'
	Set @strXml += '<QUALF>'	+ '015'			+ '</QUALF>'
	Set @strXml += '<NATANF>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmScheduledDate,112),'')		+ '</NATANF>'
	Set @strXml +=	'</E1EDL13>'

	Delete From @tblDetail

	Insert Into @tblDetail(intLoadStgId,intLGLoadDetailStgId,intLoadId,intLoadDetailId,strDeliveryItemNo,strDeliverySubItemNo,strItemNo,
		strSubLocation,strStorageLocation,strContainerNo,dblQuantity,strUOM,strPONo,strPOLineItemNo,strShipItemRefNo,strRowState,strCommodityCode)
	Select sd.intLoadStgId,sd.intLGLoadDetailStgId,sd.intLoadId,sd.intLoadDetailId,
		9 + (ROW_NUMBER() OVER(ORDER BY intLGLoadDetailStgId ASC)) strDeliveryItemNo,'',sd.strItemNo,
		sd.strSubLocationName,sd.strStorageLocationName,cd.strERPBatchNumber,sd.dblDeliveredQty,sd.strUnitOfMeasure,cd.strERPPONumber,cd.strERPItemNumber,sd.intLoadDetailId,sd.strRowState,'' strCommodityCode
		From tblLGLoadDetailStg sd Join tblLGLoadDetail ld on sd.intLoadDetailId=ld.intLoadDetailId
		Join tblCTContractDetail cd on ld.intPContractDetailId=cd.intContractDetailId
		Where intLoadStgId=@intMinHeader

	Set @strItemXml=''

	Select @intMinDetail=Min(intLGLoadDetailStgId) From @tblDetail

	While(@intMinDetail is not null) --Loop Detail
	Begin
		Select 
			@strDeliveryItemNo			=	strDeliveryItemNo,
			@strDeliverySubItemNo		=	strDeliverySubItemNo,
			@strItemNo					=	strItemNo,
			@strSubLocation				=	strSubLocation,
			@strStorageLocation			=	strStorageLocation,
			@strContainerNo				=	strContainerNo,
			@dblQuantity				=	dblQuantity,
			@strUOM						=	dbo.fnIPConverti21UOMToSAP(strUOM),
			@strPONo					=	strPONo,
			@strPOLineItemNo			=	strPOLineItemNo,
			@strShipItemRefNo			=	strShipItemRefNo
		From @tblDetail Where intLGLoadDetailStgId=@intMinDetail

			Set @strItemXml += '<E1EDL24 SEGMENT="1">'
			Set @strItemXml += '<POSNR>'  +  ISNULL(@strDeliveryItemNo,'') + '</POSNR>' 
			Set @strItemXml += '<MATNR>'  +  ISNULL(@strItemNo,'') + '</MATNR>' 
			Set @strItemXml += '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
			Set @strItemXml += '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
			Set @strItemXml += '<CHARG>'  +  ISNULL(@strContainerNo,'') + '</CHARG>' 
			Set @strItemXml += '<LFIMG>'  +  ISNULL(CONVERT(VARCHAR,@dblQuantity),'') + '</LFIMG>' 
			Set @strItemXml += '<VRKME>'  +  ISNULL(@strUOM,'') + '</VRKME>' 

			Set @strItemXml += '<E1EDL43 SEGMENT="1">'
			Set @strItemXml += '<QUALF>'  +  'C' + '</QUALF>' 
			Set @strItemXml += '</E1EDL43>'

			Set @strItemXml += '<E1EDL41 SEGMENT="1">'
			Set @strItemXml += '<QUALI>'  +  '001' + '</QUALI>' 
			Set @strItemXml += '<BSTNR>'  +  ISNULL(@strPONo,'') + '</BSTNR>' 
			Set @strItemXml += '<POSEX>'  +  ISNULL(@strPOLineItemNo,'') + '</POSEX>' 
			Set @strItemXml += '<IHREZ>'  +  ISNULL(@strShipItemRefNo,'') + '</IHREZ>' 
			Set @strItemXml += '</E1EDL41>'

			If UPPER(@strRowState)='MODIFIED' AND @dblQuantity IS NOT NULL
			Begin
				Set @strItemXml += '<E1EDL19 SEGMENT="1">'
				Set @strItemXml += '<QUALF>'  +  'QUA' + '<QUALF>' 
				Set @strItemXml += '</E1EDL19>'
			End

			If UPPER(@strRowState)='DELETE'
			Begin
				Set @strItemXml += '<E1EDL19 SEGMENT="1">'
				Set @strItemXml += '<QUALF>'  +  'DEL' + '<QUALF>' 
				Set @strItemXml += '</E1EDL19>'
			End

			Set @strItemXml += '</E1EDL24>'

		Select @intMinDetail=Min(intLGLoadDetailStgId) From @tblDetail Where intLGLoadDetailStgId>@intMinDetail
	End --Loop Detail End

	--Final Xml
	Set @strXml += @strItemXml

	Set @strXml += '</E1ELD20>'
	Set @strXml += '</IDOC>'
	Set @strXml +=  '</DELVRY07>'

	Set @strLoadStgIds=NULL
	Select @strLoadStgIds=COALESCE(CONVERT(VARCHAR,@strLoadStgIds) + ',', '') + intLoadStgId From @tblDetail

	INSERT INTO @tblOutput(strLoadStgIds,strRowState,strXml)
	VALUES(@strLoadStgIds,'CREATE',@strXml)

	Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where intLoadStgId>@intMinHeader AND ISNULL(strFeedStatus,'')='' AND strTransactionType='Shipping Instructions'
End --Loop Header End


--Shipping Advice

Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where ISNULL(strFeedStatus,'')='' AND strTransactionType='Shipment'

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
		@strShippingLine			=	strShippingLine , 
		@strExternalDeliveryNumber	=	strExternalDeliveryNumber , 
		@dtmScheduledDate			=   dtmScheduledDate,
		@strHeaderRowState			=	strRowState ,
		@strFeedStatus				=	strFeedStatus
	From tblLGLoadStg Where intLoadStgId=@intMinHeader

	Set @strXml =  '<DELVRY07>'
	Set @strXml += '<IDOC BEGIN="1">'
	
	--IDOC Header
	Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
	Set @strXml +=	@strAdviceIDOCHeader
	Set @strXml +=	'</EDI_DC40>'
		
	--Header
	Set @strXml += '<E1ELD20 SEGMENT="1">'
	Set @strXml += '<INCO1>'	+ ISNULL(@strContractBasis,'')			+ '</INCO1>'
	Set @strXml += '<INCO2>'	+ ISNULL(@strContractBasisDesc,'')		+ '</INCO2>'
	Set @strXml += '<BOLNR>'	+ ISNULL(@strBillOfLading,'')			+ '</BOLNR>'
	Set @strXml += '<TRAID>'	+ ISNULL(@strShippingLine,'')			+ '</TRAID>'
	Set @strXml += '<VBELN>'	+ ISNULL(@strExternalDeliveryNumber,'')	+ '</VBELN>'
	Set @strXml += '<LIFEX>'	+ ISNULL(@strLoadNumber,'')				+ '</LIFEX>'

	Set @strXml += '<E1EDL18 SEGMENT="1">'
	Set @strXml += '<QUALF>' + 'CHG' + '</QUALF>'
	Set @strXml +=	'</E1EDL18>'

	Set @strXml += '<E1EDL13 SEGMENT="1">'
	Set @strXml += '<QUALF>'	+ '007'			+ '</QUALF>'
	Set @strXml += '<NATANF>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmScheduledDate,112),'')		+ '</NATANF>'
	Set @strXml +=	'</E1EDL13>'

	Delete From @tblDetail

	Insert Into @tblDetail(intLoadStgId,intLGLoadDetailStgId,intLoadId,intLoadDetailId,strDeliveryItemNo,strDeliverySubItemNo,strItemNo,
		strSubLocation,strStorageLocation,strContainerNo,dblQuantity,strUOM,strPONo,strPOLineItemNo,strShipItemRefNo,strRowState,strCommodityCode)
	Select sd.intLoadStgId,sd.intLGLoadDetailStgId,sd.intLoadId,sd.intLoadDetailId,
		9 + (ROW_NUMBER() OVER(ORDER BY intLGLoadDetailStgId ASC)) strDeliveryItemNo,'',sd.strItemNo,
		sd.strSubLocationName,sd.strStorageLocationName,cd.strERPBatchNumber,sd.dblDeliveredQty,sd.strUnitOfMeasure,cd.strERPPONumber,cd.strERPItemNumber,sd.intLoadDetailId,sd.strRowState,c.strCommodityCode
		From tblLGLoadDetailStg sd Join tblLGLoadDetail ld on sd.intLoadDetailId=ld.intLoadDetailId
		Join tblCTContractDetail cd on ld.intPContractDetailId=cd.intContractDetailId
		Join tblICItem i on ld.intItemId=i.intItemId
		Join tblICCommodity c on i.intCommodityId=c.intCommodityId
		Where intLoadStgId=@intMinHeader

	Select TOP 1 @strCommodityCode=strCommodityCode From @tblDetail

	Set @strItemXml=''

	Select @intMinDetail=Min(intLGLoadDetailStgId) From @tblDetail

	While(@intMinDetail is not null) --Loop Detail
	Begin
		Select 
			@strDeliveryItemNo			=	strDeliveryItemNo,
			@strDeliverySubItemNo		=	strDeliverySubItemNo,
			@strItemNo					=	strItemNo,
			@strSubLocation				=	strSubLocation,
			@strStorageLocation			=	strStorageLocation,
			@strContainerNo				=	strContainerNo,
			@dblQuantity				=	dblQuantity,
			@strUOM						=	dbo.fnIPConverti21UOMToSAP(strUOM),
			@strPONo					=	strPONo,
			@strPOLineItemNo			=	strPOLineItemNo,
			@strShipItemRefNo			=	strShipItemRefNo
		From @tblDetail Where intLGLoadDetailStgId=@intMinDetail

			Set @strItemXml += '<E1EDL24 SEGMENT="1">'
			Set @strItemXml += '<POSNR>'  +  ISNULL(@strDeliveryItemNo,'') + '</POSNR>' 
			Set @strItemXml += '<MATNR>'  +  ISNULL(@strItemNo,'') + '</MATNR>' 
			Set @strItemXml += '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
			Set @strItemXml += '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
			Set @strItemXml += '<CHARG>'  +  ISNULL(@strContainerNo,'') + '</CHARG>' 
			Set @strItemXml += '<LFIMG>'  +  ISNULL(CONVERT(VARCHAR,@dblQuantity),'') + '</LFIMG>' 
			Set @strItemXml += '<VRKME>'  +  ISNULL(@strUOM,'') + '</VRKME>' 

			Set @strItemXml += '<E1EDL43 SEGMENT="1">'
			Set @strItemXml += '<QUALF>'  +  'C' + '</QUALF>' 
			Set @strItemXml += '</E1EDL43>'

			Set @strItemXml += '<E1EDL41 SEGMENT="1">'
			Set @strItemXml += '<QUALI>'  +  '001' + '</QUALI>' 
			Set @strItemXml += '<BSTNR>'  +  ISNULL(@strPONo,'') + '</BSTNR>' 
			Set @strItemXml += '<POSEX>'  +  ISNULL(@strPOLineItemNo,'') + '</POSEX>' 
			Set @strItemXml += '<IHREZ>'  +  ISNULL(@strShipItemRefNo,'') + '</IHREZ>' 
			Set @strItemXml += '</E1EDL41>'

			If UPPER(@strRowState)='MODIFIED' AND @dblQuantity IS NOT NULL
			Begin
				Set @strItemXml += '<E1EDL19 SEGMENT="1">'
				Set @strItemXml += '<QUALF>'  +  'QUA' + '<QUALF>' 
				Set @strItemXml += '</E1EDL19>'
			End

			If UPPER(@strRowState)='DELETE'
			Begin
				Set @strItemXml += '<E1EDL19 SEGMENT="1">'
				Set @strItemXml += '<QUALF>'  +  'DEL' + '<QUALF>' 
				Set @strItemXml += '</E1EDL19>'
			End

			Set @strItemXml += '</E1EDL24>'

		Select @intMinDetail=Min(intLGLoadDetailStgId) From @tblDetail Where intLGLoadDetailStgId>@intMinDetail
	End --Loop Detail End

	--Final Xml
	Set @strXml += @strItemXml

	Set @strXml += '</E1ELD20>'
	Set @strXml += '</IDOC>'
	Set @strXml +=  '</DELVRY07>'

	Set @strLoadStgIds=NULL
	Select @strLoadStgIds=COALESCE(CONVERT(VARCHAR,@strLoadStgIds) + ',', '') + intLoadStgId From @tblDetail

	INSERT INTO @tblOutput(strLoadStgIds,strRowState,strXml)
	VALUES(@strLoadStgIds,'CREATE',@strXml)

	Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where intLoadStgId>@intMinHeader AND ISNULL(strFeedStatus,'')='' AND strTransactionType='Shipment'
End --Loop Header End
Select * From @tblOutput ORDER BY intRowNo