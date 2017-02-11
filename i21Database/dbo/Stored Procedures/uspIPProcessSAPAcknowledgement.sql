CREATE PROCEDURE [dbo].[uspIPProcessSAPAcknowledgement]
	@strXml nvarchar(max)
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc INT
DECLARE @ErrMsg nvarchar(max)
DECLARE @strMessage NVARCHAR(MAX)
DECLARE @strMesssageType NVARCHAR(50)
DECLARE @strStatus NVARCHAR(50)
DECLARE @strStatusCode NVARCHAR(MAX)
DECLARE @strStatusDesc NVARCHAR(MAX)
DECLARE @strStatusType NVARCHAR(MAX)
DECLARE @strParam NVARCHAR(MAX)
DECLARE @strRefNo NVARCHAR(50)
DECLARE @strTrackingNo NVARCHAR(50)
DECLARE @strPOItemNo NVARCHAR(50)
DECLARE @strLineItemBatchNo NVARCHAR(50)
DECLARE @strDeliveryItemNo NVARCHAR(50)
DECLARE @intContractHeaderId INT
DECLARE @intMinRowNo INT
DECLARE @intLoadId INT
DECLARE @intReceiptId INT
DECLARE @strDeliveryType NVARCHAR(50)

Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

EXEC sp_xml_preparedocument @idoc OUTPUT
,@strXml

Declare @tblAcknowledgement AS TABLE
(
	intRowNo INT IDENTITY(1,1),
	strMesssageType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStatusCode NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStatusDesc NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strStatusType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strParam NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTrackingNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strPOItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strLineItemBatchNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strDeliveryItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strDeliveryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
)

Declare @tblMessage AS Table
(
	strMessageType NVARCHAR(50),
	strMessage	NVARCHAR(MAX)
)

	Insert Into @tblAcknowledgement(strMesssageType,strStatus,strStatusCode,strStatusDesc,strStatusType,
	strParam,strRefNo,strTrackingNo,strPOItemNo,strLineItemBatchNo,strDeliveryItemNo,strDeliveryType)
	SELECT 
	 MESTYP_LNG
	,[STATUS]
	,STACOD
	,STATXT
	,STATYP
	,STAPA2_LNG
	,REF_1
	,TRACKINGNO
	,PO_ITEM
	,CHARG
	,DEL_ITEM
	,Z1PA1
	FROM OPENXML(@idoc, 'ZALEAUD01/IDOC/E1ADHDR/E1STATE/E1PRTOB/Z1PRTOB', 2) WITH (
			 MESTYP_LNG NVARCHAR(50)	'../../../MESTYP_LNG'
			,[STATUS] NVARCHAR(50)		'../../STATUS'
			,STACOD NVARCHAR(50)		'../../STACOD'
			,STATXT NVARCHAR(50)		'../../STATXT'
			,STATYP NVARCHAR(50)		'../../STATYP'
			,STAPA2_LNG NVARCHAR(50)	'../../STAPA2_LNG'
			,REF_1 NVARCHAR(50)			
			,TRACKINGNO NVARCHAR(50)	
			,PO_ITEM NVARCHAR(50)		
			,CHARG NVARCHAR(50)			
			,DEL_ITEM  NVARCHAR(50)		
			,Z1PA1	NVARCHAR(50)
			)

Select @intMinRowNo=MIN(intRowNo) From @tblAcknowledgement

