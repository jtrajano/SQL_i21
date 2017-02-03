CREATE PROCEDURE [dbo].[uspIPGenerateSAPShipmentIDOC]
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
		@strCreateIDOCHeader		NVARCHAR(MAX),
		@strUpdateIDOCHeader		NVARCHAR(MAX),
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
		@dtmETAPOD					DATETIME

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
	intLoadContainerStgId INT,
	intLoadContainerId	INT,
	strContainerNo NVARCHAR(100),
	strContainerSizeCode NVARCHAR(100)
)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strLoadStgIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
)

Select @strCreateIDOCHeader=dbo.fnIPGetSAPIDOCHeader('SHIPMENT CREATE')
Select @strUpdateIDOCHeader=dbo.fnIPGetSAPIDOCHeader('SHIPMENT UPDATE')
Select @strCompCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL','COMP_CODE')

Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where ISNULL(strFeedStatus,'')=''

Set @strXml=''

While(@intMinHeader is not null) --Loop Header
Begin
	Select 
		@intLoadStgId				=	intLoadStgId ,
		@intLoadId					=	intLoadId,
		@strTransactionType			=	strTransactionType,
		@strLoadNumber				=	strShippingInstructionNumber,
		@strContractBasis			=	strContractBasis ,--INCOTERMS1
		@strContractBasisDesc		=	strContractBasisDesc ,--INCOTERMS2
		@strBillOfLading			=	strBillOfLading , 
		@strShippingLine			=	strShippingLineAccountNo , 
		@strExternalDeliveryNumber	=	strExternalShipmentNumber, 
		@dtmScheduledDate			=   dtmScheduledDate,
		@strFeedStatus				=	strFeedStatus,
		@dtmETAPOD					=	dtmETAPOD
	From tblLGLoadStg Where intLoadStgId=@intMinHeader

	Select TOP 1 @strVendorAccountNo=v.strVendorAccountNum 
	From tblLGLoadDetail ld Join vyuAPVendor v on ld.intVendorEntityId=v.intEntityId Where intLoadId = @intLoadId

	--If Exists (Select 1 From tblLGLoad Where intLoadId=@intLoadId AND intLoadShippingInstructionId is not null)
	If ISNULL(@strExternalDeliveryNumber,'')<>''
		Set @strHeaderRowState='MODIFIED'
	Else
		Set @strHeaderRowState='ADDED'

	Set @strXml =  '<DELVRY07>'
	Set @strXml += '<IDOC BEGIN="1">'
	
	--IDOC Header
	Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
	If UPPER(@strHeaderRowState)='ADDED'
		Set @strXml +=	@strCreateIDOCHeader
	Else
		Set @strXml +=	@strUpdateIDOCHeader
	Set @strXml +=	'</EDI_DC40>'
	
	--Header
	Set @strXml += '<E1EDL20 SEGMENT="1">'
	Set @strXml += '<VBELN>'	+ ISNULL(@strExternalDeliveryNumber,'')	+ '</VBELN>'
	--Set @strXml += '<INCO1>'	+ ISNULL(@strContractBasis,'')			+ '</INCO1>'
	--Set @strXml += '<INCO2>'	+ ISNULL(@strContractBasisDesc,'')		+ '</INCO2>'
	Set @strXml += '<BOLNR>'	+ ISNULL(@strBillOfLading,'')			+ '</BOLNR>'
	Set @strXml += '<TRAID>'	+ ISNULL(@strShippingLine,'')			+ '</TRAID>'
	Set @strXml += '<LIFEX>'	+ ISNULL(@strLoadNumber,'')				+ '</LIFEX>'

	Set @strXml += '<E1EDL18 SEGMENT="1">'
	Set @strXml += '<QUALF>'	
					+ CASE WHEN UPPER(@strHeaderRowState)='ADDED' THEN 'ORI' ELSE 'CHG' END			
					+ '</QUALF>'
	Set @strXml +=	'</E1EDL18>'

	Set @strXml += '<E1ADRM1 SEGMENT="1">'
	Set @strXml += '<PARTNER_Q>'	+ 'WE'			+ '</PARTNER_Q>'
	Set @strXml += '<PARTNER_ID>'	+ ISNULL(@strVendorAccountNo,'')		+ '</PARTNER_ID>'
	Set @strXml +=	'</E1ADRM1>'

	Set @strXml += '<E1EDT13 SEGMENT="1">'
	Set @strXml += '<QUALF>'	+ '015'			+ '</QUALF>'
	Set @strXml += '<NTANF>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmScheduledDate,112),'')		+ '</NTANF>'
	Set @strXml +=	'</E1EDT13>'

	Set @strXml += '<E1EDT13 SEGMENT="1">'
	Set @strXml += '<QUALF>'	+ '006'			+ '</QUALF>'
	Set @strXml += '<NTANF>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmScheduledDate,112),'')		+ '</NTANF>'
	Set @strXml +=	'</E1EDT13>'

	Set @strXml += '<E1EDT13 SEGMENT="1">'
	Set @strXml += '<QUALF>'	+ '007'			+ '</QUALF>'
	Set @strXml += '<NTANF>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmETAPOD,112),'')		+ '</NTANF>'
	Set @strXml +=	'</E1EDT13>'

	Delete From @tblDetail

	Insert Into @tblDetail(intLoadStgId,intLGLoadDetailStgId,intLoadId,intLoadDetailId,strDeliveryItemNo,strDeliverySubItemNo,strItemNo,
		strSubLocation,strStorageLocation,strContainerNo,dblQuantity,strUOM,strPONo,strPOLineItemNo,strShipItemRefNo,strRowState,strCommodityCode,
		dblGrossWeight,dblNetWeight,strWeightUOM)
	Select sd.intLoadStgId,sd.intLGLoadDetailStgId,sd.intLoadId,sd.intLoadDetailId,
		--CASE WHEN ISNULL(sd.strExternalShipmentItemNumber,'')='' THEN  (10 * ROW_NUMBER() OVER(ORDER BY intLGLoadDetailStgId ASC)) ELSE sd.strExternalShipmentItemNumber END strDeliveryItemNo,
		(10 * ROW_NUMBER() OVER(ORDER BY intLGLoadDetailStgId ASC)) strDeliveryItemNo,
		'',sd.strItemNo,sd.strSubLocationName,sd.strStorageLocationName,
		CASE WHEN @strTransactionType='Shipping Instructions' THEN '' 
		ELSE (Select TOP 1 c.strContainerNumber 
			From tblLGLoadContainer c Join tblLGLoadDetailContainerLink cl on c.intLoadContainerId=cl.intLoadContainerId Where cl.intLoadDetailId=sd.intLoadDetailId)
		END,
		sd.dblDeliveredQty,sd.strUnitOfMeasure,sd.strExternalPONumber,sd.strExternalPOItemNumber,sd.intSIDetailId,sd.strRowState,sd.strCommodityCode,
		sd.dblGrossWt,sd.dblNetWt,sd.strWeightUOM
		From tblLGLoadDetailStg sd
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
			@strSubLocation				=	strSubLocation,
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
			Set @strItemXml += '<MATNR>'  +  ISNULL(@strItemNo,'') + '</MATNR>' 
			Set @strItemXml += '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
			Set @strItemXml += '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
			Set @strItemXml += '<CHARG>'  +  ISNULL(@strContainerNo,'') + '</CHARG>' 
			Set @strItemXml += '<KDMAT>'  +  ISNULL(@strItemNo,'') + '</KDMAT>' 
			Set @strItemXml += '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblNetWeight)),'') + '</LFIMG>'
			Set @strItemXml += '<VRKME>'  +  ISNULL(@strWeightUOM,'') + '</VRKME>' 

			--Set @strItemXml += '<E1EDL43 SEGMENT="1">'
			--Set @strItemXml += '<QUALF>'  +  'C' + '</QUALF>' 
			--Set @strItemXml += '</E1EDL43>'

			If UPPER(@strHeaderRowState)='MODIFIED'
			Begin
				Set @strItemXml += '<E1EDL19 SEGMENT="1">'
				Set @strItemXml += '<QUALF>'  +  'QUA' + '</QUALF>' 
				Set @strItemXml += '</E1EDL19>'
			End

			If UPPER(@strRowState)='DELETE'
			Begin
				Set @strItemXml += '<E1EDL19 SEGMENT="1">'
				Set @strItemXml += '<QUALF>'  +  'DEL' + '</QUALF>' 
				Set @strItemXml += '</E1EDL19>'
			End
			--Else
			--Begin
			--	If ISNULL(@ysnBatchSplit,0)=0 AND (UPPER(@strRowState)='ADDED' OR UPPER(@strRowState)='MODIFIED')
			--	Begin
			--		Set @strItemXml += '<E1EDL19 SEGMENT="1">'
			--		Set @strItemXml += '<QUALF>'  +  'QUA' + '</QUALF>' 
			--		Set @strItemXml += '</E1EDL19>'
			--	End
			--End

			Set @strItemXml += '<E1EDL41 SEGMENT="1">'
			Set @strItemXml += '<QUALI>'  +  '001' + '</QUALI>' 
			Set @strItemXml += '<BSTNR>'  +  ISNULL(@strPONo,'') + '</BSTNR>' 
			Set @strItemXml += '<IHREZ>'  +  ISNULL(@strShipItemRefNo,'') + '</IHREZ>' 
			Set @strItemXml += '<POSEX>'  +  ISNULL(@strPOLineItemNo,'') + '</POSEX>' 
			Set @strItemXml += '</E1EDL41>'

			--Batch Split for Coffee
			If UPPER(@strCommodityCode)='COFFEE' AND ISNULL(@ysnBatchSplit,0)=1
			Begin
				If (Select COUNT(1) From tblLGLoadDetailContainerLink lc Join tblLGLoadDetail ld on lc.intLoadDetailId=ld.intLoadDetailId
					Where ld.intLoadId=@intLoadId AND lc.intLoadDetailId=@intLoadDetailId)>1
				Begin
					Select @strContainerXml=COALESCE(@strContainerXml, '') 
							+ '<E1EDL24 SEGMENT="1">'
							+ '<POSNR>' + ISNULL(CONVERT(VARCHAR,(900000 + ROW_NUMBER() OVER(ORDER BY c.intLoadContainerId ASC))),'') + '</POSNR>' 
							+ '<MATNR>'  +  ISNULL(@strItemNo,'') + '</MATNR>' 
							+ '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
							+ '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
							+ '<CHARG>'  +  ISNULL(c.strContainerNumber,'') + '</CHARG>' 
							+ '<KDMAT>'  +  ISNULL(@strItemNo,'') + '</KDMAT>' 
							+ '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),c.dblNetWt)),'') + '</LFIMG>' 
							+ '<VRKME>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(um.strUnitMeasure,'')) + '</VRKME>' 
							+ '<HIPOS>' + ISNULL(@strDeliveryItemNo,'') + '</HIPOS>' 

							+ '<E1EDL19 SEGMENT="1">'
							+ '<QUALF>'  +  'BAS' + '</QUALF>' 
							+ '</E1EDL19>'

							+ '<E1EDL41 SEGMENT="1">'
							+ '<QUALI>'  +  '001' + '</QUALI>' 
							+ '<BSTNR>'  +  ISNULL(@strPONo,'') + '</BSTNR>' 
							+ '<POSEX>'  +  ISNULL(@strPOLineItemNo,'') + '</POSEX>' 
							+ '</E1EDL41>'

							+ '</E1EDL24>'
					From tblLGLoadDetailContainerLink lc Join tblLGLoadDetail ld on lc.intLoadDetailId=ld.intLoadDetailId
					Join tblLGLoadContainer c on lc.intLoadContainerId=c.intLoadContainerId
					Join tblICUnitMeasure um on c.intWeightUnitMeasureId=um.intUnitMeasureId
					Where ld.intLoadId=@intLoadId AND lc.intLoadDetailId=@intLoadDetailId

					Set @strItemXml += ISNULL(@strContainerXml,'')
				End
			End

			Set @strItemXml += '</E1EDL24>'

		Select @intMinDetail=Min(intRowNo) From @tblDetail Where intRowNo>@intMinDetail
	End --Loop Detail End

	--For Tea
	If UPPER(@strCommodityCode)='TEA'
	Begin
			Set @strContainerXml=''

			Delete From @tblContainer

			Insert Into @tblContainer(intLoadContainerStgId,intLoadContainerId,strContainerNo,strContainerSizeCode)
			Select c.intLoadContainerStgId,c.intLoadContainerId,c.strContainerNo,c.strContainerSizeCode
			From tblLGLoadContainerStg c Where c.intLoadStgId=@intMinHeader

			Select @intMinContainer=Min(intLoadContainerStgId) From @tblContainer

			While(@intMinContainer is not null) --Loop Container
			Begin
				Select @strContainerNo=strContainerNo,@strContainerSizeCode=strContainerSizeCode,@intLoadContainerId=intLoadContainerId
				From @tblContainer Where intLoadContainerStgId=@intMinContainer

					Set @strContainerXml += '<E1EDL37 SEGMENT="1">'
					Set @strContainerXml += '<EXIDV>'  +  ISNULL(@strContainerNo,'') + '</EXIDV>' 
					Set @strContainerXml += '<VHILM>'  +  ISNULL(@strContainerSizeCode,'') + '</VHILM>' 
					Set @strContainerXml += '<VHART>'  +  '0002' + '</VHART>' 

					Set @strContainerItemXml=NULL
					Select @strContainerItemXml=COALESCE(@strContainerItemXml, '') 
					+ '<E1EDL44 SEGMENT="1">'
					+ '<VBELN>'  +  ISNULL(@strExternalDeliveryNumber,'') + '</VBELN>' 
					+ '<POSNR>'  +  ISNULL(ld.strExternalShipmentItemNumber,'') + '</POSNR>'
					+ '<VEMNG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),cl.dblQuantity)),'') + '</VEMNG>'
					+ '<VEMEH>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(ld.strUnitOfMeasure,'')) + '</VEMEH>'
					+ '</E1EDL44>'			 
					From tblLGLoadDetailContainerLink cl Join tblLGLoadDetailStg ld on cl.intLoadDetailId=ld.intLoadDetailId
					Where intLoadContainerId=@intLoadContainerId

					Set @strContainerXml += ISNULL(@strContainerItemXml,'')
					Set @strContainerXml += '</E1EDL37>'

				Select @intMinContainer=Min(intLoadContainerStgId) From @tblContainer Where intLoadContainerStgId>@intMinContainer
			End --Loop Container End

	End

	--Final Xml
	Set @strXml += ISNULL(@strItemXml,'') + ISNULL(@strContainerXml,'')

	Set @strXml += '</E1EDL20>'
	Set @strXml += '</IDOC>'
	Set @strXml +=  '</DELVRY07>'

	--Set @strLoadStgIds=NULL
	--Select @strLoadStgIds=COALESCE(CONVERT(VARCHAR,@strLoadStgIds) + ',', '') + intLoadStgId From @tblDetail

	INSERT INTO @tblOutput(strLoadStgIds,strRowState,strXml)
	VALUES(@intMinHeader,CASE WHEN UPPER(@strHeaderRowState)='ADDED' THEN 'CREATE' ELSE 'UPDATE' END,@strXml)

	Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where intLoadStgId>@intMinHeader AND ISNULL(strFeedStatus,'')='' AND strTransactionType='Shipment'
End --Loop Header End
Select * From @tblOutput ORDER BY intRowNo