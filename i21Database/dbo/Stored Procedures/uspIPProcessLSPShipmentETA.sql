CREATE PROCEDURE [dbo].[uspIPProcessLSPShipmentETA]
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
		@dtmETA DATETIME,
		@intLoadId INT,
		@strPartnerNo NVARCHAR(100),
		@intLoadStgId INT,
		@intNewLoadStgId INT,
		@dtmOldETA DATETIME,
		@strJson NVARCHAR(MAX),
		@intEntityId INT,
		@strGMT NVARCHAR(50)

Select @intMinRowNo=Min(intStageShipmentETAId) From tblIPShipmentETAStage

While(@intMinRowNo is not null)
Begin
	BEGIN TRY
		Set @intLoadId=NULL
		Set @intLoadStgId=NULL

		Select @strDeliveryNo=strDeliveryNo,@dtmETA=dtmETA,@strPartnerNo=strPartnerNo
		From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo

		Select @strDeliveryNo AS strInfo1,ISNULL(CONVERT(VARCHAR(10),@dtmETA,121),'') AS strInfo2

		If NOT EXISTS (Select 1 From tblIPLSPPartner Where strPartnerNo=@strPartnerNo)
			RaisError('Invalid LSP Partner',16,1)

		Select TOP 1 @intEntityId=[intEntityId] From tblAPVendor 
		Where strVendorAccountNum=(Select strWarehouseVendorAccNo From tblIPLSPPartner Where strPartnerNo=@strPartnerNo)

		If @dtmETA IS NULL
			RaisError('Invalid ETA',16,1)

		Select @intLoadId=intLoadId,@dtmOldETA=dtmETAPOD From tblLGLoad Where strExternalShipmentNumber=@strDeliveryNo AND intShipmentType=1
		If ISNULL(@intLoadId,0)=0
			RaisError('Invalid Delivery No',16,1)

		If ISNULL(CONVERT(VARCHAR(10),@dtmOldETA,112),'') = ISNULL(CONVERT(VARCHAR(10),@dtmETA,112),'')
			RaisError('No Change in ETA',16,1)

		Begin Tran

		Update tblLGLoad Set dtmETAPOD=@dtmETA,intConcurrencyId=intConcurrencyId+1 Where intLoadId=@intLoadId

		Insert Into tblLGETATracking(intLoadId,strTrackingType,dtmETAPOD,dtmModifiedOn)
		Values(@intLoadId,'ETA POD',@dtmETA,GETDATE()) 

		Set @strGMT = 'GMT' + CASE WHEN DATEDIFF(hh, GETUTCDATE(), GETDATE())>0 THEN '+' ELSE '-' END + CONVERT(varchar,ABS(DATEDIFF(hh, GETUTCDATE(), GETDATE())))

		--Add Audit Trail Record
		Set @strJson='{"action":"Updated","change":"Updated - Record: ' + CONVERT(VARCHAR,@intLoadId) + '","keyValue":' + CONVERT(VARCHAR,@intLoadId) + 
		',"iconCls":"small-tree-modified","children":[{"change":"dtmETAPOD","from":"' + case When @dtmOldETA IS NULL THEN '' ELSE  CONVERT(VARCHAR(10),@dtmOldETA,121) END  + ' ' + @strGMT + '","to":"' + CONVERT(VARCHAR(10),@dtmETA,121) + ' ' + @strGMT + '","leaf":true,"iconCls":"small-gear"}]}'

		Insert Into tblSMAuditLog(strActionType,strTransactionType,strRecordNo,strDescription,strRoute,strJsonData,dtmDate,intEntityId,intConcurrencyId)
		Values('Updated','Logistics.view.ShipmentSchedule',@intLoadId,'','',@strJson,GETUTCDATE(),@intEntityId,1)

		Select TOP 1 @intLoadStgId=intLoadStgId From tblLGLoadStg Where intLoadId=@intLoadId Order By intLoadStgId Desc

		--Write to Shipment Stg Tables so that ETA Update will send to SAP
		Insert Into tblLGLoadStg(intLoadId,strTransactionType,strLoadNumber,strShippingInstructionNumber,strContractBasis,strContractBasisDesc,strBillOfLading,strShippingLine,
				strShippingLineAccountNo,strExternalShipmentNumber,strDateQualifier,dtmScheduledDate,dtmETAPOD,dtmETAPOL,dtmETSPOL,dtmBLDate,strRowState,dtmFeedCreated)
		Select intLoadId,strTransactionType,strLoadNumber,strShippingInstructionNumber,strContractBasis,strContractBasisDesc,strBillOfLading,strShippingLine,
				strShippingLineAccountNo,strExternalShipmentNumber,strDateQualifier,dtmScheduledDate,@dtmETA,dtmETAPOL,dtmETSPOL,dtmBLDate,'Modified',GETDATE()
		From tblLGLoadStg Where intLoadStgId=@intLoadStgId

		Set @intNewLoadStgId=SCOPE_IDENTITY()

		Insert Into tblLGLoadDetailStg(intLoadStgId,intLoadId,intSIDetailId,intLoadDetailId,intRowNumber,strItemNo,strSubLocationName,strStorageLocationName,strBatchNumber,dblDeliveredQty,strUnitOfMeasure,
				dblNetWt,dblGrossWt,strWeightUOM,intHigherPositionRef,strDocumentCategory,strReferenceDataInfo,strSeq,strLoadNumber,strExternalPONumber,strExternalPOItemNumber,
				strExternalPOBatchNumber,strExternalShipmentItemNumber,strExternalBatchNo,strCommodityCode,strChangeType,strRowState,dtmFeedCreated)
		Select @intNewLoadStgId,intLoadId,intSIDetailId,intLoadDetailId,intRowNumber,strItemNo,strSubLocationName,strStorageLocationName,strBatchNumber,dblDeliveredQty,strUnitOfMeasure,
			dblNetWt,dblGrossWt,strWeightUOM,intHigherPositionRef,strDocumentCategory,strReferenceDataInfo,strSeq,strLoadNumber,strExternalPONumber,strExternalPOItemNumber,
			strExternalPOBatchNumber,strExternalShipmentItemNumber,strExternalBatchNo,strCommodityCode,strChangeType,'Modified',GETDATE()
			From tblLGLoadDetailStg Where intLoadStgId=@intLoadStgId

		Insert Into tblLGLoadContainerStg(intLoadStgId,intLoadId,intLoadContainerId,strContainerNo,strContainerSizeCode,strPackagingMaterialType,strExternalPONumber,strSeq,dblContainerQty,strContainerUOM,
					dblNetWt,dblGrossWt,strWeightUOM,strExternalContainerId,strRowState,dtmFeedCreated)
		Select @intNewLoadStgId,intLoadId,intLoadContainerId,strContainerNo,strContainerSizeCode,strPackagingMaterialType,strExternalPONumber,strSeq,dblContainerQty,strContainerUOM,
				dblNetWt,dblGrossWt,strWeightUOM,strExternalContainerId,'Modified',GETDATE()
				From tblLGLoadContainerStg Where intLoadStgId=@intLoadStgId

		--Move to Archive
		Insert Into tblIPShipmentETAArchive(strDeliveryNo,dtmETA,strPartnerNo,strImportStatus,strErrorMessage)
		Select strDeliveryNo,dtmETA,strPartnerNo,'Success',''
		From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo

		Delete From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo

		Commit Tran
	END TRY
	BEGIN CATCH
		IF XACT_STATE() != 0
			AND @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		SET @ErrMsg = ERROR_MESSAGE()

		--Move to Error
		Insert Into tblIPShipmentETAError(strDeliveryNo,dtmETA,strPartnerNo,strImportStatus,strErrorMessage)
		Select strDeliveryNo,dtmETA,strPartnerNo,'Failed',@ErrMsg
		From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo

		Delete From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo
	END CATCH

	Select @intMinRowNo=Min(intStageShipmentETAId) From tblIPShipmentETAStage Where intStageShipmentETAId>@intMinRowNo
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