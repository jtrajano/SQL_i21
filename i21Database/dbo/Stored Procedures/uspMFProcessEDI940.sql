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
		,@intCustomTabDetailId INT
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
	DECLARE @ShipmentStagingTable ShipmentStagingTable
	DECLARE @OtherCharges ShipmentChargeStagingTable
	DECLARE @tblMFOrderNo TABLE (
		intRecordId INT identity(1, 1)
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	UPDATE tblMFEDI940
	SET strDepositorOrderNumber = REPLACE(LTRIM(REPLACE(strDepositorOrderNumber, '0', ' ')), ' ', '0')

	DECLARE @tblMFSession TABLE (intEDI940Id INT)

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

			SELECT @strErrorMessage = ''

			SELECT @strOrderNo = strOrderNo
			FROM @tblMFOrderNo
			WHERE intRecordId = @intRecordId

			SELECT @strCustomerCode = strCustomerCode
				,@strShipToName = strShipToName
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
					,'IGNORED'
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

				SELECT @intRecordId = min(intRecordId)
				FROM @tblMFOrderNo
				WHERE intRecordId > @intRecordId

				CONTINUE
			END

			SELECT @intEntityLocationId = NULL

			SELECT @intEntityLocationId = intEntityLocationId
			FROM tblEMEntityLocation
			WHERE strCheckPayeeName = @strCustomerCode

			IF @intEntityLocationId IS NULL
			BEGIN
				SELECT @intEntityId = NULL

				SELECT @intEntityId = intEntityId
				FROM tblEMEntity
				WHERE strName = @strShipToName

				IF @intEntityId IS NULL
				BEGIN
					SELECT @strEntityNo = IsNULL(Max(strEntityNo), 0) + 1
					FROM tblENEntity

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
					,strShipToState + ' ' + Ltrim(IsNULL((
								SELECT Count(*)
								FROM tblEMEntity E
								JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
								JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId
									AND EL.strState = strShipToState
								WHERE ET.strType = 'Customer'
									AND E.strName = strShipToName
								), 0) + row_number() OVER (
							PARTITION BY @intEntityId
							,strShipToState ORDER BY strShipToState
							)) strLocationName
					,strShipToAddress1 + CASE 
						WHEN IsNULL(strShipToAddress2, '') <> ''
							THEN ' ' + strShipToAddress2
						END strAddress
					,strShipToCity strCity
					,'United States' strCountry
					,strShipToState strState
					,strShipToZip strZipCode
					,1 intTermsId
					,(
						CASE 
							WHEN row_number() OVER (
									PARTITION BY @intEntityId
									,strShipToState ORDER BY strShipToState
									) = 1
								THEN 1
							ELSE 0
							END
						) ysnDefaultLocation
					,1 ysnActive
					,'(UTC-06:00) Central Time (US & Canada)' strTimezone
					,1 intConcurrencyId
					,strCustomerCode strCheckPayeeName
				FROM tblMFEDI940
				WHERE strDepositorOrderNumber = @strOrderNo

				SELECT @intEntityLocationId = SCOPE_IDENTITY()

				--New Customer Notification
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

				--IF NOT EXISTS (
				--		SELECT *
				--		FROM tblEMEntity E
				--		JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
				--		JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId
				--		WHERE ET.strType = 'Customer'
				--			AND EL.intEntityLocationId = @intEntityLocationId
				--			AND E.strName = @strShipToName
				--		)
				--BEGIN
				--	UPDATE E
				--	SET E.strName = @strShipToName
				--	FROM tblEMEntity E
				--	JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
				--	JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId
				--	WHERE ET.strType = 'Customer'
				--		AND EL.intEntityLocationId = @intEntityLocationId
				--	SELECT @intEntityId = NULL
				--SELECT @intEntityId = intEntityId
				--FROM tblEMEntity
				--WHERE strName = @strShipToName
				--	UPDATE tblMFEDI940
				--	SET ysnNotify = 1
				--		,intCustomerCodeType = 3
				--	WHERE strDepositorOrderNumber = @strOrderNo
				--END
				IF NOT EXISTS (
						SELECT *
						FROM tblEMEntityLocation
						WHERE intEntityLocationId = @intEntityLocationId
							AND strAddress = @strShipToAddress1 + CASE 
								WHEN IsNULL(@strShipToAddress1, '') <> ''
									THEN ' ' + @strShipToAddress1
								END
							AND strCity = @strShipToCity
							AND strState = @strShipToState
							AND strZipCode = @strShipToZip
						)
				BEGIN
					UPDATE tblEMEntityLocation
					SET strAddress = @strShipToAddress1 + ' ' + @strShipToAddress2
						,strCity = @strShipToCity
						,strState = @strShipToState
						,strZipCode = @strShipToZip
					WHERE intEntityLocationId = @intEntityLocationId

					UPDATE tblMFEDI940
					SET ysnNotify = 1
						,intCustomerCodeType = 4
					WHERE strDepositorOrderNumber = @strOrderNo
				END
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

			DELETE
			FROM @ShipmentStagingTable

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
				,dtmRequestedArrivalDate = EDI.strShipmentDate
			FROM tblMFEDI940 EDI
			JOIN tblICItem I ON I.strItemNo = EDI.strCustomerItemNumber
			JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
				AND IL.intLocationId IS NOT NULL
			JOIN tblEMEntityLocation EL ON 1 = 1
				AND EL.intEntityLocationId = @intEntityLocationId
			LEFT JOIN dbo.tblICUnitMeasure UM ON UM.strUnitMeasure = I.strExternalGroup
			LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND UM.intUnitMeasureId = IU.intUnitMeasureId
			WHERE EDI.strDepositorOrderNumber = @strOrderNo

			EXEC dbo.uspICAddItemShipment @Entries = @ShipmentStagingTable
				,@Charges = @OtherCharges
				,@intUserId = @intUserId;

			SELECT TOP 1 @intInventoryShipmentId = intInventoryShipmentId
			FROM #tmpAddItemShipmentResult

			DELETE
			FROM #tmpAddItemShipmentResult

			IF @intInventoryShipmentId > 0
			BEGIN
				SELECT @strShipmentNumber = strShipmentNumber
				FROM tblICInventoryShipment
				WHERE intInventoryShipmentId = @intInventoryShipmentId

				SELECT @strPONumber = ''

				SELECT @strPONumber = strPONumber
				FROM tblMFEDI940 EDI940
				WHERE strDepositorOrderNumber = @strOrderNo

				SELECT @intScreenId = intScreenId
				FROM tblSMScreen
				WHERE strNamespace = 'Inventory.view.InventoryShipment'

				SELECT @intCustomTabId = intCustomTabId
				FROM tblSMCustomTab
				WHERE intScreenId = @intScreenId

				SELECT @intCustomTabDetailId = [Extent1].[intCustomTabDetailId]
				FROM [dbo].[tblSMCustomTabDetail] AS [Extent1]
				WHERE [Extent1].[intCustomTabId] = @intCustomTabId
					AND strFieldName = 'CustomerPONo'

				INSERT [dbo].[tblSMTransaction] (
					[intScreenId]
					,[strTransactionNo]
					,[intEntityId]
					,[intRecordId]
					,[intConcurrencyId]
					)
				SELECT @intScreenId
					,@strShipmentNumber
					,1
					,@intInventoryShipmentId
					,1

				SELECT @intTransactionId = scope_identity()

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

				INSERT [dbo].[tblSMFieldValue] (
					[intTabRowId]
					,[intCustomTabDetailId]
					,[strValue]
					,[intConcurrencyId]
					)
				SELECT @intTabRowId
					,@intCustomTabDetailId
					,@strPONumber
					,1

				SELECT @intCustomTabDetailId = [Extent1].[intCustomTabDetailId]
				FROM [dbo].[tblSMCustomTabDetail] AS [Extent1]
				WHERE [Extent1].[intCustomTabId] = @intCustomTabId
					AND strFieldName = 'CreatedByEDI'

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
