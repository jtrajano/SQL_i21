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
		,@intEntityLocationId INT
		,@strCustomerCode NVARCHAR(50)
		,@strShipToName NVARCHAR(100)
		,@intEntityId INT
		,@intEntityContactId INT
		,@strEntityNo NVARCHAR(50)
		,@strShipToAddress1 NVARCHAR(MAX)
		,@strShipToAddress2 NVARCHAR(MAX)
		,@strShipToCity NVARCHAR(MAX)
		,@strShipToState NVARCHAR(MAX)
		,@strShipToZip NVARCHAR(MAX)
		,@intTabRowId INT
		,@intTransactionId INT
		,@intScreenId INT
		,@intCustomTabId INT
		,@intCustomTabDetailId INT
		,@intCustomTabDetailId0 INT
		,@strReceiptNumber NVARCHAR(50)
		,@strLocationCount NVARCHAR(50)
		,@ysnDefaultLocation BIT
	DECLARE @tblMFItemLineNumber TABLE (
		intEDI943Id INT
		,intLineNumber INT
		)
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType
	DECLARE @tblMFOrderNo TABLE (
		intRecordId INT identity(1, 1)
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblMFSession TABLE (intEDI943Id INT)
	DECLARE @tblMFItem TABLE (
		intItemId INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

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

			SELECT @intInventoryReceiptId = NULL

			SELECT @strErrorMessage = ''

			SELECT @strOrderNo = strOrderNo
			FROM @tblMFOrderNo
			WHERE intRecordId = @intRecordId

			SELECT @strCustomerCode = strWarehouseCode
				,@strShipToName = strShipFromName
				,@strShipToState = strShipFromState
			FROM tblMFEDI943 EDI943
			WHERE strDepositorOrderNumber = @strOrderNo

			IF @strOrderNo IS NULL
				OR @strOrderNo = ''
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + 'Depositor Order Number cannot be blank.'
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
						AND strType <> 'Cancel'
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
					AND strType <> 'Cancel'

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' Qty shipped cannot be blank for the item number ' + @strItemNo + '. '
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblMFEDI943 EDI943
					JOIN tblICItem I ON I.strItemNo = EDI943.strVendorItemNumber
					JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
						AND (
							IU.ysnAllowPurchase = 1
							OR IU.ysnAllowSale = 1
							)
					JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
						AND (
							UM.strUnitType <> 'Weight'
							OR UM.strUnitMeasure = EDI943.strUOM
							)
					WHERE strDepositorOrderNumber = @strOrderNo
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strVendorItemNumber + ', '
				FROM tblMFEDI943 EDI943
				JOIN tblICItem I ON I.strItemNo = EDI943.strVendorItemNumber
				JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
					AND (
						IU.ysnAllowPurchase = 1
						OR IU.ysnAllowSale = 1
						)
				LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND (
						UM.strUnitType <> 'Weight'
						OR UM.strUnitMeasure = EDI943.strUOM
						)
				WHERE strDepositorOrderNumber = @strOrderNo
					AND UM.intUnitMeasureId IS NULL

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' Qty UOM cannot be blank for the item number ' + @strItemNo + '. '
			END

			DELETE
			FROM @tblMFItem

			INSERT INTO @tblMFItem (
				intItemId
				,strItemNo
				,strUOM
				)
			SELECT DISTINCT I.intItemId
				,I.strItemNo
				,EDI943.strUOM
			FROM tblMFEDI943 EDI943
			JOIN tblICItem I ON I.strItemNo = EDI943.strVendorItemNumber
			WHERE strDepositorOrderNumber = @strOrderNo

			IF EXISTS (
					SELECT I.intItemId
						,count(*)
					FROM @tblMFItem I
					JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
						AND (
							IU.ysnAllowPurchase = 1
							OR IU.ysnAllowSale = 1
							)
					JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
						AND UM.strUnitType <> 'Weight'
						AND I.intItemId NOT IN (
							SELECT I.intItemId
							FROM @tblMFItem I
							JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
								AND (
									IU.ysnAllowPurchase = 1
									OR IU.ysnAllowSale = 1
									)
							JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
								AND UM.strUnitMeasure = I.strUOM
							)
					GROUP BY I.intItemId
					HAVING count(*) > 1
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strItemNo + ', '
				FROM @tblMFItem I
				JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
					AND (
						IU.ysnAllowPurchase = 1
						OR IU.ysnAllowSale = 1
						)
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND UM.strUnitType <> 'Weight'
				GROUP BY strItemNo
				HAVING count(*) > 1

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' Multiple Pack UOM for the item number ' + @strItemNo + ' are configured. Please configure only one Pack UOM. '
			END

			IF EXISTS (
					SELECT *
					FROM tblICInventoryReceipt
					WHERE strWarehouseRefNo = @strOrderNo
						AND ysnPosted = 1
					)
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + ' Inventory Receipt is already posted for the order number ' + @strOrderNo + '. '
			END

			IF EXISTS (
					SELECT *
					FROM @tblMFItem I
					LEFT JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
						AND IL.ysnOpenPricePLU = 1
					WHERE IL.ysnOpenPricePLU IS NULL
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strItemNo + ', '
				FROM @tblMFItem I
				LEFT JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					AND IL.ysnOpenPricePLU = 1
				WHERE IL.ysnOpenPricePLU IS NULL

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' EDI Default Location is not configured for the item(s) ' + @strItemNo + ' in the item location configuration.'
			END

			IF EXISTS (
					SELECT I.intItemId
					FROM @tblMFItem I
					JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
						AND IL.ysnOpenPricePLU = 1
					GROUP BY I.intItemId
					HAVING Count(*) > 1
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strItemNo + ', '
				FROM @tblMFItem I
				JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					AND IL.ysnOpenPricePLU = 1
				GROUP BY I.strItemNo
				HAVING Count(*) > 1

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' Multiple EDI Default Location is configured for the item(s) ' + @strItemNo + ' in the item location configuration.'
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
				SELECT @intInventoryReceiptId = intInventoryReceiptId
				FROM tblICInventoryReceipt
				WHERE strWarehouseRefNo = @strOrderNo
			END

			SELECT @intEntityLocationId = NULL

			SELECT @intEntityId = NULL

			SELECT @intEntityLocationId = intEntityLocationId
				,@intEntityId = intEntityId
			FROM tblEMEntityLocation
			WHERE strCheckPayeeName = @strCustomerCode

			IF @intEntityLocationId IS NULL
			BEGIN
				IF @intEntityId IS NULL
				BEGIN
					SELECT @intEntityId = intEntityId
					FROM tblEMEntity
					WHERE strName = @strShipToName
						AND strEntityNo <> ''
				END

				IF @intEntityId IS NULL
				BEGIN
					SELECT @strEntityNo = IsNULL(Max(strEntityNo), 0) + 1
					FROM tblEMEntity

					INSERT INTO tblEMEntity (
						strName
						,strEmail
						,strWebsite
						,strInternalNotes
						,ysnPrint1099
						,str1099Name
						,str1099Form
						,str1099Type
						,strFederalTaxId
						,dtmW9Signed
						,imgPhoto
						,strContactNumber
						,strTitle
						,strDepartment
						,strMobile
						,strPhone
						,strPhone2
						,strEmail2
						,strFax
						,strNotes
						,strContactMethod
						,strTimezone
						,strEntityNo
						,strContactType
						,intDefaultLocationId
						,ysnActive
						,ysnReceiveEmail
						,strEmailDistributionOption
						,dtmOriginationDate
						,strPhoneBackUp
						,intDefaultCountryId
						,strDocumentDelivery
						,strNickName
						,strSuffix
						,intEntityClassId
						,strExternalERPId
						,intConcurrencyId
						)
					SELECT @strShipToName
						,''
						,''
						,''
						,0
						,''
						,''
						,''
						,''
						,GETDATE()
						,NULL
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,@strEntityNo
						,''
						,NULL
						,0
						,0
						,''
						,GETDATE()
						,''
						,NULL
						,''
						,''
						,''
						,NULL
						,''
						,1

					SELECT @intEntityId = NULL

					SELECT @intEntityId = SCOPE_IDENTITY()

					INSERT INTO tblEMEntity (
						strName
						,strEmail
						,strWebsite
						,strInternalNotes
						,ysnPrint1099
						,str1099Name
						,str1099Form
						,str1099Type
						,strFederalTaxId
						,dtmW9Signed
						,imgPhoto
						,strContactNumber
						,strTitle
						,strDepartment
						,strMobile
						,strPhone
						,strPhone2
						,strEmail2
						,strFax
						,strNotes
						,strContactMethod
						,strTimezone
						,strEntityNo
						,strContactType
						,intDefaultLocationId
						,ysnActive
						,ysnReceiveEmail
						,strEmailDistributionOption
						,dtmOriginationDate
						,strPhoneBackUp
						,intDefaultCountryId
						,strDocumentDelivery
						,strNickName
						,strSuffix
						,intEntityClassId
						,strExternalERPId
						,intConcurrencyId
						)
					SELECT @strShipToName
						,''
						,''
						,''
						,0
						,''
						,''
						,''
						,''
						,GETDATE()
						,NULL
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,''
						,NULL
						,1
						,0
						,''
						,GETDATE()
						,''
						,NULL
						,''
						,''
						,''
						,NULL
						,''
						,2

					SELECT @intEntityContactId = NULL

					SELECT @intEntityContactId = SCOPE_IDENTITY()

					INSERT INTO tblEMEntityType (
						intEntityId
						,strType
						,intConcurrencyId
						)
					SELECT @intEntityId
						,'Vendor'
						,1

					INSERT INTO tblAPVendor (
						intEntityId
						,strVendorPayToId
						,intVendorType
						,strVendorId
						,strVendorAccountNum
						,ysnPymtCtrlActive
						,ysnPymtCtrlAlwaysDiscount
						,ysnPymtCtrlEFTActive
						,ysnPymtCtrlHold
						,ysnWithholding
						,dblCreditLimit
						,intConcurrencyId
						)
					SELECT DISTINCT @intEntityId
						,''
						,0
						,@strEntityNo
						,''
						,1
						,0
						,0
						,0
						,0
						,0
						,1

					--New Customer Notification
					UPDATE tblMFEDI943
					SET ysnNotify = 1
						,intWarehouseCodeType = 1
					WHERE strDepositorOrderNumber = @strOrderNo
				END

				SELECT @strLocationCount = ''

				SELECT @strLocationCount = Count(*) + 1
				FROM tblEMEntityLocation
				WHERE intEntityId = @intEntityId
					AND strState = @strShipToState

				IF @strLocationCount = '1'
				BEGIN
					SELECT @strLocationCount = ''
				END

				IF EXISTS (
						SELECT *
						FROM tblEMEntityLocation
						WHERE intEntityId = @intEntityId
							AND ysnDefaultLocation = 1
						)
				BEGIN
					SELECT @ysnDefaultLocation = 0
				END
				ELSE
				BEGIN
					SELECT @ysnDefaultLocation = 1
				END

				INSERT INTO tblEMEntityLocation (
					intEntityId
					,strLocationName
					,strAddress
					,strCity
					,strCountry
					,strState
					,strZipCode
					,intTermsId
					,ysnDefaultLocation
					,ysnActive
					,strTimezone
					,intConcurrencyId
					,strCheckPayeeName
					)
				SELECT TOP 1 @intEntityId intEntityId
					,Rtrim(strShipFromState + ' ' + @strLocationCount) AS strLocationName
					,strShipFromAddress1 + CASE 
						WHEN IsNULL(strShipFromAddress2, '') <> ''
							THEN ' ' + strShipFromAddress2
						ELSE ''
						END strAddress
					,strShipFromCity strCity
					,'United States' strCountry
					,strShipFromState strState
					,strShipFromZip strZipCode
					,1 intTermsId
					,@ysnDefaultLocation ysnDefaultLocation
					,1 ysnActive
					,'(UTC-06:00) Central Time (US & Canada)' strTimezone
					,1 intConcurrencyId
					,strWarehouseCode strCheckPayeeName
				FROM tblMFEDI943
				WHERE strDepositorOrderNumber = @strOrderNo

				SELECT @intEntityLocationId = IDENT_CURRENT('tblEMEntityLocation') --SCOPE_IDENTITY()

				--New Customer Notification
				UPDATE tblMFEDI943
				SET ysnNotify = 1
					,intWarehouseCodeType = CASE 
						WHEN intWarehouseCodeType = 0
							THEN 2
						END
				WHERE strDepositorOrderNumber = @strOrderNo

				INSERT INTO tblEMEntityToContact (
					intEntityId
					,intEntityContactId
					,intEntityLocationId
					,ysnPortalAccess
					,intConcurrencyId
					,ysnDefaultContact
					)
				SELECT @intEntityId
					,@intEntityContactId
					,L.intEntityLocationId
					,0
					,1
					,L.ysnDefaultLocation
				FROM tblEMEntityLocation L
				WHERE intEntityLocationId = @intEntityLocationId
			END
			ELSE
			BEGIN
				SELECT @strShipToAddress1 = NULL
					,@strShipToAddress2 = NULL
					,@strShipToCity = NULL
					,@strShipToState = NULL
					,@strShipToZip = NULL

				SELECT @strShipToAddress1 = strShipFromAddress1
					,@strShipToAddress2 = strShipFromAddress2
					,@strShipToCity = strShipFromCity
					,@strShipToState = strShipFromState
					,@strShipToZip = strShipFromZip
				FROM tblMFEDI943
				WHERE strDepositorOrderNumber = @strOrderNo

				IF NOT EXISTS (
						SELECT *
						FROM tblEMEntityLocation
						WHERE intEntityLocationId = @intEntityLocationId
							AND strAddress = @strShipToAddress1 + CASE 
								WHEN IsNULL(@strShipToAddress2, '') <> ''
									THEN ' ' + @strShipToAddress2
								ELSE ''
								END
							AND strCity = @strShipToCity
							AND strState = @strShipToState
							AND strZipCode = @strShipToZip
						)
				BEGIN
					UPDATE tblEMEntityLocation
					SET strAddress = @strShipToAddress1 + CASE 
							WHEN IsNULL(@strShipToAddress2, '') <> ''
								THEN ' ' + @strShipToAddress2
							ELSE ''
							END
						,strCity = @strShipToCity
						,strState = @strShipToState
						,strZipCode = @strShipToZip
					WHERE intEntityLocationId = @intEntityLocationId

					--Update Customer Location Notification
					UPDATE tblMFEDI943
					SET ysnNotify = 1
						,intWarehouseCodeType = 3
					WHERE strDepositorOrderNumber = @strOrderNo
				END
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblEMEntityType
					WHERE intEntityId = @intEntityId
						AND strType = 'Vendor'
					)
			BEGIN
				INSERT INTO tblEMEntityType (
					intEntityId
					,strType
					,intConcurrencyId
					)
				SELECT @intEntityId
					,'Vendor'
					,1
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblAPVendor
					WHERE intEntityId = @intEntityId
					)
			BEGIN
				SELECT @strEntityNo = strEntityNo
				FROM tblEMEntity
				WHERE intEntityId = @intEntityId

				INSERT INTO tblAPVendor (
					intEntityId
					,strVendorPayToId
					,intVendorType
					,strVendorId
					,strVendorAccountNum
					,ysnPymtCtrlActive
					,ysnPymtCtrlAlwaysDiscount
					,ysnPymtCtrlEFTActive
					,ysnPymtCtrlHold
					,ysnWithholding
					,dblCreditLimit
					,intConcurrencyId
					)
				SELECT DISTINCT @intEntityId
					,''
					,0
					,@strEntityNo
					,''
					,1
					,0
					,0
					,0
					,0
					,0
					,1
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

			DELETE
			FROM @tblMFItemLineNumber

			INSERT INTO @tblMFItemLineNumber
			SELECT intEDI943Id
				,Row_Number() OVER (
					PARTITION BY strFileName ORDER BY intEDI943Id
					)
			FROM tblMFEDI943
			WHERE strDepositorOrderNumber = @strOrderNo

			UPDATE tblMFEDI943
			SET intLineNumber = L.intLineNumber
			FROM tblMFEDI943 EDI
			JOIN @tblMFItemLineNumber L ON EDI.intEDI943Id = L.intEDI943Id
			WHERE strDepositorOrderNumber = @strOrderNo

			DELETE
			FROM @ReceiptStagingTable

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
				,intInventoryReceiptId
				)
			SELECT DISTINCT strReceiptType = 'Direct'
				,intEntityVendorId = EL.intEntityId
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = IL.intLocationId
				,strBillOfLadding = NULL
				,intItemId = I.intItemId
				,intItemLocationId = IL.intItemLocationId
				,intItemUOMId = (
					CASE 
						WHEN I.intWeightUOMId = IU.intUnitMeasureId
							THEN IU2.intItemUOMId
						ELSE IU.intItemUOMId
						END
					)
				,intContractHeaderId = NULL
				,intContractDetailId = NULL
				,dtmDate = GETDATE()
				,intShipViaId = NULL
				,dblQty = (
					CASE 
						WHEN I.intWeightUOMId = IU.intUnitMeasureId
							THEN dbo.fnMFConvertQuantityToTargetItemUOM(IU.intItemUOMId, IU2.intItemUOMId, dblQtyShipped)
						ELSE dblQtyShipped
						END
					)
				,intGrossNetUOMId = CASE 
					WHEN I.ysnLotWeightsRequired = 1
						THEN I.intWeightUOMId
					ELSE NULL
					END
				,dblGross = CASE 
					WHEN I.ysnLotWeightsRequired = 1
						THEN dbo.fnMFConvertQuantityToTargetItemUOM(IU.intItemUOMId, IU1.intItemUOMId, dblQtyShipped)
					ELSE NULL
					END
				,dblNet = CASE 
					WHEN I.ysnLotWeightsRequired = 1
						THEN dbo.fnMFConvertQuantityToTargetItemUOM(IU.intItemUOMId, IU1.intItemUOMId, dblQtyShipped)
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
				,intInventoryReceiptId = @intInventoryReceiptId
			FROM tblMFEDI943 EDI
			JOIN tblICItem I ON I.strItemNo = EDI.strVendorItemNumber
			JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
				AND IL.intLocationId IS NOT NULL
				AND IL.ysnOpenPricePLU = 1
			JOIN tblEMEntityLocation EL ON 1 = 1
				AND EL.intEntityLocationId = @intEntityLocationId
			JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				AND UM.strUnitMeasure = EDI.strUOM
			LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemId = I.intItemId
				AND IU1.intUnitMeasureId = I.intWeightUOMId
			JOIN tblICItemUOM IU2 ON I.intItemId = IU2.intItemId
				AND (
					IU2.ysnAllowPurchase = 1
					OR IU2.ysnAllowSale = 1
					)
			JOIN tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
				AND UM2.strUnitType <> 'Weight'
			WHERE EDI.strDepositorOrderNumber = @strOrderNo
				AND EDI.strType <> 'Cancel'
			ORDER BY EDI.intLineNumber

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
				,intInventoryReceiptId
				)
			SELECT DISTINCT strReceiptType = 'Direct'
				,intEntityVendorId = EL.intEntityId
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
						THEN dbo.fnMFConvertQuantityToTargetItemUOM(IU.intItemUOMId, IU1.intItemUOMId, dblQtyShipped)
					ELSE NULL
					END
				,dblNet = CASE 
					WHEN I.ysnLotWeightsRequired = 1
						THEN dbo.fnMFConvertQuantityToTargetItemUOM(IU.intItemUOMId, IU1.intItemUOMId, dblQtyShipped)
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
				,intInventoryReceiptId = @intInventoryReceiptId
			FROM tblMFEDI943 EDI
			JOIN tblICItem I ON I.strItemNo = EDI.strVendorItemNumber
			JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
				AND IL.intLocationId IS NOT NULL
				AND IL.ysnOpenPricePLU = 1
			JOIN tblEMEntityLocation EL ON 1 = 1
				AND EL.intEntityLocationId = @intEntityLocationId
			JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
				AND (
					IU.ysnAllowPurchase = 1
					OR IU.ysnAllowSale = 1
					)
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				AND UM.strUnitType <> 'Weight'
				AND UM.strUnitMeasure <> EDI.strUOM
			LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemId = I.intItemId
				AND IU1.intUnitMeasureId = I.intWeightUOMId
			WHERE EDI.strDepositorOrderNumber = @strOrderNo
				AND EDI.strType <> 'Cancel'
				AND NOT EXISTS (
					SELECT *
					FROM @ReceiptStagingTable RST
					WHERE RST.intItemId = I.intItemId
					)
			ORDER BY EDI.intLineNumber

			IF EXISTS (
					SELECT *
					FROM @ReceiptStagingTable
					)
			BEGIN
				EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
					,@OtherCharges = @OtherCharges
					,@intUserId = @intUserId;

				SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
				FROM #tmpAddItemReceiptResult

				DELETE
				FROM #tmpAddItemReceiptResult

				UPDATE tblICInventoryReceipt
				SET strWarehouseRefNo = @strOrderNo
				WHERE intInventoryReceiptId = @intInventoryReceiptId
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI943
					WHERE strDepositorOrderNumber = @strOrderNo
						AND strType = 'Cancel'
					)
			BEGIN
				DELETE IRL
				FROM dbo.tblICInventoryReceipt IR
				JOIN dbo.tblICInventoryReceiptItem IRL ON IRL.intInventoryReceiptId = IR.intInventoryReceiptId
					AND IR.intInventoryReceiptId = @intInventoryReceiptId
				JOIN tblICItem I ON I.intItemId = IRL.intItemId
				JOIN tblMFEDI943 EDI ON EDI.strVendorItemNumber = I.strItemNo
				WHERE EDI.strDepositorOrderNumber = @strOrderNo
					AND EDI.strType = 'Cancel'

				IF NOT EXISTS (
						SELECT *
						FROM tblICInventoryReceiptItem
						WHERE intInventoryReceiptId = @intInventoryReceiptId
						)
				BEGIN
					DELETE
					FROM dbo.tblICInventoryReceipt
					WHERE intInventoryReceiptId = @intInventoryReceiptId

					SELECT @intInventoryReceiptId = NULL
				END
			END

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

			IF @intInventoryReceiptId > 0
			BEGIN
				SELECT @strReceiptNumber = strReceiptNumber
				FROM tblICInventoryReceipt
				WHERE intInventoryReceiptId = @intInventoryReceiptId

				SELECT @intScreenId = intScreenId
				FROM tblSMScreen
				WHERE strNamespace = 'Inventory.view.InventoryReceipt'

				SELECT @intCustomTabId = intCustomTabId
				FROM tblSMCustomTab
				WHERE intScreenId = @intScreenId

				SELECT @intCustomTabDetailId = [Extent1].[intCustomTabDetailId]
				FROM [dbo].[tblSMCustomTabDetail] AS [Extent1]
				WHERE [Extent1].[intCustomTabId] = @intCustomTabId
					AND strFieldName = 'CreatedByEDI'

				SELECT @intCustomTabDetailId0 = [Extent1].[intCustomTabDetailId]
				FROM [dbo].[tblSMCustomTabDetail] AS [Extent1]
				WHERE [Extent1].[intCustomTabId] = @intCustomTabId
					AND strFieldName = 'Id'

				DECLARE @tblCustomTabColumn TABLE (
					intCustomTabDetailId INT
					,strValue NVARCHAR(50)
					)

				DELETE
				FROM @tblCustomTabColumn

				INSERT INTO @tblCustomTabColumn
				SELECT Extent1.intCustomTabDetailId
					,NULL
				FROM dbo.tblSMCustomTabDetail AS Extent1
				WHERE Extent1.intCustomTabId = @intCustomTabId
					AND strFieldName NOT IN (
						'CreatedByEDI'
						,'Id'
						)

				IF NOT EXISTS (
						SELECT *
						FROM [tblSMTransaction]
						WHERE [intScreenId] = @intScreenId
							--AND [strTransactionNo] = @strReceiptNumber
							AND [intRecordId] = @intInventoryReceiptId
						)
				BEGIN
					INSERT [dbo].[tblSMTransaction] (
						[intScreenId]
						,[strTransactionNo]
						,[intEntityId]
						,[intRecordId]
						,[intConcurrencyId]
						)
					SELECT @intScreenId
						,@strReceiptNumber
						,1
						,@intInventoryReceiptId
						,1

					SELECT @intTransactionId = scope_identity()
				END
				ELSE
				BEGIN
					SELECT @intTransactionId = intTransactionId
					FROM [tblSMTransaction]
					WHERE [intScreenId] = @intScreenId
						--AND [strTransactionNo] = @strReceiptNumber
						AND [intRecordId] = @intInventoryReceiptId
				END

				IF NOT EXISTS (
						SELECT *
						FROM tblSMTabRow
						WHERE intCustomTabId = @intCustomTabId
							AND [intTransactionId] = @intTransactionId
						)
				BEGIN
					INSERT [dbo].[tblSMTabRow] (
						[intCustomTabId]
						,[intTransactionId]
						,[intSort]
						,[intConcurrencyId]
						)
					SELECT @intCustomTabId
						,@intTransactionId
						,0
						,1

					SELECT @intTabRowId = scope_identity()
				END
				ELSE
				BEGIN
					SELECT @intTabRowId = intTabRowId
					FROM tblSMTabRow
					WHERE intCustomTabId = @intCustomTabId
						AND [intTransactionId] = @intTransactionId
				END

				IF NOT EXISTS (
						SELECT *
						FROM tblSMFieldValue
						WHERE intTabRowId = @intTabRowId
							AND intCustomTabDetailId = @intCustomTabDetailId0
						)
				BEGIN
					INSERT dbo.tblSMFieldValue (
						intTabRowId
						,intCustomTabDetailId
						,strValue
						,intConcurrencyId
						)
					SELECT @intTabRowId
						,@intCustomTabDetailId0
						,1
						,1
				END

				IF NOT EXISTS (
						SELECT *
						FROM [tblSMFieldValue]
						WHERE [intTabRowId] = @intTabRowId
							AND [intCustomTabDetailId] = @intCustomTabDetailId
						)
				BEGIN
					INSERT [dbo].[tblSMFieldValue] (
						[intTabRowId]
						,[intCustomTabDetailId]
						,[strValue]
						,[intConcurrencyId]
						)
					SELECT @intTabRowId
						,@intCustomTabDetailId
						,1
						,1
				END
				ELSE
				BEGIN
					UPDATE [tblSMFieldValue]
					SET [strValue] = 1
						,[intConcurrencyId] = [intConcurrencyId] + 1
					WHERE [intTabRowId] = @intTabRowId
						AND [intCustomTabDetailId] = @intCustomTabDetailId
				END

				INSERT dbo.tblSMFieldValue (
					intTabRowId
					,intCustomTabDetailId
					,strValue
					,intConcurrencyId
					)
				SELECT @intTabRowId
					,C.intCustomTabDetailId
					,C.strValue
					,1
				FROM @tblCustomTabColumn C
				WHERE NOT EXISTS (
						SELECT *
						FROM tblSMFieldValue FV
						WHERE FV.intTabRowId = @intTabRowId
							AND FV.intCustomTabDetailId = C.intCustomTabDetailId
						)
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
				,strWarehouseCode
				,intWarehouseCodeType
				,ysnNotify
				,intInventoryReceiptItemId
				)
			SELECT EDI943.intEDI943Id
				,EDI943.intTransactionId
				,EDI943.strCustomerId
				,EDI943.strType
				,EDI943.strDepositorOrderNumber
				,EDI943.dtmDate
				,EDI943.strShipmentId
				,EDI943.strActionCode
				,EDI943.strShipFromName
				,EDI943.strShipFromAddress1
				,EDI943.strShipFromAddress2
				,EDI943.strShipFromCity
				,EDI943.strShipFromState
				,EDI943.strShipFromZip
				,EDI943.strShipFromCode
				,EDI943.strTransportationMethod
				,EDI943.strSCAC
				,EDI943.dblTotalNumberofUnitsShipped
				,EDI943.dblTotalWeight
				,EDI943.strWeightUOM
				,EDI943.strVendorItemNumber
				,EDI943.strDescription
				,EDI943.dblQtyShipped
				,EDI943.strUOM
				,EDI943.dtmCreated
				,'SUCCESS'
				,@intInventoryReceiptId
				,EDI943.strFileName
				,EDI943.strParentLotNumber
				,EDI943.intLineNumber
				,EDI943.strWarehouseCode
				,EDI943.intWarehouseCodeType
				,EDI943.ysnNotify
				,RI.intInventoryReceiptItemId
			FROM tblMFEDI943 EDI943
			JOIN tblICItem I ON I.strItemNo = EDI943.strVendorItemNumber
			LEFT JOIN tblICInventoryReceiptItem RI ON RI.intItemId = I.intItemId
				AND RI.intInventoryReceiptId = @intInventoryReceiptId
				AND EDI943.intLineNumber = RI.intSourceId
			WHERE strDepositorOrderNumber = @strOrderNo

			DELETE
			FROM tblMFEDI943
			WHERE strDepositorOrderNumber = @strOrderNo

			INSERT INTO tblMFEDIStage944 (
				intInventoryReceiptId
				,intStatusId
				)
			SELECT @intInventoryReceiptId
				,0
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ''
			SET @ErrMsg = ERROR_MESSAGE()

			DELETE
			FROM tblMFEDI943Error
			WHERE strDepositorOrderNumber = @strOrderNo

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
				,strWarehouseCode
				,intWarehouseCodeType
				,ysnNotify
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
				,strWarehouseCode
				,intWarehouseCodeType
				,ysnNotify
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
