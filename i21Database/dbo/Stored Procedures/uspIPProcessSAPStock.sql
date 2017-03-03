CREATE PROCEDURE [dbo].[uspIPProcessSAPStock]
@strSessionId NVARCHAR(50)=''
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intMinRowNo int,
		@intItemId int,
		@intSubLocationId int,
		@strItemNo NVARCHAR(100),
		@strSubLocation NVARCHAR(100),
		@dblInspectionQuantity NUMERIC(38,20),
		@dblBlockedQuantity NUMERIC(38,20),
		@dblQuantity NUMERIC(38,20),
		@intLocationId int,
		@intEntityUserId int,
		@intSourceId int=1,
		@ErrMsg NVARCHAR(MAX),
		@intMinRowNo1 int,
		@strFinalErrMsg NVARCHAR(MAX)=''

DECLARE @tblStock TABLE (
[intRowNo] INT IDENTITY(1,1),
[strItemNo] NVARCHAR(100) ,
[strSubLocation] NVARCHAR(100) ,
[dblQuantity] NUMERIC(38,20),
[strSessionId] NVARCHAR(50)
)

Select @intLocationId=dbo.[fnIPGetSAPIDOCTagValue]('STOCK','LOCATION_ID')

If ISNULL(@strSessionId,'')=''
	Insert Into @tblStock(strItemNo,strSubLocation,dblQuantity,strSessionId)
	Select strItemNo,strSubLocation,SUM(ISNULL(dblQuantity,0)),strSessionId 
	From tblIPStockStage Group By strItemNo,strSubLocation,strSessionId
Else
	Insert Into @tblStock(strItemNo,strSubLocation,dblQuantity,strSessionId)
	Select strItemNo,strSubLocation,SUM(ISNULL(dblQuantity,0)),strSessionId 
	From tblIPStockStage 
	Where strSessionId=@strSessionId
	Group By strItemNo,strSubLocation,strSessionId

Select @intMinRowNo=Min(intRowNo) From @tblStock

While(@intMinRowNo is not null)
Begin
	BEGIN TRY
		Set @intItemId=NULL
		Set @intSubLocationId=NULL

		Select @strItemNo=strItemNo,@strSubLocation=strSubLocation,@dblQuantity=dblQuantity,@strSessionId=strSessionId
		From @tblStock Where intRowNo=@intMinRowNo

		Select @intItemId=intItemId From tblICItem Where strItemNo=@strItemNo
		Select @intSubLocationId=intCompanyLocationSubLocationId 
		From tblSMCompanyLocationSubLocation Where strSubLocationName=@strSubLocation AND intCompanyLocationId=@intLocationId

		Begin Tran

		Exec [uspICAdjustStockFromSAP]	 @dtmQtyChange			= NULL
										,@intItemId				= @intItemId
										,@strLotNumber			= 'FIFO'
										,@intLocationId			= @intLocationId
										,@intSubLocationId		= @intSubLocationId
										,@intStorageLocationId	= NULL
										,@intItemUOMId			= NULL
										,@dblNewQty				= @dblQuantity
										,@dblCost				= NULL 
										,@intEntityUserId		= @intEntityUserId
										,@intSourceId			= @intSourceId

		--Adjust Qty in SubLocation in other Location as 0
		Select @intMinRowNo1=MIN(intCompanyLocationId) From tblSMCompanyLocation Where intCompanyLocationId<>@intLocationId
		While (@intMinRowNo1 is not null)
		Begin
			Set @intSubLocationId=NULL

			Select @intSubLocationId=intCompanyLocationSubLocationId 
			From tblSMCompanyLocationSubLocation Where strSubLocationName=@strSubLocation AND intCompanyLocationId=@intMinRowNo1

			If EXISTS (Select 1 From tblICItemStock s Join tblICItemLocation il on s.intItemLocationId=il.intItemLocationId 
					Where s.intItemId=@intItemId AND il.intLocationId=@intMinRowNo1)
			Begin
				Exec [uspICAdjustStockFromSAP]	 @dtmQtyChange			= NULL
												,@intItemId				= @intItemId
												,@strLotNumber			= 'FIFO'
												,@intLocationId			= @intMinRowNo1
												,@intSubLocationId		= @intSubLocationId
												,@intStorageLocationId	= NULL
												,@intItemUOMId			= NULL
												,@dblNewQty				= 0
												,@dblCost				= NULL 
												,@intEntityUserId		= @intEntityUserId
												,@intSourceId			= @intSourceId			
			End

			Select @intMinRowNo1=MIN(intCompanyLocationId) From tblSMCompanyLocation Where intCompanyLocationId<>@intLocationId AND intCompanyLocationId>@intMinRowNo1
		End

		--Move to Archive
		Insert Into tblIPStockArchive(strItemNo,strSubLocation,strStockType,dblInspectionQuantity,dblBlockedQuantity,dblQuantity,strSessionId,strImportStatus,strErrorMessage)
		Select strItemNo,strSubLocation,strStockType,dblInspectionQuantity,dblBlockedQuantity,dblQuantity,strSessionId,'Success',''
		From tblIPStockStage Where strItemNo=@strItemNo AND strSubLocation=@strSubLocation AND strSessionId=@strSessionId

		Delete From tblIPStockStage Where strItemNo=@strItemNo AND strSubLocation=@strSubLocation AND strSessionId=@strSessionId

		Commit Tran
	END TRY
	BEGIN CATCH
		IF XACT_STATE() != 0
			AND @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		SET @ErrMsg = ERROR_MESSAGE()
		SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

		--Move to Error
		Insert Into tblIPStockError(strItemNo,strSubLocation,strStockType,dblInspectionQuantity,dblBlockedQuantity,dblQuantity,strSessionId,strImportStatus,strErrorMessage)
		Select strItemNo,strSubLocation,strStockType,dblInspectionQuantity,dblBlockedQuantity,dblQuantity,strSessionId,'Failed',@ErrMsg
		From tblIPStockStage Where strItemNo=@strItemNo AND strSubLocation=@strSubLocation AND strSessionId=@strSessionId

		Delete From tblIPStockStage Where strItemNo=@strItemNo AND strSubLocation=@strSubLocation AND strSessionId=@strSessionId
	END CATCH

	Select @intMinRowNo=Min(intRowNo) From @tblStock Where intRowNo>@intMinRowNo
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