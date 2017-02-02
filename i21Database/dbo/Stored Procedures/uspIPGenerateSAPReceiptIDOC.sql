CREATE PROCEDURE [dbo].[uspIPGenerateSAPReceiptIDOC]
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
		@strContainerSizeCode		NVARCHAR(10),
		@intLoadContainerId			INT

Declare @tblReceiptHeader AS Table
(
	intInventoryReceiptId INT,
	strDeliveryNo NVARCHAR(100),
	dtmReceiptDate DATETIME,
	intLoadId INT
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
	intLoadContainerStgId INT,
	intLoadContainerId	INT,
	strContainerNo NVARCHAR(100),
	strContainerSizeCode NVARCHAR(100)
)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strReceiptDetailIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
)

Select @strReceiptIDOCHeader=dbo.fnIPGetSAPIDOCHeader('RECEIPT')

Insert Into @tblReceiptHeader(intInventoryReceiptId,strDeliveryNo,dtmReceiptDate,intLoadId)
Select DISTINCT r.intInventoryReceiptId,l.strExternalShipmentNumber,r.dtmReceiptDate,l.intLoadId
From tblICInventoryReceiptItem ri 
Join tblICInventoryReceipt r on ri.intInventoryReceiptId=r.intInventoryReceiptId
JOIN vyuLGLoadContainerPurchaseContracts s ON s.intPContractDetailId = ri.intLineNo
JOIN tblLGLoad l on s.intLoadId=l.intLoadId
Where r.intSourceType=2 AND r.ysnPosted=1 AND ri.ysnExported IS NULL

Select @intMinHeader=Min(intInventoryReceiptId) From @tblReceiptHeader

