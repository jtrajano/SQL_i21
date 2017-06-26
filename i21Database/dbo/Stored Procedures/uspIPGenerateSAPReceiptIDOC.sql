CREATE PROCEDURE [dbo].[uspIPGenerateSAPReceiptIDOC]
	@ysnUpdateFeedStatusOnRead bit=0
AS

Declare @intMinHeader				INT,
		@intMinDetail				INT,
		@intMinContainer			INT,
		@strCommodityCode			NVARCHAR(100) ,
		@strSAPDeliveryNo			NVARCHAR(100) ,
		@dtmReceiptDate				DATETIME ,
		@ysnBatchSplit				BIT,
		@strXml						NVARCHAR(MAX),
		@strReceiptIDOCHeader		NVARCHAR(MAX),
		@strReceiptDetailIds		NVARCHAR(MAX),
		@strItemXml					NVARCHAR(MAX),
		@intLoadId					INT,
		@intLoadDetailId			INT,
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
		@strContainerXml			NVARCHAR(MAX),
		@intContractDetailId		INT,
		@intInventoryReceiptItemId	INT,
		@strContainerItemXml		NVARCHAR(MAX),
		@strContainerSizeCode		NVARCHAR(100),
		@intLoadContainerId			INT,
		@intNoOfContainer			INT,
		@strReceiptNo				NVARCHAR(50),
		@ysnWMMBXY					bit=1,
		@str10Zeros					NVARCHAR(50)='0000000000'

Declare @tblReceiptHeader AS Table
(
	intInventoryReceiptId INT,
	strDeliveryNo NVARCHAR(100),
	dtmReceiptDate DATETIME,
	intLoadId INT,
	strReceiptNo NVARCHAR(100)
)

Declare @tblReceiptDetail AS Table
(
	intRowNo INT IDENTITY(1,1),
	intInventoryReceiptId INT,
	intInventoryReceiptItemId INT,
	strDeliveryItemNo NVARCHAR(100),
	strDeliverySubItemNo NVARCHAR(100),
	strItemNo NVARCHAR(100),
	strSubLocation NVARCHAR(50),
	strStorageLocation NVARCHAR(50),
	strContainerNo NVARCHAR(50),
	dblQuantity NUMERIC(38,20),
	strUOM NVARCHAR(50),
	strCommodityCode NVARCHAR(50),
	intLoadDetailId INT,
	strPONo NVARCHAR(100),
	intContractDetailId int
)

Declare @tblContainer AS Table
(
	intRowNo INT IDENTITY(1,1),
	intLoadContainerId	INT,
	strContainerNo NVARCHAR(100),
	strContainerSizeCode NVARCHAR(100)
)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strReceiptDetailIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX),
	strReceiptNo NVARCHAR(100),
	strMessageType NVARCHAR(50)
)

Insert Into @tblReceiptHeader(intInventoryReceiptId,strDeliveryNo,dtmReceiptDate,intLoadId,strReceiptNo)
Select DISTINCT r.intInventoryReceiptId,l.strExternalShipmentNumber,r.dtmReceiptDate,l.intLoadId,r.strReceiptNumber
From tblICInventoryReceiptItem ri 
Join tblICInventoryReceipt r on ri.intInventoryReceiptId=r.intInventoryReceiptId
JOIN tblLGLoadDetail ld on ri.intSourceId=ld.intLoadDetailId
JOIN tblLGLoad l on ld.intLoadId=l.intLoadId
Where r.intSourceType=2 AND r.ysnPosted=1 AND ri.ysnExported IS NULL AND ISNULL(l.strExternalShipmentNumber,'')<>'' AND strReceiptType<>'Inventory Return'

Select @intMinHeader=Min(intInventoryReceiptId) From @tblReceiptHeader

