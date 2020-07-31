/*
* Set invalid Shipment type to 1 (Shipment)
*/
IF EXISTS(SELECT 1 FROM tblLGLoad WHERE ISNULL(intShipmentType,0) = 0)
BEGIN
	UPDATE tblLGLoad SET intShipmentType = 1 WHERE ISNULL(intShipmentType,0) = 0
END
GO

/*
* Create record on tblLGCompanyPreference if empty
*/
IF NOT EXISTS(SELECT 1 FROM tblLGCompanyPreference)
BEGIN
	INSERT INTO tblLGCompanyPreference(intConcurrencyId)
	SELECT 1
END
GO

/*
* Set Document Received value 
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoad') AND name = 'ysnDocumentsReceived')
BEGIN
	EXEC ('UPDATE tblLGLoad
			SET ysnDocumentsReceived = CASE WHEN NOT EXISTS(SELECT TOP 1 1 FROM tblLGLoadDocuments WHERE intLoadId = tblLGLoad.intLoadId) THEN NULL
											WHEN EXISTS(SELECT TOP 1 1 FROM tblLGLoadDocuments WHERE intLoadId = tblLGLoad.intLoadId AND ISNULL(ysnReceived, 0) = 0) THEN 0 
										ELSE 1 END
			WHERE ysnDocumentsReceived IS NULL AND EXISTS(SELECT TOP 1 1 FROM tblLGLoadDocuments WHERE intLoadId = tblLGLoad.intLoadId)
	')
END
GO

/*
* Set Container Numbers value 
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoadDetail') AND name = 'strContainerNumbers')
BEGIN
	EXEC ('UPDATE LD
			SET strContainerNumbers = STUFF(
										(SELECT '', '' + CAST(strContainerNumber AS VARCHAR(MAX)) [text()]
										FROM tblLGLoadContainer LC 
										INNER JOIN tblLGLoadDetailContainerLink LDCL ON LC.intLoadContainerId = LDCL.intLoadContainerId
										WHERE LDCL.intLoadDetailId = LD.intLoadDetailId
										FOR XML PATH (''''), TYPE).value(''.'',''NVARCHAR(MAX)''),1,2,'' '')
			FROM tblLGLoadDetail LD
			WHERE strContainerNumbers IS NULL AND EXISTS(SELECT TOP 1 1 FROM tblLGLoadContainer LC 
													INNER JOIN tblLGLoadDetailContainerLink LDCL ON LC.intLoadContainerId = LDCL.intLoadContainerId
													 WHERE LDCL.intLoadDetailId = LD.intLoadDetailId)
	')
END

/* 
* Generate Load - Data Migration to New Fields 
*/

--Transport Mode
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'intTransportationMode')
BEGIN
	EXEC('UPDATE tblLGGenerateLoad
		SET intTransportationMode = ISNULL((SELECT TOP 1 intTransportationMode FROM tblLGLoad WHERE intGenerateLoadId = tblLGGenerateLoad.intGenerateLoadId),
										   (SELECT TOP 1 intDefaultTransportationMode FROM tblLGCompanyPreference))
		WHERE intTransportationMode IS NULL
	')
END
GO

--Hauler
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'intHaulerEntityId')
BEGIN
	EXEC('UPDATE tblLGGenerateLoad
		SET intHaulerEntityId = CASE WHEN (intType IN (1, 3)) THEN intPHaulerEntityId ELSE intSHaulerEntityId END
		WHERE intHaulerEntityId IS NULL
	')
END
GO

--Equipment Type
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'intEquipmentTypeId')
BEGIN
	EXEC('UPDATE tblLGGenerateLoad
		SET intEquipmentTypeId = CASE WHEN (intType IN (1, 3)) THEN intPHaulerEntityId ELSE intSHaulerEntityId END
		WHERE intEquipmentTypeId IS NULL
	')
END
GO

--Item Id
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'intItemId')
BEGIN
	EXEC('UPDATE GL
		SET intItemId = CASE WHEN (GL.intType IN (1, 3)) THEN VGL.intPItemId ELSE VGL.intSItemId END
		FROM tblLGGenerateLoad GL
		INNER JOIN vyuLGGenerateLoad VGL ON GL.intGenerateLoadId = VGL.intGenerateLoadId
		WHERE GL.intItemId IS NULL
	')
END
GO

--Ship Date
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'dtmShipDate')
BEGIN
	EXEC('UPDATE tblLGGenerateLoad
		SET dtmShipDate = CASE WHEN (intType IN (1, 3)) THEN dtmPArrivalDate ELSE dtmSShipToDate END
		WHERE intEquipmentTypeId IS NULL
	')
END
GO

--End Date
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'dtmEndDate')
BEGIN
	EXEC('UPDATE GL
		SET dtmEndDate = CASE WHEN (intType IN (1, 3)) THEN PCD.dtmEndDate ELSE SCD.dtmEndDate END
		FROM tblLGGenerateLoad GL
		LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = GL.intPContractDetailId
		LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = GL.intSContractDetailId
		WHERE GL.dtmEndDate IS NULL
	')
END
GO

/*
* Set Load-Based value on Load Schedule table
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoad') AND name = 'ysnLoadBased')
BEGIN
	EXEC ('UPDATE tblLGLoad
			SET ysnLoadBased = CASE WHEN EXISTS(SELECT TOP 1 1 FROM vyuLGLoadDetailView WHERE intLoadId = tblLGLoad.intLoadId AND (ysnPLoad = 1 OR ysnSLoad = 1)) THEN 1 ELSE 0 END
			WHERE ysnLoadBased IS NULL 
				OR ysnLoadBased <> CASE WHEN EXISTS(SELECT TOP 1 1 FROM vyuLGLoadDetailView WHERE intLoadId = tblLGLoad.intLoadId AND (ysnPLoad = 1 OR ysnSLoad = 1)) THEN 1 ELSE 0 END
	')
END
GO

/*
* Set Load-Based value on Generate Load table
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'ysnLoadBased')
BEGIN
	EXEC ('UPDATE GL
			SET ysnLoadBased = CASE WHEN (ISNULL(PCH.ysnLoad, 0) = 1 OR ISNULL(SCH.ysnLoad, 0) = 1) THEN 1 ELSE 0 END
			FROM tblLGGenerateLoad GL
				LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = GL.intPContractDetailId
				LEFT JOIN tblCTContractHeader PCH ON PCD.intContractHeaderId = PCH.intContractHeaderId
				LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = GL.intSContractDetailId
				LEFT JOIN tblCTContractHeader SCH ON PCD.intContractHeaderId = SCH.intContractHeaderId
			WHERE 
				GL.ysnLoadBased IS NULL
				OR GL.ysnLoadBased <> CASE WHEN (ISNULL(PCH.ysnLoad, 0) = 1 OR ISNULL(SCH.ysnLoad, 0) = 1) THEN 1 ELSE 0 END
	')
END
GO

/*
* Apply default Sort value on Containers table
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoadContainer') AND name = 'intSort')
BEGIN
	EXEC ('UPDATE LC
				SET intSort = LC_Sorted.intSort
			FROM 
				tblLGLoadContainer LC
				INNER JOIN 
				(SELECT intLoadContainerId
					,intSort = DENSE_RANK() OVER(PARTITION BY intLoadId ORDER BY intLoadContainerId)
				FROM tblLGLoadContainer) LC_Sorted
					ON LC.intLoadContainerId = LC_Sorted.intLoadContainerId
			WHERE LC.intSort IS NULL
	')
END
GO

/*
* Set default data for Transshipment Port Information
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoad') AND name = 'strVessel1')
BEGIN
	EXEC ('UPDATE tblLGLoad
			SET strVessel1 = strMVessel
			WHERE strMVessel IS NOT NULL AND strVessel1 IS NULL
	')

	EXEC ('UPDATE tblLGLoad
			SET strOriginPort1 = strOriginPort
			WHERE strOriginPort IS NOT NULL AND strOriginPort1 IS NULL
	')

	EXEC ('UPDATE tblLGLoad
			SET strDestinationPort1 = strDestinationPort
			WHERE strDestinationPort IS NOT NULL AND strDestinationPort1 IS NULL
	')

	EXEC ('UPDATE tblLGLoad
			SET dtmETSPOL1 = dtmETSPOL
			WHERE dtmETSPOL IS NOT NULL AND dtmETSPOL1 IS NULL
	')

	EXEC ('UPDATE tblLGLoad
			SET dtmETAPOD1 = dtmETAPOD
			WHERE dtmETAPOD IS NOT NULL AND dtmETAPOD1 IS NULL
	')

END
GO

/*
* Set default data for Pick Lot/Container Type
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGPickLotHeader') AND name = 'intType')
BEGIN
	EXEC ('UPDATE tblLGPickLotHeader
			SET intType = 1
			WHERE intType IS NULL
	')
END
GO

/* 
* Populate Pending Claims table
*/

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGPendingClaim'))
BEGIN
	EXEC('
		INSERT INTO tblLGPendingClaim 
			([intPurchaseSale]
			,[intLoadId]
			,[intContractDetailId]
			,[intEntityId]
			,[intPartyEntityId]
			,[intWeightId]
			,[intItemId]
			,[intWeightUnitMeasureId]
			,[dblShippedNetWt]
			,[dblReceivedNetWt]
			,[dblReceivedGrossWt]
			,[dblFranchisePercent]
			,[dblFranchise]
			,[dblFranchiseWt]
			,[dblWeightLoss]
			,[dblClaimableWt]
			,[dblClaimableAmount]
			,[dblSeqPrice]
			,[intSeqCurrencyId]
			,[intSeqPriceUOMId]
			,[intSeqBasisCurrencyId]
			,[ysnSeqSubCurrency]
			,[dblSeqPriceInWeightUOM]
			,[dblSeqPriceConversionFactoryWeightUOM]
			,[dtmDateAdded]
			)
		SELECT 
			[intPurchaseSale]
			,[intLoadId]
			,[intContractDetailId]
			,[intEntityId]
			,[intPartyEntityId]
			,[intWeightId]
			,[intItemId]
			,[intWeightUnitMeasureId]
			,[dblShippedNetWt]
			,[dblReceivedNetWt]
			,[dblReceivedGrossWt]
			,[dblFranchisePercent]
			,[dblFranchise]
			,[dblFranchiseWt]
			,[dblWeightLoss]
			,[dblClaimableWt]
			,[dblClaimableAmount] = ROUND(CASE WHEN (((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) < 0)
								THEN ((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) * - 1
								ELSE ((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END)
								END, 2)
			,[dblSeqPrice]
			,[intSeqCurrencyId]
			,[intSeqPriceUOMId]
			,[intSeqBasisCurrencyId]
			,[ysnSeqSubCurrency]
			,[dblSeqPriceInWeightUOM]
			,[dblSeqPriceConversionFactoryWeightUOM]
			,[dtmDateAdded] = GETDATE()
		FROM 
			(SELECT 
				intPurchaseSale = 1
				,intEntityId = EM.intEntityId
				,intPartyEntityId = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
											THEN EMPD.intEntityId
										WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
											THEN EMPH.intEntityId
										ELSE EM.intEntityId END
				,intLoadId = L.intLoadId
				,intWeightUnitMeasureId = L.intWeightUnitMeasureId
				,intWeightId = CH.intWeightId
				,dblShippedNetWt = (CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0))
				,dblReceivedNetWt = (RI.dblNet - ISNULL(IRN.dblIRNet, 0))
				,dblReceivedGrossWt = (RI.dblGross - ISNULL(IRN.dblIRGross, 0))
				,dblFranchisePercent = WG.dblFranchise
				,dblFranchise = WG.dblFranchise / 100
				,dblFranchiseWt = CASE WHEN (CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END * WG.dblFranchise / 100) <> 0.0
									THEN ((CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0)) * WG.dblFranchise / 100)
								ELSE 0.0 END
				,dblWeightLoss = CASE WHEN (RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) < 0.0
									THEN (RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
								ELSE (RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) END
				,dblClaimableWt = CASE WHEN ((RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
									THEN ((RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100))
									ELSE (RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
								END
				,dblSeqPrice = AD.dblSeqPrice
				,strSeqCurrency = AD.strSeqCurrency
				,strSeqPriceUOM = AD.strSeqPriceUOM
				,intSeqCurrencyId = AD.intSeqCurrencyId
				,intSeqPriceUOMId = ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId)
				,intSeqBasisCurrencyId = AD.intSeqBasisCurrencyId
				,strSeqBasisCurrency = BCUR.strCurrency 
				,ysnSeqSubCurrency = BCUR.ysnSubCurrency
				,dblSeqPriceInWeightUOM = (WUI.dblUnitQty / PUI.dblUnitQty) * AD.dblSeqPrice
				,intItemId = LD.intItemId
				,intContractDetailId = CD.intContractDetailId
				,dblSeqPriceConversionFactoryWeightUOM = (WUI.dblUnitQty / PUI.dblUnitQty)
			FROM tblLGLoad L
				JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = intPContractDetailId
				JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
				JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
				LEFT JOIN tblSMCurrency BCUR ON BCUR.intCurrencyID = AD.intSeqBasisCurrencyId
				LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
				LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
				OUTER APPLY (SELECT TOP 1 intWeightClaimId = WC.intWeightClaimId 
					FROM tblLGWeightClaim WC INNER JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId 
					WHERE WCD.intContractDetailId = LD.intPContractDetailId AND WC.intLoadId = L.intLoadId AND WC.intPurchaseSale = 1) WC
				OUTER APPLY (SELECT TOP 1 intWeightUOMId = IU.intItemUOMId, dblUnitQty FROM tblICItemUOM IU WHERE IU.intItemId = CD.intItemId AND IU.intUnitMeasureId = L.intWeightUnitMeasureId) WUI
				OUTER APPLY (SELECT TOP 1 intPriceUOMId = IU.intItemUOMId, dblUnitQty FROM tblICItemUOM IU WHERE IU.intItemUOMId = AD.intSeqPriceUOMId) PUI
				OUTER APPLY (SELECT TOP 1 strSubLocation = CLSL.strSubLocationName FROM tblLGLoadWarehouse LW JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId WHERE LW.intLoadId = L.intLoadId) SL
				OUTER APPLY (SELECT dblLinkNetWt = SUM(ISNULL(dblLinkNetWt, 0)) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
				CROSS APPLY (SELECT dblNet = SUM(ISNULL(IRI.dblNet,0)),dblGross = SUM(ISNULL(IRI.dblGross,0)) FROM tblICInventoryReceipt IR 
								JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
								WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
									AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType <> ''Inventory Return'') RI
				CROSS APPLY (SELECT dblIRNet = SUM(ISNULL(IRI.dblNet,0)),dblIRGross = SUM(ISNULL(IRI.dblGross,0)) FROM tblICInventoryReceipt IR 
								JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
								WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
									AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType = ''Inventory Return'') IRN
				WHERE 
					L.intPurchaseSale IN (1, 3)
					AND ((L.intPurchaseSale = 1 AND L.intShipmentStatus = 4) OR (L.intPurchaseSale <> 1 AND L.intShipmentStatus IN (6,11)))
					AND WC.intWeightClaimId IS NULL
					AND (LD.ysnNoClaim IS NULL OR LD.ysnNoClaim = 0)
					AND NOT EXISTS (SELECT TOP 1 1 FROM tblLGPendingClaim WHERE intLoadId = L.intLoadId AND intPurchaseSale = 1)

			UNION ALL

			SELECT
				intPurchaseSale = 2
				,intEntityId = EM.intEntityId
				,intPartyEntityId = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
											THEN EMPD.intEntityId
										WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
											THEN EMPH.intEntityId
										ELSE EM.intEntityId END
				,intLoadId = L.intLoadId
				,intWeightUnitMeasureId = L.intWeightUnitMeasureId
				,intWeightId = CH.intWeightId
				,dblShippedNetWt = CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END
				,dblReceivedNetWt = CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END
				,dblReceivedGrossWt = CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkGrossWt) ELSE LD.dblGross END
				,dblFranchisePercent = WG.dblFranchise
				,dblFranchise = WG.dblFranchise / 100
				,dblFranchiseWt = CASE WHEN (CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END * WG.dblFranchise / 100) <> 0.0
									THEN ((CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) * WG.dblFranchise / 100)
								ELSE 0.0 END
				,dblWeightLoss = CAST(0.0 AS NUMERIC(18, 6))
				,dblClaimableWt = CAST(0.0 AS NUMERIC(18, 6))
				,dblSeqPrice = AD.dblSeqPrice
				,strSeqCurrency = AD.strSeqCurrency
				,strSeqPriceUOM = AD.strSeqPriceUOM
				,intSeqCurrencyId = AD.intSeqCurrencyId
				,intSeqPriceUOMId = AD.intSeqPriceUOMId
				,intSeqBasisCurrencyId = AD.intSeqBasisCurrencyId
				,strSeqBasisCurrency = BCUR.strCurrency 
				,ysnSeqSubCurrency = BCUR.ysnSubCurrency
				,dblSeqPriceInWeightUOM = (WUI.dblUnitQty / PUI.dblUnitQty) * AD.dblSeqPrice
				,intItemId = CD.intItemId
				,intContractDetailId = CD.intContractDetailId
				,dblSeqPriceConversionFactoryWeightUOM = (WUI.dblUnitQty / PUI.dblUnitQty)
			FROM tblLGLoad L
				JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
				JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = intSContractDetailId
				JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
				JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
				LEFT JOIN tblSMCurrency BCUR ON BCUR.intCurrencyID = AD.intSeqBasisCurrencyId
				LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
				LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
				LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
				OUTER APPLY (SELECT TOP 1 intWeightClaimId = WC.intWeightClaimId 
					FROM tblLGWeightClaim WC INNER JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId 
					WHERE WCD.intContractDetailId = CD.intContractDetailId AND WC.intLoadId = L.intLoadId AND WC.intPurchaseSale = 2) WC
				OUTER APPLY (SELECT TOP 1 intWeightUOMId = IU.intItemUOMId, dblUnitQty FROM tblICItemUOM IU WHERE IU.intItemId = CD.intItemId AND IU.intUnitMeasureId = WUOM.intUnitMeasureId) WUI
				OUTER APPLY (SELECT TOP 1 intPriceUOMId = IU.intItemUOMId, dblUnitQty FROM tblICItemUOM IU WHERE IU.intItemUOMId = AD.intSeqPriceUOMId) PUI
				OUTER APPLY (SELECT TOP 1 strSubLocation = CLSL.strSubLocationName FROM tblLGLoadWarehouse LW JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId WHERE LW.intLoadId = L.intLoadId) SL
				OUTER APPLY (SELECT intCount = COUNT(1) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLCT
				OUTER APPLY (SELECT dblLinkNetWt = SUM(dblLinkNetWt),dblLinkGrossWt = SUM(dblLinkGrossWt) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
				WHERE 
					L.intPurchaseSale IN (2, 3)
					AND L.intShipmentStatus IN (6, 11)
					AND WC.intWeightClaimId IS NULL
					AND (LD.ysnNoClaim IS NULL OR LD.ysnNoClaim = 0)
					AND NOT EXISTS (SELECT TOP 1 1 FROM tblLGPendingClaim WHERE intLoadId = L.intLoadId AND intPurchaseSale = 2)
				) LI
	')
END