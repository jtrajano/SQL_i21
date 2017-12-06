CREATE PROCEDURE uspMFProcessEDI943 (@strInfo1 NVARCHAR(MAX) = NULL OUTPUT)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@intRecordId INT
		,@strOrderNo NVARCHAR(50)
		,@intInventoryReceiptId INT
		,@intUserId INT
		,@strItemNo NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
		,@intItemId INT
		,@dblQty NUMERIC(38, 20)
		,@intUnitPerPallet INT
		,@strParentLotNumber NVARCHAR(50)
		,@ysnPickByLotCode BIT
		,@intLotCodeStartingPosition INT
		,@intLotCodeNoOfDigits INT
		,@strLotCode NVARCHAR(50)
		,@intLineNumber INT
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType
	DECLARE @tblMFOrderNo TABLE (
		intRecordId INT identity(1, 1)
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblMFSession TABLE (intEDI943Id INT)

	INSERT INTO @tblMFSession (intEDI943Id)
	SELECT intEDI943Id
	FROM tblMFEDI943

	INSERT INTO @tblMFOrderNo (strOrderNo)
	SELECT DISTINCT strDepositorOrderNumber
	FROM tblMFEDI943

	IF EXISTS (
			SELECT 1
			FROM tblSMUserSecurity
			WHERE strUserName = 'irelyadmin'
			)
		SELECT TOP 1 @intUserId = intEntityId
		FROM tblSMUserSecurity
		WHERE strUserName = 'irelyadmin'
	ELSE
		SELECT TOP 1 @intUserId = intEntityId
		FROM tblSMUserSecurity

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
	FROM tblMFCompanyPreference

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
					FROM tblMFEDI943 EDI
					JOIN tblEMEntity E ON E.strName = EDI.strShipFromName
					JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
						AND ET.strType = 'Vendor'
					WHERE EDI.strDepositorOrderNumber = @strOrderNo
					)
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + ' ' + 'Ship from Name does not exist.'
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI943 EDI943
					WHERE strDepositorOrderNumber = @strOrderNo
						AND NOT EXISTS (
							SELECT *
							FROM tblICItem I
							WHERE I.strItemNo = EDI943.strVendorItemNumber
							)
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strVendorItemNumber + ', '
				FROM tblMFEDI943 EDI943
				WHERE strDepositorOrderNumber = @strOrderNo
					AND NOT EXISTS (
						SELECT *
						FROM tblICItem I
						WHERE I.strItemNo = EDI943.strVendorItemNumber
						)

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' Item Number(s) ' + @strItemNo + ' does not exist.'
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI943 EDI943
					WHERE strDepositorOrderNumber = @strOrderNo
						AND (
							dblQtyShipped IS NULL
							OR dblQtyShipped = 0
							)
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strVendorItemNumber + ', '
				FROM tblMFEDI943 EDI943
				WHERE strDepositorOrderNumber = @strOrderNo
					AND (
						dblQtyShipped IS NULL
						OR dblQtyShipped = 0
						)

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' Qty shipped cannot be blank for the item number ' + @strItemNo + '. '
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI943 EDI943
					WHERE strDepositorOrderNumber = @strOrderNo
						AND NOT EXISTS (
							SELECT *
							FROM tblICItem I
							WHERE I.strItemNo = EDI943.strVendorItemNumber
								AND I.strExternalGroup <> ''
							)
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strVendorItemNumber + ', '
				FROM tblMFEDI943 EDI943
				WHERE strDepositorOrderNumber = @strOrderNo
					AND NOT EXISTS (
						SELECT *
						FROM tblICItem I
						WHERE I.strItemNo = EDI943.strVendorItemNumber
							AND I.strExternalGroup <> ''
						)

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' Qty UOM cannot be blank for the item number ' + @strItemNo + '. '
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
					FROM tblICInventoryReceipt
					WHERE strWarehouseRefNo = @strOrderNo
					)
			BEGIN
				INSERT INTO tblMFEDI943Archive (
					intEDI943Id
					,intTransactionId
					,strCustomerId
					,strType
					,strDepositorOrderNumber
					,dtmDate
					,strShipmentId
					,strActionCode
					,strShipFromName
					,strShipFromAddress1
					,strShipFromAddress2
					,strShipFromCity
					,strShipFromState
					,strShipFromZip
					,strShipFromCode
					,strTransportationMethod
					,strSCAC
					,dblTotalNumberofUnitsShipped
					,dblTotalWeight
					,strWeightUOM
					,strVendorItemNumber
					,strDescription
					,dblQtyShipped
					,strUOM
					,dtmCreated
					,strStatus
					,strFileName
					,strParentLotNumber
					,intLineNumber
					)
				SELECT intEDI943Id
					,intTransactionId
					,strCustomerId
					,strType
					,strDepositorOrderNumber
					,dtmDate
					,strShipmentId
					,strActionCode
					,strShipFromName
					,strShipFromAddress1
					,strShipFromAddress2
					,strShipFromCity
					,strShipFromState
					,strShipFromZip
					,strShipFromCode
					,strTransportationMethod
					,strSCAC
					,dblTotalNumberofUnitsShipped
					,dblTotalWeight
					,strWeightUOM
					,strVendorItemNumber
					,strDescription
					,dblQtyShipped
					,strUOM
					,dtmCreated
					,'IGNORED'
					,strFileName
					,strParentLotNumber
					,intLineNumber
				FROM tblMFEDI943
				WHERE strDepositorOrderNumber = @strOrderNo

				DELETE
				FROM tblMFEDI943
				WHERE strDepositorOrderNumber = @strOrderNo

				SELECT @intRecordId = min(intRecordId)
				FROM @tblMFOrderNo
				WHERE intRecordId > @intRecordId

				CONTINUE
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tempdb..sysobjects
					WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')
					)
			BEGIN
				CREATE TABLE #tmpAddItemReceiptResult (
					intSourceId INT
					,intInventoryReceiptId INT
					)
			END

			SELECT @intLineNumber = 0

			UPDATE tblMFEDI943
			SET @intLineNumber = intLineNumber = @intLineNumber + 1
			WHERE strDepositorOrderNumber = @strOrderNo

			INSERT INTO @ReceiptStagingTable (
				strReceiptType
				,intEntityVendorId
				,intShipFromId
				,intLocationId
				,strBillOfLadding
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,intContractHeaderId
				,intContractDetailId
				,dtmDate
				,intShipViaId
				,dblQty
				,intGrossNetUOMId
				,dblGross
				,dblNet
				,dblCost
				,intCostUOMId
				,intCurrencyId
				,intSubCurrencyCents
				,dblExchangeRate
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intSourceId
				,intSourceType
				,strSourceId
				,strSourceScreenName
				,ysnSubCurrency
				,intForexRateTypeId
				,dblForexRate
				,intContainerId
				,intFreightTermId
				)
			SELECT strReceiptType = 'Direct'
				,intEntityVendorId = E.intEntityId
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = IL.intLocationId
				,strBillOfLadding = NULL
				,intItemId = I.intItemId
				,intItemLocationId = IL.intItemLocationId
				,intItemUOMId = IU.intItemUOMId
				,intContractHeaderId = NULL
				,intContractDetailId = NULL
				,dtmDate = GETDATE()
				,intShipViaId = NULL
				,dblQty = dblQtyShipped
				,intGrossNetUOMId = CASE 
					WHEN I.ysnLotWeightsRequired = 1
						THEN I.intWeightUOMId
					ELSE NULL
					END
				,dblGross = CASE 
					WHEN I.ysnLotWeightsRequired = 1
						THEN dblQtyShipped * I.dblWeight
					ELSE NULL
					END
				,dblNet = CASE 
					WHEN I.ysnLotWeightsRequired = 1
						THEN dblQtyShipped * I.dblWeight
					ELSE NULL
					END
				,dblCost = 0
				,intCostUOMId = NULL
				,intCurrencyId = NULL
				,intSubCurrencyCents = 1
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = intSubLocationId
				,intStorageLocationId = intStorageLocationId
				,ysnIsStorage = 0
				,intSourceId = EDI.intLineNumber
				,intSourceType = 0
				,strSourceId = EDI.strDepositorOrderNumber
				,strSourceScreenName = 'EDI943'
				,ysnSubCurrency = NULL
				,intForexRateTypeId = NULL
				,dblForexRate = NULL
				,intContainerId = NULL
				,intFreightTermId = NULL
			FROM tblMFEDI943 EDI
			JOIN tblICItem I ON I.strItemNo = EDI.strVendorItemNumber
			JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
				AND IL.intLocationId IS NOT NULL
			JOIN tblEMEntity E ON E.strName = EDI.strShipFromName
			JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
				AND ET.strType = 'Vendor'
			JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId
			LEFT JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
			LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND UM.intUnitMeasureId = IU.intUnitMeasureId
			WHERE EDI.strDepositorOrderNumber = @strOrderNo

			EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
				,@OtherCharges = @OtherCharges
				,@intUserId = @intUserId;

			SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
			FROM #tmpAddItemReceiptResult

			UPDATE tblICInventoryReceipt
			SET strWarehouseRefNo = @strOrderNo
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			DECLARE @intMinInvRecItemId INT

			SELECT @intMinInvRecItemId = NULL

			SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			WHILE @intMinInvRecItemId > 0
			BEGIN
				SELECT @intItemId = NULL
					,@dblQty = NULL

				SELECT @intUnitPerPallet = NULL
					,@strItemNo = NULL
					,@strLotCode = NULL
					,@intLineNumber = 0

				SELECT @intItemId = intItemId
					,@dblQty = RI.dblOpenReceive
					,@intLineNumber = intSourceId
				FROM tblICInventoryReceiptItem RI
				WHERE intInventoryReceiptItemId = @intMinInvRecItemId

				SELECT @intUnitPerPallet = intUnitPerLayer * intLayerPerPallet
					,@strItemNo = strItemNo
				FROM tblICItem
				WHERE intItemId = @intItemId

				SELECT @strParentLotNumber = strParentLotNumber
				FROM tblMFEDI943
				WHERE strDepositorOrderNumber = @strOrderNo
					AND strVendorItemNumber = @strItemNo
					AND intLineNumber = @intLineNumber

				IF @ysnPickByLotCode = 1
				BEGIN
					SELECT @strLotCode = Substring(@strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)

					IF ISNUMERIC(@strLotCode) = 0
						AND len(@strLotCode) > 0
					BEGIN
						SELECT @strParentLotNumber = Replace(Left(@strParentLotNumber, 5), '-', '') + Right(@strParentLotNumber, CASE 
									WHEN Len(@strParentLotNumber) < 5
										THEN 0
									ELSE Len(@strParentLotNumber) - 5
									END)
					END
				END

				IF @intUnitPerPallet = 0
					OR @intUnitPerPallet IS NULL
				BEGIN
					INSERT INTO dbo.tblICInventoryReceiptItemLot (
						[intInventoryReceiptItemId]
						,strParentLotNumber
						,[intLotId]
						,[strLotNumber]
						,[strLotAlias]
						,intSubLocationId
						,intStorageLocationId
						,[intItemUnitMeasureId]
						,dblQuantity
						,dblGrossWeight
						,dblTareWeight
						,strContainerNo
						,[intSort]
						,[intConcurrencyId]
						)
					SELECT intInventoryReceiptItemId
						,@strParentLotNumber
						,NULL
						,''
						,''
						,intSubLocationId
						,intStorageLocationId
						,RI.intUnitMeasureId
						,RI.dblOpenReceive
						,dblGross
						,ISNULL(RI.dblGross, 0) - ISNULL(RI.dblNet, 0)
						,''
						,1
						,1
					FROM tblICInventoryReceiptItem RI
					WHERE intInventoryReceiptItemId = @intMinInvRecItemId
				END
				ELSE
				BEGIN
					WHILE Ceiling(@dblQty / @intUnitPerPallet) > 0
						AND @dblQty > 0
					BEGIN
						INSERT INTO dbo.tblICInventoryReceiptItemLot (
							[intInventoryReceiptItemId]
							,strParentLotNumber
							,[intLotId]
							,[strLotNumber]
							,[strLotAlias]
							,intSubLocationId
							,intStorageLocationId
							,[intItemUnitMeasureId]
							,dblQuantity
							,dblGrossWeight
							,dblTareWeight
							,strContainerNo
							,[intSort]
							,[intConcurrencyId]
							)
						SELECT intInventoryReceiptItemId
							,@strParentLotNumber
							,NULL
							,''
							,''
							,intSubLocationId
							,intStorageLocationId
							,RI.intUnitMeasureId
							,(
								CASE 
									WHEN @intUnitPerPallet > @dblQty
										THEN @dblQty
									ELSE @intUnitPerPallet
									END
								)
							,(dblGross / dblOpenReceive) * (
								CASE 
									WHEN @intUnitPerPallet > @dblQty
										THEN @dblQty
									ELSE @intUnitPerPallet
									END
								)
							,ISNULL((RI.dblGross / dblOpenReceive) * (
									CASE 
										WHEN @intUnitPerPallet > @dblQty
											THEN @dblQty
										ELSE @intUnitPerPallet
										END
									), 0) - ISNULL((RI.dblNet / dblOpenReceive) * (
									CASE 
										WHEN @intUnitPerPallet > @dblQty
											THEN @dblQty
										ELSE @intUnitPerPallet
										END
									), 0)
							,''
							,1
							,1
						FROM tblICInventoryReceiptItem RI
						WHERE intInventoryReceiptItemId = @intMinInvRecItemId

						SELECT @dblQty = @dblQty - @intUnitPerPallet
					END
				END

				SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
				FROM tblICInventoryReceiptItem
				WHERE intInventoryReceiptId = @intInventoryReceiptId
					AND intInventoryReceiptItemId > @intMinInvRecItemId
			END

			INSERT INTO tblMFEDI943Archive (
				intEDI943Id
				,intTransactionId
				,strCustomerId
				,strType
				,strDepositorOrderNumber
				,dtmDate
				,strShipmentId
				,strActionCode
				,strShipFromName
				,strShipFromAddress1
				,strShipFromAddress2
				,strShipFromCity
				,strShipFromState
				,strShipFromZip
				,strShipFromCode
				,strTransportationMethod
				,strSCAC
				,dblTotalNumberofUnitsShipped
				,dblTotalWeight
				,strWeightUOM
				,strVendorItemNumber
				,strDescription
				,dblQtyShipped
				,strUOM
				,dtmCreated
				,strStatus
				,intInventoryReceiptId
				,strFileName
				,strParentLotNumber
				,intLineNumber
				)
			SELECT intEDI943Id
				,intTransactionId
				,strCustomerId
				,strType
				,strDepositorOrderNumber
				,dtmDate
				,strShipmentId
				,strActionCode
				,strShipFromName
				,strShipFromAddress1
				,strShipFromAddress2
				,strShipFromCity
				,strShipFromState
				,strShipFromZip
				,strShipFromCode
				,strTransportationMethod
				,strSCAC
				,dblTotalNumberofUnitsShipped
				,dblTotalWeight
				,strWeightUOM
				,strVendorItemNumber
				,strDescription
				,dblQtyShipped
				,strUOM
				,dtmCreated
				,'SUCCESS'
				,@intInventoryReceiptId
				,strFileName
				,strParentLotNumber
				,intLineNumber
			FROM tblMFEDI943
			WHERE strDepositorOrderNumber = @strOrderNo

			DELETE
			FROM tblMFEDI943
			WHERE strDepositorOrderNumber = @strOrderNo
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ''
			SET @ErrMsg = ERROR_MESSAGE()

			INSERT INTO tblMFEDI943Error (
				intEDI943Id
				,intTransactionId
				,strCustomerId
				,strType
				,strDepositorOrderNumber
				,dtmDate
				,strShipmentId
				,strActionCode
				,strShipFromName
				,strShipFromAddress1
				,strShipFromAddress2
				,strShipFromCity
				,strShipFromState
				,strShipFromZip
				,strShipFromCode
				,strTransportationMethod
				,strSCAC
				,dblTotalNumberofUnitsShipped
				,dblTotalWeight
				,strWeightUOM
				,strVendorItemNumber
				,strDescription
				,dblQtyShipped
				,strUOM
				,dtmCreated
				,strErrorMessage
				,strFileName
				,strParentLotNumber
				,intLineNumber
				)
			SELECT intEDI943Id
				,intTransactionId
				,strCustomerId
				,strType
				,strDepositorOrderNumber
				,dtmDate
				,strShipmentId
				,strActionCode
				,strShipFromName
				,strShipFromAddress1
				,strShipFromAddress2
				,strShipFromCity
				,strShipFromState
				,strShipFromZip
				,strShipFromCode
				,strTransportationMethod
				,strSCAC
				,dblTotalNumberofUnitsShipped
				,dblTotalWeight
				,strWeightUOM
				,strVendorItemNumber
				,strDescription
				,dblQtyShipped
				,strUOM
				,dtmCreated
				,@ErrMsg
				,strFileName
				,strParentLotNumber
				,intLineNumber
			FROM tblMFEDI943
			WHERE strDepositorOrderNumber = @strOrderNo

			DELETE
			FROM tblMFEDI943
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
		FROM tblMFEDI943Archive A
		WHERE A.intEDI943Id IN (
				SELECT S.intEDI943Id
				FROM @tblMFSession S
				)
		) AS DT

	SELECT @strInfo1 = @strInfo1 + DT.strFileName + '; '
	FROM (
		SELECT DISTINCT strFileName
		FROM tblMFEDI943Error E
		WHERE E.intEDI943Id IN (
				SELECT S.intEDI943Id
				FROM @tblMFSession S
				)
		) AS DT

	IF EXISTS (
			SELECT *
			FROM tblMFEDI943Error E
			WHERE E.intEDI943Id IN (
					SELECT S.intEDI943Id
					FROM @tblMFSession S
					)
			)
	BEGIN
		SELECT @ErrMsg = ''

		SELECT @ErrMsg = @ErrMsg + ' ' + strErrorMessage + '; '
		FROM (
			SELECT DISTINCT strErrorMessage
			FROM tblMFEDI943Error E
			WHERE E.intEDI943Id IN (
					SELECT S.intEDI943Id
					FROM @tblMFSession S
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
