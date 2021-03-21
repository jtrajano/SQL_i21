CREATE PROCEDURE dbo.uspMFGenerateProductionOrder (@strCompanyLocation NVARCHAR(6) = NULL)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intUserId INT
		,@intWorkOrderId INT
		,@intWorkOrderPreStageId INT
		,@strRowState NVARCHAR(50)
		,@strXML NVARCHAR(MAX) = ''
		,@strWorkOrderNo NVARCHAR(50)
		,@strERPOrderNo NVARCHAR(50)
		,@strDetailXML NVARCHAR(MAX) = ''
		,@strUserName nvarchar(50)
		,@strWorkOrderType nvarchar(50)
		,@strSubLocationName nvarchar(50)

	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intWorkOrderId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strWorkOrderNo NVARCHAR(50)
		,strERPOrderNo NVARCHAR(50)
		)
	DECLARE @tblMFWorkOrderPreStage TABLE (intWorkOrderPreStageId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderPreStage
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	INSERT INTO @tblMFWorkOrderPreStage (intWorkOrderPreStageId)
	SELECT TOP 20 PS.intWorkOrderPreStageId
	FROM dbo.tblMFWorkOrderPreStage PS
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PS.intWorkOrderId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
	WHERE PS.intStatusId IS NULL
		AND CL.strLotOrigin = @strCompanyLocation

	INSERT INTO @tblMFWorkOrderPreStage (intWorkOrderPreStageId)
	SELECT TOP 20 PS.intWorkOrderPreStageId
	FROM dbo.tblMFWorkOrderPreStage PS
	WHERE PS.intStatusId IS NULL
		AND PS.strCompanyLocation = @strCompanyLocation
		AND strRowState='Deleted'

	SELECT @intWorkOrderPreStageId = MIN(intWorkOrderPreStageId)
	FROM @tblMFWorkOrderPreStage

	IF @intWorkOrderPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblMFWorkOrderPreStage
	SET intStatusId = - 1
	WHERE intWorkOrderPreStageId IN (
			SELECT PS.intWorkOrderPreStageId
			FROM @tblMFWorkOrderPreStage PS
			)

	WHILE @intWorkOrderPreStageId IS NOT NULL
	BEGIN
		SELECT @intWorkOrderId = NULL
			,@strRowState = NULL
			,@intUserId = NULL
			,@strUserName =NULL
			,@strERPOrderNo = NULL
			,@strWorkOrderNo = NULL
			,@strWorkOrderType=NULL
			,@strSubLocationName=NULL

		SELECT @intWorkOrderId = intWorkOrderId
			,@strRowState = strRowState
			,@intUserId = intUserId
			,@strERPOrderNo  = strERPOrderNo 
			,@strUserName = strUserName
			,@strWorkOrderNo = strWorkOrderNo
			,@strWorkOrderType=strWorkOrderType
			,@strSubLocationName=strSubLocationName
		FROM dbo.tblMFWorkOrderPreStage
		WHERE intWorkOrderPreStageId = @intWorkOrderPreStageId
		
		IF @strRowState='Delete'
		BEGIN
				Select @strXML=@strXML+'<header TrxSequenceNo="'+ltrim(@intWorkOrderPreStageId) +'">'
									+'<TrxSequenceNo>'+ltrim(@intWorkOrderPreStageId) +'</TrxSequenceNo>'
									+'<CompanyLocation>'+@strCompanyLocation +'</CompanyLocation>'
									+'<ActionId>4</ActionId>'
									+'<CreatedDate>'+CONVERT(VARCHAR(33), GetDate(), 126) +'</CreatedDate>'
									+'<CreatedBy>'+	@strUserName +'</CreatedBy>'
									+'<StorageLocation>'+	IsNULL(@strSubLocationName,'')  +'</StorageLocation>'
									+'<WorkOrderType>'+	isNULL(@strWorkOrderType,'')   +'</WorkOrderType>'
									+'<WorkOrderNo>'+	IsNULL(@strWorkOrderNo,'')    +'</WorkOrderNo>'
									+'<ERPShopOrderNo>'+	IsNULL(@strERPOrderNo,'')     +'</ERPShopOrderNo>'
									+ '</header>'
		END
		Else
		Begin
		SELECT @strWorkOrderNo = strWorkOrderNo
			,@strERPOrderNo = strERPOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		IF @strRowState ='Modified'
			AND IsNULL(@strERPOrderNo, '') = ''
		BEGIN
			GOTO NextPO
		END;
		Select @strXML=@strXML+'<header TrxSequenceNo="'+ltrim(@intWorkOrderPreStageId) +'">'
								+'<TrxSequenceNo>'+ltrim(@intWorkOrderPreStageId) +'</TrxSequenceNo>'
								+'<CompanyLocation>'+CL.strLotOrigin +'</CompanyLocation>'
									+'<ActionId>'+Ltrim(Case When @strRowState='Added' then 1 When @strRowState='Modified' then 2 else 4 End) +'</ActionId>'
									+'<CreatedDate>'+CONVERT(VARCHAR(33), GetDate(), 126) +'</CreatedDate>'
									+'<CreatedBy>'+	US.strUserName +'</CreatedBy>'
									+'<StorageLocation>'+	IsNULL(SL.strSubLocationName,'')  +'</StorageLocation>'
									+'<ProcessName>'+	MP.strProcessName   +'</ProcessName>'
									+'<WorkOrderType>'+	(Case When SL.ysnExternal =1 Then 'Offsite' Else 'Inhouse' End)   +'</WorkOrderType>'
									+'<VendorAccountNo>'+	IsNULL(V.strVendorAccountNum,'')   +'</VendorAccountNo>'
									+'<WorkOrderNo>'+	W.strWorkOrderNo    +'</WorkOrderNo>'
									+'<ItemNo>'+	I.strItemNo     +'</ItemNo>'
									+'<FormulaNumber>'+	IsNULL(WR.strERPRecipeNo,'')     +'</FormulaNumber>'
									+'<Quantity>'+	ltrim(W.dblQuantity)    +'</Quantity>'
									+'<QuantityUOM>'+	UM.strUnitMeasure    +'</QuantityUOM>'
									+'<ManufacturingCell>'+	MC.strCellName     +'</ManufacturingCell>'
									+'<DueDate>'+	IsNULL(convert(varchar, W.dtmPlannedDate, 112),'')    +'</DueDate>'
									+'<Machine>'+	IsNULL(M.strName,'')    +'</Machine>'
									+'<ERPShopOrderNo>'+	IsNULL(W.strERPOrderNo,'')     +'</ERPShopOrderNo>'

		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
		LEFT JOIN dbo.tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = IsNULL(W.intSubLocationId,MC.intSubLocationId)
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
		JOIN dbo.tblMFWorkOrderRecipe WR ON WR.intItemId = W.intItemId
			AND WR.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblSMUserSecurity US ON US.intEntityId = W.intCreatedUserId
		LEFT JOIN tblMFMachine M ON M.intMachineId = W.intMachineId
		LEFT JOIN dbo.tblLGWarehouseRateMatrixHeader WRM ON WRM.intWarehouseRateMatrixHeaderId = W.intWarehouseRateMatrixHeaderId
		LEFT JOIN dbo.tblAPVendor V ON V.intEntityId = WRM.intVendorEntityId
		WHERE W.intWorkOrderId = @intWorkOrderId

		SELECT @strDetailXML = ''

		SELECT @strDetailXML=@strDetailXML+'<line  TrxSequenceNo="'+ltrim(WP.intWorkOrderInputParentLotId) +'" ParentTrxSequenceNo="'+ltrim(@intWorkOrderPreStageId)+'">'
								+'<TrxSequenceNo>'+ltrim(WP.intWorkOrderInputParentLotId) +'</TrxSequenceNo>'
									+'<ItemNo>'+	I.strItemNo  +'</ItemNo>'
									+'<MotherLotNo>'+	PL.strParentLotNumber   +'</MotherLotNo>'
									+'<StorageUnit>'+	SL.strName    +'</StorageUnit>'
									+'<Quantity>'+	ltrim(Convert(Numeric(18,6),WP.dblQuantity))    +'</Quantity>'
									+'<QuantityUOM>'+	UM.strUnitMeasure    +'</QuantityUOM>'
									+'</line>'FROM dbo.tblMFWorkOrderInputParentLot WP
		JOIN dbo.tblICParentLot PL ON PL.intParentLotId = WP.intParentLotId
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
		End
		UPDATE dbo.tblMFWorkOrderPreStage
		SET intStatusId = 1
			,strMessage = 'Success'
		WHERE intWorkOrderPreStageId = @intWorkOrderPreStageId

		NextPO:

		SELECT @intWorkOrderPreStageId = MIN(intWorkOrderPreStageId)
		FROM @tblMFWorkOrderPreStage
		WHERE intWorkOrderPreStageId > @intWorkOrderPreStageId
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

	UPDATE dbo.tblMFWorkOrderPreStage
	SET intStatusId = NULL
	WHERE intWorkOrderPreStageId IN (
			SELECT PS.intWorkOrderPreStageId
			FROM @tblMFWorkOrderPreStage PS
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