While(@intMinHeader is not null)
Begin
	Select @strSAPDeliveryNo=strDeliveryNo,@dtmReceiptDate=dtmReceiptDate,@intLoadId=intLoadId 
	From @tblReceiptHeader Where intInventoryReceiptId=@intMinHeader

	--Get the Details
	Delete From @tblReceiptDetail

	Insert Into @tblReceiptDetail(intInventoryReceiptId,intInventoryReceiptItemId,strDeliveryItemNo,strItemNo,strSubLocation,strStorageLocation,strContainerNo,dblQuantity,strUOM,strCommodityCode,intLoadDetailId,strPONo,intContractDetailId)
	Select ri.intInventoryReceiptId,ri.intInventoryReceiptItemId,ld.strExternalShipmentItemNumber AS strDeliveryItemNo,
	ri.strItemNo,ri.strSubLocationName,ri.strStorageLocationName,ri.strContainer strContainerNumber,ri.dblQtyToReceive,ri.strUnitMeasure,c.strCommodityCode,ri.intSourceId,ri.strOrderNumber,ri.intLineNo
	From vyuICGetInventoryReceiptItem ri 
	Join tblLGLoadDetail ld on ri.intSourceId=ld.intLoadDetailId
	JOIN tblICCommodity c on ri.intCommodityId=c.intCommodityId
	Where ri.intInventoryReceiptId=@intMinHeader AND ri.strSourceType='Inbound Shipment' AND ri.ysnPosted=1 AND ri.ysnExported IS NULL

	Select TOP 1 @strCommodityCode=strCommodityCode From @tblReceiptDetail 

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

	Set @strXml =  '<DELVRY07>'
	Set @strXml += '<IDOC BEGIN="1">'

	--IDOC Header
	Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
	Set @strXml +=	@strReceiptIDOCHeader
	Set @strXml +=	'</EDI_DC40>'

	Set @strXml += '<E1EDL20 SEGMENT="1">'
	Set @strXml += '<VBELN>' + ISNULL(@strSAPDeliveryNo,'') + '</VBELN>'

	Set @strXml += '<E1EDL18 SEGMENT="1">'
	Set @strXml += '<QUALF>' + 'PGI' + '</QUALF>'
	Set @strXml += '</E1EDL18>'

	Set @strXml += '<E1EDT13 SEGMENT="1">'
	Set @strXml += '<QUALF>' + '019' + '</QUALF>'
	Set @strXml += '<NTANF>' + ISNULL(CONVERT(VARCHAR(10),@dtmReceiptDate,112),'') + '</NTANF>'
	Set @strXml += '</E1EDT13>'

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
			@strUOM						=	dbo.fnIPConverti21UOMToSAP(strUOM),
			@strPONo					=	strPONo,
			@intContractDetailId		=	intContractDetailId	
		From @tblReceiptDetail Where intRowNo=@intMinDetail

		Select @strPOLineItemNo=strERPItemNumber From tblCTContractDetail Where intContractDetailId=@intContractDetailId
			
			Set @strItemXml += '<E1EDL24 SEGMENT="1">'
			Set @strItemXml += '<POSNR>'  +  ISNULL(@strDeliveryItemNo,'') + '</POSNR>' 
			Set @strItemXml += '<MATNR>'  +  ISNULL(@strItemNo,'') + '</MATNR>' 
			Set @strItemXml += '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
			Set @strItemXml += '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
			Set @strItemXml += '<CHARG>'  +  ISNULL(@strContainerNo,'') + '</CHARG>' 
			Set @strItemXml += '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblQuantity)),'') + '</LFIMG>'
			Set @strItemXml += '<VRKME>'  +  ISNULL(@strUOM,'') + '</VRKME>' 

			If ISNULL(@ysnBatchSplit,0)=0 
			Begin
				Set @strItemXml += '<E1EDL19 SEGMENT="1">'
				Set @strItemXml += '<QUALF>'  +  'QUA' + '</QUALF>' 
				Set @strItemXml += '</E1EDL19>'
			End

			--Set @strItemXml += '<E1EDL41 SEGMENT="1">'
			--Set @strItemXml += '<QUALI>'  +  '001' + '</QUALI>' 
			--Set @strItemXml += '<BSTNR>'  +  ISNULL(@strPONo,'') + '</BSTNR>' 
			--Set @strItemXml += '<POSEX>'  +  ISNULL(@strPOLineItemNo,'') + '</POSEX>' 
			--Set @strItemXml += '<IHREZ>'  +  ISNULL(CONVERT(VARCHAR,@intInventoryReceiptItemId),'') + '</IHREZ>' 
			--Set @strItemXml += '</E1EDL41>'

			--Batch Split for Coffee
			If UPPER(@strCommodityCode)='COFFEE' AND ISNULL(@ysnBatchSplit,0)=1
			Begin
				If (Select COUNT(1) From tblLGLoadDetailContainerLink lc Join tblLGLoadDetail ld on lc.intLoadDetailId=ld.intLoadDetailId
					Where ld.intLoadId=@intLoadId AND lc.intLoadDetailId=@intLoadDetailId)>1
				Begin
					Select @strContainerXml=COALESCE(@strContainerXml, '') 
							+ '<E1EDL24 SEGMENT="1">'
							+ '<POSNR>'	 +	ISNULL(CONVERT(VARCHAR,c.intLoadContainerId),'') + '</POSNR>' 
							+ '<MATNR>'  +  ISNULL(@strItemNo,'') + '</MATNR>' 
							+ '<WERKS>'  +  ISNULL(@strSubLocation,'') + '</WERKS>' 
							+ '<LGORT>'  +  ISNULL(@strStorageLocation,'') + '</LGORT>' 
							+ '<CHARG>'  +  ISNULL(c.strContainerNumber,'') + '</CHARG>' 
							+ '<LFIMG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),c.dblQuantity)),'') + '</LFIMG>' 
							+ '<VRKME>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(um.strUnitMeasure,'')) + '</VRKME>' 
							+ '<HIPOS>'  +   ISNULL(@strDeliveryItemNo,'') + '</HIPOS>' 

							+ '<E1EDL19 SEGMENT="1">'
							+ '<QUALF>'  +  'BAS' + '<QUALF>' 
							+ '</E1EDL19>'

							--+ '<E1EDL41 SEGMENT="1">'
							--+ '<QUALI>'  +  '001' + '</QUALI>' 
							--+ '<BSTNR>'  +  ISNULL(@strPONo,'') + '</BSTNR>' 
							--+ '<POSEX>'  +  ISNULL(@strPOLineItemNo,'') + '</POSEX>' 
							--+ '</E1EDL41>'

							+ '</E1EDL24>'
					From tblLGLoadDetailContainerLink lc Join tblLGLoadDetail ld on lc.intLoadDetailId=ld.intLoadDetailId
					Join tblLGLoadContainer c on lc.intLoadContainerId=c.intLoadContainerId
					Join tblICUnitMeasure um on c.intUnitMeasureId=um.intUnitMeasureId
					Where ld.intLoadId=@intLoadId AND lc.intLoadDetailId=@intLoadDetailId

					Set @strItemXml += ISNULL(@strContainerXml,'')
				End
			End

			Set @strItemXml += '</E1EDL24>'

		Select @intMinDetail=Min(intRowNo) From @tblReceiptDetail Where intRowNo>@intMinDetail
	End --Loop Detail End

	--For Tea
	If UPPER(@strCommodityCode)='TEA'
	Begin
			Set @strContainerXml=''

			Delete From @tblContainer

			Insert Into @tblContainer(intLoadContainerId,strContainerNo,strContainerSizeCode)
			Select c.intLoadContainerId,c.strContainerNumber,''
			From tblLGLoadContainer c Join tblLGLoadDetailContainerLink l on c.intLoadContainerId=l.intLoadContainerId Where c.intLoadId=@intLoadId

			Select @intMinContainer=Min(intLoadContainerId) From @tblContainer

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
					+ '<VBELN>'  +  ISNULL(@strDeliveryItemNo,'') + '</VBELN>' 
					+ '<POSNR>'  +  ISNULL(ld.strExternalShipmentItemNumber,'') + '</POSNR>'
					+ '<VEMNG>'  +  ISNULL(LTRIM(CONVERT(NUMERIC(38,2),cl.dblQuantity)),'') + '</VEMNG>'
					+ '<VEMEH>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(um.strUnitMeasure,'')) + '</VEMEH>'
					+ '</E1EDL44>'			 
					From tblLGLoadDetailContainerLink cl Join tblLGLoadDetail ld on cl.intLoadDetailId=ld.intLoadDetailId
					Join tblICItemUOM iu on iu.intItemUOMId=cl.intItemUOMId
					Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
					Where intLoadContainerId=@intLoadContainerId

					Set @strContainerXml += ISNULL(@strContainerItemXml,'')
					Set @strContainerXml += '</E1EDL37>'

				Select @intMinContainer=Min(intLoadContainerId) From @tblContainer Where intLoadContainerId>@intMinContainer
			End --Loop Container End

	End

	--Final Xml
	Set @strXml += ISNULL(@strItemXml,'') + ISNULL(@strContainerXml,'')

	Set @strXml += '</E1EDL20>'

	Set @strXml += '</IDOC>'
	Set @strXml +=  '</DELVRY07>'

	Select @strReceiptDetailIds=COALESCE(CONVERT(VARCHAR,@strReceiptDetailIds) + ',', '') + intInventoryReceiptItemId From @tblReceiptDetail

	INSERT INTO @tblOutput(strReceiptDetailIds,strRowState,strXml)
	VALUES(@strReceiptDetailIds,'CREATE',@strXml)

	Select @intMinHeader=Min(intInventoryReceiptId) From @tblReceiptHeader Where intInventoryReceiptId>@intMinHeader
End

Select * From @tblOutput ORDER BY intRowNo