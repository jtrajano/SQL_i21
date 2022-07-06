CREATE PROCEDURE dbo.uspMFGenerateVoucher @intWorkOrderId INT
	,@intUserId INT
	,@strXML NVARCHAR(MAX)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLocationId INT
		,@intAPAccount INT
		,@intWarehouseRateMatrixHeaderId INT
		,@intCurrencyId INT
		,@ysnSubCurrency BIT
		,@intBillId INT
		,@intProcessedItemUOMId INT
		,@intUnitMeasureId INT
		,@intVendorEntityId INT
		,@intBookId INT
		,@intPaymentMethodId INT
		,@strPaymentMethod NVARCHAR(50)
	DECLARE @xmlVoucherIds XML
		,@intCents INT
	DECLARE @createVoucherIds NVARCHAR(MAX)
	DECLARE @voucherIds TABLE (intBillId INT)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intWarehouseRateMatrixHeaderId = intWarehouseRateMatrixHeaderId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intProcessedItemUOMId = intItemUOMId
	FROM tblMFWorkOrderInputLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnConsumptionReversed = 0

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intProcessedItemUOMId

	SELECT @intUnitMeasureId = 1

	SELECT @intAPAccount = ISNULL(intServiceCharges, 0)
	FROM tblSMCompanyLocation CL
	WHERE intCompanyLocationId = @intLocationId

	SELECT @intCurrencyId = intCurrencyId
		,@ysnSubCurrency = ysnSubCurrency
		,@intCents = CU.intCent
		,@intVendorEntityId = intVendorEntityId
	FROM tblLGWarehouseRateMatrixHeader WRMH
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WRMH.intCurrencyId
	WHERE intWarehouseRateMatrixHeaderId = @intWarehouseRateMatrixHeaderId

	SELECT @intPaymentMethodId = intPaymentMethodId
	FROM tblAPVendor
	WHERE intEntityId = @intVendorEntityId

	SELECT @strPaymentMethod = strPaymentMethod
	FROM tblSMPaymentMethod
	WHERE intPaymentMethodID = @intPaymentMethodId

	SELECT @intBookId = intBookId
	FROM tblCTBook
	WHERE strBook = @strPaymentMethod

	DECLARE @voucherPayables AS VoucherPayable

	INSERT INTO @voucherPayables (
		intPartitionId
		,intEntityVendorId
		,intTransactionType
		,dtmDate
		,dtmVoucherDate
		,dblOrderQty
		,dblQuantityToBill
		,dblCost
		,intCostUOMId
		,intAccountId
		,strVendorOrderNumber
		,ysnStage
		,intItemId
		,intCurrencyId
		,ysnSubCurrency
		,intSubCurrencyCents
		,strMiscDescription
		,intLocationId
		,intSubLocationId
		,strSourceNumber
		,intOrderUOMId
		,intQtyToBillUOMId
		,intCostCurrencyId
		,dblWeight
		,dblNetWeight
		,intWeightUOMId
		,strReference
		,intBookId
		)
	SELECT 1 AS intPartitionId
		,RH.intVendorEntityId
		,1 AS intTransactionType
		,IsNULL(W.dtmPlannedDate, W.dtmExpectedDate)
		,IsNULL(W.dtmPlannedDate, W.dtmExpectedDate)
		,WRD.dblProcessedQty
		,WRD.dblProcessedQty
		,RD.dblUnitRate / CASE 
			WHEN (@ysnSubCurrency = 1)
				THEN 100
			ELSE 1
			END
		,RD.intItemUOMId
		,@intAPAccount AS intAccountId
		,''
		,0 AS ysnStage
		,RD.intItemId
		,@intCurrencyId
		,@ysnSubCurrency
		,CASE 
			WHEN @ysnSubCurrency = 1
				THEN @intCents
			ELSE NULL
			END
		,RD.strActivity
		,@intLocationId
		,W.intSubLocationId
		,strWorkOrderNo
		,IU.intItemUOMId
		,IU.intItemUOMId
		,@intCurrencyId
		,WRD.dblProcessedQty
		,WRD.dblProcessedQty
		,IU.intItemUOMId
		,strWorkOrderNo
		,@intBookId
	FROM dbo.tblMFWorkOrderWarehouseRateMatrixDetail WRD
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WRD.intWorkOrderId
	JOIN dbo.tblLGWarehouseRateMatrixHeader RH ON RH.intWarehouseRateMatrixHeaderId = W.intWarehouseRateMatrixHeaderId
	JOIN dbo.tblLGWarehouseRateMatrixDetail RD ON RD.intWarehouseRateMatrixDetailId = WRD.intWarehouseRateMatrixDetailId
	LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = RD.intItemId
		AND IU.intUnitMeasureId = @intUnitMeasureId
	WHERE W.intWorkOrderId = @intWorkOrderId
		AND WRD.intWorkOrderWarehouseRateMatrixDetailId IN (
			SELECT x.intWorkOrderWarehouseRateMatrixDetailId
			FROM OPENXML(@idoc, 'root/WorkOrderWarehouseServices', 2) WITH (intWorkOrderWarehouseRateMatrixDetailId INT) x
			)

	EXEC [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayables
		,@userId = @intUserId
		,@throwError = 0
		,@error = @ErrMsg OUT
		,@createdVouchersId = @createVoucherIds OUT

	UPDATE tblMFWorkOrderWarehouseRateMatrixDetail
	SET intBillId = @createVoucherIds
	WHERE intWorkOrderWarehouseRateMatrixDetailId IN (
			SELECT x.intWorkOrderWarehouseRateMatrixDetailId
			FROM OPENXML(@idoc, 'root/WorkOrderWarehouseServices', 2) WITH (intWorkOrderWarehouseRateMatrixDetailId INT) x
			)
		AND intWorkOrderId = @intWorkOrderId

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