While(@intMinHeader is not null)
Begin
	Select @strSAPDeliveryNo=strDeliveryNo,@dtmReceiptDate=dtmReceiptDate,@intLoadId=intLoadId,@strReceiptNo=strReceiptNo 
	From @tblReceiptHeader Where intInventoryReceiptId=@intMinHeader

	--Get the Details
	Delete From @tblReceiptDetail

	Insert Into @tblReceiptDetail(intInventoryReceiptId,intInventoryReceiptItemId,strDeliveryItemNo,strItemNo,strSubLocation,strStorageLocation,strContainerNo,dblQuantity,strUOM,strCommodityCode,intLoadDetailId,strPONo,intContractDetailId)
	Select ri.intInventoryReceiptId,ri.intInventoryReceiptItemId,ld.strExternalShipmentItemNumber AS strDeliveryItemNo,
	i.strItemNo,csl.strSubLocationName,sl.strName AS strStorageLocation,lc.strContainerNumber,ri.dblNet,um.strUnitMeasure AS strWeightUOM,c.strCommodityCode,ri.intSourceId,ch.strContractNumber,ri.intLineNo
	From tblICInventoryReceiptItem ri 
	Join tblICItem i on ri.intItemId=i.intItemId
	Join tblLGLoadDetail ld on ri.intSourceId=ld.intLoadDetailId
	JOIN tblICCommodity c on i.intCommodityId=c.intCommodityId
	Join tblSMCompanyLocationSubLocation csl on ri.intSubLocationId=csl.intCompanyLocationSubLocationId
	Join tblICStorageLocation sl on ri.intStorageLocationId=sl.intStorageLocationId
	Join tblLGLoadContainer lc on ri.intContainerId=lc.intLoadContainerId
	Join tblCTContractDetail cd on ri.intLineNo=cd.intContractDetailId and cd.intContractDetailId=ld.intPContractDetailId
	Join tblCTContractHeader ch on cd.intContractHeaderId=ch.intContractHeaderId and ri.intOrderId=ch.intContractHeaderId
	join tblICItemUOM iu on ri.intWeightUOMId=iu.intItemUOMId
	join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where ri.intInventoryReceiptId=@intMinHeader

	Select TOP 1 @strCommodityCode=strCommodityCode From @tblReceiptDetail 

	--Coffee Multiple Container/Batch Split
	Set @ysnBatchSplit=0
	If UPPER(@strCommodityCode)='COFFEE' AND @ysnWMMBXY=0
	Begin
		If Exists (Select 1 From @tblReceiptDetail Group By intLoadDetailId Having COUNT(intLoadDetailId)>1)
		Begin
			Set @ysnBatchSplit=1

			--Delete duplicate records
			DELETE t FROM @tblReceiptDetail t 
				WHERE EXISTS (
					SELECT *
					FROM @tblReceiptDetail t1
					WHERE t.intLoadDetailId = t1.intLoadDetailId
					AND t.intInventoryReceiptItemId > t1.intInventoryReceiptItemId
					)
		End
	End

	If UPPER(@strCommodityCode)='COFFEE' AND @ysnBatchSplit=1 AND @ysnWMMBXY=0
		Update @tblReceiptDetail Set strContainerNo=''

	If UPPER(@strCommodityCode)='TEA'
		Update d Set d.strContainerNo=ct.strERPBatchNumber From @tblReceiptDetail d Join tblCTContractDetail ct on d.intContractDetailId=ct.intContractDetailId

	If UPPER(@strCommodityCode)='COFFEE' AND @ysnWMMBXY=1
	Begin
		Set @strXml =  '<WMMBID02>'
		Set @strXml += '<IDOC BEGIN="1">'

		--IDOC Header
		Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
		Set @strXml +=	dbo.fnIPGetSAPIDOCHeader('RECEIPT WMMBXY')
		Set @strXml +=	'</EDI_DC40>'

		Set @strXml += '<E1MBXYH SEGMENT="1">'
		Set @strXml += '<BLDAT>' + ISNULL(CONVERT(VARCHAR(10),@dtmReceiptDate,112),'') + '</BLDAT>'
		Set @strXml += '<BUDAT>' + ISNULL(CONVERT(VARCHAR(10),@dtmReceiptDate,112),'') + '</BUDAT>'
		Set @strXml += '<XBLNR>' + ISNULL(@strReceiptNo,'') + '</XBLNR>'
		Set @strXml += '<TCODE>' + 'MIGO' + '</TCODE>'
	End
	Else
	Begin
		Set @strXml =  '<DELVRY07>'
		Set @strXml += '<IDOC BEGIN="1">'

		--IDOC Header
		Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
		Set @strXml +=	dbo.fnIPGetSAPIDOCHeader('RECEIPT WHSCON')
		Set @strXml +=	'</EDI_DC40>'

		Set @strXml += '<E1EDL20 SEGMENT="1">'
		Set @strXml += '<VBELN>' + ISNULL(@strSAPDeliveryNo,'') + '</VBELN>'
		Set @strXml += '<LIFEX>' + ISNULL(@strReceiptNo,'') + '</LIFEX>'

		Set @strXml += '<E1EDL18 SEGMENT="1">'
		Set @strXml += '<QUALF>' + 'PGI' + '</QUALF>'
		Set @strXml += '</E1EDL18>'

		Set @strXml += '<E1EDT13 SEGMENT="1">'
		Set @strXml += '<QUALF>' + '019' + '</QUALF>'
		Set @strXml += '<NTANF>' + ISNULL(CONVERT(VARCHAR(10),@dtmReceiptDate,112),'') + '</NTANF>'
		Set @strXml += '</E1EDT13>'
	End

	Set @strItemXml=''

	Select @intMinDetail=Min(intRowNo) From @tblReceiptDetail

	While(@intMinDetail is not null) --Loop Detail
	Begin
		Select 
			@intInventoryReceiptItemId	=   intInventoryReceiptItemId,
			@intLoadDetailId			=	intLoadDetailId,
			@strDeliveryItemNo			=	strDeliveryItemNo,
			@strDeliverySubItemNo		=	strDeliverySubItemNo,
			@strItemNo					=	strItemNo,
			@strSubLocation				=	strSubLocation,
			@strStorageLocation			=	strStorageLocation,
			@strContainerNo				=	strContainerNo,
			@dblQuantity				=	dblQuantity,
			@strUOM						=	strUOM,
			@intContractDetailId		=	intContractDetailId	
		From @tblReceiptDetail Where intRowNo=@intMinDetail

		Select @strPONo=strERPPONumber,@strPOLineItemNo=strERPItemNumber From tblCTContractDetail Where intContractDetailId=@intContractDetailId
	
		If UPPER(@strCommodityCode)='COFFEE' AND @ysnWMMBXY=1
		Begin
			Set @strItemXml += '<E1MBXYI SEGMENT="1">'
			Set @strItemXml += '<MATNR>'  +  ISNULL(@str10Zeros + @strItemNo,'') + '</MATNR>' 
			Set @strItemXml += '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
			Set @strItemXml += '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
			Set @strItemXml += '<CHARG>'  +  ISNULL(@strContainerNo,'') + '</CHARG>' 
			Set @strItemXml += '<BWART>'  +  '101' + '</BWART>' 
			Set @strItemXml += '<ERFMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblQuantity)),'') + '</ERFMG>' 
			Set @strItemXml += '<ERFME>'  +  ISNULL(@strUOM,'') + '</ERFME>' 
			Set @strItemXml += '<EBELN>'  +  ISNULL(@strPONo,'') + '</EBELN>' 
			Set @strItemXml += '<EBELP>'  +  ISNULL(@strPOLineItemNo,'') + '</EBELP>' 
			Set @strItemXml += '<UMWRK>'  +  ISNULL(@strSubLocation,'') + '</UMWRK>' 
			Set @strItemXml += '<KZBEW>'  +  'B' + '</KZBEW>' 
			Set @strItemXml += '</E1MBXYI>'
		End
		Else
		Begin			
			Set @strItemXml += '<E1EDL24 SEGMENT="1">'
			Set @strItemXml += '<POSNR>'  +  ISNULL(@strDeliveryItemNo,'') + '</POSNR>' 
			Set @strItemXml += '<MATNR>'  +  ISNULL(@str10Zeros + @strItemNo,'') + '</MATNR>' 
			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
			Else
				Set @strItemXml += '<WERKS>'  +  '' + '</WERKS>' 
			Set @strItemXml += '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
			Set @strItemXml += '<CHARG>'  +  ISNULL(@strContainerNo,'') + '</CHARG>' 
			If ISNULL(@ysnBatchSplit,0)=0
				Set @strItemXml += '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblQuantity)),'') + '</LFIMG>'
			Else
				Set @strItemXml += '<LFIMG>'  +  '' + '</LFIMG>'
			Set @strItemXml += '<VRKME>'  +  ISNULL(dbo.fnIPConverti21UOMToSAP(@strUOM),'') + '</VRKME>' 
			If ISNULL(@ysnBatchSplit,0)=1
				Set @strItemXml += '<HIPOS>'  +  ISNULL(@strDeliveryItemNo,'') + '</HIPOS>'

			Set @strItemXml += '<E1EDL19 SEGMENT="1">'
			Set @strItemXml += '<QUALF>'  +  'QUA' + '</QUALF>' 
			Set @strItemXml += '</E1EDL19>'

			Set @strItemXml += '</E1EDL24>'

			--Batch Split for Coffee
			If UPPER(@strCommodityCode)='COFFEE' AND ISNULL(@ysnBatchSplit,0)=1
			Begin
				Set @strContainerXml=''
				Select @strContainerXml=@strContainerXml
						+ '<E1EDL24 SEGMENT="1">'
						+ '<POSNR>'	 +	ISNULL(cl.strExternalContainerId,'')  + '</POSNR>' 
						+ '<MATNR>'  +  ISNULL(ri.strItemNo,'') + '</MATNR>' 
						+ '<WERKS>'  +  ISNULL(ri.strSubLocationName,'') + '</WERKS>' 
						+ '<LGORT>'  +  ISNULL(ri.strStorageLocationName,'') + '</LGORT>' 
						+ '<CHARG>'  +  ISNULL(ri.strContainer,'') + '</CHARG>' 
						+ '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),ri.dblNetWgt)),'') + '</LFIMG>' 
						+ '<VRKME>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(ri.strWeightUOM,'')) + '</VRKME>' 
						+ '<HIPOS>'  +   ISNULL(@strDeliveryItemNo,'') + '</HIPOS>' 

						+ '<E1EDL19 SEGMENT="1">'
						+ '<QUALF>'  +  'QUA' + '</QUALF>' 
						+ '</E1EDL19>'

						+ '</E1EDL24>'
				From vyuICGetInventoryReceiptItem ri 
				Join tblLGLoadDetailContainerLink cl on ri.intSourceId=cl.intLoadDetailId AND ri.intContainerId=cl.intLoadContainerId
				Join tblLGLoadDetail ld on ri.intSourceId=ld.intLoadDetailId AND ri.intItemId=ld.intItemId
				Where ri.intInventoryReceiptId=@intMinHeader AND ri.intSourceId=@intLoadDetailId

				Set @strItemXml += ISNULL(@strContainerXml,'')
			End
		End

		Select @intMinDetail=Min(intRowNo) From @tblReceiptDetail Where intRowNo>@intMinDetail
	End --Loop Detail End

	--Final Xml
	Set @strXml += ISNULL(@strItemXml,'')

	If UPPER(@strCommodityCode)='COFFEE' AND @ysnWMMBXY=1
	Begin
		Set @strXml += '</E1MBXYH>'

		Set @strXml += '</IDOC>'
		Set @strXml +=  '</WMMBID02>'
	End
	Else
	Begin
		Set @strXml += '</E1EDL20>'

		Set @strXml += '</IDOC>'
		Set @strXml +=  '</DELVRY07>'
	End

	Set @strReceiptDetailIds=NULL
	Select @strReceiptDetailIds=COALESCE(CONVERT(VARCHAR(max),@strReceiptDetailIds) + ',', '') + CONVERT(VARCHAR,intInventoryReceiptItemId) 
	From tblICInventoryReceiptItem Where intInventoryReceiptId=@intMinHeader

	If @ysnUpdateFeedStatusOnRead=1
		Update tblICInventoryReceiptItem Set ysnExported=0 Where intInventoryReceiptId=@intMinHeader

	INSERT INTO @tblOutput(strReceiptDetailIds,strRowState,strXml,strReceiptNo,strMessageType)
	VALUES(@strReceiptDetailIds,'CREATE',@strXml,ISNULL(@strReceiptNo,''),CASE WHEN @ysnWMMBXY=1 AND UPPER(@strCommodityCode)='COFFEE' THEN 'WMMBXY' ELSE 'WHSCON' END)

	Select @intMinHeader=Min(intInventoryReceiptId) From @tblReceiptHeader Where intInventoryReceiptId>@intMinHeader
End

Select * From @tblOutput ORDER BY intRowNo