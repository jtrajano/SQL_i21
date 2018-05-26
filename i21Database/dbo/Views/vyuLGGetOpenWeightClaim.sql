CREATE VIEW vyuLGGetOpenWeightClaim
AS
SELECT TOP 100 PERCENT Convert(INT, ROW_NUMBER() OVER (
			ORDER BY intLoadId
			)) AS intKeyColumn
	,dblClaimableAmount = CASE 
		WHEN (
				(
					CASE 
						WHEN ysnSeqSubCurrency = 1
							THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
						ELSE dblClaimableWt * dblSeqPriceInWeightUOM
						END
					) < 0
				)
			THEN (
					CASE 
						WHEN ysnSeqSubCurrency = 1
							THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
						ELSE dblClaimableWt * dblSeqPriceInWeightUOM
						END
					) * - 1
		ELSE (
				CASE 
					WHEN ysnSeqSubCurrency = 1
						THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
					ELSE dblClaimableWt * dblSeqPriceInWeightUOM
					END
				)
		END
	,*
FROM (
	SELECT intPurchaseSale = LOAD.intPurchaseSale
		,strType = CASE 
			WHEN LOAD.intPurchaseSale = 1
				THEN 'Inbound'
			ELSE CASE 
					WHEN LOAD.intPurchaseSale = 2
						THEN 'Outbound'
					ELSE 'Drop Ship'
					END
			END
		,CH.strContractNumber
		,CD.intContractSeq
		,strEntityName = EM.strName
		,intEntityId = EM.intEntityId
		,intPartyEntityId = ISNULL((
				CASE 
					WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
						THEN EMPD.intEntityId
					ELSE CASE 
							WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
								THEN EMPH.intEntityId
							ELSE EM.intEntityId
							END
					END
				), 0)
		,strPaidTo = (
			CASE 
				WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
					THEN EMPD.strName
				ELSE CASE 
						WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
							THEN EMPH.strName
						ELSE EM.strName
						END
				END
			)
		,LOAD.intLoadId
		,LOAD.strLoadNumber
		,LOAD.dtmScheduledDate
		,strTransportationMode = CASE 
			WHEN LOAD.intPurchaseSale = 1
				THEN 'Truck'
			ELSE 'Ocean Vessel'
			END
		,LOAD.dtmETAPOD
		,dtmLastWeighingDate = LOAD.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0)
		,dtmClaimValidTill = NULL
		,intClaimValidTill = ISNULL(ASN.intClaimValidTill, 0)
		,LOAD.strBLNumber
		,LOAD.dtmBLDate
		,LOAD.intWeightUnitMeasureId
		,strWeightUOM = WUOM.strUnitMeasure
		,CH.intWeightId
		,WG.strWeightGradeDesc
		,dblShippedNetWt = (
			CASE 
				WHEN (
						SELECT COUNT(*)
						FROM tblLGLoadDetailContainerLink
						WHERE intLoadDetailId = LD.intLoadDetailId
						) > 0
					THEN (
							SELECT SUM(dblLinkNetWt)
							FROM tblLGLoadDetailContainerLink
							WHERE intLoadDetailId = LD.intLoadDetailId
							)
				ELSE LD.dblNet
				END - ISNULL((
					SELECT SUM(IRI.dblNet)
					FROM tblICInventoryReceipt IR
					JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					WHERE IRI.intSourceId = LD.intLoadDetailId
						AND IRI.intLineNo = CD.intContractDetailId
						AND IRI.intOrderId = CH.intContractHeaderId
						AND IR.strReceiptType = 'Inventory Return'
					), 0)
			)
		,dblReceivedNetWt = (
			(
				CASE LOAD.intPurchaseSale
					WHEN 1
						THEN RI.dblNet
					ELSE 0.0
					END
				) - ISNULL((
					SELECT SUM(IRI.dblNet)
					FROM tblICInventoryReceipt IR
					JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					WHERE IRI.intSourceId = LD.intLoadDetailId
						AND IRI.intLineNo = CD.intContractDetailId
						AND IRI.intOrderId = CH.intContractHeaderId
						AND IR.strReceiptType = 'Inventory Return'
					), 0)
			)
		,dblFranchisePercent = WG.dblFranchise
		,dblFranchise = WG.dblFranchise / 100
		,dblFranchiseWt =CASE 
						WHEN (
								CASE 
									WHEN (
											SELECT COUNT(*)
											FROM tblLGLoadDetailContainerLink
											WHERE intLoadDetailId = LD.intLoadDetailId
											) > 0
										THEN (
												SELECT SUM(dblLinkNetWt)
												FROM tblLGLoadDetailContainerLink
												WHERE intLoadDetailId = LD.intLoadDetailId
												)
									ELSE LD.dblNet
									END * WG.dblFranchise / 100
								) > 0.0
							THEN (
									(
										CASE 
											WHEN (
													SELECT COUNT(*)
													FROM tblLGLoadDetailContainerLink
													WHERE intLoadDetailId = LD.intLoadDetailId
													) > 0
												THEN (
														SELECT SUM(dblLinkNetWt)
														FROM tblLGLoadDetailContainerLink
														WHERE intLoadDetailId = LD.intLoadDetailId
														)
											ELSE LD.dblNet
											END - ISNULL((
												SELECT SUM(IRI.dblNet)
												FROM tblICInventoryReceipt IR
												JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
												WHERE IRI.intSourceId = LD.intLoadDetailId
													AND IRI.intLineNo = CD.intContractDetailId
													AND IRI.intOrderId = CH.intContractHeaderId
													AND IR.strReceiptType = 'Inventory Return'
												), 0)
										) * WG.dblFranchise / 100
									)
						ELSE 0.0
						END
		,dblWeightLoss = CASE LOAD.intPurchaseSale
			WHEN 1
				THEN CASE 
						WHEN (
								RI.dblNet - CASE 
									WHEN (
											SELECT COUNT(*)
											FROM tblLGLoadDetailContainerLink
											WHERE intLoadDetailId = LD.intLoadDetailId
											) > 0
										THEN (
												SELECT SUM(dblLinkNetWt)
												FROM tblLGLoadDetailContainerLink
												WHERE intLoadDetailId = LD.intLoadDetailId
												)
									ELSE LD.dblNet
									END
								) < 0.0
							THEN (
									RI.dblNet - CASE 
										WHEN (
												SELECT COUNT(*)
												FROM tblLGLoadDetailContainerLink
												WHERE intLoadDetailId = LD.intLoadDetailId
												) > 0
											THEN (
													SELECT SUM(dblLinkNetWt)
													FROM tblLGLoadDetailContainerLink
													WHERE intLoadDetailId = LD.intLoadDetailId
													)
										ELSE LD.dblNet
										END
									)
						ELSE (
								RI.dblNet - CASE 
									WHEN (
											SELECT COUNT(*)
											FROM tblLGLoadDetailContainerLink
											WHERE intLoadDetailId = LD.intLoadDetailId
											) > 0
										THEN (
												SELECT SUM(dblLinkNetWt)
												FROM tblLGLoadDetailContainerLink
												WHERE intLoadDetailId = LD.intLoadDetailId
												)
									ELSE LD.dblNet
									END
								)
						END
			ELSE 0.0
			END
		,dblClaimableWt = CASE LOAD.intPurchaseSale
			WHEN 1
				THEN CASE 
						WHEN (
								(
									RI.dblNet - CASE 
										WHEN (
												SELECT COUNT(*)
												FROM tblLGLoadDetailContainerLink
												WHERE intLoadDetailId = LD.intLoadDetailId
												) > 0
											THEN (
													SELECT SUM(dblLinkNetWt)
													FROM tblLGLoadDetailContainerLink
													WHERE intLoadDetailId = LD.intLoadDetailId
													)
										ELSE LD.dblNet
										END
									) + (LD.dblNet * WG.dblFranchise / 100)
								) < 0.0
							THEN (
									(
										RI.dblNet - CASE 
											WHEN (
													SELECT COUNT(*)
													FROM tblLGLoadDetailContainerLink
													WHERE intLoadDetailId = LD.intLoadDetailId
													) > 0
												THEN (
														SELECT SUM(dblLinkNetWt)
														FROM tblLGLoadDetailContainerLink
														WHERE intLoadDetailId = LD.intLoadDetailId
														)
											ELSE LD.dblNet
											END
										) + (LD.dblNet * WG.dblFranchise / 100)
									)
						ELSE (
								RI.dblNet - CASE 
									WHEN (
											SELECT COUNT(*)
											FROM tblLGLoadDetailContainerLink
											WHERE intLoadDetailId = LD.intLoadDetailId
											) > 0
										THEN (
												SELECT SUM(dblLinkNetWt)
												FROM tblLGLoadDetailContainerLink
												WHERE intLoadDetailId = LD.intLoadDetailId
												)
									ELSE LD.dblNet
									END
								)
						END
			ELSE 0.0
			END
		,intWeightClaimId = WC.intWeightClaimId
		,ysnWeightClaimed = CASE 
			WHEN IsNull(WC.intWeightClaimId, 0) <> 0
				THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
			END
		,AD.dblSeqPrice
		,AD.strSeqCurrency
		,AD.strSeqPriceUOM
		,AD.intSeqCurrencyId
		,AD.intSeqPriceUOMId
		,AD.ysnSeqSubCurrency
		,dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP (1) IU.intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = CD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
				), AD.intSeqPriceUOMId, AD.dblSeqPrice)
		,CD.intItemId
		,CD.intContractDetailId
		,CD.intBookId
		,BO.strBook
		,CD.intSubBookId
		,SB.strSubBook
		,WC.strReferenceNumber
		,WC.dtmTransDate
		,WC.dtmActualWeighingDate
		,I.strItemNo
		,C.strCommodityCode
		,CONI.strContractItemNo
		,CONI.strContractItemName
		,OG.strCountry AS strOrigin
		,dblSeqPriceConversionFactoryWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP (1) IU.intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = CD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
				), AD.intSeqPriceUOMId, 1)
	FROM tblLGLoad LOAD
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
	JOIN tblLGLoadDetail LD ON LD.intLoadId = LOAD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId 
		  = CASE LOAD.intPurchaseSale
			WHEN 3
				THEN LD.intSContractDetailId
			END OR CD.intContractDetailId = CASE LOAD.intPurchaseSale
			WHEN 3
				THEN LD.intPContractDetailId
			END OR CD.intContractDetailId = CASE LOAD.intPurchaseSale
			WHEN 1
				THEN LD.intPContractDetailId
			END OR CD.intContractDetailId = CASE LOAD.intPurchaseSale
			WHEN 2
				THEN LD.intSContractDetailId
			END
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
	JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
	LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
		AND CA.strType = 'Origin'
	LEFT JOIN tblSMCountry OG ON OG.intCountryID = CA.intCountryID
	LEFT JOIN tblICItemContract CONI ON CONI.intItemContractId = CD.intItemContractId
	LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	LEFT JOIN (
		SELECT SUM(ReceiptItem.dblNet) dblNet
			,ReceiptItem.intSourceId
			,ReceiptItem.intLineNo
			,ReceiptItem.intOrderId
		FROM tblICInventoryReceiptItem ReceiptItem
		JOIN tblICInventoryReceipt RI ON RI.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		WHERE RI.strReceiptType <> 'Inventory Return'
		GROUP BY ReceiptItem.intSourceId
			,ReceiptItem.intLineNo
			,ReceiptItem.intOrderId
		) RI ON RI.intSourceId = LD.intLoadDetailId
		AND RI.intLineNo = LD.intPContractDetailId
		AND RI.intOrderId = CH.intContractHeaderId
		AND LOAD.intPurchaseSale = 1
	LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGWeightClaim WC ON WCD.intWeightClaimId = WC.intWeightClaimId
	WHERE LOAD.intShipmentStatus = CASE LOAD.intPurchaseSale
			WHEN 1
				THEN 4
			WHEN 2
				THEN 6
			WHEN 3
				THEN 6
			ELSE 6
			END
		OR
		 LOAD.intShipmentStatus = CASE LOAD.intPurchaseSale
			WHEN 3
				THEN 11
			END
		AND ISNULL(WC.intWeightClaimId, 0) = 0
		AND ISNULL(LD.ysnNoClaim, 0) = 0
	) t1