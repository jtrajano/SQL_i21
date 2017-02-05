CREATE PROCEDURE [dbo].[uspIPProcessLSPReceipt]
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intMinRowNo int,
		@ErrMsg NVARCHAR(MAX),
		@strDeliveryNo NVARCHAR(50),
		@dtmReceiptDate DATETIME,
		@intLoadId INT,
		@intLocationId INT,
		@intNewStageReceiptId INT,
		@strReceiptNo NVARCHAR(50),
		@intReceiptId INT

Declare @ReceiptEntries AS ReceiptStagingTable
Declare @LotEntries AS ReceiptItemLotStagingTable

Select @intLocationId=dbo.[fnIPGetSAPIDOCTagValue]('STOCK','LOCATION_ID')

Select @intMinRowNo=Min(intStageReceiptId) From tblIPReceiptStage

While(@intMinRowNo is not null)
Begin
	BEGIN TRY
		Select @strDeliveryNo=strDeliveryNo,@dtmReceiptDate=dtmReceiptDate
		From tblIPReceiptStage Where intStageReceiptId=@intMinRowNo

		Select @intLoadId=intLoadId From tblLGLoad Where strExternalShipmentNumber=@strDeliveryNo

		Begin Tran

		--Receipt Items
		Insert Into @ReceiptEntries(strReceiptType,intSourceType,intEntityVendorId,intLocationId,dtmDate,intCurrencyId,intShipFromId,
					intItemId,intItemLocationId,intItemUOMId,dblQty,intSubLocationId,intStorageLocationId)
			Select 'Purchase Contract',2,ld.intVendorEntityId,@intLocationId,@dtmReceiptDate,null,null,
			i.intItemId,il.intItemLocationId,iu.intItemUOMId,ri.dblQuantity,csl.intCompanyLocationSubLocationId,sl.intStorageLocationId
			From tblIPReceiptItemStage ri Join tblICItem i on ri.strItemNo=i.strItemNo
			Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=@intLocationId
			Join tblICItemUOM iu on i.intItemId=iu.intItemId
			Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId AND um.strUnitMeasure=ri.strUOM
			Join tblLGLoadDetail ld on ld.intItemId=i.intItemId
			Join tblSMCompanyLocationSubLocation csl on ri.strSubLocation=csl.strSubLocationName AND csl.intCompanyLocationId=@intLocationId
			Join tblICStorageLocation sl on ri.strStorageLocation=sl.strName AND sl.intSubLocationId=csl.intCompanyLocationSubLocationId
			Where ri.intStageReceiptId=@intMinRowNo AND ISNULL(ri.strHigherPositionRefNo,'')=''

		--Lots
		Insert Into @LotEntries(strReceiptType,intSourceType,intEntityVendorId,intLocationId,intCurrencyId,intShipFromId,
					intItemId,intSubLocationId,intStorageLocationId,
					intItemUnitMeasureId,dblQuantity)
		Select strReceiptType,intSourceType,intEntityVendorId,intLocationId,intCurrencyId,intShipFromId,
					intItemId,intSubLocationId,intStorageLocationId,
					intItemUOMId,dblQty
			From @ReceiptEntries

			--Create Receipt
			Exec [uspICAddItemReceipt]	 @ReceiptEntries	= @ReceiptEntries
										,@OtherCharges		= NULL
										,@intUserId			= NULL
										,@LotEntries		= @LotEntries

			IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
			Begin
				Select @intReceiptId=intInventoryReceiptId From #tmpAddItemReceiptResult
				Select @strReceiptNo=strReceiptNumber From tblICInventoryReceipt Where intInventoryReceiptId=@intReceiptId
			End

			--Post Receipt
			Exec [uspICPostInventoryReceipt]  @ysnPost					= 1
											 ,@ysnRecap					= 0
											 ,@strTransactionId			= @strReceiptNo
											 ,@intEntityUserSecurityId	= NULL
											 	
		--Move to Archive
		Insert Into tblIPReceiptArchive(strDeliveryNo,dtmReceiptDate,strImportStatus,strErrorMessage)
		Select strDeliveryNo,dtmReceiptDate,'Success',''
		From tblIPReceiptStage Where intStageReceiptId=@intMinRowNo

		Select @intNewStageReceiptId=SCOPE_IDENTITY()

		Insert Into tblIPReceiptItemArchive(intStageReceiptId,strDeliveryItemNo,strItemNo,strSubLocation,strStorageLocation,strBatchNo,dblQuantity,strUOM,strHigherPositionRefNo)
		Select @intNewStageReceiptId,strDeliveryItemNo,strItemNo,strSubLocation,strStorageLocation,strBatchNo,dblQuantity,strUOM,strHigherPositionRefNo
		From tblIPReceiptItemStage Where intStageReceiptId=@intMinRowNo

		Insert Into tblIPReceiptItemContainerArchive(intStageReceiptId,strContainerNo,strContainerSize,strDeliveryNo,strDeliveryItemNo,dblQuantity,strUOM)
		Select @intNewStageReceiptId,strContainerNo,strContainerSize,strDeliveryNo,strDeliveryItemNo,dblQuantity,strUOM
		From tblIPReceiptItemContainerStage Where intStageReceiptId=@intMinRowNo

		Delete From tblIPReceiptStage Where intStageReceiptId=@intMinRowNo

		Commit Tran
	END TRY
	BEGIN CATCH
		IF XACT_STATE() != 0
			AND @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		SET @ErrMsg = ERROR_MESSAGE()

		----Move to Error
		Insert Into tblIPReceiptError(strDeliveryNo,dtmReceiptDate,strImportStatus,strErrorMessage)
		Select strDeliveryNo,dtmReceiptDate,'Failed',@ErrMsg
		From tblIPReceiptStage Where intStageReceiptId=@intMinRowNo

		Select @intNewStageReceiptId=SCOPE_IDENTITY()

		Insert Into tblIPReceiptItemError(intStageReceiptId,strDeliveryItemNo,strItemNo,strSubLocation,strStorageLocation,strBatchNo,dblQuantity,strUOM,strHigherPositionRefNo)
		Select @intNewStageReceiptId,strDeliveryItemNo,strItemNo,strSubLocation,strStorageLocation,strBatchNo,dblQuantity,strUOM,strHigherPositionRefNo
		From tblIPReceiptItemStage Where intStageReceiptId=@intMinRowNo

		Insert Into tblIPReceiptItemContainerError(intStageReceiptId,strContainerNo,strContainerSize,strDeliveryNo,strDeliveryItemNo,dblQuantity,strUOM)
		Select @intNewStageReceiptId,strContainerNo,strContainerSize,strDeliveryNo,strDeliveryItemNo,dblQuantity,strUOM
		From tblIPReceiptItemContainerStage Where intStageReceiptId=@intMinRowNo

		Delete From tblIPReceiptStage Where intStageReceiptId=@intMinRowNo
	END CATCH

	Select @intMinRowNo=Min(intStageReceiptId) From tblIPReceiptStage Where intStageReceiptId>@intMinRowNo
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