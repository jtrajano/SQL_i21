CREATE PROCEDURE [dbo].[uspIPProcessSAPStock]
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
		@dblQuantity NUMERIC(38,20),
		@strSessionId NVARCHAR(50),
		@intLocationId int,
		@intEntityUserId int,
		@intSourceId int=1,
		@ErrMsg NVARCHAR(MAX),
		@intMinRowNo1 int

DECLARE @tblStock TABLE (
[intRowNo] INT IDENTITY(1,1),
[strItemNo] NVARCHAR(100) ,
[strSubLocation] NVARCHAR(100) ,
[dblQuantity] NUMERIC(38,20),
[strSessionId] NVARCHAR(50)
)

Select @intLocationId=dbo.[fnIPGetSAPIDOCTagValue]('STOCK','LOCATION_ID')

Insert Into @tblStock(strItemNo,strSubLocation,dblQuantity,strSessionId)
Select strItemNo,strSubLocation,SUM(dblQuantity),strSessionId 
From tblIPStockStage Group By strItemNo,strSubLocation,strSessionId

Select @intMinRowNo=Min(intRowNo) From @tblStock

While(@intMinRowNo is not null)
Begin
	BEGIN TRY
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
			Select @intSubLocationId=intCompanyLocationSubLocationId 
			From tblSMCompanyLocationSubLocation Where strSubLocationName=@strSubLocation AND intCompanyLocationId=@intMinRowNo1

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

			Select @intMinRowNo1=MIN(intCompanyLocationId) From tblSMCompanyLocation Where intCompanyLocationId<>@intLocationId AND intCompanyLocationId>@intMinRowNo1
		End

		--Move to Archive
		Insert Into tblIPStockArchive(strItemNo,strSubLocation,strStockType,dblQuantity,strSessionId,strImportStatus,strErrorMessage)
		Select strItemNo,strSubLocation,strStockType,dblQuantity,strSessionId,'Success',''
		From tblIPStockStage Where strItemNo=@strItemNo AND strSubLocation=@strSubLocation AND strSessionId=@strSessionId

		Delete From tblIPStockStage Where strItemNo=@strItemNo AND strSubLocation=@strSubLocation AND strSessionId=@strSessionId

		Commit Tran
	END TRY
	BEGIN CATCH
		IF XACT_STATE() != 0
			AND @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		SET @ErrMsg = ERROR_MESSAGE()

		--Move to Error
		Insert Into tblIPStockError(strItemNo,strSubLocation,strStockType,dblQuantity,strSessionId,strImportStatus,strErrorMessage)
		Select strItemNo,strSubLocation,strStockType,dblQuantity,strSessionId,'Failed',@ErrMsg
		From tblIPStockStage Where strItemNo=@strItemNo AND strSubLocation=@strSubLocation AND strSessionId=@strSessionId

		Delete From tblIPStockStage Where strItemNo=@strItemNo AND strSubLocation=@strSubLocation AND strSessionId=@strSessionId
	END CATCH

	Select @intMinRowNo=Min(intRowNo) From @tblStock Where intRowNo>@intMinRowNo
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