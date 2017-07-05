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
DECLARE @strParam1 NVARCHAR(MAX)
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
DECLARE @strPartnerNo NVARCHAR(100)
DECLARE @strContractSeq NVARCHAR(50)
DECLARE @intLoadStgId INT

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
	strParam1 NVARCHAR(50) COLLATE Latin1_General_CI_AS,
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
	strMessage	NVARCHAR(MAX),
	strInfo1 NVARCHAR(50),
	strInfo2 NVARCHAR(50)
)

	Select @strPartnerNo = RCVPRN 
	FROM OPENXML(@idoc, 'ZALEAUD01/IDOC/EDI_DC40', 2) WITH ( 
		RCVPRN NVARCHAR(100)
	)

	Insert Into @tblAcknowledgement(strMesssageType,strStatus,strStatusCode,strStatusDesc,strStatusType,
	strParam,strParam1,strRefNo,strTrackingNo,strPOItemNo,strLineItemBatchNo,strDeliveryItemNo,strDeliveryType)
	SELECT 
	 MESTYP_LNG
	,[STATUS]
	,STACOD
	,STATXT
	,STATYP
	,STAPA2_LNG
	,STAPA1_LNG
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
			,STAPA1_LNG NVARCHAR(50)	'../../STAPA1_LNG'
			,REF_1 NVARCHAR(50)			
			,TRACKINGNO NVARCHAR(50)	
			,PO_ITEM NVARCHAR(50)		
			,CHARG NVARCHAR(50)			
			,DEL_ITEM  NVARCHAR(50)		
			,Z1PA1	NVARCHAR(50)
			)

--delete records if tracking no is not a number
Delete From @tblAcknowledgement Where ISNUMERIC(strTrackingNo)=0 AND strMesssageType IN ('PORDCR1','PORDCH','DESADV')

Select @intMinRowNo=MIN(intRowNo) From @tblAcknowledgement

