﻿CREATE PROCEDURE [dbo].[uspIPGenerateSAPShipmentIDOC]
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
		@strShippingLineName		NVARCHAR(250) , 
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
		@dtmETAPOD					DATETIME,
		@intNoOfContainer			INT,
		@intExternalContainerNo		INT,
		@str10Zeros					NVARCHAR(50)='0000000000',
		@strMVessel					NVARCHAR(200)

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
	intRowNo INT IDENTITY(1,1),
	intLoadContainerId	INT,
	strContainerNo NVARCHAR(100),
	strContainerSizeCode NVARCHAR(100),
	strExternalContainerId NVARCHAR(100),
	dblNetWt NUMERIC(38,20),
	strWeightUOM NVARCHAR(50),
	strRowState NVARCHAR(50),
	ysnNewContainer BIT,
	strSubLocation NVARCHAR(100),
	strStorageLocation NVARCHAR(100)
)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strLoadStgIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX),
	strShipmentNo NVARCHAR(100),
	strDeliveryNo NVARCHAR(100)
)

Select @strCreateIDOCHeader=dbo.fnIPGetSAPIDOCHeader('SHIPMENT CREATE')
Select @strUpdateIDOCHeader=dbo.fnIPGetSAPIDOCHeader('SHIPMENT UPDATE')
Select @strCompCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL','COMP_CODE')

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
		@strShippingLine			=	strShippingLineAccountNo ,
		@strShippingLineName		=	strShippingLine , 
		@strExternalDeliveryNumber	=	strExternalShipmentNumber, 
		@dtmScheduledDate			=   dtmScheduledDate,
		@strFeedStatus				=	strFeedStatus,
		@dtmETAPOD					=	dtmETAPOD,
		@strMVessel					=	strMVessel,
		@strHeaderRowState			=	strRowState
	From tblLGLoadStg Where intLoadStgId=@intMinHeader

	Select TOP 1 @strVendorAccountNo=v.strVendorAccountNum 
	From tblLGLoadDetail ld Join vyuAPVendor v on ld.intVendorEntityId=v.intEntityId Where intLoadId = @intLoadId

	--Validation
	Update tblLGLoadStg Set strMessage=NULL  Where intLoadStgId=@intLoadStgId --message should be null not empty(used in loadstg sps as null)

	--Do not send instruction if advice is created
	If @strTransactionType='Shipping Instructions'
	Begin
		If Exists (Select 1 From tblLGLoadStg sl Join tblLGLoad l on sl.intLoadId=l.intLoadId 
					Where strShippingInstructionNumber=@strLoadNumber AND strTransactionType='Shipment' AND intLoadStgId<@intLoadStgId AND ISNULL(l.ysnCancelled,0)=0)
		Begin
			Update tblLGLoadStg Set strMessage='System will not send shipping instruction once advice is created.'  Where intLoadStgId=@intLoadStgId
			GOTO NEXT_SHIPMENT			
		End
	End

	If ISNULL(@strLoadNumber,'')=''
	Begin
		Update tblLGLoadStg Set strMessage='Load Number is empty.'  Where intLoadStgId=@intLoadStgId
		GOTO NEXT_SHIPMENT
	End
	If @dtmETAPOD is null
	Begin
		Update tblLGLoadStg Set strMessage='ETA POD is empty.'  Where intLoadStgId=@intLoadStgId
		GOTO NEXT_SHIPMENT
	End

	If UPPER(@strHeaderRowState) in ('MODIFIED','DELETE') AND ISNULL(@strExternalDeliveryNumber,'')=''
		Begin
			GOTO NEXT_SHIPMENT
		End

	--if ack is not received for the previous feed do not send the current feed
	If (Select TOP 1 strFeedStatus From tblLGLoadStg Where intLoadId=@intLoadId AND strTransactionType='Shipment' 
		AND intLoadStgId < @intLoadStgId Order By intLoadStgId Desc)<>'Ack Rcvd'
		GOTO NEXT_SHIPMENT

	--Donot send any feed if the Load is Cancelled
	If UPPER(@strHeaderRowState)<>'DELETE' AND (Select intShipmentStatus from tblLGLoad Where intLoadId=@intLoadId)=10
		GOTO NEXT_SHIPMENT

	Update tblLGLoadStg Set strMessageState=@strHeaderRowState  Where intLoadStgId=@intLoadStgId

	Set @strXml =  '<DELVRY07>'
	Set @strXml += '<IDOC BEGIN="1">'
	
	--IDOC Header
	Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
	If UPPER(@strHeaderRowState)='ADDED'
		Set @strXml +=	@strCreateIDOCHeader
	Else
		Set @strXml +=	@strUpdateIDOCHeader
	Set @strXml +=	'</EDI_DC40>'
	
	If UPPER(@strHeaderRowState)='DELETE'
	Begin
		Set @strXml += '<E1EDL20 SEGMENT="1">'
		Set @strXml += '<VBELN>'	+ ISNULL(@strExternalDeliveryNumber,'')	+ '</VBELN>'
		Set @strXml += '<LIFEX>'	+ LTRIM(RTRIM(ISNULL(@strLoadNumber,'') + ' ' + dbo.fnEscapeXML(ISNULL(@strMVessel,'')))) + '</LIFEX>'

		Set @strXml += '<E1EDL18 SEGMENT="1">'
		Set @strXml += '<QUALF>' + 'DEL' + '</QUALF>'
		Set @strXml +=	'</E1EDL18>'

		GOTO END_TAG
	End

	--Header
	Set @strXml += '<E1EDL20 SEGMENT="1">'
	Set @strXml += '<VBELN>'	+ ISNULL(@strExternalDeliveryNumber,'')	+ '</VBELN>'
	Set @strXml += '<BOLNR>'	+ LEFT(LEFT(ISNULL(@strShippingLineName,''),4) + '     ',4) + ISNULL(@strBillOfLading,'') + '</BOLNR>'
	Set @strXml += '<TRAID>'	+ ISNULL(@strShippingLine,'')			+ '</TRAID>'
	Set @strXml += '<LIFEX>'	+ LTRIM(RTRIM(ISNULL(@strLoadNumber,'') + ' ' + dbo.fnEscapeXML(ISNULL(@strMVessel,'')))) + '</LIFEX>'

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
		CASE WHEN isnull(sd.strExternalShipmentItemNumber,'')='' THEN (10 * ROW_NUMBER() OVER(ORDER BY intLGLoadDetailStgId ASC)) ELSE sd.strExternalShipmentItemNumber END strDeliveryItemNo,
		'',sd.strItemNo,sd.strSubLocationName,sd.strStorageLocationName,
		CASE WHEN @strTransactionType='Shipping Instructions' THEN '' 
		Else sd.strExternalPOBatchNumber End,
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

	If @strTransactionType='Shipment'
	Begin
		If UPPER(@strCommodityCode)='COFFEE' AND @ysnBatchSplit=0
			Begin
				Update d Set d.strContainerNo=c.strContainerNumber From @tblDetail d Join tblLGLoadDetailContainerLink cl on d.intLoadDetailId=cl.intLoadDetailId 
				Join tblLGLoadContainer c on c.intLoadContainerId=cl.intLoadContainerId

				Update cl Set cl.strExternalContainerId=d.strDeliveryItemNo 
				From tblLGLoadDetailContainerLink cl Join @tblDetail d on cl.intLoadDetailId=d.intLoadDetailId  Where cl.intLoadId=@intLoadId
			End

		If UPPER(@strCommodityCode)='COFFEE' AND @ysnBatchSplit=1
			Update @tblDetail Set strContainerNo=''
	End

	Set @strItemXml=''

	--For Tea Update/existing container, do not send Items
	If UPPER(@strCommodityCode)='TEA' AND Exists (Select 1 From tblLGLoadContainer Where intLoadId=@intLoadId AND ISNULL(ysnNewContainer,0)=0) 
		GOTO END_TAG

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

			If UPPER(@strCommodityCode)='COFFEE' AND ISNULL(@ysnBatchSplit,0)=0
				Select TOP 1 @dblNetWeight=dblNetWt from tblLGLoadContainerStg Where intLoadStgId=@intLoadStgId

			--Validation
			If ISNULL(@dblNetWeight,0)<=0
			Begin
				Update tblLGLoadStg Set strMessage='Net Weight is empty.'  Where intLoadStgId=@intLoadStgId
				GOTO NEXT_SHIPMENT
			End
			If ISNULL(@strWeightUOM,'')=''
			Begin
				Update tblLGLoadStg Set strMessage='Weight UOM is empty.'  Where intLoadStgId=@intLoadStgId
				GOTO NEXT_SHIPMENT
			End
			If ISNULL(@strPONo,'')=''
			Begin
				Update tblLGLoadStg Set strMessage='PO No is empty.'  Where intLoadStgId=@intLoadStgId
				GOTO NEXT_SHIPMENT
			End
			If ISNULL(@strPOLineItemNo,'')=''
			Begin
				Update tblLGLoadStg Set strMessage='PO Line No is empty.'  Where intLoadStgId=@intLoadStgId
				GOTO NEXT_SHIPMENT
			End

			--update strExternalShipmentItemNumber if null
			Update tblLGLoadDetail Set strExternalShipmentItemNumber=@strDeliveryItemNo Where intLoadDetailId=@intLoadDetailId AND ISNULL(strExternalShipmentItemNumber,'')=''
			Update tblLGLoadDetailStg Set strExternalShipmentItemNumber=@strDeliveryItemNo 
			Where intLoadStgId=@intLoadStgId AND intLoadDetailId=@intLoadDetailId AND ISNULL(strExternalShipmentItemNumber,'')=''

			Set @strItemXml += '<E1EDL24 SEGMENT="1">'
			Set @strItemXml += '<POSNR>'  +  ISNULL(@strDeliveryItemNo,'') + '</POSNR>' 
			Set @strItemXml += '<MATNR>'  +  ISNULL(@str10Zeros + @strItemNo,'') + '</MATNR>' 
			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
			Else
				Set @strItemXml += '<WERKS>'  +  '' + '</WERKS>' 
			If ISNULL(@ysnBatchSplit,0)=1 AND UPPER(@strHeaderRowState)='ADDED'--coffee batch split DESADV / shipping advice
				Set @strItemXml += '<LGORT>'  +  '' + '</LGORT>' 
			Else
				Set @strItemXml += '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
			If UPPER(@strCommodityCode)='COFFEE'
				Set @strItemXml += '<CHARG>'  +  LTRIM(RTRIM(REPLACE(ISNULL(@strContainerNo,''), char(9), ''))) + '</CHARG>' 
			Else
				Set @strItemXml += '<CHARG>'  +  '' + '</CHARG>' 
			Set @strItemXml += '<KDMAT>'  +  ISNULL(@str10Zeros + @strItemNo,'') + '</KDMAT>' 
			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblNetWeight)),'') + '</LFIMG>'
			Else
				If UPPER(@strHeaderRowState)='ADDED'
					Set @strItemXml += '<LFIMG>'  +  '0' + '</LFIMG>' --coffee batch split DESADV / shipping advice
				Else
					Set @strItemXml += '<LFIMG>'  +  '' + '</LFIMG>'
			Set @strItemXml += '<VRKME>'  +  ISNULL(@strWeightUOM,'') + '</VRKME>' 
			If UPPER(@strCommodityCode)='TEA' AND UPPER(@strHeaderRowState)='ADDED'
				Set @strItemXml += '<VOLUM>'  +  '1' + '</VOLUM>' 
			If ISNULL(@ysnBatchSplit,0)=1 AND UPPER(@strHeaderRowState)='MODIFIED'
				Set @strItemXml += '<HIPOS>'  +  ISNULL(@strDeliveryItemNo,'') + '</HIPOS>'
			If ISNULL(@ysnBatchSplit,0)=0 AND UPPER(@strCommodityCode)='COFFEE'
				Set @strItemXml += '<LICHN>' + LTRIM(RTRIM(REPLACE(ISNULL(@strContainerNo,''), char(9), ''))) + '</LICHN>'

			If UPPER(@strHeaderRowState)='MODIFIED'
			Begin
				Set @strItemXml += '<E1EDL19 SEGMENT="1">'
				Set @strItemXml += '<QUALF>'  +  'QUA' + '</QUALF>' 
				Set @strItemXml += '</E1EDL19>'
			End

			Set @strItemXml += '<E1EDL41 SEGMENT="1">'
			Set @strItemXml += '<QUALI>'  +  '001' + '</QUALI>' 
			Set @strItemXml += '<BSTNR>'  +  ISNULL(@strPONo,'') + '</BSTNR>' 
			Set @strItemXml += '<IHREZ>'  +  ISNULL(@strShipItemRefNo,'') + '</IHREZ>' 
			Set @strItemXml += '<POSEX>'  +  ISNULL(@strPOLineItemNo,'') + '</POSEX>' 
			Set @strItemXml += '</E1EDL41>'

			Set @strItemXml += '</E1EDL24>'

			--Batch Split for Coffee
			If UPPER(@strCommodityCode)='COFFEE' AND ISNULL(@ysnBatchSplit,0)=1
			Begin
				If (Select COUNT(1) From tblLGLoadDetailContainerLink lc Join tblLGLoadDetail ld on lc.intLoadDetailId=ld.intLoadDetailId
					Where ld.intLoadId=@intLoadId AND lc.intLoadDetailId=@intLoadDetailId)>1
				Begin
					--Generate POSNR
					SELECT @intExternalContainerNo = CASE WHEN ISNULL(MAX(strExternalContainerId),0)=0 THEN 900000 ELSE MAX(strExternalContainerId) END 
					FROM tblLGLoadContainerStg Where intLoadStgId=@intLoadStgId
					Update tblLGLoadContainerStg Set strExternalContainerId=@intExternalContainerNo,@intExternalContainerNo=@intExternalContainerNo+1
					Where intLoadStgId=@intLoadStgId AND ISNULL(strExternalContainerId,'')=''

					Delete From @tblContainer

					Insert Into @tblContainer(strExternalContainerId,strContainerNo,dblNetWt,strWeightUOM,strRowState,ysnNewContainer,strSubLocation,strStorageLocation)
					Select lc.strExternalContainerId,lc.strContainerNo,lc.dblNetWt,lc.strWeightUOM,lc.strRowState,c.ysnNewContainer,lc.strSubLocation,lc.strStorageLocation
					From tblLGLoadContainerStg lc
					Left Join tblLGLoadContainer c on lc.intLoadContainerId=c.intLoadContainerId
					Left Join tblLGLoadDetailContainerLink cl on lc.intLoadContainerId=cl.intLoadContainerId
					Left Join tblLGLoadDetail ld on ld.intLoadDetailId=cl.intLoadDetailId AND ld.intLoadDetailId=@intLoadDetailId
					Where lc.intLoadStgId=@intLoadStgId
					Order By lc.strExternalContainerId

					--Validation
					If Exists (Select 1 From @tblContainer Where ISNULL(strContainerNo,'')='')
					Begin
						Update tblLGLoadStg Set strMessage='Container No is empty.'  Where intLoadStgId=@intLoadStgId
						GOTO NEXT_SHIPMENT
					End
					If Exists (Select 1 From @tblContainer Where ISNULL(dblNetWt,0)<=0)
					Begin
						Update tblLGLoadStg Set strMessage='Container Net Weight is empty.'  Where intLoadStgId=@intLoadStgId
						GOTO NEXT_SHIPMENT
					End
					If Exists (Select 1 From @tblContainer Where ISNULL(strWeightUOM,'')='')
					Begin
						Update tblLGLoadStg Set strMessage='Container Weight UOM is empty.'  Where intLoadStgId=@intLoadStgId
						GOTO NEXT_SHIPMENT
					End

					Set @strContainerXml=''
					Select @strContainerXml=@strContainerXml
							+ '<E1EDL24 SEGMENT="1">'
							+ '<POSNR>' + ISNULL(CONVERT(VARCHAR,lc.strExternalContainerId),'') + '</POSNR>' 
							+ '<MATNR>'  +  ISNULL(@str10Zeros + @strItemNo,'') + '</MATNR>' 
							+ '<WERKS>'  +  CASE WHEN UPPER(@strHeaderRowState)='ADDED' THEN ISNULL(lc.strSubLocation,'')  ELSE '' END + '</WERKS>' 
							+ '<LGORT>'  +  ISNULL(lc.strStorageLocation,'') + '</LGORT>' 
							+ '<CHARG>'  +  LTRIM(RTRIM(REPLACE(ISNULL(lc.strContainerNo,''), char(9), ''))) + '</CHARG>' 
							+ '<KDMAT>'  +  ISNULL(@str10Zeros + @strItemNo,'') + '</KDMAT>' 
							+ '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),lc.dblNetWt)),'') + '</LFIMG>' 
							+ '<VRKME>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(lc.strWeightUOM,'')) + '</VRKME>' 
							+ '<HIPOS>' + ISNULL(@strDeliveryItemNo,'') + '</HIPOS>' 
							+ '<LICHN>' + LTRIM(RTRIM(REPLACE(ISNULL(lc.strContainerNo,''), char(9), ''))) + '</LICHN>' 

							+ '<E1EDL19 SEGMENT="1">'
							+ '<QUALF>'  + CASE WHEN UPPER(lc.strRowState)='DELETE' Then 'DEL' ELSE 'QUA' END + '</QUALF>' 
							+ '</E1EDL19>'

							+
							Case When ISNULL(lc.ysnNewContainer,0)=1 THEN --New Container
							'<E1EDL19 SEGMENT="1">'
							+ '<QUALF>'  +  'BAS' + '</QUALF>' 
							+ '</E1EDL19>'
							ELSE '' END
							+

							+ '<E1EDL41 SEGMENT="1">'
							+ '<QUALI>'  +  '001' + '</QUALI>' 
							+ '<BSTNR>'  +  ISNULL(@strPONo,'') + '</BSTNR>' 
							+ '<POSEX>'  +  ISNULL(@strPOLineItemNo,'') + '</POSEX>' 
							+ '</E1EDL41>'

							+ '</E1EDL24>'
					From @tblContainer lc

					--Update the POSNR in container link table
					Update lc Set lc.strExternalContainerId=cs.strExternalContainerId
					From tblLGLoadDetailContainerLink lc Join tblLGLoadContainerStg cs on lc.intLoadContainerId=cs.intLoadContainerId
					Where lc.intLoadId=@intLoadId AND cs.intLoadStgId=@intLoadStgId

					Set @strItemXml += ISNULL(@strContainerXml,'')
				End
			End

		Select @intMinDetail=Min(intRowNo) From @tblDetail Where intRowNo>@intMinDetail
	End --Loop Detail End

	--For Tea
	If UPPER(@strCommodityCode)='TEA' AND Exists (Select 1 From tblLGLoadContainer Where intLoadId=@intLoadId AND ISNULL(ysnNewContainer,0)=1) 
	Begin
			Set @strContainerXml=''
			Set @intNoOfContainer=1

			Delete From @tblContainer

			Insert Into @tblContainer(intLoadContainerId,strContainerNo,strContainerSizeCode)
			Select DISTINCT c.intLoadContainerId,c.strContainerNo,c.strContainerSizeCode
			From tblLGLoadContainerStg c Where c.intLoadStgId=@intMinHeader AND UPPER(c.strRowState)<>'DELETE'

			--Validation
			If Exists (Select 1 From @tblContainer Where ISNULL(strContainerNo,'')='')
			Begin
				Update tblLGLoadStg Set strMessage='Container No is empty.'  Where intLoadStgId=@intLoadStgId
				GOTO NEXT_SHIPMENT
			End
			If Exists (Select 1 From @tblContainer Where ISNULL(strContainerSizeCode,'')='')
			Begin
				Update tblLGLoadStg Set strMessage='Container Size is empty.'  Where intLoadStgId=@intLoadStgId
				GOTO NEXT_SHIPMENT
			End

			Select @intMinContainer=Min(intRowNo) From @tblContainer

			While(@intMinContainer is not null) --Loop Container
			Begin
				Select @strContainerNo=strContainerNo,@strContainerSizeCode=strContainerSizeCode,@intLoadContainerId=intLoadContainerId
				From @tblContainer Where intRowNo=@intMinContainer

					Set @strContainerXml += '<E1EDL37 SEGMENT="1">'
					Set @strContainerXml += '<EXIDV>'  +  LTRIM(RTRIM(REPLACE(ISNULL(@strContainerNo,''), char(9), ''))) + '</EXIDV>' 
					Set @strContainerXml += '<VHILM>'  +  ISNULL(@strContainerSizeCode,'') + '</VHILM>' 
					Set @strContainerXml += '<VHART>'  +  '0002' + '</VHART>' 
					Set @strContainerXml += '<VHILM_KU>'  +  ISNULL(@strContainerSizeCode,'') + '</VHILM_KU>' 

					Set @strContainerItemXml=''
					Select @strContainerItemXml=@strContainerItemXml
					+ '<E1EDL44 SEGMENT="1">'
					+ '<POSNR>'  +  ISNULL(ld.strExternalShipmentItemNumber,'') + '</POSNR>'
					+ '<VEMNG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),cl.dblQuantity)),'') + '</VEMNG>'
					+ '<VEMEH>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(ld.strUnitOfMeasure,'')) + '</VEMEH>'
					+ '</E1EDL44>'			 
					From tblLGLoadDetailContainerLink cl Join tblLGLoadDetailStg ld on cl.intLoadDetailId=ld.intLoadDetailId
					Where intLoadContainerId=@intLoadContainerId AND ld.intLoadStgId=@intLoadStgId

					Set @strContainerXml += ISNULL(@strContainerItemXml,'')
					Set @strContainerXml += '</E1EDL37>'

					--Update the POSNR in container link table
					Update cl Set cl.strExternalContainerId=ld.strExternalShipmentItemNumber 
					From tblLGLoadDetailContainerLink cl Join tblLGLoadDetailStg ld on cl.intLoadDetailId=ld.intLoadDetailId
					Where intLoadContainerId=@intLoadContainerId AND ld.intLoadStgId=@intLoadStgId AND cl.intLoadId=@intLoadId

				Select @intMinContainer=Min(intRowNo) From @tblContainer Where intRowNo>@intMinContainer
			End --Loop Container End

			Set @strItemXml += ISNULL(@strContainerXml,'')
	End

	--Final Xml
	Set @strXml += ISNULL(@strItemXml,'')

	END_TAG:

	Set @strXml += '</E1EDL20>'
	Set @strXml += '</IDOC>'
	Set @strXml +=  '</DELVRY07>'

	If @ysnUpdateFeedStatusOnRead=1
		Begin
			Update tblLGLoadContainer Set ysnNewContainer=0 Where intLoadId=@intLoadId AND ysnNewContainer=1

			Update tblLGLoadStg Set strFeedStatus='Awt Ack' Where intLoadStgId = @intMinHeader

			--For Tea Update mark as Rcvd
			If UPPER(@strCommodityCode)='TEA' AND (Select UPPER(strRowState) from tblLGLoadStg Where intLoadStgId = @intMinHeader)='MODIFIED'
			AND Exists (Select 1 From tblLGLoadContainer Where intLoadId=@intLoadId AND ISNULL(ysnNewContainer,0)=0) 
				Update tblLGLoadStg Set strFeedStatus='Ack Rcvd',strMessage='Success' Where intLoadStgId = @intMinHeader
		End

	INSERT INTO @tblOutput(strLoadStgIds,strRowState,strXml,strShipmentNo,strDeliveryNo)
	VALUES(@intMinHeader,CASE WHEN UPPER(@strHeaderRowState)='ADDED' THEN 'CREATE' WHEN UPPER(@strHeaderRowState)='DELETE' THEN 'DELETE' ELSE 'UPDATE' END,@strXml,ISNULL(@strLoadNumber,''),ISNULL(@strExternalDeliveryNumber,''))

	NEXT_SHIPMENT:
	Select @intMinHeader=Min(intLoadStgId) From tblLGLoadStg Where intLoadStgId>@intMinHeader AND ISNULL(strFeedStatus,'')=''  AND strTransactionType='Shipment'
End --Loop Header End
Select * From @tblOutput ORDER BY intRowNo