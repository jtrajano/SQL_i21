CREATE PROCEDURE uspMFProcessEDI945 (
	@strShipmentNumber NVARCHAR(50) = NULL
	,@ysnForce BIT = 0
	)
AS
BEGIN
	DECLARE @tblMFOrderNo TABLE (
		intInventoryShipmentId INT
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strShipmentNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intEntityCustomerId INT
		)
	DECLARE @intCustomerId INT
		,@strType NVARCHAR(1)
		,@strOrderStatus NVARCHAR(2)
		,@strName NVARCHAR(50)
		,@intInventoryShipmentId INT
		,@strShipmentNo NVARCHAR(50)
		,@strError NVARCHAR(MAX)
		,@strOrderNo NVARCHAR(50)
		,@strShipToAddress1 NVARCHAR(MAX)
		,@strShipToAddress2 NVARCHAR(MAX)
		,@strShipToCode NVARCHAR(50)
		,@strTransportationMethod NVARCHAR(50)
		,@strSCAC NVARCHAR(50)
		,@strRouting NVARCHAR(50)

	--IF @strShipmentNumber = ''
	--BEGIN
	--	INSERT INTO @tblMFOrderNo (
	--		intInventoryShipmentId
	--		,strOrderNo
	--		,strShipmentNo
	--		,intEntityCustomerId
	--		)
	--	SELECT TOP 1 InvS.intInventoryShipmentId
	--		,InvS.strReferenceNumber
	--		,InvS.strShipmentNumber
	--		,InvS.intEntityCustomerId
	--	FROM tblICInventoryShipment InvS
	--	WHERE ysnPosted = 1
	--		AND EXISTS (
	--			SELECT *
	--			FROM tblMFEDI940Archive EDI940
	--			WHERE EDI940.strDepositorOrderNumber = InvS.strReferenceNumber
	--			)
	--		AND NOT EXISTS (
	--			SELECT *
	--			FROM tblMFEDI945 EDI945
	--			WHERE EDI945.ysnStatus = 1
	--				AND EDI945.intInventoryShipmentId = InvS.intInventoryShipmentId
	--			)
	--		AND NOT EXISTS (
	--			SELECT *
	--			FROM tblMFEDI945Error E
	--			WHERE E.strDepositorOrderNumber = InvS.strReferenceNumber
	--			)
	--	ORDER BY InvS.intInventoryShipmentId
	--	IF NOT EXISTS (
	--			SELECT *
	--			FROM @tblMFOrderNo
	--			)
	--	BEGIN
	--		INSERT INTO @tblMFOrderNo (
	--			intInventoryShipmentId
	--			,strOrderNo
	--			,strShipmentNo
	--			,intEntityCustomerId
	--			)
	--		SELECT TOP 1 InvS.intInventoryShipmentId
	--			,InvS.strReferenceNumber
	--			,InvS.strShipmentNumber
	--			,InvS.intEntityCustomerId
	--		FROM tblICInventoryShipment InvS
	--		WHERE ysnPosted = 1
	--			AND EXISTS (
	--				SELECT *
	--				FROM tblMFEDI940Archive EDI940
	--				WHERE EDI940.strDepositorOrderNumber = InvS.strReferenceNumber
	--				)
	--			AND NOT EXISTS (
	--				SELECT *
	--				FROM tblMFEDI945 EDI945
	--				WHERE EDI945.ysnStatus = 1
	--					AND EDI945.intInventoryShipmentId = InvS.intInventoryShipmentId
	--				)
	--		ORDER BY InvS.intInventoryShipmentId
	--	END
	--END
	--ELSE
	--BEGIN
	--	INSERT INTO @tblMFOrderNo (
	--		intInventoryShipmentId
	--		,strOrderNo
	--		,strShipmentNo
	--		,intEntityCustomerId
	--		)
	--	SELECT TOP 1 InvS.intInventoryShipmentId
	--		,InvS.strReferenceNumber
	--		,InvS.strShipmentNumber
	--		,InvS.intEntityCustomerId
	--	FROM tblICInventoryShipment InvS
	--	WHERE ysnPosted = 1
	--		AND EXISTS (
	--			SELECT *
	--			FROM tblMFEDI940Archive EDI940
	--			WHERE EDI940.strDepositorOrderNumber = InvS.strReferenceNumber
	--			)
	--		AND InvS.strShipmentNumber = @strShipmentNumber
	--END
	IF @strShipmentNumber IS NULL
	BEGIN
		INSERT INTO @tblMFOrderNo (
			intInventoryShipmentId
			,strOrderNo
			,strShipmentNo
			,intEntityCustomerId
			)
		SELECT TOP 1 InvS.intInventoryShipmentId
			,InvS.strReferenceNumber
			,InvS.strShipmentNumber
			,InvS.intEntityCustomerId
		FROM tblMFEDIStage945 EDI
		JOIN tblICInventoryShipment InvS ON EDI.intInventoryShipmentId = InvS.intInventoryShipmentId
		WHERE InvS.ysnPosted = 1
			AND EDI.intStatusId = 0
		ORDER BY InvS.intInventoryShipmentId

		IF NOT EXISTS (
				SELECT *
				FROM @tblMFOrderNo
				)
		BEGIN
			INSERT INTO @tblMFOrderNo (
				intInventoryShipmentId
				,strOrderNo
				,strShipmentNo
				,intEntityCustomerId
				)
			SELECT TOP 1 InvS.intInventoryShipmentId
				,InvS.strReferenceNumber
				,InvS.strShipmentNumber
				,InvS.intEntityCustomerId
			FROM tblMFEDIStage945 EDI
			JOIN tblICInventoryShipment InvS ON EDI.intInventoryShipmentId = InvS.intInventoryShipmentId
			WHERE InvS.ysnPosted = 1
			ORDER BY InvS.intInventoryShipmentId
		END
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFOrderNo (
			intInventoryShipmentId
			,strOrderNo
			,strShipmentNo
			,intEntityCustomerId
			)
		SELECT TOP 1 InvS.intInventoryShipmentId
			,InvS.strReferenceNumber
			,InvS.strShipmentNumber
			,InvS.intEntityCustomerId
		FROM tblICInventoryShipment InvS
		WHERE ysnPosted = 1
			AND EXISTS (
				SELECT *
				FROM tblMFEDI940Archive EDI940
				WHERE EDI940.strDepositorOrderNumber = InvS.strReferenceNumber
				)
			AND InvS.strShipmentNumber = @strShipmentNumber
	END

	IF NOT EXISTS (
			SELECT *
			FROM @tblMFOrderNo
			)
	BEGIN
		RAISERROR (
				'No data to export.'
				,16
				,1
				)

		RETURN
	END

	SELECT @intInventoryShipmentId = intInventoryShipmentId
	FROM @tblMFOrderNo

	IF EXISTS (
			SELECT *
			FROM @tblMFOrderNo O
			JOIN tblMFItemOwner Lbl ON O.intEntityCustomerId = Lbl.intOwnerId
				AND intCustomerLabelTypeId IS NOT NULL
			)
	BEGIN
		EXEC dbo.uspMFReassignCustomerLabel @intInventoryShipmentId = @intInventoryShipmentId
	END

	SELECT @intCustomerId = intCustomerId
		,@strType = strType
		,@strOrderStatus = strOrderStatus
	FROM tblMFEDIPreference
	WHERE strTransactionId = '945'

	SELECT @strName = strName
	FROM tblEMEntity
	WHERE intEntityId = @intCustomerId

	IF @strType IS NULL
	BEGIN
		SELECT @strType = ''
	END

	IF @strOrderStatus IS NULL
	BEGIN
		SELECT @strOrderStatus = ''
	END

	IF @strName IS NULL
	BEGIN
		SELECT @strName = ''
	END

	SELECT @strOrderNo = strOrderNo
	FROM @tblMFOrderNo

	SELECT TOP 1 @strShipToAddress1 = strShipToAddress1
		,@strShipToAddress2 = strShipToAddress2
		,@strShipToCode = strShipToCode
		,@strTransportationMethod = strTransportationMethod
		,@strSCAC = strSCAC
		,@strRouting = strRouting
	FROM tblMFEDI940Archive
	WHERE strDepositorOrderNumber = @strOrderNo
	ORDER BY intEDI940Id DESC

	SELECT 945 AS strTransactionId
		,@strName AS strCustomerId
		,@strType AS strType
		,strReferenceNumber strDepositorOrderNumber
		,strCustomerPONo strPurchaseOrderNumber
		,dtmShipDate dtmShipmentDate
		,strShipmentNumber strShipmentId
		,E.strName
		,IsNULL(EDI.strShipToAddress1, @strShipToAddress1) AS strShipToAddress1
		,IsNULL(EDI.strShipToAddress2, @strShipToAddress2) AS strShipToAddress2
		,EL.strCity AS strShipToCity
		,EL.strState AS strShipToState
		,EL.strZipCode AS strShipToZipCode
		,IsNULL(IsNULL(EDI.strShipToCode, @strShipToCode), '') AS strShipToCode
		,dtmShipDate dtmShippedDate
		,IsNULL(IsNULL(CASE 
					WHEN CF.ysnCustomerPickUp = '1'
						OR CF.ysnCustomerPickUp = 'True'
						THEN 'H'
					ELSE 'M'
					END, IsNULL(EDI.strTransportationMethod, @strTransportationMethod)), '') AS strTransportationMethod
		,IsNULL(IsNULL(SV.strFederalId, IsNULL(EDI.strSCAC, @strSCAC)), '') AS strSCAC
		,IsNULL(IsNULL(SV.strShipVia, IsNULL(EDI.strRouting, @strRouting)), '') AS strRouting
		,FT.strFreightTerm AS strShipmentMethodOfPayment
		,strTotalPalletsLoaded
		,SUM(dblQuantityShipped) OVER (PARTITION BY InvS.intInventoryShipmentId) dblTotalUnitsShipped
		,0 AS dblTotalWeight
		,'' AS strWeightUOM
		,InvSI.intLineNo AS intLineNo
		,@strOrderStatus AS strOrderStatus
		,IsNULL(EDI.strUPCCaseCode, '') AS strUPCCaseCode
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,IsNULL(EDI.dblQtyOrdered, 0) AS dblQtyOrdered
		,(
			CASE 
				WHEN EXISTS (
						SELECT *
						FROM tblMFItemOwner ItemOwner
						WHERE ItemOwner.intCustomerLabelTypeId = 2
							AND ItemOwner.intOwnerId = InvS.intEntityCustomerId
						)
					THEN 1
				ELSE (
						CASE 
							WHEN IsNULL(UM.strUnitType, '') = 'Weight'
								THEN dbo.fnMFConvertQuantityToTargetItemUOM(IU.intItemUOMId, IU1.intItemUOMId, InvSL.dblQuantityShipped)
							ELSE InvSL.dblQuantityShipped
							END
						)
				END
			) AS dblQtyShipped
		,IsNULL(EDI.strUOM, (
				SELECT TOP 1 Arc.strUOM
				FROM tblMFEDI940Archive Arc
				WHERE Arc.strCustomerItemNumber = I.strItemNo
				)) AS strUOM
		,PL.strParentLotNumber strParentLotNumber
		,L.strLotNumber
		,Ltrim(1 + (year(L.dtmExpiryDate) - 1) / 100) + (CONVERT(VARCHAR(6), L.dtmExpiryDate, 12)) strBestby
	INTO #tblMFEDI945
	FROM dbo.tblICInventoryShipment InvS
	JOIN @tblMFOrderNo O ON O.intInventoryShipmentId = InvS.intInventoryShipmentId
		AND InvS.ysnPosted = 1
	JOIN dbo.tblICInventoryShipmentItem InvSI ON InvSI.intInventoryShipmentId = InvS.intInventoryShipmentId
	JOIN dbo.tblICInventoryShipmentItemLot InvSL ON InvSL.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
	JOIN tblICItemUOM IU ON InvSI.intItemUOMId = IU.intItemUOMId
	JOIN dbo.tblICLot L ON L.intLotId = InvSL.intLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN vyuMFGetInventoryShipmentCustomField CF ON CF.intRecordId = InvS.intInventoryShipmentId
	JOIN dbo.tblEMEntity E ON E.intEntityId = InvS.intEntityCustomerId
	JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = InvS.intShipToLocationId
	JOIN tblICItem I ON I.intItemId = InvSI.intItemId
	LEFT JOIN tblMFEDI940Archive EDI ON EDI.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
		AND EDI.intEDI940Id IN (
			SELECT MAX(EDI1.intEDI940Id)
			FROM tblMFEDI940Archive EDI1
			WHERE EDI1.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
			)
	LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = EDI.strUOM
	LEFT JOIN tblICItemUOM IU1 ON UM.intUnitMeasureId = IU1.intUnitMeasureId
		AND I.intItemId = IU1.intItemId
	LEFT JOIN tblSMShipVia SV ON SV.intEntityId = InvS.intShipViaId
	JOIN tblSMFreightTerms FT ON FT.intFreightTermId = InvS.intFreightTermId

	SELECT *
	INTO #tblMFSSCCNo
	FROM dbo.vyuMFGetPalletSSCCNo
	WHERE strReferenceNo IN (
			SELECT strShipmentNo
			FROM @tblMFOrderNo
			)

	IF EXISTS (
			SELECT *
			FROM #tblMFEDI945 EDI
			WHERE strUOM IS NULL
			)
	BEGIN
		INSERT INTO tblMFEDI945Error (
			strTransactionId
			,strCustomerId
			,strType
			,strDepositorOrderNumber
			,strPurchaseOrderNumber
			,dtmShipmentDate
			,strShipmentId
			,strName
			,strShipToAddress1
			,strShipToAddress2
			,strShipToCity
			,strShipToState
			,strShipToZipCode
			,strShipToCode
			,strBOL
			,dtmShippedDate
			,strTransportationMethod
			,strSCAC
			,strRouting
			,strShipmentMethodOfPayment
			,strTotalPalletsLoaded
			,dblTotalUnitsShipped
			,dblTotalWeight
			,strWeightUOM
			,intLineNo
			,strSSCCNo
			,strOrderStatus
			,strUPCCaseCode
			,strItemNo
			,strDescription
			,dblQtyOrdered
			,dblQtyShipped
			,dblQtyDifference
			,strUOM
			,strParentLotNumber
			,strBestBy
			,intRowNumber
			,ysnNotify
			,ysnSentEMail
			)
		SELECT DISTINCT DT.strTransactionId
			,DT.strCustomerId
			,DT.strType
			,DT.strDepositorOrderNumber
			,DT.strPurchaseOrderNumber
			,DT.dtmShipmentDate
			,DT.strShipmentId
			,DT.strName
			,DT.strShipToAddress1
			,DT.strShipToAddress2
			,DT.strShipToCity
			,DT.strShipToState
			,DT.strShipToZipCode
			,DT.strShipToCode
			,DT.strShipmentId
			,DT.dtmShippedDate
			,DT.strTransportationMethod
			,DT.strSCAC
			,DT.strRouting
			,DT.strShipmentMethodOfPayment
			,DT.strTotalPalletsLoaded
			,[dbo].[fnRemoveTrailingZeroes](DT.dblTotalUnitsShipped) AS dblTotalUnitsShipped
			,DT.dblTotalWeight
			,DT.strWeightUOM
			,DT.intLineNo
			,DT.strSSCCNo
			,DT.strOrderStatus
			,DT.strUPCCaseCode
			,DT.strItemNo
			,DT.strDescription
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyOrdered) AS dblQtyOrdered
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyShipped) AS dblQtyShipped
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyDifference) AS dblQtyDifference
			,DT.strUOM
			,DT.strParentLotNumber AS strLotNumber
			,DT.strBestBy
			,Row_Number() OVER (
				PARTITION BY DT.strDepositorOrderNumber ORDER BY DT.intLineNo
					,DT.strParentLotNumber
				) AS intRowNumber
			,1
			,0
		FROM (
			SELECT DISTINCT EDI.strTransactionId
				,EDI.strCustomerId
				,EDI.strType
				,EDI.strDepositorOrderNumber
				,EDI.strPurchaseOrderNumber
				,EDI.dtmShipmentDate
				,EDI.strName
				,EDI.strShipToAddress1
				,EDI.strShipToAddress2
				,EDI.strShipToCity
				,EDI.strShipToState
				,EDI.strShipToZipCode
				,EDI.strShipToCode
				,EDI.strShipmentId
				,EDI.dtmShippedDate
				,EDI.strTransportationMethod
				,EDI.strSCAC
				,EDI.strRouting
				,EDI.strShipmentMethodOfPayment
				,EDI.strTotalPalletsLoaded
				,EDI.dblTotalUnitsShipped
				,EDI.dblTotalWeight
				,EDI.strWeightUOM
				,EDI.intLineNo
				,Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(SSCCNo.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 20) AS strSSCCNo
				,EDI.strOrderStatus
				,EDI.strUPCCaseCode
				,EDI.strItemNo
				,EDI.strDescription
				,EDI.dblQtyOrdered
				,SUM(EDI.dblQtyShipped) OVER (
					PARTITION BY EDI.strShipmentId
					,EDI.strParentLotNumber
					,EDI.strItemNo
					,Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(SSCCNo.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 20)
					) dblQtyShipped
				,EDI.dblQtyOrdered - SUM(EDI.dblQtyShipped) OVER (
					PARTITION BY EDI.strShipmentId
					,EDI.strItemNo
					) AS dblQtyDifference
				,EDI.strUOM
				,EDI.strParentLotNumber
				,EDI.strBestBy
			FROM #tblMFEDI945 EDI
			LEFT JOIN #tblMFSSCCNo SSCCNo ON SSCCNo.strLotNumber = EDI.strLotNumber
			WHERE NOT EXISTS (
					SELECT *
					FROM tblMFEDI945Error E
					WHERE E.strDepositorOrderNumber = EDI.strDepositorOrderNumber
					)
			) AS DT
		ORDER BY DT.strDepositorOrderNumber
			,DT.intLineNo
			,DT.strParentLotNumber

		SELECT @strShipmentNo = strShipmentNo
		FROM @tblMFOrderNo

		UPDATE tblMFEDIStage945
		SET intStatusId = 1
		WHERE intInventoryShipmentId = @intInventoryShipmentId

		SELECT @strError = 'UOM is missing for the inventory shipment # ' + @strShipmentNo

		RAISERROR (
				@strError
				,16
				,1
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM @tblMFOrderNo O
			JOIN tblMFItemOwner Lbl ON O.intEntityCustomerId = Lbl.intOwnerId
				AND intCustomerLabelTypeId IS NOT NULL
			)
	BEGIN
		IF (
				EXISTS (
					SELECT *
					FROM #tblMFEDI945 EDI
					LEFT JOIN #tblMFSSCCNo SSCCNo ON SSCCNo.strLotNumber = EDI.strLotNumber
					WHERE strSSCCNo IS NULL
					)
				OR NOT EXISTS (
					SELECT 1
					FROM #tblMFEDI945 EDI
					LEFT JOIN #tblMFSSCCNo SSCCNo ON SSCCNo.strLotNumber = EDI.strLotNumber
					GROUP BY dblTotalUnitsShipped
					HAVING dblTotalUnitsShipped = SUM(dblQtyShipped)
					)
				)
			AND @ysnForce = 0
			--AND EXISTS (
			--	SELECT *
			--	FROM @tblMFOrderNo O
			--	JOIN tblMFItemOwner Lbl ON O.intEntityCustomerId = Lbl.intOwnerId
			--		AND intCustomerLabelTypeId = 2
			--	)
		BEGIN
			INSERT INTO tblMFEDI945Error (
				strTransactionId
				,strCustomerId
				,strType
				,strDepositorOrderNumber
				,strPurchaseOrderNumber
				,dtmShipmentDate
				,strShipmentId
				,strName
				,strShipToAddress1
				,strShipToAddress2
				,strShipToCity
				,strShipToState
				,strShipToZipCode
				,strShipToCode
				,strBOL
				,dtmShippedDate
				,strTransportationMethod
				,strSCAC
				,strRouting
				,strShipmentMethodOfPayment
				,strTotalPalletsLoaded
				,dblTotalUnitsShipped
				,dblTotalWeight
				,strWeightUOM
				,intLineNo
				,strSSCCNo
				,strOrderStatus
				,strUPCCaseCode
				,strItemNo
				,strDescription
				,dblQtyOrdered
				,dblQtyShipped
				,dblQtyDifference
				,strUOM
				,strParentLotNumber
				,strBestBy
				,intRowNumber
				,ysnNotify
				,ysnSentEMail
				)
			SELECT DISTINCT DT.strTransactionId
				,DT.strCustomerId
				,DT.strType
				,DT.strDepositorOrderNumber
				,DT.strPurchaseOrderNumber
				,DT.dtmShipmentDate
				,DT.strShipmentId
				,DT.strName
				,DT.strShipToAddress1
				,DT.strShipToAddress2
				,DT.strShipToCity
				,DT.strShipToState
				,DT.strShipToZipCode
				,DT.strShipToCode
				,DT.strShipmentId
				,DT.dtmShippedDate
				,DT.strTransportationMethod
				,DT.strSCAC
				,DT.strRouting
				,DT.strShipmentMethodOfPayment
				,DT.strTotalPalletsLoaded
				,[dbo].[fnRemoveTrailingZeroes](DT.dblTotalUnitsShipped) AS dblTotalUnitsShipped
				,DT.dblTotalWeight
				,DT.strWeightUOM
				,DT.intLineNo
				,DT.strSSCCNo
				,DT.strOrderStatus
				,DT.strUPCCaseCode
				,DT.strItemNo
				,DT.strDescription
				,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyOrdered) AS dblQtyOrdered
				,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyShipped) AS dblQtyShipped
				,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyDifference) AS dblQtyDifference
				,DT.strUOM
				,DT.strParentLotNumber AS strLotNumber
				,DT.strBestBy
				,Row_Number() OVER (
					PARTITION BY DT.strDepositorOrderNumber ORDER BY DT.intLineNo
						,DT.strParentLotNumber
					) AS intRowNumber
				,1
				,0
			FROM (
				SELECT DISTINCT EDI.strTransactionId
					,EDI.strCustomerId
					,EDI.strType
					,EDI.strDepositorOrderNumber
					,EDI.strPurchaseOrderNumber
					,EDI.dtmShipmentDate
					,EDI.strName
					,EDI.strShipToAddress1
					,EDI.strShipToAddress2
					,EDI.strShipToCity
					,EDI.strShipToState
					,EDI.strShipToZipCode
					,EDI.strShipToCode
					,EDI.strShipmentId
					,EDI.dtmShippedDate
					,EDI.strTransportationMethod
					,EDI.strSCAC
					,EDI.strRouting
					,EDI.strShipmentMethodOfPayment
					,EDI.strTotalPalletsLoaded
					,EDI.dblTotalUnitsShipped
					,EDI.dblTotalWeight
					,EDI.strWeightUOM
					,EDI.intLineNo
					,Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(SSCCNo.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 20) AS strSSCCNo
					,EDI.strOrderStatus
					,EDI.strUPCCaseCode
					,EDI.strItemNo
					,EDI.strDescription
					,EDI.dblQtyOrdered
					,SUM(EDI.dblQtyShipped) OVER (
						PARTITION BY EDI.strShipmentId
						,EDI.strParentLotNumber
						,EDI.strItemNo
						,Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(SSCCNo.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 20)
						) dblQtyShipped
					,EDI.dblQtyOrdered - SUM(EDI.dblQtyShipped) OVER (
						PARTITION BY EDI.strShipmentId
						,EDI.strItemNo
						) AS dblQtyDifference
					,EDI.strUOM
					,EDI.strParentLotNumber
					,EDI.strBestBy
				FROM #tblMFEDI945 EDI
				LEFT JOIN #tblMFSSCCNo SSCCNo ON SSCCNo.strLotNumber = EDI.strLotNumber
				WHERE NOT EXISTS (
						SELECT *
						FROM tblMFEDI945Error E
						WHERE E.strDepositorOrderNumber = EDI.strDepositorOrderNumber
						)
				) AS DT
			ORDER BY DT.strDepositorOrderNumber
				,DT.intLineNo
				,DT.strParentLotNumber

			SELECT @strShipmentNo = strShipmentNo
			FROM @tblMFOrderNo

			UPDATE tblMFEDIStage945
			SET intStatusId = 1
			WHERE intInventoryShipmentId = @intInventoryShipmentId

			SELECT @strError = 'No of SSCC labels are not matching with shipped Qty.' + @strShipmentNo

			RAISERROR (
					@strError
					,16
					,1
					)

			RETURN
		END

		SELECT DISTINCT DT.strTransactionId
			,DT.strCustomerId
			,DT.strType
			,DT.strDepositorOrderNumber
			,DT.strPurchaseOrderNumber
			,DT.dtmShipmentDate
			,DT.strShipmentId
			,DT.strName
			,DT.strShipToAddress1
			,DT.strShipToAddress2
			,DT.strShipToCity
			,DT.strShipToState
			,DT.strShipToZipCode
			,DT.strShipToCode
			,DT.strShipmentId
			,DT.dtmShippedDate
			,DT.strTransportationMethod
			,DT.strSCAC
			,DT.strRouting
			,DT.strShipmentMethodOfPayment
			,DT.strTotalPalletsLoaded
			,[dbo].[fnRemoveTrailingZeroes](DT.dblTotalUnitsShipped) AS dblTotalUnitsShipped
			,DT.dblTotalWeight
			,DT.strWeightUOM
			,DT.intLineNo
			,DT.strSSCCNo
			,DT.strOrderStatus
			,DT.strUPCCaseCode
			,DT.strItemNo
			,DT.strDescription
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyOrdered) AS dblQtyOrdered
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyShipped) AS dblQtyShipped
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyDifference) AS dblQtyDifference
			,DT.strUOM
			,DT.strParentLotNumber AS strLotNumber
			,DT.strBestBy
			,ROW_NUMBER() OVER (
				PARTITION BY DT.strDepositorOrderNumber ORDER BY DT.intLineNo
					,DT.strParentLotNumber
				) AS intRowNumber
		FROM (
			SELECT DISTINCT EDI.strTransactionId
				,EDI.strCustomerId
				,EDI.strType
				,EDI.strDepositorOrderNumber
				,EDI.strPurchaseOrderNumber
				,EDI.dtmShipmentDate
				,EDI.strName
				,EDI.strShipToAddress1
				,EDI.strShipToAddress2
				,EDI.strShipToCity
				,EDI.strShipToState
				,EDI.strShipToZipCode
				,EDI.strShipToCode
				,EDI.strShipmentId
				,EDI.dtmShippedDate
				,EDI.strTransportationMethod
				,EDI.strSCAC
				,EDI.strRouting
				,EDI.strShipmentMethodOfPayment
				,EDI.strTotalPalletsLoaded
				,EDI.dblTotalUnitsShipped
				,EDI.dblTotalWeight
				,EDI.strWeightUOM
				,EDI.intLineNo
				,Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(SSCCNo.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 20) AS strSSCCNo
				,EDI.strOrderStatus
				,EDI.strUPCCaseCode
				,EDI.strItemNo
				,EDI.strDescription
				,EDI.dblQtyOrdered
				,SUM(EDI.dblQtyShipped) OVER (
					PARTITION BY EDI.strShipmentId
					,EDI.strParentLotNumber
					,EDI.strItemNo
					,Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(SSCCNo.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 20)
					) dblQtyShipped
				,EDI.dblQtyOrdered - SUM(EDI.dblQtyShipped) OVER (
					PARTITION BY EDI.strShipmentId
					,EDI.strItemNo
					) AS dblQtyDifference
				,EDI.strUOM
				,EDI.strParentLotNumber
				,EDI.strBestBy
			FROM #tblMFEDI945 EDI
			LEFT JOIN #tblMFSSCCNo SSCCNo ON SSCCNo.strLotNumber = EDI.strLotNumber
			) AS DT
		ORDER BY DT.strDepositorOrderNumber
			,DT.intLineNo
			,DT.strParentLotNumber
	END
	ELSE
	BEGIN
		SELECT DISTINCT DT.strTransactionId
			,DT.strCustomerId
			,DT.strType
			,DT.strDepositorOrderNumber
			,DT.strPurchaseOrderNumber
			,DT.dtmShipmentDate
			,DT.strShipmentId
			,DT.strName
			,DT.strShipToAddress1
			,DT.strShipToAddress2
			,DT.strShipToCity
			,DT.strShipToState
			,DT.strShipToZipCode
			,DT.strShipToCode
			,DT.strShipmentId
			,DT.dtmShippedDate
			,DT.strTransportationMethod
			,DT.strSCAC
			,DT.strRouting
			,DT.strShipmentMethodOfPayment
			,DT.strTotalPalletsLoaded
			,[dbo].[fnRemoveTrailingZeroes](DT.dblTotalUnitsShipped) AS dblTotalUnitsShipped
			,DT.dblTotalWeight
			,DT.strWeightUOM
			,DT.intLineNo
			,DT.strSSCCNo
			,DT.strOrderStatus
			,DT.strUPCCaseCode
			,DT.strItemNo
			,DT.strDescription
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyOrdered) AS dblQtyOrdered
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyShipped) AS dblQtyShipped
			,[dbo].[fnRemoveTrailingZeroes](DT.dblQtyDifference) AS dblQtyDifference
			,DT.strUOM
			,DT.strParentLotNumber AS strLotNumber
			,DT.strBestBy
			,ROW_NUMBER() OVER (
				PARTITION BY DT.strDepositorOrderNumber ORDER BY DT.intLineNo
					,DT.strParentLotNumber
				) intRowNumber
		FROM (
			SELECT DISTINCT EDI.strTransactionId
				,EDI.strCustomerId
				,EDI.strType
				,EDI.strDepositorOrderNumber
				,EDI.strPurchaseOrderNumber
				,EDI.dtmShipmentDate
				,EDI.strName
				,EDI.strShipToAddress1
				,EDI.strShipToAddress2
				,EDI.strShipToCity
				,EDI.strShipToState
				,EDI.strShipToZipCode
				,EDI.strShipToCode
				,EDI.strShipmentId
				,EDI.dtmShippedDate
				,EDI.strTransportationMethod
				,EDI.strSCAC
				,EDI.strRouting
				,EDI.strShipmentMethodOfPayment
				,EDI.strTotalPalletsLoaded
				,EDI.dblTotalUnitsShipped
				,EDI.dblTotalWeight
				,EDI.strWeightUOM
				,EDI.intLineNo
				,NULL AS strSSCCNo
				,EDI.strOrderStatus
				,EDI.strUPCCaseCode
				,EDI.strItemNo
				,EDI.strDescription
				,EDI.dblQtyOrdered
				,SUM(EDI.dblQtyShipped) OVER (
					PARTITION BY EDI.strShipmentId
					,EDI.strParentLotNumber
					,EDI.strItemNo
					) dblQtyShipped
				,EDI.dblQtyOrdered - SUM(EDI.dblQtyShipped) OVER (
					PARTITION BY EDI.strShipmentId
					,EDI.strItemNo
					) AS dblQtyDifference
				,EDI.strUOM
				,EDI.strParentLotNumber
				,EDI.strBestBy
			FROM #tblMFEDI945 EDI
			) AS DT
		ORDER BY DT.strDepositorOrderNumber
			,DT.intLineNo
			,DT.strParentLotNumber
	END

	INSERT INTO tblMFEDI945 (
		intInventoryShipmentId
		,strDepositorOrderNumber
		,ysnStatus
		)
	SELECT intInventoryShipmentId
		,strOrderNo
		,1
	FROM @tblMFOrderNo

	DELETE
	FROM tblMFEDI945Error
	WHERE strShipmentId IN (
			SELECT O.strShipmentNo
			FROM @tblMFOrderNo O
			)

	DELETE EDI
	FROM tblMFEDIStage945 EDI
	JOIN @tblMFOrderNo O ON EDI.intInventoryShipmentId = O.intInventoryShipmentId
END