While(@intMinRowNo is not null) --Loop Start
Begin
	Set @strDeliveryType=''

	Select 
		@strMesssageType = strMesssageType,
		@strStatus = strStatus,
		@strStatusCode = ISNULL(strStatusCode,''),
		@strStatusDesc = ISNULL(strStatusDesc,''),
		@strStatusType = ISNULL(strStatusType,''),
		@strParam = strParam,
		@strParam1 = strParam1,
		@strRefNo = strRefNo,
		@strTrackingNo = strTrackingNo,
		@strPOItemNo = strPOItemNo,
		@strLineItemBatchNo = strLineItemBatchNo,
		@strDeliveryItemNo = strDeliveryItemNo,
		@strDeliveryType = strDeliveryType	
		From @tblAcknowledgement Where intRowNo=@intMinRowNo

	--PO Create
	If @strMesssageType='PORDCR1'
	Begin
		Select @intContractHeaderId=intContractHeaderId From tblCTContractHeader Where strContractNumber=@strRefNo AND intContractTypeId=1

		Select @strContractSeq=CONVERT(VARCHAR,intContractSeq) From tblCTContractDetail Where intContractDetailId=@strTrackingNo

		If @strStatus IN (52,53) --Success
		Begin
			If (Select ISNULL(strERPPONumber,'') from tblCTContractDetail Where intContractDetailId=@strTrackingNo)<>@strParam
			Begin
				Update tblCTContractDetail  Set strERPPONumber=@strParam,strERPItemNumber=@strPOItemNo,strERPBatchNumber=@strLineItemBatchNo,intConcurrencyId=intConcurrencyId+1 
				Where intContractHeaderId=@intContractHeaderId AND intContractDetailId=@strTrackingNo

				Update tblCTContractHeader Set intConcurrencyId=intConcurrencyId+1 Where intContractHeaderId=@intContractHeaderId
			End

			--For Added Contract
			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage='Success',strERPPONumber=@strParam,strERPItemNumber=@strPOItemNo,strERPBatchNumber=@strLineItemBatchNo
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND ISNULL(strFeedStatus,'') IN ('Awt Ack','Ack Rcvd')

			--update the PO Details in modified sequences
			Update tblCTContractFeed Set strERPPONumber=@strParam,strERPItemNumber=@strPOItemNo,strERPBatchNumber=@strLineItemBatchNo
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND ISNULL(strFeedStatus,'')=''

			--update po details in shipping instruction/advice staging table
			Update sld Set sld.strExternalPONumber=@strParam,sld.strExternalPOItemNumber=@strPOItemNo,sld.strExternalPOBatchNumber=@strLineItemBatchNo 
			From tblLGLoadDetailStg sld Join tblLGLoadDetail ld on sld.intLoadDetailId=ld.intLoadDetailId 
			Where ld.intPContractDetailId=@strTrackingNo

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,'Success',@strRefNo + ' / ' + ISNULL(@strContractSeq,''),@strParam)
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			--update the rowstate of next modified record to added if available
			Update tblCTContractFeed Set strRowState='Added'
			Where intContractFeedId = (Select TOP 1 intContractFeedId From tblCTContractFeed 
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND ISNULL(strFeedStatus,'')='' Order By intContractFeedId)

			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND ISNULL(strFeedStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,@strMessage,@strRefNo + ' / ' + ISNULL(@strContractSeq,''),@strParam)
		End
	End

	--PO Update
	If @strMesssageType='PORDCH'
	Begin
		Select @intContractHeaderId=intContractHeaderId From tblCTContractHeader Where strContractNumber=@strRefNo AND intContractTypeId=1

		Select @strContractSeq=CONVERT(VARCHAR,intContractSeq) From tblCTContractDetail Where intContractDetailId=@strTrackingNo

		If @strStatus IN (52,53) --Success
		Begin
			If (Select ISNULL(strERPPONumber,'') from tblCTContractDetail Where intContractDetailId=@strTrackingNo)<>@strParam
				Update tblCTContractDetail  Set strERPPONumber=@strParam,strERPItemNumber=@strPOItemNo,strERPBatchNumber=@strLineItemBatchNo,intConcurrencyId=intConcurrencyId+1 
				Where intContractHeaderId=@intContractHeaderId AND intContractDetailId=@strTrackingNo

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage='Success'
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND strFeedStatus IN ('Awt Ack','Ack Rcvd')

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,'Success',@strRefNo + ' / ' + ISNULL(@strContractSeq,''),@strParam)
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
			Where intContractHeaderId=@intContractHeaderId AND intContractDetailId = @strTrackingNo AND strFeedStatus='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,@strMessage,@strRefNo + ' / ' + ISNULL(@strContractSeq,''),@strParam)
		End
	End

	--Shipment Create
	If @strMesssageType='DESADV'
	Begin
		Select @intLoadId=intLoadId From tblLGLoad Where strLoadNumber=@strRefNo

		--Get Last sent StgId
		Select TOP 1 @intLoadStgId=intLoadStgId From tblLGLoadStg Where intLoadId=@intLoadId AND strFeedStatus='Awt Ack' Order By intLoadStgId Desc

		If @strStatus IN (52,53) --Success
			Begin
				If (Select ISNULL(strExternalShipmentNumber,'') from tblLGLoad Where intLoadId=@intLoadId)<>@strParam
				Begin
					Update tblLGLoadContainer Set ysnNewContainer=0, intConcurrencyId=intConcurrencyId+1 Where intLoadId=@intLoadId 
					AND Exists (Select 1 From tblLGLoadContainerStg Where intLoadStgId=@intLoadStgId) 

					Update tblLGLoad  Set strExternalShipmentNumber=@strParam,intConcurrencyId=intConcurrencyId+1
					Where intLoadId=@intLoadId

					Update tblLGLoadDetail Set strExternalShipmentItemNumber=@strDeliveryItemNo,intConcurrencyId=intConcurrencyId+1 Where intLoadDetailId=@strTrackingNo And intLoadId=@intLoadId
				End

				Update tblLGLoadStg Set strFeedStatus='Ack Rcvd',strMessage='Success',strExternalShipmentNumber=@strParam
				Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'') IN ('Awt Ack','Ack Rcvd')

				Update tblLGLoadDetailStg Set strExternalShipmentItemNumber=@strDeliveryItemNo Where intLoadDetailId=@strTrackingNo AND intLoadId=@intLoadId

				--update the delivery Details in modified loads both instruction and advice
				Update tblLGLoadStg Set strExternalShipmentNumber=@strParam Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')=''

				Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
				Values(@strMesssageType,'Success',@strRefNo,@strParam)
			End

		If @strStatus NOT IN (52,53) --Error
		Begin
			--update the rowstate of next modified record to added if available
			Update tblLGLoadStg Set strRowState='Added' 
			Where intLoadStgId = (Select TOP 1 intLoadStgId From tblLGLoadStg Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='' Order By intLoadStgId)

			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblLGLoadStg Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
			Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,@strMessage,@strRefNo,@strParam)
		End
	End

	--Shipment Delete
	If @strMesssageType='WHSCON' AND ISNULL(@strDeliveryType,'')=''
	Begin
		If @strRefNo like 'LSI-%' OR @strRefNo like 'LS-%'
			Set @strDeliveryType='U'
	End

	--Shipment Update
	If @strMesssageType='WHSCON' AND ISNULL(@strDeliveryType,'')='U'
	Begin
		If @strRefNo like 'IR-%'
		Begin
			Set @strDeliveryType='P'
			GOTO RECEIPT 
		End

		Set @strMesssageType='DESADV'

		Select @intLoadId=intLoadId From tblLGLoad Where strLoadNumber=@strRefNo

		--Check for Delete
		If ISNULL(@intLoadId,0)=0
			Select @intLoadId=intLoadId From tblLGLoadStg Where strLoadNumber=@strRefNo

		--Get Last sent StgId
		Select TOP 1 @intLoadStgId=intLoadStgId From tblLGLoadStg Where intLoadId=@intLoadId AND strFeedStatus='Awt Ack' Order By intLoadStgId Desc

		If @strStatus IN (52,53) --Success
		Begin
			DECLARE @tblContainerIdOutput table (intLoadContainerId int)

			Update tblLGLoadContainer Set ysnNewContainer=0, intConcurrencyId=intConcurrencyId+1 
			OUTPUT INSERTED.intLoadContainerId INTO @tblContainerIdOutput
			Where intLoadId=@intLoadId 
			AND Exists (Select 1 From tblLGLoadContainerStg Where intLoadStgId=@intLoadStgId) AND ysnNewContainer=1

			If Exists (Select TOP 1 1 From @tblContainerIdOutput)
				Update tblLGLoad Set intConcurrencyId=intConcurrencyId+1 Where intLoadId=@intLoadId

			Update tblLGLoadStg Set strFeedStatus='Ack Rcvd',strMessage='Success'
			Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'') IN ('Awt Ack','Ack Rcvd')

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,'Success',@strRefNo,@strParam1)
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblLGLoadStg Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
			Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,@strMessage,@strRefNo,@strParam)
		End
	End

	--Receipt
	RECEIPT:
	If @strMesssageType='WHSCON' AND ISNULL(@strDeliveryType,'')='P'
	Begin
		Select @intReceiptId=r.intInventoryReceiptId
		From tblICInventoryReceipt r 
		Where r.strReceiptNumber=@strRefNo

		If @strStatus IN (52,53) --Success
		Begin
			Update tblICInventoryReceiptItem  Set ysnExported=1 Where intInventoryReceiptId=@intReceiptId

			Update tblIPReceiptError Set strErrorMessage='Success' Where strExternalRefNo=@strRefNo AND strPartnerNo='i212SAP'

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,'Success',@strRefNo,@strParam)
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			--Log for sending mails
			If Exists (Select 1 From tblIPReceiptError Where strExternalRefNo=@strRefNo AND strPartnerNo='i212SAP')
				Update tblIPReceiptError Set strErrorMessage=@strMessage Where strExternalRefNo=@strRefNo AND strPartnerNo='i212SAP'
			Else
				Insert Into tblIPReceiptError(strExternalRefNo,strErrorMessage,strPartnerNo,strImportStatus)
				Values(@strRefNo,@strMessage,'i212SAP','Ack Sent')

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,@strMessage,@strRefNo,@strParam)
		End
	End

	--Receipt WMMBXY
	If @strMesssageType='WMMBXY'
	Begin
		Set @strMesssageType='WHSCON'

		Select @intReceiptId=r.intInventoryReceiptId
		From tblICInventoryReceipt r 
		Where r.strReceiptNumber=@strRefNo

		If @strStatus IN (52,53) --Success
		Begin
			Update tblICInventoryReceiptItem  Set ysnExported=1 Where intInventoryReceiptId=@intReceiptId

			Update tblIPReceiptError Set strErrorMessage='Success' Where strExternalRefNo=@strRefNo AND strPartnerNo='i212SAP'

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,'Success',@strRefNo,'')
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			--Log for sending mails
			If Exists (Select 1 From tblIPReceiptError Where strExternalRefNo=@strRefNo AND strPartnerNo='i212SAP')
				Update tblIPReceiptError Set strErrorMessage=@strMessage Where strExternalRefNo=@strRefNo AND strPartnerNo='i212SAP'
			Else
				Insert Into tblIPReceiptError(strExternalRefNo,strErrorMessage,strPartnerNo,strImportStatus)
				Values(@strRefNo,@strMessage,'i212SAP','Ack Sent')

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,@strMessage,@strRefNo,'')
		End
	End

	--Profit & Loss
	If @strMesssageType='ACC_DOCUMENT'
	Begin
		If @strStatus IN (52,53) --Success
		Begin
			Update tblRKStgMatchPnS Set strStatus='Ack Rcvd',strMessage='Success' Where intMatchNo=@strParam AND ISNULL(strStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,'Success',@strRefNo,@strParam)
		End

		If @strStatus NOT IN (52,53) --Error
		Begin
			Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblRKStgMatchPnS Set strStatus='Ack Rcvd',strMessage=@strMessage Where intMatchNo=@strParam AND ISNULL(strStatus,'')='Awt Ack'

			Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
			Values(@strMesssageType,@strMessage,@strRefNo,@strParam)
		End
	End

	--LSP Shipment
	If @strMesssageType='SHPMNT'
	Begin
		If EXISTS (Select 1 From tblIPLSPPartner Where strPartnerNo=@strPartnerNo)
		Begin
			Select @intLoadId=intLoadId From tblLGLoad Where strLoadNumber=@strRefNo

			If @strStatus IN (52,53) --Success
			Begin
				Update tblLGLoadLSPStg Set strFeedStatus='Ack Rcvd',strMessage='Success'
				Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='Awt Ack'

				Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
				Values(@strMesssageType,'Success',@strRefNo,@strParam)
			End

			If @strStatus NOT IN (52,53) --Error
			Begin
				Set @strMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				Update tblLGLoadLSPStg Set strFeedStatus='Ack Rcvd',strMessage=@strMessage
				Where intLoadId=@intLoadId AND ISNULL(strFeedStatus,'')='Awt Ack'

				Insert Into @tblMessage(strMessageType,strMessage,strInfo1,strInfo2)
				Values(@strMesssageType,@strMessage,@strRefNo,@strParam)
			End
		End
		Else
		Begin
			Insert Into @tblMessage(strMessageType,strMessage)
			Values(@strMesssageType,'Invalid LSP Partner')
		End	
	End

	Select @intMinRowNo=MIN(intRowNo) From @tblAcknowledgement Where intRowNo>@intMinRowNo
End --Loop End

Select strMessageType,strMessage,ISNULL(strInfo1,'') AS strInfo1,ISNULL(strInfo2,'') AS strInfo2 from @tblMessage

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