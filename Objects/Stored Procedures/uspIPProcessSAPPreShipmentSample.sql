CREATE PROCEDURE [dbo].[uspIPProcessSAPPreShipmentSample]
@strSessionId NVARCHAR(50)='',
@strInfo1 NVARCHAR(MAX)='' OUT,
@strInfo2 NVARCHAR(MAX)='' OUT
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intMinRowNo int,
		@dtmSampleDate DATETIME,
		@strPONo NVARCHAR(100),
		@strPOItemNo NVARCHAR(100),
		@strItemNo NVARCHAR(100),
		@dblQuantity NUMERIC(38,20),
		@strUOM NVARCHAR(50),
		@strSampleNo NVARCHAR(100),
		@strReferenceNo NVARCHAR(100),
		@strStatus NVARCHAR(50),
		@strLotNo NVARCHAR(100),
		@ErrMsg NVARCHAR(MAX),
		@intItemId int,
		@intContractDetailId int,
		@strXml NVARCHAR(MAX),
		@strSampleNoOut NVARCHAR(100),
		@intSampleId int,
		@strFinalErrMsg NVARCHAR(MAX)=''

If ISNULL(@strSessionId,'')=''
	Select @intMinRowNo=Min(intStageSampleId) From tblIPPreShipmentSampleStage
Else
	Select @intMinRowNo=Min(intStageSampleId) From tblIPPreShipmentSampleStage Where strSessionId=@strSessionId

While(@intMinRowNo is not null)
Begin
	BEGIN TRY
		Set @intItemId=NULL
		Set @intContractDetailId=NULL

		Select  @dtmSampleDate=dtmSampleDate,
				@strPONo=strPONo,
				@strPOItemNo=strPOItemNo,
				@strItemNo=strItemNo,
				@dblQuantity=dblQuantity,
				@strUOM=dbo.fnIPConvertSAPUOMToi21(strUOM),
				@strSampleNo=strSampleNo,
				@strReferenceNo=strReferenceNo,
				@strStatus=strStatus,
				@strLotNo=strLotNo
		From tblIPPreShipmentSampleStage Where intStageSampleId=@intMinRowNo

		Set @strInfo1=@strPONo
		Set @strInfo2=ISNULL(@strItemNo,'') + ' / ' +  ISNULL(@strSampleNo,'')

		Select @intItemId=intItemId From tblICItem Where strItemNo=@strItemNo
		Select @intContractDetailId=intContractDetailId 
		From tblCTContractDetail Where strERPPONumber=@strPONo AND intItemId=@intItemId

		If ISNULL(@intItemId,0)=0 RaisError('Item not found',16,1)
		If ISNULL(@intContractDetailId,0)=0 RaisError('Contract Sequence not found',16,1)

		Set @strXml = '<root>'
		Set @strXml += '<strSampleNumber>' + ISNULL(dbo.fnEscapeXML(@strSampleNo),'') + '</strSampleNumber>'
		Set @strXml += '<intContractDetailId>' + CONVERT(VARCHAR,@intContractDetailId) + '</intContractDetailId>'
		Set @strXml += '<dblRepresentingQty>' + CONVERT(VARCHAR,@dblQuantity) + '</dblRepresentingQty>'
		Set @strXml += '<strRepresentingUOM>' + ISNULL(dbo.fnEscapeXML(@strUOM),'') + '</strRepresentingUOM>'
		Set @strXml += '<strRefNo>' + ISNULL(dbo.fnEscapeXML(@strReferenceNo),'') + '</strRefNo>'
		Set @strXml += '<strSampleStatus>' + ISNULL(CASE WHEN @strStatus='ACC' THEN 'Approved' ELSE 'Rejected' END,'') + '</strSampleStatus>'
		Set @strXml += '<dtmSampleReceivedDate>' + ISNULL(CONVERT(VARCHAR(10),@dtmSampleDate,112),'') + '</dtmSampleReceivedDate>'
		Set @strXml += '<strSampleNote>' + ISNULL(dbo.fnEscapeXML(@strLotNo),'') + '</strSampleNote>'
		Set @strXml += '</root>'

		Begin Tran

		Exec uspQMSamplePreShipment @strXml,@strSampleNoOut OUT,@intSampleId OUT

		If Not Exists (Select 1 From tblQMSample Where intSampleId=@intSampleId) 
			RaisError('Sample not created',16,1)

		If ISNULL(@strSampleNo,'')<>'' AND Not Exists (Select 1 From tblQMSample Where strSampleNumber=@strSampleNo) 
			RaisError('Sample not created',16,1)

		--Move to Archive
		Insert Into tblIPPreShipmentSampleArchive(dtmSampleDate,strPONo,strPOItemNo,strItemNo,dblQuantity,strUOM,strSampleNo,strReferenceNo,strStatus,strLotNo,strImportStatus,strErrorMessage,strSessionId)
		Select dtmSampleDate,strPONo,strPOItemNo,strItemNo,dblQuantity,strUOM,strSampleNo,strReferenceNo,strStatus,strLotNo,'Success','',strSessionId
		From tblIPPreShipmentSampleStage Where intStageSampleId=@intMinRowNo

		Delete From tblIPPreShipmentSampleStage Where intStageSampleId=@intMinRowNo

		Commit Tran

	END TRY
	BEGIN CATCH
		IF XACT_STATE() != 0
			AND @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		SET @ErrMsg = ERROR_MESSAGE()
		SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

		--Move to Error
		Insert Into tblIPPreShipmentSampleError(dtmSampleDate,strPONo,strPOItemNo,strItemNo,dblQuantity,strUOM,strSampleNo,strReferenceNo,strStatus,strLotNo,strImportStatus,strErrorMessage,strSessionId)
		Select dtmSampleDate,strPONo,strPOItemNo,strItemNo,dblQuantity,strUOM,strSampleNo,strReferenceNo,strStatus,strLotNo,'Failed',@ErrMsg,strSessionId
		From tblIPPreShipmentSampleStage Where intStageSampleId=@intMinRowNo

		Delete From tblIPPreShipmentSampleStage Where intStageSampleId=@intMinRowNo
	END CATCH

	If ISNULL(@strSessionId,'')=''
		Select @intMinRowNo=Min(intStageSampleId) From tblIPPreShipmentSampleStage Where intStageSampleId>@intMinRowNo
	Else
		Select @intMinRowNo=Min(intStageSampleId) From tblIPPreShipmentSampleStage Where intStageSampleId>@intMinRowNo AND strSessionId=@strSessionId
End

If ISNULL(@strFinalErrMsg,'')<>'' RaisError(@strFinalErrMsg,16,1)

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