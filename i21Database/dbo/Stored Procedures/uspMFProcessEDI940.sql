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
		,@intTabRowId INT
		,@intTransactionId INT
		,@intScreenId INT
		,@intCustomTabId INT
		,@intCustomTabDetailId0 INT
		,@intCustomTabDetailId1 INT
		,@intCustomTabDetailId2 INT
		,@intCustomTabDetailId3 INT
		,@strShipmentNumber NVARCHAR(50)
		,@strPONumber NVARCHAR(50)
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
		,@dtmShipmentDate DATETIME
		,@dtmDeliveryRequestedDate DATETIME
		,@intFunctionalCurrencyId INT
		,@intDefaultForexRateTypeId INT
		,@strLocationCount NVARCHAR(50)
		,@ysnDefaultLocation BIT
		,@strShipmentMethodOfPayment NVARCHAR(50)
		,@intShipViaId INT
		,@strSCAC NVARCHAR(50)
		,@strTransportationMethod NVARCHAR(50)

	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

	SELECT TOP 1 @intDefaultForexRateTypeId = intInventoryRateTypeId
	FROM tblSMMultiCurrency

	DECLARE @ShipmentStagingTable ShipmentStagingTable
	DECLARE @FinalShipmentStagingTable ShipmentStagingTable
	DECLARE @OtherCharges ShipmentChargeStagingTable
	DECLARE @tblMFOrderNo TABLE (
		intRecordId INT identity(1, 1)
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblMFSession TABLE (intEDI940Id INT)
	DECLARE @tblMFItem TABLE (
		intItemId INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblMFSession (intEDI940Id)
	SELECT intEDI940Id
	FROM tblMFEDI940

	INSERT INTO @tblMFOrderNo (strOrderNo)
	SELECT DISTINCT strDepositorOrderNumber
	FROM tblMFEDI940

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

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'Inventory.view.InventoryShipment'

	SELECT @intCustomTabId = intCustomTabId
	FROM tblSMCustomTab
	WHERE intScreenId = @intScreenId

	SELECT @intCustomTabDetailId0 = Extent1.intCustomTabDetailId
	FROM dbo.tblSMCustomTabDetail AS Extent1
	WHERE Extent1.intCustomTabId = @intCustomTabId
		AND strFieldName = 'Id'

	SELECT @intCustomTabDetailId1 = Extent1.intCustomTabDetailId
	FROM dbo.tblSMCustomTabDetail AS Extent1
	WHERE Extent1.intCustomTabId = @intCustomTabId
		AND strFieldName = 'CustomerPONo'

	SELECT @intCustomTabDetailId2 = Extent1.intCustomTabDetailId
	FROM dbo.tblSMCustomTabDetail AS Extent1
	WHERE Extent1.intCustomTabId = @intCustomTabId
		AND strFieldName = 'CreatedByEDI'

	SELECT @intCustomTabDetailId3 = Extent1.intCustomTabDetailId
	FROM dbo.tblSMCustomTabDetail AS Extent1
	WHERE Extent1.intCustomTabId = @intCustomTabId
		AND strFieldName = 'CustomerPickUp'

	DECLARE @tblCustomTabColumn TABLE (
		intCustomTabDetailId INT
		,strValue NVARCHAR(50)
		)

	INSERT INTO @tblCustomTabColumn
	SELECT Extent1.intCustomTabDetailId
		,NULL
	FROM dbo.tblSMCustomTabDetail AS Extent1
	WHERE Extent1.intCustomTabId = @intCustomTabId
		AND strFieldName NOT IN (
			'Id'
			,'CustomerPickUp'
			,'CustomerPONo'
			,'CreatedByEDI'
			)

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @intRecordId = min(intRecordId)
	FROM @tblMFOrderNo

	WHILE @intRecordId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @strOrderNo = NULL
				,@strCustomerCode = NULL
				,@strShipToName = NULL
				,@intInventoryShipmentId = NULL
				,@dtmShipmentDate = NULL
				,@dtmDeliveryRequestedDate = NULL
				,@strPONumber = NULL
				,@strShipmentMethodOfPayment = NULL
				,@intShipViaId = NULL
				,@strSCAC = NULL
				,@strTransportationMethod = NULL

			SELECT @strErrorMessage = ''

			SELECT @strOrderNo = strOrderNo
			FROM @tblMFOrderNo
			WHERE intRecordId = @intRecordId

			SELECT @strCustomerCode = strCustomerCode
				,@strShipToName = strShipToName
				,@dtmShipmentDate = strShipmentDate
				,@dtmDeliveryRequestedDate = strDeliveryRequestedDate
				,@strPONumber = strPONumber
				,@strShipToState = strShipToState
				,@strShipmentMethodOfPayment = strShipmentMethodOfPayment
				,@strSCAC = strSCAC
				,@strTransportationMethod = strTransportationMethod
			FROM tblMFEDI940 EDI940
			WHERE strDepositorOrderNumber = @strOrderNo

			IF @strOrderNo IS NULL
				OR @strOrderNo = ''
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + 'Depositor Order Number cannot be blank.'
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

				SELECT @strErrorMessage = @strErrorMessage + ' Item Number(s) ' + @strItemNo + ' does not exist.'
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI940 EDI940
					WHERE strDepositorOrderNumber = @strOrderNo
						AND (
							dblQtyOrdered IS NULL
							OR dblQtyOrdered = 0
							)
						AND strPurpose <> 'Cancel'
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
					AND strPurpose <> 'Cancel'

				IF len(@strItemNo) > 0
					SELECT @strItemNo = Left(@strItemNo, len(@strItemNo) - 1)

				SELECT @strErrorMessage = @strErrorMessage + ' Qty Ordered cannot be blank for the item number ' + @strItemNo + '.'
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblMFEDI940 EDI940
					JOIN tblICItem I ON I.strItemNo = EDI940.strCustomerItemNumber
					JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
						AND (
							IU.ysnAllowPurchase = 1
							OR IU.ysnAllowSale = 1
							)
					JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
						AND (
							UM.strUnitType <> 'Weight'
							OR UM.strUnitMeasure = EDI940.strUOM
							)
					WHERE strDepositorOrderNumber = @strOrderNo
					)
			BEGIN
				SELECT @strItemNo = ''

				SELECT @strItemNo = @strItemNo + strCustomerItemNumber + ', '
				FROM tblMFEDI940 EDI940
				JOIN tblICItem I ON I.strItemNo = EDI940.strCustomerItemNumber
				JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
					AND (
						IU.ysnAllowPurchase = 1
						OR IU.ysnAllowSale = 1
						)
				LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND (
						UM.strUnitType <> 'Weight'
						OR UM.strUnitMeasure = EDI940.strUOM
						)
				WHERE strDepositorOrderNumber = @strOrderNo
					AND UM.intUnitMeasureId IS NULL

				SELECT @strErrorMessage = @strErrorMessage + 'Qty UOM cannot be blank for the item number ' + @strItemNo + '.'
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
				,EDI940.strUOM
			FROM tblMFEDI940 EDI940
			JOIN tblICItem I ON I.strItemNo = EDI940.strCustomerItemNumber
			WHERE strDepositorOrderNumber = @strOrderNo

			IF EXISTS (
					SELECT I.intItemId
						,Count(*)
					FROM @tblMFItem I
					JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
						AND (
							IU.ysnAllowPurchase = 1
							OR IU.ysnAllowSale = 1
							)
					JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
						AND UM.strUnitType <> 'Weight'
						AND I.intItemId NOT IN (
							SELECT I1.intItemId
							FROM @tblMFItem I1
							JOIN tblICItemUOM IU1 ON I1.intItemId = IU1.intItemId
								AND (
									IU1.ysnAllowPurchase = 1
									OR IU1.ysnAllowSale = 1
									)
							JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
								AND UM1.strUnitMeasure = I1.strUOM
							)
					GROUP BY I.intItemId
					HAVING Count(*) > 1
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
				HAVING Count(*) > 1

				SELECT @strErrorMessage = ' Multiple Pack UOM for the item number ' + @strItemNo + ' are configured. Please configure only one Pack UOM. '
			END

			IF EXISTS (
					SELECT *
					FROM tblICInventoryShipment
					WHERE strReferenceNumber = @strOrderNo
						AND ysnPosted = 1
					)
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + ' Inventory Shipment is already posted for the order number ' + @strOrderNo + '. '
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
					FROM tblICInventoryShipment
					WHERE strReferenceNumber = @strOrderNo
					)
			BEGIN
				SELECT @intInventoryShipmentId = intInventoryShipmentId
				FROM tblICInventoryShipment
				WHERE strReferenceNumber = @strOrderNo
			END

			SELECT @intEntityLocationId = NULL

			SELECT @intEntityId = NULL

			SELECT @intEntityLocationId = intEntityLocationId
				,@intEntityId = intEntityId
			FROM tblEMEntityLocation
			WHERE strCheckPayeeName = @strCustomerCode

			IF @intEntityId IS NULL
			BEGIN
				SELECT @intEntityId = intEntityId
				FROM tblEMEntity
				WHERE strName = @strShipToName
					AND strEntityNo <> ''
			END

			IF @intEntityLocationId IS NULL
			BEGIN
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
						,'Customer'
						,1

					INSERT INTO tblARCustomer (
						intEntityId
						,strCustomerNumber
						,strType
						,strPricing
						,intBillToId
						,intShipToId
						,dblCreditLimit
						,dblARBalance
						,intConcurrencyId
						,intCurrencyId
						)
					SELECT @intEntityId
						,@strEntityNo
						,'Company'
						,'None'
						,NULL
						,NULL
						,0
						,0
						,1
						,(
							SELECT TOP 1 intCurrencyID
							FROM tblSMCurrency
							WHERE strCurrency = 'USD'
							)

					--New Customer Notification
					UPDATE tblMFEDI940
					SET ysnNotify = 1
						,intCustomerCodeType = 1
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
					,Rtrim(strShipToState + ' ' + @strLocationCount) strLocationName
					,strShipToAddress1 + CASE 
						WHEN IsNULL(strShipToAddress2, '') <> ''
							THEN ' ' + strShipToAddress2
						ELSE ''
						END strAddress
					,strShipToCity strCity
					,'United States' strCountry
					,strShipToState strState
					,strShipToZip strZipCode
					,1 intTermsId
					,@ysnDefaultLocation AS ysnDefaultLocation
					,1 ysnActive
					,'(UTC-06:00) Central Time (US & Canada)' strTimezone
					,1 intConcurrencyId
					,strCustomerCode strCheckPayeeName
				FROM tblMFEDI940
				WHERE strDepositorOrderNumber = @strOrderNo

				SELECT @intEntityLocationId = SCOPE_IDENTITY()

				--New Customer Location Notification
				UPDATE tblMFEDI940
				SET ysnNotify = 1
					,intCustomerCodeType = CASE 
						WHEN intCustomerCodeType = 0
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

				SELECT @strShipToAddress1 = strShipToAddress1
					,@strShipToAddress2 = strShipToAddress2
					,@strShipToCity = strShipToCity
					,@strShipToState = strShipToState
					,@strShipToZip = strShipToZip
				FROM tblMFEDI940
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
					UPDATE tblMFEDI940
					SET ysnNotify = 1
						,intCustomerCodeType = 3
					WHERE strDepositorOrderNumber = @strOrderNo
				END
			END

			IF @intInventoryShipmentId IS NULL
			BEGIN
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

				DELETE
				FROM @ShipmentStagingTable

				DELETE
				FROM @FinalShipmentStagingTable

				IF IsNULL(@strShipmentMethodOfPayment, '') <> ''
					AND NOT EXISTS (
						SELECT *
						FROM tblSMFreightTerms
						WHERE strFreightTerm = @strShipmentMethodOfPayment
						)
				BEGIN
					INSERT INTO tblSMFreightTerms (
						strFreightTerm
						,strFobPoint
						,ysnActive
						,intConcurrencyId
						)
					SELECT @strShipmentMethodOfPayment
						,'Other'
						,1
						,1
				END

				SELECT @intShipViaId = intEntityId
				FROM tblSMShipVia
				WHERE strFederalId = @strSCAC

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
					,dtmRequestedArrivalDate
					,intShipViaId
					)
				SELECT DISTINCT intOrderType = 4
					,intSourceType = 0
					,intEntityCustomerId = EL.intEntityId
					,dtmShipDate = EDI.strShipmentDate
					,intShipFromLocationId = IL.intLocationId
					,intShipToLocationId = EL.intEntityLocationId
					,intFreightTermId = IsNULL(FT.intFreightTermId, (
							SELECT TOP 1 intFreightTermId
							FROM tblSMFreightTerms
							WHERE strFreightTerm = 'Collect'
							))
					,strSourceScreenName = 'EDI940'
					,strBOLNumber = ''
					,strReferenceNumber = EDI.strDepositorOrderNumber
					,intItemId = I.intItemId
					,intOwnershipType = 1
					,dblQuantity = (
						CASE 
							WHEN I.intWeightUOMId = IU.intUnitMeasureId
								THEN dbo.fnMFConvertQuantityToTargetItemUOM(IU.intItemUOMId, IU2.intItemUOMId, EDI.dblQtyOrdered)
							ELSE EDI.dblQtyOrdered
							END
						)
					,intItemUOMId = (
						CASE 
							WHEN I.intWeightUOMId = IU.intUnitMeasureId
								THEN IU2.intItemUOMId
							ELSE IU.intItemUOMId
							END
						)
					,intOrderId = NULL
					,intLineNo = EDI.intLineNumber
					,intWeightUOMId = NULL
					,dblUnitPrice = 0
					,intCurrencyId = NULL
					,intForexRateTypeId = NULL
					,dblForexRate = NULL
					,dtmRequestedArrivalDate = EDI.strShipmentDate
					,intShipViaId = @intShipViaId
				FROM tblMFEDI940 EDI
				JOIN tblICItem I ON I.strItemNo = EDI.strCustomerItemNumber
				JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					AND IL.intLocationId IS NOT NULL
					AND IL.ysnOpenPricePLU = 1
				JOIN tblEMEntityLocation EL ON 1 = 1
					AND EL.intEntityLocationId = @intEntityLocationId
				JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND UM.strUnitMeasure = EDI.strUOM
				JOIN tblICItemUOM IU2 ON I.intItemId = IU2.intItemId
					AND (
						IU2.ysnAllowPurchase = 1
						OR IU2.ysnAllowSale = 1
						)
				JOIN tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
					AND UM2.strUnitType <> 'Weight'
				LEFT JOIN tblSMFreightTerms FT ON FT.strFreightTerm = EDI.strShipmentMethodOfPayment
				WHERE EDI.strDepositorOrderNumber = @strOrderNo
					AND strPurpose <> 'Cancel'

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
					,dtmRequestedArrivalDate
					,intShipViaId
					)
				SELECT DISTINCT intOrderType = 4
					,intSourceType = 0
					,intEntityCustomerId = EL.intEntityId
					,dtmShipDate = EDI.strShipmentDate
					,intShipFromLocationId = IL.intLocationId
					,intShipToLocationId = EL.intEntityLocationId
					,intFreightTermId = IsNULL(FT.intFreightTermId, (
							SELECT TOP 1 intFreightTermId
							FROM tblSMFreightTerms
							WHERE strFreightTerm = 'Collect'
							))
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
					,dtmRequestedArrivalDate = EDI.strShipmentDate
					,intShipViaId = @intShipViaId
				FROM tblMFEDI940 EDI
				JOIN tblICItem I ON I.strItemNo = EDI.strCustomerItemNumber
				JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					AND IL.intLocationId IS NOT NULL
					AND IL.ysnOpenPricePLU = 1
				JOIN tblEMEntityLocation EL ON 1 = 1
					AND EL.intEntityLocationId = @intEntityLocationId
				JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND UM.strUnitType <> 'Weight'
					AND (
						IU.ysnAllowPurchase = 1
						OR IU.ysnAllowSale = 1
						)
				LEFT JOIN tblSMFreightTerms FT ON FT.strFreightTerm = EDI.strShipmentMethodOfPayment
				WHERE EDI.strDepositorOrderNumber = @strOrderNo
					AND NOT EXISTS (
						SELECT *
						FROM @ShipmentStagingTable SST
						WHERE SST.intItemId = I.intItemId
						)
					AND strPurpose <> 'Cancel'

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
					,dtmRequestedArrivalDate
					,intShipViaId
					)
				SELECT DISTINCT intOrderType = 4
					,intSourceType = 0
					,intEntityCustomerId = EL.intEntityId
					,dtmShipDate = EDI.strShipmentDate
					,intShipFromLocationId = IL.intLocationId
					,intShipToLocationId = EL.intEntityLocationId
					,intFreightTermId = IsNULL(FT.intFreightTermId, (
							SELECT TOP 1 intFreightTermId
							FROM tblSMFreightTerms
							WHERE strFreightTerm = 'Collect'
							))
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
					,dtmRequestedArrivalDate = EDI.strShipmentDate
					,intShipViaId = @intShipViaId
				FROM tblMFEDI940 EDI
				JOIN tblICItem I ON I.strItemNo = EDI.strCustomerItemNumber
				JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					AND IL.intLocationId IS NOT NULL
					AND IL.ysnOpenPricePLU = 1
				JOIN tblEMEntityLocation EL ON 1 = 1
					AND EL.intEntityLocationId = @intEntityLocationId
				JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND UM.strUnitMeasure = EDI.strUOM
				LEFT JOIN tblSMFreightTerms FT ON FT.strFreightTerm = EDI.strShipmentMethodOfPayment
				WHERE EDI.strDepositorOrderNumber = @strOrderNo
					AND NOT EXISTS (
						SELECT *
						FROM @ShipmentStagingTable SST
						WHERE SST.intItemId = I.intItemId
						)
					AND strPurpose <> 'Cancel'

				INSERT INTO @FinalShipmentStagingTable (
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
					,dtmRequestedArrivalDate
					,intShipViaId
					)
				SELECT intOrderType
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
					,dtmRequestedArrivalDate
					,intShipViaId
				FROM @ShipmentStagingTable
				ORDER BY intLineNo

				IF EXISTS (
						SELECT *
						FROM @FinalShipmentStagingTable
						)
				BEGIN
					EXEC dbo.uspICAddItemShipment @Items = @FinalShipmentStagingTable
						,@Charges = @OtherCharges
						,@intUserId = @intUserId;

					SELECT TOP 1 @intInventoryShipmentId = intInventoryShipmentId
					FROM #tmpAddItemShipmentResult

					UPDATE tblICInventoryShipment
					SET dtmRequestedArrivalDate = @dtmDeliveryRequestedDate
						,strComment = @strPONumber
						,intShipViaId = @intShipViaId
					WHERE intInventoryShipmentId = @intInventoryShipmentId

					DELETE
					FROM #tmpAddItemShipmentResult
				END
			END
			ELSE
			BEGIN
				IF NOT EXISTS (
						SELECT *
						FROM tblICInventoryShipment
						WHERE intInventoryShipmentId = @intInventoryShipmentId
							AND intEntityCustomerId = @intEntityId
							AND intShipToLocationId = @intEntityLocationId
						)
				BEGIN
					UPDATE tblICInventoryShipment
					SET intEntityCustomerId = @intEntityId
						,intShipToLocationId = @intEntityLocationId
						,dtmShipDate = @dtmShipmentDate
						,dtmRequestedArrivalDate = @dtmDeliveryRequestedDate
					WHERE intInventoryShipmentId = @intInventoryShipmentId
				END

				DELETE
				FROM @ShipmentStagingTable

				DELETE
				FROM @FinalShipmentStagingTable

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
					,dtmRequestedArrivalDate
					,intShipViaId
					)
				SELECT DISTINCT intOrderType = 4
					,intSourceType = 0
					,intEntityCustomerId = EL.intEntityId
					,dtmShipDate = EDI.strShipmentDate
					,intShipFromLocationId = IL.intLocationId
					,intShipToLocationId = EL.intEntityLocationId
					,intFreightTermId = (
						SELECT TOP 1 intFreightTermId
						FROM tblSMFreightTerms
						WHERE strFreightTerm = 'Collect'
						)
					,strSourceScreenName = 'EDI940'
					,strBOLNumber = ''
					,strReferenceNumber = EDI.strDepositorOrderNumber
					,intItemId = I.intItemId
					,intOwnershipType = 1
					,dblQuantity = (
						CASE 
							WHEN I.intWeightUOMId = IU.intUnitMeasureId
								THEN dbo.fnMFConvertQuantityToTargetItemUOM(IU.intItemUOMId, IU2.intItemUOMId, EDI.dblQtyOrdered)
							ELSE EDI.dblQtyOrdered
							END
						)
					,intItemUOMId = (
						CASE 
							WHEN I.intWeightUOMId = IU.intUnitMeasureId
								THEN IU2.intItemUOMId
							ELSE IU.intItemUOMId
							END
						)
					,intOrderId = NULL
					,intLineNo = EDI.intLineNumber
					,intWeightUOMId = NULL
					,dblUnitPrice = 0
					,intCurrencyId = NULL
					,intForexRateTypeId = NULL
					,dblForexRate = NULL
					,dtmRequestedArrivalDate = EDI.strShipmentDate
					,intShipViaId = @intShipViaId
				FROM tblMFEDI940 EDI
				JOIN tblICItem I ON I.strItemNo = EDI.strCustomerItemNumber
				JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					AND IL.intLocationId IS NOT NULL
					AND IL.ysnOpenPricePLU = 1
				JOIN tblEMEntityLocation EL ON 1 = 1
					AND EL.intEntityLocationId = @intEntityLocationId
				JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND UM.strUnitMeasure = EDI.strUOM
				JOIN tblICItemUOM IU2 ON I.intItemId = IU2.intItemId
					AND (
						IU2.ysnAllowPurchase = 1
						OR IU2.ysnAllowSale = 1
						)
				JOIN tblICUnitMeasure UM2 ON UM2.intUnitMeasureId = IU2.intUnitMeasureId
					AND UM2.strUnitType <> 'Weight'
				WHERE EDI.strDepositorOrderNumber = @strOrderNo
					AND strPurpose <> 'Cancel'

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
					,dtmRequestedArrivalDate
					,intShipViaId
					)
				SELECT DISTINCT intOrderType = 4
					,intSourceType = 0
					,intEntityCustomerId = EL.intEntityId
					,dtmShipDate = EDI.strShipmentDate
					,intShipFromLocationId = IL.intLocationId
					,intShipToLocationId = EL.intEntityLocationId
					,intFreightTermId = (
						SELECT TOP 1 intFreightTermId
						FROM tblSMFreightTerms
						WHERE strFreightTerm = 'Collect'
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
					,dtmRequestedArrivalDate = EDI.strShipmentDate
					,intShipViaId = @intShipViaId
				FROM tblMFEDI940 EDI
				JOIN tblICItem I ON I.strItemNo = EDI.strCustomerItemNumber
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
				WHERE EDI.strDepositorOrderNumber = @strOrderNo
					AND NOT EXISTS (
						SELECT *
						FROM @ShipmentStagingTable SST
						WHERE SST.intItemId = I.intItemId
						)
					AND strPurpose <> 'Cancel'

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
					,dtmRequestedArrivalDate
					,intShipViaId
					)
				SELECT DISTINCT intOrderType = 4
					,intSourceType = 0
					,intEntityCustomerId = EL.intEntityId
					,dtmShipDate = EDI.strShipmentDate
					,intShipFromLocationId = IL.intLocationId
					,intShipToLocationId = EL.intEntityLocationId
					,intFreightTermId = (
						SELECT TOP 1 intFreightTermId
						FROM tblSMFreightTerms
						WHERE strFreightTerm = 'Collect'
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
					,dtmRequestedArrivalDate = EDI.strShipmentDate
					,intShipViaId = @intShipViaId
				FROM tblMFEDI940 EDI
				JOIN tblICItem I ON I.strItemNo = EDI.strCustomerItemNumber
				JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					AND IL.intLocationId IS NOT NULL
					AND IL.ysnOpenPricePLU = 1
				JOIN tblEMEntityLocation EL ON 1 = 1
					AND EL.intEntityLocationId = @intEntityLocationId
				JOIN tblICItemUOM IU ON I.intItemId = IU.intItemId
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND UM.strUnitMeasure = EDI.strUOM
				WHERE EDI.strDepositorOrderNumber = @strOrderNo
					AND NOT EXISTS (
						SELECT *
						FROM @ShipmentStagingTable SST
						WHERE SST.intItemId = I.intItemId
						)
					AND strPurpose <> 'Cancel'

				IF EXISTS (
						SELECT *
						FROM @ShipmentStagingTable
						)
				BEGIN
					DELETE
					FROM tblICInventoryShipmentItem
					WHERE intInventoryShipmentId = @intInventoryShipmentId

					-- Insert shipment items
					INSERT INTO tblICInventoryShipmentItem (
						intInventoryShipmentId
						,intItemId
						,intOwnershipType
						,dblQuantity
						,intItemUOMId
						,intOrderId
						,intSourceId
						,intLineNo
						,intSubLocationId
						,intStorageLocationId
						,intCurrencyId
						,intWeightUOMId
						,dblUnitPrice
						,intDockDoorId
						,strNotes
						,intGradeId
						,intDiscountSchedule
						,intStorageScheduleTypeId
						,intDestinationGradeId
						,intDestinationWeightId
						,intForexRateTypeId
						,dblForexRate
						,intConcurrencyId
						)
					SELECT @intInventoryShipmentId
						,se.intItemId
						,se.intOwnershipType
						,se.dblQuantity
						,se.intItemUOMId
						,se.intOrderId
						,se.intSourceId
						,se.intLineNo
						,se.intSubLocationId
						,se.intStorageLocationId
						,se.intItemCurrencyId
						,se.intWeightUOMId
						,se.dblUnitPrice
						,se.intDockDoorId
						,se.strNotes
						,se.intGradeId
						,se.intDiscountSchedule
						,se.intStorageScheduleTypeId
						,se.intDestinationGradeId
						,se.intDestinationWeightId
						,intForexRateTypeId = CASE 
							WHEN ISNULL(s.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId
								THEN ISNULL(se.intForexRateTypeId, @intDefaultForexRateTypeId)
							ELSE NULL
							END
						,dblForexRate = CASE 
							WHEN ISNULL(s.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId
								THEN ISNULL(se.dblForexRate, forexRate.dblRate)
							ELSE NULL
							END
						,intConcurrencyId = 1
					FROM @ShipmentStagingTable se
					INNER JOIN tblICInventoryShipment s ON s.intInventoryShipmentId = @intInventoryShipmentId
					-- Get the SM forex rate. 
					OUTER APPLY dbo.fnSMGetForexRate(ISNULL(s.intCurrencyId, @intFunctionalCurrencyId), CASE 
								WHEN ISNULL(s.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId
									THEN ISNULL(se.intForexRateTypeId, @intDefaultForexRateTypeId)
								ELSE NULL
								END, se.dtmShipDate) forexRate
					ORDER BY se.intLineNo
				END
			END

			IF EXISTS (
					SELECT *
					FROM tblMFEDI940
					WHERE strDepositorOrderNumber = @strOrderNo
						AND strPurpose = 'Cancel'
					)
			BEGIN
				DELETE InvSI
				FROM dbo.tblICInventoryShipment InvS
				JOIN dbo.tblICInventoryShipmentItem InvSI ON InvSI.intInventoryShipmentId = InvS.intInventoryShipmentId
					AND InvS.intInventoryShipmentId = @intInventoryShipmentId
				JOIN tblICItem I ON I.intItemId = InvSI.intItemId
				JOIN tblMFEDI940 EDI ON EDI.strCustomerItemNumber = I.strItemNo
				WHERE EDI.strDepositorOrderNumber = @strOrderNo
					AND EDI.strPurpose = 'Cancel'

				IF NOT EXISTS (
						SELECT *
						FROM tblICInventoryShipmentItem
						WHERE intInventoryShipmentId = @intInventoryShipmentId
						)
				BEGIN
					DELETE
					FROM dbo.tblICInventoryShipment
					WHERE intInventoryShipmentId = @intInventoryShipmentId

					SELECT @intInventoryShipmentId = NULL
				END
			END

			IF @intInventoryShipmentId > 0
			BEGIN
				SELECT @strShipmentNumber = strShipmentNumber
				FROM tblICInventoryShipment
				WHERE intInventoryShipmentId = @intInventoryShipmentId

				SELECT @strPONumber = ''

				SELECT @strPONumber = strPONumber
				FROM tblMFEDI940 EDI940
				WHERE strDepositorOrderNumber = @strOrderNo

				SELECT @intTransactionId = NULL

				SELECT @intTransactionId = intTransactionId
				FROM tblSMTransaction
				WHERE intScreenId = @intScreenId
					--AND strTransactionNo = @strShipmentNumber
					AND intRecordId = @intInventoryShipmentId

				IF @intTransactionId IS NULL
				BEGIN
					INSERT dbo.tblSMTransaction (
						intScreenId
						,strTransactionNo
						,intEntityId
						,intRecordId
						,intConcurrencyId
						)
					SELECT @intScreenId
						,@strShipmentNumber
						,1
						,@intInventoryShipmentId
						,1

					SELECT @intTransactionId = scope_identity()
				END

				SELECT @intTabRowId = NULL

				SELECT @intTabRowId = intTabRowId
				FROM tblSMTabRow
				WHERE intCustomTabId = @intCustomTabId
					AND intTransactionId = @intTransactionId

				IF @intTabRowId IS NULL
				BEGIN
					INSERT dbo.tblSMTabRow (
						intCustomTabId
						,intTransactionId
						,intSort
						,intConcurrencyId
						)
					SELECT @intCustomTabId
						,@intTransactionId
						,0
						,1

					SELECT @intTabRowId = scope_identity()
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
						FROM tblSMFieldValue
						WHERE intTabRowId = @intTabRowId
							AND intCustomTabDetailId = @intCustomTabDetailId1
						)
				BEGIN
					INSERT dbo.tblSMFieldValue (
						intTabRowId
						,intCustomTabDetailId
						,strValue
						,intConcurrencyId
						)
					SELECT @intTabRowId
						,@intCustomTabDetailId1
						,@strPONumber
						,1
				END
				ELSE
				BEGIN
					UPDATE tblSMFieldValue
					SET strValue = @strPONumber
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intTabRowId = @intTabRowId
						AND intCustomTabDetailId = @intCustomTabDetailId1
				END

				IF NOT EXISTS (
						SELECT *
						FROM tblSMFieldValue
						WHERE intTabRowId = @intTabRowId
							AND intCustomTabDetailId = @intCustomTabDetailId2
						)
				BEGIN
					INSERT dbo.tblSMFieldValue (
						intTabRowId
						,intCustomTabDetailId
						,strValue
						,intConcurrencyId
						)
					SELECT @intTabRowId
						,@intCustomTabDetailId2
						,1
						,1
				END
				ELSE
				BEGIN
					UPDATE tblSMFieldValue
					SET strValue = 1
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intTabRowId = @intTabRowId
						AND intCustomTabDetailId = @intCustomTabDetailId2
				END

				IF NOT EXISTS (
						SELECT *
						FROM tblSMFieldValue
						WHERE intTabRowId = @intTabRowId
							AND intCustomTabDetailId = @intCustomTabDetailId3
						)
				BEGIN
					INSERT dbo.tblSMFieldValue (
						intTabRowId
						,intCustomTabDetailId
						,strValue
						,intConcurrencyId
						)
					SELECT @intTabRowId
						,@intCustomTabDetailId3
						,CASE 
							WHEN @strTransportationMethod = 'H'
								THEN 1
							ELSE 0
							END
						,1
				END
				ELSE
				BEGIN
					UPDATE tblSMFieldValue
					SET strValue = CASE 
							WHEN @strTransportationMethod = 'H'
								THEN 1
							ELSE 0
							END
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intTabRowId = @intTabRowId
						AND intCustomTabDetailId = @intCustomTabDetailId3
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

			INSERT INTO tblMFEDI940Archive (
				intEDI940Id
				,intTransactionId
				,strCustomerId
				,strPurpose
				,strDepositorOrderNumber
				,strPONumber
				,strShipToName
				,strShipToAddress1
				,strShipToAddress2
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
				,strShipmentDate
				,strTransportationMethod
				,strSCAC
				,strRouting
				,strShipmentMethodOfPayment
				,strCustomerCode
				,intCustomerCodeType
				,ysnNotify
				)
			SELECT intEDI940Id
				,intTransactionId
				,strCustomerId
				,strPurpose
				,strDepositorOrderNumber
				,strPONumber
				,strShipToName
				,strShipToAddress1
				,strShipToAddress2
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
				,strShipmentDate
				,strTransportationMethod
				,strSCAC
				,strRouting
				,strShipmentMethodOfPayment
				,strCustomerCode
				,intCustomerCodeType
				,ysnNotify
			FROM tblMFEDI940 EDI940
			JOIN tblICItem I ON I.strItemNo = strCustomerItemNumber
			LEFT JOIN tblICInventoryShipmentItem SI ON SI.intItemId = I.intItemId
				AND SI.intInventoryShipmentId = @intInventoryShipmentId
				AND EDI940.intLineNumber = SI.intLineNo
			WHERE strDepositorOrderNumber = @strOrderNo

			DELETE
			FROM tblMFEDI940
			WHERE strDepositorOrderNumber = @strOrderNo

			INSERT INTO tblMFEDIStage945 (
				intInventoryShipmentId
				,intStatusId
				)
			SELECT @intInventoryShipmentId
				,0
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			DELETE
			FROM tblMFEDI940Error
			WHERE strDepositorOrderNumber = @strOrderNo

			INSERT INTO tblMFEDI940Error (
				intEDI940Id
				,intTransactionId
				,strCustomerId
				,strPurpose
				,strDepositorOrderNumber
				,strPONumber
				,strShipToName
				,strShipToAddress1
				,strShipToAddress2
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
				,strShipmentDate
				,strTransportationMethod
				,strSCAC
				,strRouting
				,strShipmentMethodOfPayment
				,strCustomerCode
				,intCustomerCodeType
				,ysnNotify
				)
			SELECT intEDI940Id
				,intTransactionId
				,strCustomerId
				,strPurpose
				,strDepositorOrderNumber
				,strPONumber
				,strShipToName
				,strShipToAddress1
				,strShipToAddress2
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
				,strShipmentDate
				,strTransportationMethod
				,strSCAC
				,strRouting
				,strShipmentMethodOfPayment
				,strCustomerCode
				,intCustomerCodeType
				,ysnNotify
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
		FROM tblMFEDI940Archive A
		WHERE A.intEDI940Id IN (
				SELECT S.intEDI940Id
				FROM @tblMFSession S
				)
		) AS DT

	SELECT @strInfo1 = @strInfo1 + DT.strFileName + '; '
	FROM (
		SELECT DISTINCT strFileName
		FROM tblMFEDI940Error E
		WHERE E.intEDI940Id IN (
				SELECT S.intEDI940Id
				FROM @tblMFSession S
				)
		) AS DT

	IF EXISTS (
			SELECT *
			FROM tblMFEDI940Error E
			WHERE E.intEDI940Id IN (
					SELECT S.intEDI940Id
					FROM @tblMFSession S
					)
			)
	BEGIN
		SELECT @ErrMsg = ''

		SELECT @ErrMsg = @ErrMsg + strErrorMessage + '; '
		FROM (
			SELECT DISTINCT strErrorMessage
			FROM tblMFEDI940Error E
			WHERE E.intEDI940Id IN (
					SELECT S.intEDI940Id
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
