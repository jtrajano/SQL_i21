CREATE PROCEDURE [dbo].[uspIPProcessSAPAcknowledgement]
	@strXml nvarchar(max),
	@strMessage nvarchar(max)='' OUT
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc INT
DECLARE @ErrMsg nvarchar(max)
DECLARE @strFinalMessage NVARCHAR(MAX)
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

EXEC sp_xml_preparedocument @idoc OUTPUT
,@strXml

Declare @tblAcknowledgement AS TABLE
(
	strRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTrackingNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strPOItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strLineItemBatchNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strDeliveryItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
)

	SELECT	 @strMesssageType=MESTYP_LNG
			,@strStatus=[STATUS]
			,@strStatusCode=STACOD
			,@strStatusDesc=STATXT
			,@strStatusType=STATYP
			,@strParam=STAPA2_LNG
	FROM OPENXML(@idoc, 'ZALEAUD01/IDOC/E1ADHDR/E1STATE', 2) WITH (
			 MESTYP_LNG NVARCHAR(50) '../../E1ADHDR/MESTYP_LNG'
			,[STATUS] NVARCHAR(50)
			,STACOD NVARCHAR(50)
			,STATXT NVARCHAR(50)
			,STATYP NVARCHAR(50)
			,STAPA2_LNG NVARCHAR(50))

	INSERT INTO @tblAcknowledgement (
		 strRefNo
		,strTrackingNo
		,strPOItemNo
		,strLineItemBatchNo
		,strDeliveryItemNo
		)
	SELECT REF_1
		,TRACKINGNO
		,PO_ITEM
		,CHARG
		,DEL_ITEM
	FROM OPENXML(@idoc, 'ZALEAUD01/IDOC/E1ADHDR/E1STATE/E1PRTOB/Z1PRTOB', 2) WITH (
			 REF_1 NVARCHAR(50)
			,TRACKINGNO NVARCHAR(50)
			,PO_ITEM NVARCHAR(50)
			,CHARG NVARCHAR(50)
			,DEL_ITEM  NVARCHAR(50))

	--PO Create
	If @strMesssageType='PORDCR1'
	Begin
		Select @intContractHeaderId=intContractHeaderId From tblCTContractHeader Where strContractNumber=(Select TOP 1 strRefNo From @tblAcknowledgement) AND intContractTypeId=1

		If @strStatus=51 --Success
		Begin
			Update tblCTContractDetail Set strERPPONumber=@strParam
			Where intContractHeaderId=@intContractHeaderId AND intContractSeq IN (Select strTrackingNo From @tblAcknowledgement)

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage='SUCCESS',strERPPONumber=@strParam
			Where intContractHeaderId=@intContractHeaderId AND intContractSeq IN (Select strTrackingNo From @tblAcknowledgement) 
		End

		If @strStatus=53 --Error
		Begin
			Set @strFinalMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage=@strFinalMessage
			Where intContractHeaderId=@intContractHeaderId AND intContractSeq IN (Select strTrackingNo From @tblAcknowledgement)

			SET @strMessage=@strFinalMessage
		End
	End

	--PO Update
	If @strMesssageType='PORDCH'
	Begin
		Select @intContractHeaderId=intContractHeaderId From tblCTContractHeader Where strContractNumber=(Select TOP 1 strRefNo From @tblAcknowledgement) AND intContractTypeId=1

		If @strStatus=51 --Success
		Begin
			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage='SUCCESS'
			Where intContractHeaderId=@intContractHeaderId AND intContractSeq IN (Select strTrackingNo From @tblAcknowledgement) 
		End

		If @strStatus=53 --Error
		Begin
			Set @strFinalMessage=@strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

			Update tblCTContractFeed Set strFeedStatus='Ack Rcvd',strMessage=@strFinalMessage
			Where intContractHeaderId=@intContractHeaderId AND intContractSeq IN (Select strTrackingNo From @tblAcknowledgement)

			SET @strMessage=@strFinalMessage
		End
	End

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