While(@intMinRowNo is not null) --Loop Start
Begin
	Select 
		@strMesssageType = strMesssageType,
		@strStatus = strStatus,
		@strStatusCode = strStatusCode,
		@strStatusDesc = strStatusDesc,
		@strStatusType = strStatusType,
		@strParam = strParam,
		@strRefNo = strRefNo,
		@strTrackingNo = strTrackingNo,
		@strPOItemNo = strPOItemNo,
		@strLineItemBatchNo = strLineItemBatchNo,
		@strDeliveryItemNo = strDeliveryItemNo,
		@strDeliveryType = strDeliveryType	
		From @tblAcknowledgement Where intRowNo=@intMinRowNo

	If @strMesssageType='WHSCON' AND ISNULL(@strDeliveryType,'')='U'
		Set @strMesssageType='DESADV'

	--PO Create
	If @strMesssageType='PORDCR1'
	Begin
		Select @intContractHeaderId=intContractHeaderId From tblCTContractHeader Where strContractNumber=@strRefNo AND intContractTypeId=1

		If @strStatus IN (52,53) --Success
		Begin
			Update tblCTContractDetail  Set strERPPONumber=@strParam,strERPItemNumber=@strPOItemNo,strERPBatchNumber=@strLineItemBatchNo 
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId=@strTrackingNo

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage='Success',strERPPONumber=@strParam,strERPItemNumber=@strPOItemNo,strERPBatchNumber=@strLineItemBatchNo
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND ISNULL(strFeedStatus,'')='Awt Ack'

			--update the PO Details in modified sequences
			Update tblCTContractFeed Set strERPPONumber=@strParam,strERPItemNumber=@strPOItemNo,strERPBatchNumber=@strLineItemBatchNo
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND ISNULL(strFeedStatus,'')=''

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,'Success')
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND ISNULL(strFeedStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,@strMessage)
		End
	End

	--PO Update
	If @strMesssageType='PORDCH'
	Begin
		Select @intContractHeaderId=intContractHeaderId From tblCTContractHeader Where strContractNumber=@strRefNo AND intContractTypeId=1

		If @strStatus IN (52,53) --Success
		Begin
			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage='Success'
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND strFeedStatus='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,'Success')
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND strFeedStatus='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,@strMessage)
		End
	End

	--Shipment
	If @strMesssageType='DESADV'
	Begin
		Select @intLoadId=intLoadId From tblLGLoad Where strLoadNumber=@strRefNo

		If Exists(Select 1 From tblLGLoad Where intLoadShippingInstructionId=@intLoadId)
			Select TOP 1 @intLoadId=intLoadId From tblLGLoad Where intLoadShippingInstructionId=@intLoadId

		If @strStatus IN (52,53) --Success
		Begin
			Update tblLGLoad  Set strExternalShipmentNumber=@strParam
			Where intLoadId=@intLoadId

			Update tblLGLoadDetail Set strExternalShipmentItemNumber=@strDeliveryItemNo Where intLoadDetailId=@strTrackingNo And intLoadId=@intLoadId

			Update tblLGLoadStg Set strFeedStatus='Ack Rcvd',strMessage='Success',strExternalShipmentNumber=@strParam
			Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='Awt Ack'

			Update tblLGLoadDetailStg Set strExternalShipmentItemNumber=@strDeliveryItemNo Where intLoadDetailId=@strTrackingNo AND intLoadId=@intLoadId

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,'Success')
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblLGLoadStg Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
			Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,@strMessage)
		End
	End

	--Receipt
	If @strMesssageType='WHSCON'
	Begin
		Select @intReceiptId=r.intInventoryReceiptId
		From tblICInventoryReceipt r 
		Where r.strReceiptNumber=@strRefNo

		If @strStatus IN (52,53) --Success
		Begin
			Update tblICInventoryReceiptItem  Set ysnExported=1 Where intInventoryReceiptId=@intReceiptId

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,'Success')
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,@strMessage)
		End
	End

	--Profit & Loss
	If @strMesssageType='ACC_DOCUMENT'
	Begin
		If @strStatus IN (52,53) --Success
		Begin
			Update tblRKStgMatchPnS Set strStatus='Ack Rcvd',strMessage='Success' Where intMatchNo=@strParam AND ISNULL(strStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,'Success')
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblRKStgMatchPnS Set strStatus='Ack Rcvd',strMessage=@strMessage Where intMatchNo=@strParam AND ISNULL(strStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,@strMessage)
		End
	End

	--LSP Shipment
	If @strMesssageType='SHPMNT'
	Begin
		Select @intLoadId=intLoadId From tblLGLoad Where strLoadNumber=@strRefNo

		If @strStatus IN (52,53) --Success
		Begin
			Update tblLGLoadLSPStg Set strFeedStatus='Ack Rcvd',strMessage='Success'
			Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,'Success')
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblLGLoadLSPStg Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
			Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,@strMessage)
		End
	End

	Select @intMinRowNo=MIN(intRowNo) From @tblAcknowledgement Where intRowNo>@intMinRowNo
End --Loop End

Select * from @tblMessage

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH