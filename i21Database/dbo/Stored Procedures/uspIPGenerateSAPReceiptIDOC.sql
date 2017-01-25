CREATE PROCEDURE [dbo].[uspIPGenerateSAPReceiptIDOC]
AS

Declare @intMinHeader				INT,
		@strCommodityCode			NVARCHAR(100) ,
		@strSAPDeliveryNo			NVARCHAR(100) ,
		@dtmReceiptDate				DATETIME ,
		@ysnBatchSplit				BIT,
		@strXml						NVARCHAR(MAX),
		@strReceiptIDOCHeader		NVARCHAR(MAX),
		@strReceiptDetailIds		NVARCHAR(MAX),
		@strItemXml					NVARCHAR(MAX)

Declare @tblReceiptHeader AS Table
(
	intReceiptHeaderId INT,
	strDeliveryNo NVARCHAR(100),
	dtmReceiptDate DATETIME
)

Declare @tblReceiptDetail AS Table
(
	intReceiptHeaderId INT,
	intReceiptDetailId INT,
	strDeliveryItemNo NVARCHAR(100),
	strDeliverySubItemNo NVARCHAR(100),
	strItemNo NVARCHAR(100),
	strSubLocation NVARCHAR(50),
	strStorageLocation NVARCHAR(50),
	strContainerNo NVARCHAR(50),
	dblQuantity NUMERIC(38,20),
	strUOM NVARCHAR(50),
	strCommodityCode NVARCHAR(50)
)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strReceiptDetailIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
)

Select @strReceiptIDOCHeader=dbo.fnIPGetSAPIDOCHeader('RECEIPT')

Insert Into @tblReceiptHeader(intReceiptHeaderId,strDeliveryNo,dtmReceiptDate)
Select DISTINCT r.intInventoryReceiptId,l.strExternalLoadNumber,r.dtmReceiptDate
From tblICInventoryReceiptItem ri 
Join tblICInventoryReceipt r on ri.intInventoryReceiptId=r.intInventoryReceiptId
JOIN vyuLGLoadContainerPurchaseContracts s ON s.intPContractDetailId = ri.intLineNo
JOIN tblLGLoad l on s.intLoadId=l.intLoadId
Where r.intSourceType=2 AND r.ysnPosted=1 AND ri.ysnExported IS NULL

Select @intMinHeader=Min(intReceiptHeaderId) From @tblReceiptHeader

