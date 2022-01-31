CREATE PROCEDURE dbo.uspMFGenerateERPProduction (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intUserId INT
		,@intWorkOrderId INT
		,@intProductionPreStageId INT
		,@strRowState NVARCHAR(50)
		,@strXML NVARCHAR(MAX) = ''
		,@strWorkOrderNo NVARCHAR(50)
		,@strERPOrderNo NVARCHAR(50)
		,@strDetailXML NVARCHAR(MAX) = ''
		,@strUserName NVARCHAR(50)
		,@strWorkOrderType NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@dblProdQuantity numeric(18,6)
		,@strProducedUOM nvarchar(50)
		,@strServiceItemNo nvarchar(50)
		,@TrxSequenceNo INT

	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intWorkOrderId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strWorkOrderNo NVARCHAR(50)
		,strERPOrderNo NVARCHAR(50)
		)
	DECLARE @tblMFProductionPreStage TABLE (intProductionPreStageId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFProductionPreStage
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Production'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 50

	INSERT INTO @tblMFProductionPreStage (intProductionPreStageId)
	SELECT TOP (@tmp) PS.intProductionPreStageId
	FROM dbo.tblMFProductionPreStage PS
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PS.intWorkOrderId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
	WHERE PS.intStatusId IS NULL
		AND CL.strLotOrigin = @strCompanyLocation

	SELECT @intProductionPreStageId = MIN(intProductionPreStageId)
	FROM @tblMFProductionPreStage

	IF @intProductionPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblMFProductionPreStage
	SET intStatusId = - 1
	WHERE intProductionPreStageId IN (
			SELECT PS.intProductionPreStageId
			FROM @tblMFProductionPreStage PS
			)

	WHILE @intProductionPreStageId IS NOT NULL
	BEGIN
		SELECT @intWorkOrderId = NULL

		SELECT @intWorkOrderId = intWorkOrderId
		FROM dbo.tblMFProductionPreStage
		WHERE intProductionPreStageId = @intProductionPreStageId

		SELECT @strERPOrderNo = strERPOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		IF IsNULL(@strERPOrderNo, '') = ''
		BEGIN
			GOTO NextPO
		END;
		SELECT @strXML = @strXML + '<header id="' + ltrim(@intProductionPreStageId) + '">'
			+'<TrxSequenceNo>'+ltrim(@intProductionPreStageId) +'</TrxSequenceNo>'
			+'<CompanyLocation>'+CL.strLotOrigin +'</CompanyLocation>'
			+'<ActionId>1</ActionId>'
			+'<CreatedDate>'+CONVERT(VARCHAR(33), GetDate(), 126) +'</CreatedDate>'
			+'<CreatedBy>'+	US.strUserName +'</CreatedBy>'
			+'<StorageLocation>'+	IsNULL(SL.strSubLocationName,'')  +'</StorageLocation>'
			+'<WorkOrderNo>'+	W.strWorkOrderNo    +'</WorkOrderNo>'
			+'<ERPShopOrderNo>'+	IsNULL(W.strERPOrderNo,'')     +'</ERPShopOrderNo>'
			+'<WorkOrderStatus>Completed</WorkOrderStatus>'
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
		LEFT JOIN dbo.tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = IsNULL(W.intSubLocationId, MC.intSubLocationId)
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
		JOIN dbo.tblSMUserSecurity US ON US.intEntityId = W.intCreatedUserId
		WHERE W.intWorkOrderId = @intWorkOrderId

		SELECT 
			@dblProdQuantity=SUM(WP.dblQuantity)
			,@strProducedUOM=MIN(UM.strUnitMeasure )
		FROM dbo.tblMFWorkOrderProducedLot WP
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WP.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		WHERE WP.intWorkOrderId = @intWorkOrderId

		Select @strServiceItemNo=I.strItemNo,@TrxSequenceNo=intWorkOrderRecipeItemId
		from dbo.tblMFWorkOrderRecipeItem RI
		JOIN dbo.tblICItem I on I.intItemId=RI.intItemId and I.strType='Other Charge'
		Where RI.intWorkOrderId = @intWorkOrderId

		SELECT @strDetailXML = ''

		IF @strServiceItemNo IS NOT NULL
		BEGIN
		SELECT @strDetailXML = @strDetailXML + '<line  id="' + ltrim(@TrxSequenceNo) + '" parentId="' + ltrim(@intProductionPreStageId) + '">'
			+'<TrxSequenceNo>'+ltrim(@TrxSequenceNo) +'</TrxSequenceNo>'
			+'<TransactionType>8</TransactionType>'
			+'<ItemNo>'+	@strServiceItemNo  +'</ItemNo>'
			+'<Quantity>'+	ltrim(Convert(Numeric(18,6),@dblProdQuantity))    +'</Quantity>'
			+'<QuantityUOM>'+	@strProducedUOM    +'</QuantityUOM>'
			+'</line>'
		END

		If @strDetailXML is null
		Select @strDetailXML=''
	
		SELECT @strDetailXML = @strDetailXML + '<line  id="' + ltrim(WC.intWorkOrderConsumedLotId) + '" parentId="' + ltrim(@intProductionPreStageId) + '">'
			+'<TrxSequenceNo>'+ltrim(WC.intWorkOrderConsumedLotId) +'</TrxSequenceNo>'
			+'<TransactionType>8</TransactionType>'
			+'<ItemNo>'+	I.strItemNo  +'</ItemNo>'
			+'<MotherLotNo>'+	PL.strParentLotNumber   +'</MotherLotNo>'
			+'<LotNo>'+	L.strLotNumber   +'</LotNo>'
			+'<StorageUnit>'+	SL.strName    +'</StorageUnit>'
			+'<Quantity>'+	ltrim(Convert(Numeric(18,6),WC.dblQuantity))    +'</Quantity>'
			+'<QuantityUOM>'+	UM.strUnitMeasure    +'</QuantityUOM>'
			+'</line>'
		FROM dbo.tblMFWorkOrderConsumedLot WC
		JOIN dbo.tblICLot L ON L.intLotId = WC.intLotId
		JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
		JOIN dbo.tblICItem I ON I.intItemId = WC.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WC.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
		WHERE WC.intWorkOrderId = @intWorkOrderId

		SELECT @strDetailXML = @strDetailXML + '<line  id="' + ltrim(WP.intWorkOrderProducedLotId) + '" parentId="' + ltrim(@intProductionPreStageId) + '">'
			+'<TrxSequenceNo>'+ltrim(WP.intWorkOrderProducedLotId) +'</TrxSequenceNo>'
			+'<TransactionType>9</TransactionType>'
			+'<ItemNo>'+	I.strItemNo  +'</ItemNo>'
			+'<MotherLotNo>'+	PL.strParentLotNumber   +'</MotherLotNo>'
			+'<LotNo>'+	L.strLotNumber   +'</LotNo>'
			+'<StorageUnit>'+	SL.strName    +'</StorageUnit>'
			+'<Quantity>'+	ltrim(Convert(Numeric(18,6),WP.dblQuantity))    +'</Quantity>'
			+'<QuantityUOM>'+	UM.strUnitMeasure    +'</QuantityUOM>'
			+'</line>'
		FROM dbo.tblMFWorkOrderProducedLot WP
		JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
		JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
		JOIN dbo.tblICItem I ON I.intItemId = WP.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WP.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WP.intStorageLocationId
		WHERE WP.intWorkOrderId = @intWorkOrderId

		IF IsNULL(@strDetailXML, '') <> ''
		BEGIN
			SELECT @strXML = @strXML + @strDetailXML + '</header>'
		END
		ELSE
		BEGIN
			SELECT @strXML = @strXML + '</header>'
		END
		/*
				Not Processed: NULL
				In-Progress: -1
				Internal Error in i21: 1
				Sent to AX: 2
				AX 1st Level Failure: 3, AX 1st Level Success: 4
				AX 2nd Level Failure: 5, AX 2nd Level Success: 6
			*/
		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE dbo.tblMFProductionPreStage
			SET intStatusId = 2
				,strMessage = 'Success'
			WHERE intProductionPreStageId = @intProductionPreStageId
		END

		NextPO:

		SELECT @intProductionPreStageId = MIN(intProductionPreStageId)
		FROM @tblMFProductionPreStage
		WHERE intProductionPreStageId > @intProductionPreStageId
	END

	IF @strXML <> ''
	BEGIN
		SELECT @strXML = '<root><data>' + @strXML + '</data></root>'

		INSERT INTO @tblOutput (
			intWorkOrderId
			,strRowState
			,strXML
			,strWorkOrderNo
			,strERPOrderNo
			)
		VALUES (
			@intWorkOrderId
			,@strRowState
			,@strXML
			,ISNULL(@strWorkOrderNo, '')
			,ISNULL(@strERPOrderNo, '')
			)
	END

	UPDATE dbo.tblMFProductionPreStage
	SET intStatusId = NULL
	WHERE intProductionPreStageId IN (
			SELECT PS.intProductionPreStageId
			FROM @tblMFProductionPreStage PS
			)
		AND intStatusId = - 1

	SELECT IsNULL(intWorkOrderId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strWorkOrderNo, '') AS strInfo1
		,IsNULL(strERPOrderNo, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
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
