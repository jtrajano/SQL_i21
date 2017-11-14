CREATE PROCEDURE uspMFProcessEDI940 (@strInfo1 NVARCHAR(MAX) = NULL OUTPUT)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@intRecordId INT
		,@strOrderNo NVARCHAR(50)
		,@intInventoryShipmentId INT
		,@intUserId INT
		,@strErrorMessage NVARCHAR(MAX)
		,@strItemNo NVARCHAR(50)
	DECLARE @ShipmentStagingTable ShipmentStagingTable
	DECLARE @OtherCharges ShipmentChargeStagingTable
	DECLARE @tblMFOrderNo TABLE (
		intRecordId INT identity(1, 1)
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblMFOrderNo (strOrderNo)
	SELECT DISTINCT strDepositorOrderNumber
	FROM tblMFEDI940

	IF EXISTS (
			SELECT 1
			FROM tblSMUserSecurity
			WHERE strUserName = 'irelyadmin'
			)
		SELECT TOP 1 @intUserId = intEntityUserSecurityId
		FROM tblSMUserSecurity
		WHERE strUserName = 'irelyadmin'
	ELSE
		SELECT TOP 1 @intUserId = intEntityUserSecurityId
		FROM tblSMUserSecurity

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @intRecordId = min(intRecordId)
	FROM @tblMFOrderNo

	WHILE @intRecordId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @strOrderNo = NULL

			SELECT @strErrorMessage = ''

			SELECT @strOrderNo = strOrderNo
			FROM @tblMFOrderNo
			WHERE intRecordId = @intRecordId

			IF @strOrderNo IS NULL
				OR @strOrderNo = ''
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + 'Depositor Order Number cannot be blank.'
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblMFEDI940 EDI
					JOIN tblEMEntity E ON E.strName = EDI.strShipToName
					JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
						AND ET.strType = 'Customer'
					WHERE EDI.strDepositorOrderNumber = @strOrderNo
					)
			BEGIN
				IF @strErrorMessage <> ''
					SELECT @strErrorMessage = @strErrorMessage + ' Ship to Name does not exist.'
				ELSE
					SELECT @strErrorMessage = @strErrorMessage + 'Ship to Name does not exist.'
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI940 EDI940
					WHERE strDepositorOrderNumber = @strOrderNo
						AND NOT EXISTS (
							SELECT *
							FROM tblICItem I
							WHERE I.strItemNo = EDI940.strCustomerItemNumber
							)
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strCustomerItemNumber + ', '
				FROM tblMFEDI940 EDI940
				WHERE strDepositorOrderNumber = @strOrderNo
					AND NOT EXISTS (
						SELECT *
						FROM tblICItem I
						WHERE I.strItemNo = EDI940.strCustomerItemNumber
						)

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				IF @strErrorMessage <> ''
					SELECT @strErrorMessage = @strErrorMessage + ' Item Number(s) ' + @strItemNo + ' does not exist.'
				ELSE
					SELECT @strErrorMessage = @strErrorMessage + 'Item Number(s) ' + @strItemNo + ' does not exist.'
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI940 EDI940
					WHERE strDepositorOrderNumber = @strOrderNo
						AND (
							dblQtyOrdered IS NULL
							OR dblQtyOrdered = 0
							)
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strCustomerItemNumber + ', '
				FROM tblMFEDI940 EDI940
				WHERE strDepositorOrderNumber = @strOrderNo
					AND (
						dblQtyOrdered IS NULL
						OR dblQtyOrdered = 0
						)

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				IF @strErrorMessage <> ''
					SELECT @strErrorMessage = @strErrorMessage + ' Qty Ordered cannot be blank for the item number ' + @strItemNo + '.'
				ELSE
					SELECT @strErrorMessage = @strErrorMessage + 'Qty Ordered cannot be blank for the item number ' + @strItemNo + '.'
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI940 EDI940
					WHERE strDepositorOrderNumber = @strOrderNo
						AND NOT EXISTS (
							SELECT *
							FROM tblICItem I
							WHERE I.strItemNo = EDI940.strCustomerItemNumber
								AND I.strExternalGroup <> ''
							)
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strCustomerItemNumber + ', '
				FROM tblMFEDI940 EDI940
				WHERE strDepositorOrderNumber = @strOrderNo
					AND NOT EXISTS (
						SELECT *
						FROM tblICItem I
						WHERE I.strItemNo = EDI940.strCustomerItemNumber
							AND I.strExternalGroup <> ''
						)

				IF @strErrorMessage <> ''
					SELECT @strErrorMessage = @strErrorMessage + ' Qty UOM cannot be blank for the item number ' + @strItemNo + '.'
				ELSE
					SELECT @strErrorMessage = @strErrorMessage + 'Qty UOM cannot be blank for the item number ' + @strItemNo + '.'
			END

			IF @strErrorMessage <> ''
			BEGIN
				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF EXISTS (
					SELECT *
					FROM tblICInventoryShipment
					WHERE strReferenceNumber = @strOrderNo
					)
			BEGIN
				INSERT INTO tblMFEDI940Archive (
					intEDI940Id
					,intTransactionId
					,strCustomerId
					,strPurpose
					,strDepositorOrderNumber
					,strPONumber
					,strShipToName
					,strShipToAddress1
					,SstrhipToAddress2
					,strShipToCity
					,strShipToState
					,strShipToZip
					,strShipToCode
					,strBuyerIdentification
					,strPODate
					,strDeliveryRequestedDate
					,intLineNumber
					,strCustomerItemNumber
					,strUPCCaseCode
					,strDescription
					,dblQtyOrdered
					,strUOM
					,dblInnerPacksPerOuterPack
					,dblTotalQtyOrdered
					,dtmCreated
					,strStatus
					,strFileName
					)
				SELECT intEDI940Id
					,intTransactionId
					,strCustomerId
					,strPurpose
					,strDepositorOrderNumber
					,strPONumber
					,strShipToName
					,strShipToAddress1
					,SstrhipToAddress2
					,strShipToCity
					,strShipToState
					,strShipToZip
					,strShipToCode
					,strBuyerIdentification
					,strPODate
					,strDeliveryRequestedDate
					,intLineNumber
					,strCustomerItemNumber
					,strUPCCaseCode
					,strDescription
					,dblQtyOrdered
					,strUOM
					,dblInnerPacksPerOuterPack
					,dblTotalQtyOrdered
					,dtmCreated
					,'IGNORED'
					,strFileName
				FROM tblMFEDI940
				WHERE strDepositorOrderNumber = @strOrderNo

				DELETE
				FROM tblMFEDI940
				WHERE strDepositorOrderNumber = @strOrderNo

				SELECT @intRecordId = min(intRecordId)
				FROM @tblMFOrderNo
				WHERE intRecordId > @intRecordId

				CONTINUE
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tempdb..sysobjects
					WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')
					)
			BEGIN
				CREATE TABLE #tmpAddItemShipmentResult (
					intSourceId INT
					,intInventoryShipmentId INT
					)
			END

			INSERT INTO @ShipmentStagingTable (
				intOrderType
				,intSourceType
				,intEntityCustomerId
				,dtmShipDate
				,intShipFromLocationId
				,intShipToLocationId
				,intFreightTermId
				,strSourceScreenName
				,strBOLNumber
				,strReferenceNumber
				,intItemId
				,intOwnershipType
				,dblQuantity
				,intItemUOMId
				,intOrderId
				,intLineNo
				,intWeightUOMId
				,dblUnitPrice
				,intCurrencyId
				,intForexRateTypeId
				,dblForexRate
				)
			SELECT intOrderType = 4
				,intSourceType = 0
				,intEntityCustomerId = E.intEntityId
				,dtmShipDate = EDI.strDeliveryRequestedDate
				,intShipFromLocationId = IL.intLocationId
				,intShipToLocationId = EL.intEntityLocationId
				,intFreightTermId = (
					SELECT TOP 1 intFreightTermId
					FROM tblSMFreightTerms
					WHERE strFreightTerm = 'Deliver'
					)
				,strSourceScreenName = 'EDI940'
				,strBOLNumber = ''
				,strReferenceNumber = EDI.strDepositorOrderNumber
				,intItemId = I.intItemId
				,intOwnershipType = 1
				,dblQuantity = EDI.dblQtyOrdered
				,intItemUOMId = IU.intItemUOMId
				,intOrderId = NULL
				,intLineNo = EDI.intLineNumber
				,intWeightUOMId = NULL
				,dblUnitPrice = 0
				,intCurrencyId = NULL
				,intForexRateTypeId = NULL
				,dblForexRate = NULL
			FROM tblMFEDI940 EDI
			JOIN tblICItem I ON I.strItemNo = EDI.strCustomerItemNumber
			JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
				AND IL.intLocationId IS NOT NULL
			JOIN tblEMEntity E ON E.strName = EDI.strShipToName
			JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
				AND ET.strType = 'Customer'
			JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId
			LEFT JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
			LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND UM.intUnitMeasureId = IU.intUnitMeasureId
			WHERE EDI.strDepositorOrderNumber = @strOrderNo

			EXEC dbo.uspICAddItemShipment @Entries = @ShipmentStagingTable
				,@Charges = @OtherCharges
				,@intUserId = @intUserId;

			SELECT TOP 1 @intInventoryShipmentId = intInventoryShipmentId
			FROM #tmpAddItemShipmentResult

			INSERT INTO tblMFEDI940Archive (
				intEDI940Id
				,intTransactionId
				,strCustomerId
				,strPurpose
				,strDepositorOrderNumber
				,strPONumber
				,strShipToName
				,strShipToAddress1
				,SstrhipToAddress2
				,strShipToCity
				,strShipToState
				,strShipToZip
				,strShipToCode
				,strBuyerIdentification
				,strPODate
				,strDeliveryRequestedDate
				,intLineNumber
				,strCustomerItemNumber
				,strUPCCaseCode
				,strDescription
				,dblQtyOrdered
				,strUOM
				,dblInnerPacksPerOuterPack
				,dblTotalQtyOrdered
				,dtmCreated
				,strStatus
				,intInventoryShipmentId
				,intInventoryShipmentItemId
				,strFileName
				)
			SELECT intEDI940Id
				,intTransactionId
				,strCustomerId
				,strPurpose
				,strDepositorOrderNumber
				,strPONumber
				,strShipToName
				,strShipToAddress1
				,SstrhipToAddress2
				,strShipToCity
				,strShipToState
				,strShipToZip
				,strShipToCode
				,strBuyerIdentification
				,strPODate
				,strDeliveryRequestedDate
				,intLineNumber
				,strCustomerItemNumber
				,strUPCCaseCode
				,EDI940.strDescription
				,dblQtyOrdered
				,strUOM
				,dblInnerPacksPerOuterPack
				,dblTotalQtyOrdered
				,dtmCreated
				,'SUCCESS'
				,@intInventoryShipmentId
				,SI.intInventoryShipmentItemId
				,strFileName
			FROM tblMFEDI940 EDI940
			JOIN tblICItem I ON I.strItemNo = strCustomerItemNumber
			JOIN tblICInventoryShipmentItem SI ON SI.intItemId = I.intItemId
				AND SI.intInventoryShipmentId = @intInventoryShipmentId
				AND EDI940.intLineNumber = SI.intLineNo
			WHERE strDepositorOrderNumber = @strOrderNo

			DELETE
			FROM tblMFEDI940
			WHERE strDepositorOrderNumber = @strOrderNo
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			INSERT INTO tblMFEDI940Error (
				intEDI940Id
				,intTransactionId
				,strCustomerId
				,strPurpose
				,strDepositorOrderNumber
				,strPONumber
				,strShipToName
				,strShipToAddress1
				,SstrhipToAddress2
				,strShipToCity
				,strShipToState
				,strShipToZip
				,strShipToCode
				,strBuyerIdentification
				,strPODate
				,strDeliveryRequestedDate
				,intLineNumber
				,strCustomerItemNumber
				,strUPCCaseCode
				,strDescription
				,dblQtyOrdered
				,strUOM
				,dblInnerPacksPerOuterPack
				,dblTotalQtyOrdered
				,dtmCreated
				,strErrorMessage
				,strFileName
				)
			SELECT intEDI940Id
				,intTransactionId
				,strCustomerId
				,strPurpose
				,strDepositorOrderNumber
				,strPONumber
				,strShipToName
				,strShipToAddress1
				,SstrhipToAddress2
				,strShipToCity
				,strShipToState
				,strShipToZip
				,strShipToCode
				,strBuyerIdentification
				,strPODate
				,strDeliveryRequestedDate
				,intLineNumber
				,strCustomerItemNumber
				,strUPCCaseCode
				,strDescription
				,dblQtyOrdered
				,strUOM
				,dblInnerPacksPerOuterPack
				,dblTotalQtyOrdered
				,dtmCreated
				,@ErrMsg
				,strFileName
			FROM tblMFEDI940
			WHERE strDepositorOrderNumber = @strOrderNo

			DELETE
			FROM tblMFEDI940
			WHERE strDepositorOrderNumber = @strOrderNo
		END CATCH

		SELECT @intRecordId = min(intRecordId)
		FROM @tblMFOrderNo
		WHERE intRecordId > @intRecordId
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	SELECT @strInfo1 = ''

	SELECT @strInfo1 = @strInfo1 + DT.strFileName + '; '
	FROM (
		SELECT DISTINCT strFileName
		FROM tblMFEDI940Archive
		WHERE strDepositorOrderNumber IN (
				SELECT strOrderNo
				FROM @tblMFOrderNo
				)
		) AS DT

	SELECT @strInfo1 = @strInfo1 + DT.strFileName + '; '
	FROM (
		SELECT DISTINCT strFileName
		FROM tblMFEDI940Error
		WHERE strDepositorOrderNumber IN (
				SELECT strOrderNo
				FROM @tblMFOrderNo
				)
		) AS DT

	IF EXISTS (
			SELECT *
			FROM tblMFEDI940Error
			WHERE strDepositorOrderNumber IN (
					SELECT strOrderNo
					FROM @tblMFOrderNo
					)
			)
	BEGIN
		SELECT @ErrMsg = ''

		SELECT @ErrMsg = @ErrMsg + strErrorMessage + '; '
		FROM (
			SELECT DISTINCT strErrorMessage
			FROM tblMFEDI940Error
			WHERE strDepositorOrderNumber IN (
					SELECT strOrderNo
					FROM @tblMFOrderNo
					)
			) AS DT

		RAISERROR (
				@ErrMsg
				,18
				,1
				,'WITH NOWAIT'
				)
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH

