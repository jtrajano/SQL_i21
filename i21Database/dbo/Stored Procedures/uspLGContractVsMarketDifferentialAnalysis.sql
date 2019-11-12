CREATE PROCEDURE [dbo].[uspLGContractVsMarketDifferentialAnalysis]
	 @intCommodityId INT
	,@intUnitMeasureId INT
	,@intLocationId INT = NULL
	,@dtmStartDate DATETIME = NULL
	,@dtmEndDate DATETIME = NULL
AS
BEGIN

SELECT 
	CVMD.*
	/* Adjusted Basis = Market Basis + all adjustments*/
	,dblAdjustedBasis = ISNULL(dblMBasis, 0) 
						+ ISNULL(dblPaymentTermAdjustmentRate, 0) 
						+ ISNULL(dblPackingAdjustmentRate, 0) 
						+ ISNULL(dblPINCOAdjustmentRate, 0) 
						+ ISNULL(dblCertificationAdjustmentRate, 0)
	/* Net Basis = P.Contract Basis - Adjusted Basis */
	,dblNetBasis = ISNULL(dblPBasis, 0)
				 - (ISNULL(dblMBasis, 0) 
					+ ISNULL(dblPaymentTermAdjustmentRate, 0) 
					+ ISNULL(dblPackingAdjustmentRate, 0) 
					+ ISNULL(dblPINCOAdjustmentRate, 0) 
					+ ISNULL(dblCertificationAdjustmentRate, 0))
	/* Basis Amount = Net Basis x Sales Contract Unit Qty (in Absolute Value) */
	,dblBasisAmount = ABS(((ISNULL(dblPBasis, 0)
						 - (ISNULL(dblMBasis, 0) 
							+ ISNULL(dblPaymentTermAdjustmentRate, 0) 
							+ ISNULL(dblPackingAdjustmentRate, 0) 
							+ ISNULL(dblPINCOAdjustmentRate, 0)
							+ ISNULL(dblCertificationAdjustmentRate, 0))) 
						* ISNULL(dblQty, 1)) * dblUnitQty)				
FROM
	(SELECT
		strMonthYr = SFM.strFutureMonth
		,dtmFutureMonthsDate = SFM.dtmFutureMonthsDate
		,strPContractNumber = PCH.strContractNumber
		,dtmPContractDate = PCH.dtmContractDate
		,strVendor = VEN.strName
		,strPINCO = PFT.strFreightTerm
		,intItemId = I.intItemId
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,strItemOrigin = OG.strDescription
		,dblPBasis = CASE WHEN ISNULL(PBUOM.dblUnitQty, 0) = 0 OR ISNULL(ItemUOM.dblUnitQty, 0) = 0 THEN NULL 	
						ELSE dbo.fnCalculateCostBetweenUOM(PCD.intBasisUOMId, ItemUOM.intItemUOMId, ISNULL(PCD.dblBasis, 0)) / ISNULL(PCUR.intCent, 1) END
		,dblMBasis = CASE WHEN ISNULL(MB.dblBasisOrDiscount, 0) = 0 OR ISNULL(ItemUOM.dblUnitQty, 0) = 0 THEN NULL 	
						ELSE dbo.fnCalculateCostBetweenUOM(MB.intItemUOMId, ItemUOM.intItemUOMId, ISNULL(MB.dblBasisOrDiscount, 0)) / ISNULL(MB.intCent, 1) END
		,dblPaymentTermAdjustmentRate = CASE WHEN ISNULL(PTADJ.dblRate, 0) = 0 OR ISNULL(ItemUOM.dblUnitQty, 0) = 0 THEN NULL 
						ELSE dbo.fnCalculateCostBetweenUOM(PTADJ.intItemUOMId, ItemUOM.intItemUOMId, ISNULL(PTADJ.dblRate, 0)) / ISNULL(PTADJ.intCent, 1) END
		,dblPackingAdjustmentRate = CASE WHEN ISNULL(PKADJ.dblRate, 0) = 0 OR ISNULL(ItemUOM.dblUnitQty, 0) = 0 THEN NULL 	
						ELSE dbo.fnCalculateCostBetweenUOM(PKADJ.intItemUOMId, ItemUOM.intItemUOMId, ISNULL(PKADJ.dblRate, 0)) / ISNULL(PKADJ.intCent, 1) END
		,dblPINCOAdjustmentRate = CASE WHEN (PCH.intFreightTermId = SCH.intFreightTermId) THEN NULL
						ELSE dbo.fnCalculateCostBetweenUOM(FTADJ.intItemUOMId, ItemUOM.intItemUOMId, ISNULL(FTADJ.dblTotalCostPerContainer, 0) / ISNULL(FTADJ.dblNetWeight, 1)) / ISNULL(FTADJ.intCent, 1) END
		,dblCertificationAdjustmentRate = CASE WHEN ISNULL(CFADJ.dblRate, 0) = 0 OR ISNULL(ItemUOM.dblUnitQty, 0) = 0 THEN NULL 			
						ELSE dbo.fnCalculateCostBetweenUOM(CFADJ.intItemUOMId, ItemUOM.intItemUOMId, ISNULL(CFADJ.dblRate, 0)) / ISNULL(CFADJ.intCent, 1) END
		,strSContractNumber = SCH.strContractNumber
		,dtmSContractDate = SCH.dtmContractDate
		,strCustomer = CUS.strName
		,dblQty = SCD.dblQuantity
		,dblUnitQty = CASE WHEN ISNULL(SUOM.dblUnitQty, 0) = 0 OR ISNULL(ItemUOM.dblUnitQty, 0) = 0 THEN NULL 	
						ELSE dbo.fnCalculateQtyBetweenUOM(SCD.intItemUOMId, ItemUOM.intItemUOMId, 1) END
		,strUOM = UM.strUnitMeasure
		,intDays = DATEDIFF(DD, PCH.dtmContractDate, SCH.dtmContractDate)
		,dblSBasis = CASE WHEN ISNULL(SBUOM.dblUnitQty, 0) = 0 OR ISNULL(ItemUOM.dblUnitQty, 0) = 0 THEN NULL 	
						ELSE dbo.fnCalculateCostBetweenUOM(SCD.intBasisUOMId, ItemUOM.intItemUOMId, ISNULL(SCD.dblBasis, 0)) / ISNULL(SCUR.intCent, 1) END
		,intCurrencyId = ISNULL(SCUR.intMainCurrencyId, SCUR.intCurrencyID)
		,strCurrency = ISNULL(SMCUR.strCurrency, SCUR.strCurrency)
		,intUnitMeasureId = UM.intUnitMeasureId
		,intCompanyLocationId = PCD.intCompanyLocationId
		,intCommodityId = PCH.intCommodityId
		,intAllocationDetailId = ALD.intAllocationDetailId
		,intConcurrencyId = ALD.intConcurrencyId
	FROM 
		tblLGAllocationDetail ALD
		INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = ALD.intPContractDetailId
		INNER JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
		INNER JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
		INNER JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN tblSMCity SLP ON SLP.intCityId = SCD.intLoadingPortId
		LEFT JOIN tblSMCity SDP ON SDP.intCityId = SCD.intDestinationPortId
		LEFT JOIN tblRKFuturesMonth PFM ON PFM.intFutureMonthId = PCD.intFutureMonthId
		LEFT JOIN tblRKFuturesMonth SFM ON SFM.intFutureMonthId = SCD.intFutureMonthId
		LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = PCH.intEntityId
		LEFT JOIN tblEMEntity CUS ON CUS.intEntityId = SCH.intEntityId
		LEFT JOIN tblSMFreightTerms PFT ON PFT.intFreightTermId = PCH.intFreightTermId
		LEFT JOIN tblSMFreightTerms SFT ON SFT.intFreightTermId = SCH.intFreightTermId
		LEFT JOIN tblSMTerm SPT ON SPT.intTermID = SCH.intTermId
		LEFT JOIN tblSMCity PLOC ON PCH.intINCOLocationTypeId = PLOC.intCityId
		LEFT JOIN tblSMCity SLOC ON SCH.intINCOLocationTypeId = SLOC.intCityId
		LEFT JOIN tblICItem I ON I.intItemId = PCD.intItemId
		LEFT JOIN tblICCommodityAttribute OG ON OG.intCommodityAttributeId = I.intOriginId
		LEFT JOIN tblICCommodityUnitMeasure CM ON CM.intCommodityUnitMeasureId = SCH.intCommodityUOMId
		LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CM.intUnitMeasureId 
		LEFT JOIN tblICItemUOM SUOM ON SUOM.intItemUOMId = SCD.intItemUOMId
		LEFT JOIN tblICItemUOM PBUOM ON PBUOM.intItemUOMId = PCD.intBasisUOMId
		LEFT JOIN tblICItemUOM SBUOM ON SBUOM.intItemUOMId = SCD.intBasisUOMId
		LEFT JOIN tblICItemUOM WUOM ON WUOM.intItemUOMId = SCD.intNetWeightUOMId
		LEFT JOIN tblSMCurrency PCUR ON PCUR.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblSMCurrency SCUR ON SCUR.intCurrencyID = SCD.intBasisCurrencyId
		LEFT JOIN tblSMCurrency SMCUR ON SMCUR.intCurrencyID = SCUR.intMainCurrencyId
		/* Latest Shipment for the Sales Contract */
		OUTER APPLY (SELECT TOP 1 L.intLoadId, dtmBLDate, intShippingLineEntityId, strOriginPort, strDestinationPort, 
						strDestinationCity, intContainerTypeId, L.intNumberOfContainers
					 FROM tblLGLoad L
						LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
					 WHERE L.intShipmentType = 1
						AND LD.intSContractDetailId = SCD.intContractDetailId
					 ORDER BY L.dtmScheduledDate DESC
					) SHPMT
		/* Market Basis */
		OUTER APPLY (SELECT TOP 1 MTMBD.dblBasisOrDiscount, MTMBD.intCurrencyId, MBUOM.intItemUOMId, MBCU.intCent
					 FROM tblRKM2MBasisDetail MTMBD
						INNER JOIN tblRKM2MBasis MTMB ON MTMB.intM2MBasisId = MTMBD.intM2MBasisId
						LEFT JOIN tblICItemUOM MBUOM ON MBUOM.intItemId = MTMBD.intItemId AND MBUOM.intUnitMeasureId = MTMBD.intUnitMeasureId
						LEFT JOIN tblSMCurrency MBCU ON MBCU.intCurrencyID = MTMBD.intCurrencyId
					 WHERE SCH.intCommodityId = MTMBD.intCommodityId
						AND SCD.intItemId = MTMBD.intItemId
						AND SCD.intFutureMarketId = MTMBD.intFutureMarketId
						AND SCH.dtmContractDate >= MTMB.dtmM2MBasisDate
					 ORDER BY MTMB.dtmM2MBasisDate ASC
					 ) MB
		/* Payment Terms Adjustment Basis */
		OUTER APPLY (SELECT TOP 1 PTSA.strMasterRecord, PTSA.dblRate, PTSA.intCurrencyId, PTUOM.intItemUOMId, PTCU.intCent
					 FROM tblLGStandardAdjustment PTSA
						LEFT JOIN tblICItemUOM PTUOM ON PTUOM.intItemId = I.intItemId AND PTUOM.intUnitMeasureId = PTSA.intUnitMeasureId
						LEFT JOIN tblSMCurrency PTCU ON PTCU.intCurrencyID = PTSA.intCurrencyId
					 WHERE PTSA.intAdjustmentType = 1 
						AND PTSA.strMasterRecord IN (SPT.strTerm, SPT.strTermCode)
						AND SCH.dtmContractDate BETWEEN PTSA.dtmValidFrom AND PTSA.dtmValidTo
					 ORDER BY PTSA.intStandardAdjustmentId DESC
					 ) PTADJ 
		/* Packaging Adjustment Basis */
		OUTER APPLY (SELECT TOP 1 PKSA.strMasterRecord, PKSA.dblRate, PKSA.intCurrencyId, PKUOM.intItemUOMId, PKCU.intCent
					 FROM tblLGStandardAdjustment PKSA
						LEFT JOIN tblICItemUOM PKUOM ON PKUOM.intItemId = I.intItemId AND PKUOM.intUnitMeasureId = PKSA.intUnitMeasureId
						LEFT JOIN tblSMCurrency PKCU ON PKCU.intCurrencyID = PKSA.intCurrencyId
					 WHERE PKSA.intAdjustmentType = 2 AND SCH.dtmContractDate BETWEEN PKSA.dtmValidFrom AND PKSA.dtmValidTo
					 ORDER BY PKSA.intStandardAdjustmentId DESC
					 ) PKADJ
		/* Certification Adjustment Basis */
		OUTER APPLY (SELECT TOP 1 CFSA.strMasterRecord, CFSA.dblRate, CFSA.intCurrencyId, CFUOM.intItemUOMId, CFCU.intCent
					 FROM tblLGStandardAdjustment CFSA
						LEFT JOIN tblICItemUOM CFUOM ON CFUOM.intItemId = I.intItemId AND CFUOM.intUnitMeasureId = CFSA.intUnitMeasureId
						LEFT JOIN tblSMCurrency CFCU ON CFCU.intCurrencyID = CFSA.intCurrencyId
					 WHERE CFSA.intAdjustmentType = 3 AND SCH.dtmContractDate BETWEEN CFSA.dtmValidFrom AND CFSA.dtmValidTo
					 ORDER BY CFSA.intStandardAdjustmentId DESC
					 ) CFADJ 
		/* INCO Term Adjustment Basis */
		OUTER APPLY (SELECT TOP 1 FRMX.dblTotalCostPerContainer, FRMX.intCurrencyId, CTUOM.intItemUOMId, CON.dblNetWeight, FRMCU.intCent
					 FROM tblLGFreightRateMatrix FRMX
						LEFT JOIN tblSMCurrency FRMCU ON FRMCU.intCurrencyID = FRMX.intCurrencyId
						LEFT JOIN tblLGContainerType CON ON CON.intContainerTypeId = FRMX.intContainerTypeId
						LEFT JOIN tblICItemUOM CTUOM ON CTUOM.intItemId = I.intItemId AND CTUOM.intUnitMeasureId = CON.intWeightUnitMeasureId
					 WHERE FRMX.strOriginPort = SHPMT.strOriginPort
						AND FRMX.strDestinationCity IN (SHPMT.strDestinationPort, SHPMT.strDestinationCity) 
						AND FRMX.intEntityId = SHPMT.intShippingLineEntityId
						AND FRMX.intContainerTypeId = ISNULL(SCD.intContainerTypeId, SHPMT.intContainerTypeId)
						AND SHPMT.dtmBLDate BETWEEN FRMX.dtmValidFrom AND FRMX.dtmValidTo
					 ORDER BY FRMX.intFreightRateMatrixId DESC
					 ) FTADJ 
		OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM WHERE intItemId = I.intItemId AND intUnitMeasureId = @intUnitMeasureId) ItemUOM
	WHERE 
		DATEDIFF(DD, PCH.dtmContractDate, SCH.dtmContractDate) > 30
		AND @intCommodityId = PCH.intCommodityId
		AND (@intLocationId IS NULL OR @intLocationId = SCD.intCompanyLocationId)
		AND (@dtmStartDate IS NULL OR SCH.dtmContractDate >= @dtmStartDate) 
		AND (@dtmEndDate IS NULL OR SCH.dtmContractDate <= @dtmEndDate)
	) CVMD

END

GO