CREATE PROCEDURE [dbo].[uspIPGenerateSAPAcknowledgementIDOC]
@strMsgType NVARCHAR(50)
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc INT
DECLARE @ErrMsg nvarchar(max)
DECLARE @strMesssageType NVARCHAR(50)
DECLARE @strStatus NVARCHAR(50)
DECLARE @strStatusDesc NVARCHAR(MAX)
DECLARE @strStatusType NVARCHAR(MAX)
DECLARE @strParamType NVARCHAR(100)
DECLARE @strParam NVARCHAR(100)
DECLARE @strRefNo NVARCHAR(100)
DECLARE @strTrackingNo NVARCHAR(100)
DECLARE @intMinRowNo INT
DECLARE @strXml NVARCHAR(MAX)
DECLARE @strIDOCHeader NVARCHAR(MAX)
DECLARE @strTableName NVARCHAR(100)
DECLARE @strColumnName NVARCHAR(100)
DECLARE @strStatusColumnName NVARCHAR(100)
DECLARE @intId INT
DECLARE @strPartnerNo NVARCHAR(100)

Declare @tblAcknowledgement AS TABLE
(
	intRowNo INT IDENTITY(1,1),
	intId INT,
	strMesssageType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStatusDesc NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strStatusType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strParamType NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strParam NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strTrackingNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strTableName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strColumnName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strStatusColumnName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strPartnerNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strIds NVARCHAR(MAX),
	strTableName NVARCHAR(100),
	strColumnName NVARCHAR(100),
	strStatusColumnName NVARCHAR(100),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
)

If @strMsgType='Item'
	Insert Into @tblAcknowledgement(intId,strMesssageType,strStatus,strStatusDesc,strStatusType,strParamType,strParam,strRefNo,strTrackingNo,strTableName,strColumnName,strStatusColumnName,strPartnerNo)
	SELECT intStageItemId,'MATMAS','53','Success','S','Material Number',strItemNo,strItemNo,'','tblIPItemArchive','intStageItemId','strImportStatus',''
	FROM tblIPItemArchive Where ISNULL(strImportStatus,'')<>'Ack Sent'
	UNION
	SELECT intStageItemId,'MATMAS','51',strErrorMessage,'E','Material Number',strItemNo,strItemNo,'','tblIPItemError','intStageItemId','strImportStatus',''
	FROM tblIPItemError Where ISNULL(strImportStatus,'')<>'Ack Sent'

If @strMsgType='Vendor'
	Insert Into @tblAcknowledgement(intId,strMesssageType,strStatus,strStatusDesc,strStatusType,strParamType,strParam,strRefNo,strTrackingNo,strTableName,strColumnName,strStatusColumnName,strPartnerNo)
	SELECT intStageEntityId,'CREMAS','53','Success','S','Vendor Number',strAccountNo,strAccountNo,'','tblIPEntityArchive','intStageEntityId','strImportStatus',''
	FROM tblIPEntityArchive Where strEntityType='Vendor' AND ISNULL(strImportStatus,'')<>'Ack Sent'
	UNION
	SELECT intStageEntityId,'CREMAS','51',strErrorMessage,'E','Vendor Number',strAccountNo,strAccountNo,'','tblIPEntityError','intStageEntityId','strImportStatus',''
	FROM tblIPEntityError Where strEntityType='Vendor' AND ISNULL(strImportStatus,'')<>'Ack Sent'

If @strMsgType='PreShipment Sample'
	Insert Into @tblAcknowledgement(intId,strMesssageType,strStatus,strStatusDesc,strStatusType,strParamType,strParam,strRefNo,strTrackingNo,strTableName,strColumnName,strStatusColumnName,strPartnerNo)
	SELECT  intStageSampleId,'QCERT','53','Success','S','Sample Number',strSampleNo,strPONo,strPOItemNo,'tblIPPreShipmentSampleArchive','intStageSampleId','strImportStatus',''
	FROM tblIPPreShipmentSampleArchive Where ISNULL(strImportStatus,'')<>'Ack Sent'
	UNION
	SELECT intStageSampleId,'QCERT','51',strErrorMessage,'E','Sample Number',strSampleNo,strPONo,strPOItemNo,'tblIPPreShipmentSampleError','intStageSampleId','strImportStatus',''
	FROM tblIPPreShipmentSampleError Where ISNULL(strImportStatus,'')<>'Ack Sent'

If @strMsgType='LSP Receipt'
	Insert Into @tblAcknowledgement(intId,strMesssageType,strStatus,strStatusDesc,strStatusType,strParamType,strParam,strRefNo,strTrackingNo,strTableName,strColumnName,strStatusColumnName,strPartnerNo)
	SELECT  intStageReceiptId,'WHSCON','53','Success','S','Goods Receipt Number',strDeliveryNo,strExternalRefNo,'','tblIPReceiptArchive','intStageReceiptId','strImportStatus',strPartnerNo
	FROM tblIPReceiptArchive Where ISNULL(strImportStatus,'')<>'Ack Sent'
	UNION
	SELECT  intStageReceiptId,'WHSCON','51','Success','E','Goods Receipt Number',strDeliveryNo,strExternalRefNo,'','tblIPReceiptError','intStageReceiptId','strImportStatus',strPartnerNo
	FROM tblIPReceiptError Where ISNULL(strImportStatus,'')<>'Ack Sent'

