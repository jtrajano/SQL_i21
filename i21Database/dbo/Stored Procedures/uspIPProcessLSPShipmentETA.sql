﻿CREATE PROCEDURE [dbo].[uspIPProcessLSPShipmentETA]
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
		@intLoadId INT

Select @intMinRowNo=Min(intStageShipmentETAId) From tblIPShipmentETAStage

While(@intMinRowNo is not null)
Begin
	BEGIN TRY
		Select @strDeliveryNo=strDeliveryNo,@dtmETA=dtmETA
		From tblIPShipmentETAStage Where intStageShipmentETAId=@intMinRowNo

		If @dtmETA IS NULL
			RaisError('Invalid ETA',16,1)

		Select @intLoadId=intLoadId From tblLGLoad Where strExternalShipmentNumber=@strDeliveryNo

		Begin Tran

		Update tblLGLoad Set dtmETAPOD=@dtmETA Where intLoadId=@intLoadId

		Insert Into tblLGETATracking(intLoadId,strTrackingType,dtmETAPOD,dtmModifiedOn)
		Values(@intLoadId,'ETA POD',@dtmETA,GETDATE()) 

		--Move to Archive
		Insert Into tblIPShipmentETAArchive(strDeliveryNo,dtmETA,strImportStatus,strErrorMessage)
		Select strDeliveryNo,dtmETA,'Success',''
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
		Insert Into tblIPShipmentETAError(strDeliveryNo,dtmETA,strImportStatus,strErrorMessage)
		Select strDeliveryNo,dtmETA,'Failed',@ErrMsg
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