While(@intMinHeader is not null)
Begin
	Select @strSAPDeliveryNo=strDeliveryNo,@dtmReceiptDate=dtmReceiptDate 
	From @tblReceiptHeader Where intReceiptHeaderId=@intMinHeader

	--Get the Details
	Delete From @tblReceiptDetail

	Insert Into @tblReceiptDetail(intReceiptHeaderId,intReceiptDetailId,strDeliveryItemNo,strItemNo,strSubLocation,strStorageLocation,strContainerNo,dblQuantity,strUOM,strCommodityCode)
	Select ri.intInventoryReceiptId,ri.intInventoryReceiptItemId,s.strItemNo,s.strItemNo,s.strSubLocationName,sl.strName,s.strContainerNumber,s.dblQuantity,s.strUnitMeasure,c.strCommodityCode
	From tblICInventoryReceiptItem ri 
	Join tblICInventoryReceipt r on ri.intInventoryReceiptId=r.intInventoryReceiptId
	JOIN vyuLGLoadContainerPurchaseContracts s ON s.intPContractDetailId = ri.intLineNo
	JOIN tblLGLoad l on s.intLoadId=l.intLoadId
	Left Join tblICStorageLocation sl on ri.intStorageLocationId=sl.intStorageLocationId
	JOIN tblICCommodity c on s.intCommodityId=c.intCommodityId
	Where r.intInventoryReceiptId=@intMinHeader AND r.intSourceType=2 AND r.ysnPosted=1 AND ri.ysnExported IS NULL

	Select TOP 1 @strCommodityCode=strCommodityCode From @tblReceiptDetail 

	--Coffee Multiple Container/Batch Split
	If Exists (Select 1 From @tblReceiptDetail Group By strItemNo Having COUNT(strContainerNo)>1)
	Begin
		Set @ysnBatchSplit=1

		update d Set d.strDeliverySubItemNo=t.strDeliverySubItemNo
		From @tblReceiptDetail d Join 
		(Select strItemNo,strContainerNo,90000 + (ROW_NUMBER() OVER(PARTITION BY strItemNo ORDER BY strContainerNo ASC)) strDeliverySubItemNo From @tblReceiptDetail) t 
		on d.strItemNo=t.strItemNo AND d.strContainerNo=t.strContainerNo
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

	--Item Details
	Set @strItemXml=''
	If ISNULL(@ysnBatchSplit,0)=0
	Begin
		Select @strItemXml=COALESCE(@strItemXml, '') 
			+ '<E1EDL24 SEGMENT="1">'
			+ '<POSNR>' + ISNULL(strDeliveryItemNo,'') + '</POSNR>' 
			+ '<MATNR>'  +  ISNULL(strItemNo,'') + '</MATNR>' 
			+ '<WERKS>'  +  ISNULL(strSubLocation,'') + '</WERKS>' 
			+ '<LGORT>'  +  ISNULL(strStorageLocation,'') + '</LGORT>' 
			+ '<CHARG>'  +  ISNULL(strContainerNo,'') + '</CHARG>' 
			+ '<LFIMG>'  +  ISNULL(CONVERT(VARCHAR,dblQuantity),'') + '</LFIMG>' 
			+ '<VRKME>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(strUOM,'')) + '</VRKME>' 
			+ '</E1EDL24>'
		From @tblReceiptDetail
	End

	If ISNULL(@ysnBatchSplit,0)=1
	Begin
		Select @strItemXml=COALESCE(@strItemXml, '') 
			+ '<E1EDL24 SEGMENT="1">'
			+ '<POSNR>' + ISNULL(strDeliverySubItemNo,'') + '</POSNR>' 
			+ '<HIPOS>' + ISNULL(strDeliveryItemNo,'') + '</HIPOS>' 
			+ '<MATNR>'  +  ISNULL(strItemNo,'') + '</MATNR>' 
			+ '<WERKS>'  +  ISNULL(strSubLocation,'') + '</WERKS>' 
			+ '<LGORT>'  +  ISNULL(strStorageLocation,'') + '</LGORT>' 
			+ '<CHARG>'  +  ISNULL(strContainerNo,'') + '</CHARG>' 
			+ '<LFIMG>'  +  ISNULL(CONVERT(VARCHAR,dblQuantity),'') + '</LFIMG>' 
			+ '<VRKME>'  +  dbo.fnIPConverti21UOMToSAP(ISNULL(strUOM,'')) + '</VRKME>' 
			+ '</E1EDL24>'
		From @tblReceiptDetail
	End

	Set @strXml += @strItemXml

	--For Tea
	If @strCommodityCode='TEA'
	Begin
			Set @strItemXml=''
			Select @strItemXml=COALESCE(@strItemXml, '') 
			+ '<E1EDL37 SEGMENT="1">'
			+ '<EXIDV>'  +  ISNULL(strContainerNo,'') + '</EXIDV>' 
			+ '<VHILM>'  +  '' + '</VHILM>' 
			+ '<VHART>'  +  '0002' + '</VHART>'
			+ '</E1EDL37>'			 
			From
		(Select DISTINCT strContainerNo From @tblReceiptDetail) t
	End

	Set @strXml += '</E1EDL20>'

	Set @strXml += '</IDOC>'
	Set @strXml +=  '</DELVRY07>'

	Select @strReceiptDetailIds=COALESCE(CONVERT(VARCHAR,@strReceiptDetailIds) + ',', '') + intReceiptDetailId From @tblReceiptDetail

	INSERT INTO @tblOutput(strReceiptDetailIds,strRowState,strXml)
	VALUES(@strReceiptDetailIds,'CREATE',@strXml)

	Select @intMinHeader=Min(intReceiptHeaderId) From @tblReceiptHeader Where intReceiptHeaderId>@intMinHeader
End

Select * From @tblOutput ORDER BY intRowNo