If @strMsgType='LSP ETA'
	Insert Into @tblAcknowledgement(intId,strMesssageType,strStatus,strStatusDesc,strStatusType,strParamType,strParam,strRefNo,strTrackingNo,strTableName,strColumnName,strStatusColumnName,strPartnerNo)
	SELECT  intStageShipmentETAId,'WHSCON','53','Success','S','Delivery Number',strDeliveryNo,strDeliveryNo,'','tblIPShipmentETAArchive','intStageShipmentETAId','strImportStatus',strPartnerNo
	FROM tblIPShipmentETAArchive Where ISNULL(strImportStatus,'')<>'Ack Sent'
	UNION
	SELECT  intStageShipmentETAId,'WHSCON','51','Success','E','Delivery Number',strDeliveryNo,strDeliveryNo,'','tblIPShipmentETAError','intStageShipmentETAId','strImportStatus',strPartnerNo
	FROM tblIPShipmentETAError Where ISNULL(strImportStatus,'')<>'Ack Sent'


Select @intMinRowNo=MIN(intRowNo) From @tblAcknowledgement

While(@intMinRowNo is not null) --Loop Start
Begin
	Select 
		@strMesssageType = strMesssageType,
		@strStatus = strStatus,
		@strStatusDesc = strStatusDesc,
		@strStatusType = strStatusType,
		@strParamType = strParamType,
		@strParam = strParam,
		@strRefNo = strRefNo,
		@strTrackingNo = strTrackingNo,
		@strTableName = strTableName,
		@strColumnName = strColumnName,
		@strStatusColumnName = strStatusColumnName,
		@intId = intId,
		@strPartnerNo = strPartnerNo
		From @tblAcknowledgement Where intRowNo=@intMinRowNo

		Set @strXml =  '<ZALEAUD01>'
		Set @strXml += '<IDOC BEGIN="1">'

		--IDOC Header
		If ISNULL(@strPartnerNo,'')=''
		Begin
			Select @strIDOCHeader=dbo.fnIPGetSAPIDOCHeader('ACKNOWLEDGEMENT')

			Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
			Set @strXml +=	@strIDOCHeader
			Set @strXml +=	'</EDI_DC40>'			
		End
		Else
		Begin
			Select @strIDOCHeader=dbo.fnIPGetSAPIDOCHeader('LSP ACKNOWLEDGEMENT')

			Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
			Set @strXml +=	@strIDOCHeader
			Set @strXml += '<RCVPRN>'	+ ISNULL(@strPartnerNo,'')	+ '</RCVPRN>'
			Set @strXml +=	'</EDI_DC40>'
		End

		Set @strXml += '<E1ADHDR SEGMENT="1">'
		Set @strXml += '<MESTYP>'		+ ISNULL(@strMesssageType,'')	+ '</MESTYP>'
		Set @strXml += '<MESTYP_LNG>'	+ ISNULL(@strMesssageType,'')	+ '</MESTYP_LNG>'

		Set @strXml += '<E1STATE SEGMENT="1">'
		Set @strXml += '<STATUS>'		+ ISNULL(@strStatus,'')	+ '</STATUS>'
		Set @strXml += '<STATXT>'		+ ISNULL(@strStatusDesc,'')	+ '</STATXT>'
		Set @strXml += '<STAPA1>'		+ ISNULL(@strParamType,'')	+ '</STAPA1>'
		Set @strXml += '<STAPA2>'		+ ISNULL(@strParam,'')	+ '</STAPA2>'
		Set @strXml += '<STATYP>'		+ ISNULL(@strStatusType,'')	+ '</STATYP>'
		Set @strXml += '<STAPA1_LNG>'	+ ISNULL(@strParamType,'')	+ '</STAPA1_LNG>'
		Set @strXml += '<STAPA2_LNG>'	+ ISNULL(@strParam,'')	+ '</STAPA2_LNG>'

		Set @strXml += '<E1PRTOB SEGMENT="1">'

		Set @strXml += '<Z1PRTOB SEGMENT="1">'
		Set @strXml += '<REF_1>'		+ ISNULL(@strRefNo,'')	+ '</REF_1>'
		Set @strXml += '<TRACKINGNO>'	+ ISNULL(@strTrackingNo,'')	+ '</TRACKINGNO>'
		Set @strXml += '</Z1PRTOB>'

		Set @strXml += '</E1PRTOB>'
		Set @strXml += '</E1STATE>'

		Set @strXml += '</E1ADHDR>'

		Set @strXml += '</IDOC>'
		Set @strXml +=  '</ZALEAUD01>'

		Insert Into @tblOutput(strIds,strTableName,strColumnName,strStatusColumnName,strRowState,strXml)
		Values(@intId,@strTableName,@strColumnName,@strStatusColumnName,'CREATE',@strXml)

	Select @intMinRowNo=MIN(intRowNo) From @tblAcknowledgement Where intRowNo>@intMinRowNo
End --Loop End

Select * from @tblOutput

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