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
		@intLocationId INT,
		@intNewStageReceiptId INT,
		@strReceiptNo NVARCHAR(50),
		@intReceiptId INT,
		@strFinalErrMsg NVARCHAR(MAX)='',
		@intUserId INT,
		@strPartnerNo NVARCHAR(100),
		@intLoadId INT

Select @intLocationId=dbo.[fnIPGetSAPIDOCTagValue]('STOCK','LOCATION_ID')

Select @intMinRowNo=Min(intStageReceiptId) From tblIPReceiptStage

While(@intMinRowNo is not null)
Begin
	BEGIN TRY
		Set @intLoadId=NULL

		Select @strDeliveryNo=strDeliveryNo,@dtmReceiptDate=dtmReceiptDate,@strPartnerNo=strPartnerNo
		From tblIPReceiptStage Where intStageReceiptId=@intMinRowNo

		If NOT EXISTS (Select 1 From tblIPLSPPartner Where strPartnerNo=@strPartnerNo)
			RaisError('Invalid LSP Partner',16,1)

		If Not Exists (Select 1 From  tblLGLoad Where strExternalShipmentNumber=@strDeliveryNo)
			RaisError('Invalid Delivery No.',16,1)

		If Exists (Select 1 From tblSMUserSecurity Where strUserName='irelyadmin')
			Select TOP 1 @intUserId=intEntityUserSecurityId From tblSMUserSecurity Where strUserName='irelyadmin'
		Else
			Select TOP 1 @intUserId=intEntityUserSecurityId From tblSMUserSecurity

		Select @intLoadId=intLoadId From tblLGLoad Where strExternalShipmentNumber=@strDeliveryNo AND intShipmentType=1
		If ISNULL(@intLoadId,0)=0
			RaisError('Invalid Delivery No',16,1)

		Begin Tran

			EXEC dbo.uspSMGetStartingNumber 23, @strReceiptNo OUTPUT

			--Receipt
			If Exists (Select 1 From tblIPReceiptItemStage Where intStageReceiptId=@intMinRowNo AND ISNULL(dblQuantity,0)=0) --Batch Split
			Begin
				Insert into tblICInventoryReceipt(strReceiptType,intSourceType,intEntityVendorId,intLocationId,
				strReceiptNumber,dtmReceiptDate,intCurrencyId,intReceiverId,ysnPrepaid,ysnInvoicePaid,intShipFromId,strBillOfLading,intCreatedUserId,intEntityId)
				Select TOP 1 'Purchase Contract',2,ld.intVendorEntityId,@intLocationId,@strReceiptNo,
				@dtmReceiptDate,v.intCurrencyId,@intUserId,0,0,el.intEntityLocationId,l.strBLNumber,@intUserId,@intUserId
				From tblIPReceiptItemStage ri Join tblICItem i on ri.strItemNo=i.strItemNo
				Join tblLGLoadDetail ld on ld.intItemId=i.intItemId AND ld.strExternalShipmentItemNumber=ri.strDeliveryItemNo
				Join vyuAPVendor v on ld.intVendorEntityId=v.intEntityVendorId
				Join tblEMEntityLocation el on ld.intVendorEntityId=el.intEntityId
				Join tblLGLoad l on l.intLoadId=ld.intLoadId AND l.intLoadId=@intLoadId
				Where ri.intStageReceiptId=@intMinRowNo AND ISNULL(ri.dblQuantity,0)=0
			End
			Else
			Begin
				Insert into tblICInventoryReceipt(strReceiptType,intSourceType,intEntityVendorId,intLocationId,
				strReceiptNumber,dtmReceiptDate,intCurrencyId,intReceiverId,ysnPrepaid,ysnInvoicePaid,intShipFromId,strBillOfLading,intCreatedUserId,intEntityId)
				Select TOP 1 'Purchase Contract',2,ld.intVendorEntityId,@intLocationId,@strReceiptNo,
				@dtmReceiptDate,v.intCurrencyId,@intUserId,0,0,el.intEntityLocationId,l.strBLNumber,@intUserId,@intUserId
				From tblIPReceiptItemStage ri Join tblICItem i on ri.strItemNo=i.strItemNo
				Join tblLGLoadDetail ld on ld.intItemId=i.intItemId AND ld.strExternalShipmentItemNumber=ri.strDeliveryItemNo
				Join vyuAPVendor v on ld.intVendorEntityId=v.intEntityVendorId
				Join tblEMEntityLocation el on ld.intVendorEntityId=el.intEntityId
				Join tblLGLoad l on l.intLoadId=ld.intLoadId AND l.intLoadId=@intLoadId
				Where ri.intStageReceiptId=@intMinRowNo
			End
						 
			SET @intReceiptId = SCOPE_IDENTITY();

			--Receipt Items
			Insert into tblICInventoryReceiptItem (intInventoryReceiptId,intLineNo,intOrderId,intSourceId,
			intItemId,intContainerId,intSubLocationId,dblOrderQty,dblOpenReceive,intStorageLocationId,
			intUnitMeasureId,intWeightUOMId,dblUnitCost,dblGross,dblNet,intConcurrencyId,dblLineTotal,dblUnitRetail,intCostUOMId)
			Select @intReceiptId,ct.intContractDetailId,ct.intContractHeaderId,ld.intLoadDetailId,
			i.intItemId,cl.intLoadContainerId,csl.intCompanyLocationSubLocationId,cl.dblQuantity,cl.dblQuantity,sl.intStorageLocationId,
			cl.intItemUOMId,iu.intItemUOMId,ct.dblCashPrice,ri.dblQuantity,ri.dblQuantity,1,ri.dblQuantity * ct.dblCashPrice ,ct.dblCashPrice,ct.intPriceItemUOMId
			From tblIPReceiptItemStage ri Join tblICItem i on ri.strItemNo=i.strItemNo
			Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=@intLocationId
			Join tblICItemUOM iu on i.intItemId=iu.intItemId
			Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId AND um.strUnitMeasure=dbo.fnIPConvertSAPUOMToi21(ri.strUOM)
			Join tblLGLoadDetail ld on ld.intItemId=i.intItemId
			Join tblSMCompanyLocationSubLocation csl on ri.strSubLocation=csl.strSubLocationName AND csl.intCompanyLocationId=@intLocationId
			Join tblICStorageLocation sl on ri.strStorageLocation=sl.strName AND sl.intSubLocationId=csl.intCompanyLocationSubLocationId
			Join vyuAPVendor v on ld.intVendorEntityId=v.intEntityVendorId
			Join tblEMEntityLocation el on ld.intVendorEntityId=el.intEntityId
			Join tblCTContractDetail ct on ld.intPContractDetailId=ct.intContractDetailId
			Join tblLGLoad l on l.intLoadId=ld.intLoadId
			Join tblLGLoadDetailContainerLink cl on ld.intLoadDetailId=cl.intLoadDetailId AND cl.strExternalContainerId=ri.strDeliveryItemNo
			Where ri.intStageReceiptId=@intMinRowNo AND ri.dblQuantity>0 AND l.intLoadId=@intLoadId

			--Lots
			Insert into tblICInventoryReceiptItemLot (intInventoryReceiptItemId,strLotNumber,intSubLocationId,intStorageLocationId,dblQuantity,
			intItemUnitMeasureId,dblCost,dblGrossWeight,dblTareWeight,intConcurrencyId,strContainerNo)
			Select ri.intInventoryReceiptItemId,CASE WHEN UPPER(cd.strCommodityCode)='COFFEE' THEN c.strContainerNumber ELSE NULL END,
			ri.intSubLocationId,ri.intStorageLocationId,ri.dblOrderQty,
			ri.intUnitMeasureId,ri.dblUnitCost,ri.dblNet,0,1,c.strContainerNumber
			From tblICInventoryReceiptItem ri 
			Join tblLGLoadContainer c on ri.intContainerId=c.intLoadContainerId
			Join tblICItem i on ri.intItemId=i.intItemId
			JOin tblICCommodity cd on cd.intCommodityId=i.intCommodityId
			Where ri.intInventoryReceiptId=@intReceiptId

			--Post Receipt
			Exec dbo.uspICPostInventoryReceipt 1,0,@strReceiptNo,@intUserId
											 	
		--Move to Archive
		Insert Into tblIPReceiptArchive(strDeliveryNo,strExternalRefNo,dtmReceiptDate,strPartnerNo,strImportStatus,strErrorMessage)
		Select strDeliveryNo,strExternalRefNo,dtmReceiptDate,strPartnerNo,'Success',''
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
		SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

		----Move to Error
		Insert Into tblIPReceiptError(strDeliveryNo,strExternalRefNo,dtmReceiptDate,strPartnerNo,strImportStatus,strErrorMessage)
		Select strDeliveryNo,strExternalRefNo,dtmReceiptDate,strPartnerNo,'Failed',@ErrMsg
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