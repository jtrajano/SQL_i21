﻿CREATE PROCEDURE [dbo].[uspIPProcessLSPShipmentETA]
@strSessionId NVARCHAR(50)='',
@strInfo1 NVARCHAR(MAX)='' OUT,
@strInfo2 NVARCHAR(MAX)='' OUT,
@intNoOfRowsAffected INT=0 OUT
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
		@strGMT NVARCHAR(50),
		@strLoadNumber NVARCHAR(100),
		@strFinalErrMsg NVARCHAR(MAX)=''

DECLARE @tblLoadDetail TABLE (
	intDetailRecordId INT IDENTITY(1, 1)
	,intContractDetailId INT
	,intContractHeaderId INT
	)

DECLARE @intMinLoadDetailRecordId INT
DECLARE @intContractDetailId INT
DECLARE @intContractHeaderId INT
DECLARE @intApprovedById INT
DECLARE @dtmCalculatedAvailabilityDate DATETIME
	,@intLeadTime INT

If ISNULL(@strSessionId,'')=''
	Select @intMinRowNo=Min(intStageShipmentETAId) From tblIPShipmentETAStage
Else
	Select @intMinRowNo=Min(intStageShipmentETAId) From tblIPShipmentETAStage Where intStageShipmentETAId=@strSessionId

While(@intMinRowNo is not null)
Begin
	BEGIN TRY
		Set @intNoOfRowsAffected=1
		Set @intLoadId=NULL
		Set @intLoadStgId=NULL

		SELECT @dtmCalculatedAvailabilityDate = NULL
			,@intLeadTime = NULL

		Select @strDeliveryNo=strDeliveryNo,@dtmETA=dtmETA,@strPartnerNo=strPartnerNo
		From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo

		Select @strLoadNumber=strLoadNumber From tblLGLoad Where strExternalShipmentNumber=@strDeliveryNo AND intShipmentType=1

		Set @strInfo1=ISNULL(@strDeliveryNo,'') + ' / ' + ISNULL(@strLoadNumber,'')
		Set @strInfo2=ISNULL(CONVERT(VARCHAR(10),@dtmETA,121),'')

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

		SELECT @intLeadTime = ISNULL(DPort.intLeadTime, 0)
		FROM tblLGLoad L
		OUTER APPLY (SELECT TOP 1 intLeadTime FROM tblSMCity DPort 
					WHERE DPort.strCity = L.strDestinationPort AND DPort.ysnPort = 1) DPort
		WHERE L.intLoadId = @intLoadId
		
		SELECT @dtmCalculatedAvailabilityDate = DATEADD(DD, ISNULL(@intLeadTime, 0), @dtmETA)

		Begin Tran

		Update tblLGLoad Set dtmETAPOD=@dtmETA,dtmETAPOD1=@dtmETA,dtmPlannedAvailabilityDate=@dtmCalculatedAvailabilityDate,intConcurrencyId=intConcurrencyId+1 Where intLoadId=@intLoadId

		-- Set planned availability date and send a feed to SAP
		DELETE
		FROM @tblLoadDetail

		INSERT INTO @tblLoadDetail (
			intContractDetailId
			,intContractHeaderId
			)
		SELECT CD.intContractDetailId
			,CD.intContractHeaderId
		FROM tblCTContractDetail CD
		JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
			AND LD.intLoadId = @intLoadId
			AND CD.dtmPlannedAvailabilityDate <> @dtmCalculatedAvailabilityDate

		SELECT @intMinLoadDetailRecordId = MIN(intDetailRecordId)
		FROM @tblLoadDetail

		WHILE (ISNULL(@intMinLoadDetailRecordId, 0) > 0)
		BEGIN
			SET @intContractDetailId = NULL
			SET @intContractHeaderId = NULL
			SET @intApprovedById = NULL

			SELECT @intContractDetailId = intContractDetailId
				,@intContractHeaderId = intContractHeaderId
			FROM @tblLoadDetail
			WHERE intDetailRecordId = @intMinLoadDetailRecordId

			SELECT TOP 1 @intApprovedById = intApprovedById
			FROM tblCTApprovedContract
			WHERE intContractDetailId = @intContractDetailId
			ORDER BY intApprovedContractId DESC

			UPDATE tblCTContractDetail
			SET dtmPlannedAvailabilityDate = @dtmCalculatedAvailabilityDate
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intContractDetailId = @intContractDetailId

			EXEC uspCTContractApproved @intContractHeaderId = @intContractHeaderId
				,@intApprovedById = @intApprovedById
				,@intContractDetailId = @intContractDetailId

			SELECT @intMinLoadDetailRecordId = MIN(intDetailRecordId)
			FROM @tblLoadDetail
			WHERE intDetailRecordId > @intMinLoadDetailRecordId
		END

		Insert Into tblLGETATracking(intLoadId,strTrackingType,dtmETAPOD,dtmModifiedOn)
		Values(@intLoadId,'ETA POD',@dtmETA,GETDATE()) 

		Set @strGMT = 'GMT' + CASE WHEN DATEDIFF(hh, GETUTCDATE(), GETDATE())>0 THEN '+' ELSE '-' END + CONVERT(varchar,ABS(DATEDIFF(hh, GETUTCDATE(), GETDATE())))

		--Add Audit Trail Record
		--Set @strJson='{"action":"Updated","change":"Updated - Record: ' + CONVERT(VARCHAR,@intLoadId) + '","keyValue":' + CONVERT(VARCHAR,@intLoadId) + 
		--',"iconCls":"small-tree-modified","children":[{"change":"dtmETAPOD","from":"' + case When @dtmOldETA IS NULL THEN '' ELSE  CONVERT(VARCHAR(10),@dtmOldETA,121) END  + ' ' + @strGMT + '","to":"' + CONVERT(VARCHAR(10),@dtmETA,121) + ' ' + @strGMT + '","leaf":true,"iconCls":"small-gear"}]}'

		--Insert Into tblSMAuditLog(strActionType,strTransactionType,strRecordNo,strDescription,strRoute,strJsonData,dtmDate,intEntityId,intConcurrencyId)
		--Values('Updated','Logistics.view.ShipmentSchedule',@intLoadId,'','',@strJson,GETUTCDATE(),@intEntityId,1)

		Set @strJson='{"change":"dtmETAPOD","from":"' + case When @dtmOldETA IS NULL THEN '' ELSE  CONVERT(VARCHAR(10),@dtmOldETA,121) END  + ' ' + @strGMT + '","to":"' + CONVERT(VARCHAR(10),@dtmETA,121) + ' ' + @strGMT + '","leaf":true,"iconCls":"small-gear"}'

		EXEC uspSMAuditLog @keyValue = @intLoadId
				,@screenName = 'Logistics.view.ShipmentSchedule'
				,@entityId = @intEntityId
				,@actionType = 'Updated'
				,@actionIcon = 'small-tree-modified'
				,@details = @strJson

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
		SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

		--Move to Error
		Insert Into tblIPShipmentETAError(strDeliveryNo,dtmETA,strPartnerNo,strImportStatus,strErrorMessage)
		Select strDeliveryNo,dtmETA,strPartnerNo,'Failed',@ErrMsg
		From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo

		Delete From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo
	END CATCH

	If ISNULL(@strSessionId,'')=''
		Select @intMinRowNo=NULL
	Else
		Select @intMinRowNo=Min(intStageShipmentETAId) From tblIPShipmentETAStage Where intStageShipmentETAId>@intMinRowNo AND intStageShipmentETAId=@strSessionId
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