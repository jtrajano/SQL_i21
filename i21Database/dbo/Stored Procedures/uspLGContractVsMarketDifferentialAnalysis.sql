CREATE PROCEDURE [dbo].[uspLGContractVsMarketDifferentialAnalysis]
	 @intCommodityId INT 
	,@intUnitMeasureId INT 
	,@intLocationId INT = NULL
	,@dtmStartDate DATETIME = NULL
	,@dtmEndDate DATETIME = NULL
AS
BEGIN

SELECT 
	strMonthYr
	,strFutMarketName
	,strFutMarketCurrency
	,strFutMarketUOM
	,dtmFutureMonthsDate
	,strPContractNumber
	,dtmPContractDate
	,strVendor
	,strPINCO
	,intItemId
	,strItemNo
	,strItemDescription
	,strItemOrigin
	,strItemOriginDefaultPort
	,dblPBasis = ROUND(dblPBasis, 2)
	,dblMBasis = ROUND(dblMBasis, 2)
	,dblPaymentTermAdjustmentRate = ROUND(dblPaymentTermAdjustmentRate, 2)
	,dblPackingAdjustmentRate = ROUND(dblPackingAdjustmentRate, 2)
	,dblPINCOAdjustmentRate = ROUND(dblPINCOAdjustmentRate, 2)
	,dblCertificationAdjustmentRate = ROUND(dblCertificationAdjustmentRate, 2)
	,strSContractNumber
	,dtmSContractDate
	,strCustomer
	,dblQty = ROUND(dblQty, 2)
	,dblUnitQty = ROUND(dblUnitQty, 2)
	,strUOM
	,intDays
	,dblSBasis = ROUND(dblSBasis, 2)
	,intCompanyLocationId
	,intCommodityId
	,intAllocationDetailId
	,intConcurrencyId
	/* Adjusted Basis = Market Basis + all adjustments*/
	,dblAdjustedBasis = ROUND(ISNULL(dblMBasis, 0) 
						+ ISNULL(dblPaymentTermAdjustmentRate, 0) 
						+ ISNULL(dblPackingAdjustmentRate, 0) 
						+ ISNULL(dblPINCOAdjustmentRate, 0) 
						+ ISNULL(dblCertificationAdjustmentRate, 0), 2)
	/* Net Basis = Adjusted Basis - P.Contract Basis */
	,dblNetBasis = ROUND((ISNULL(dblMBasis, 0) 
					+ ISNULL(dblPaymentTermAdjustmentRate, 0) 
					+ ISNULL(dblPackingAdjustmentRate, 0) 
					+ ISNULL(dblPINCOAdjustmentRate, 0) 
					+ ISNULL(dblCertificationAdjustmentRate, 0)) - ISNULL(dblPBasis, 0), 2)
	/* Basis Amount = Net Basis x Sales Contract Unit Qty */
	,dblBasisAmount = ROUND(((ISNULL(dblMBasisAmt, 0) 
					+ ISNULL(dblPaymentTermAdjustmentRateAmt, 0) 
					+ ISNULL(dblPackingAdjustmentRateAmt, 0) 
					+ ISNULL(dblPINCOAdjustmentRateAmt, 0) 
					+ ISNULL(dblCertificationAdjustmentRateAmt, 0)) - ISNULL(dblPBasisAmt, 0)) * ISNULL(dblQtyInFMUOM, 1), 2)	
FROM
	(SELECT
		strMonthYr = SFM.strFutureMonth
		,strFutMarketName = FM.strFutMarketName
		,strFutMarketCurrency = FMCUR.strCurrency
		,strFutMarketUOM = FMUM.strUnitMeasure
		,dtmFutureMonthsDate = SFM.dtmFutureMonthsDate
		,strPContractNumber = PCH.strContractNumber + '/' + CAST(PCD.intContractSeq AS NVARCHAR(10))
		,dtmPContractDate = PCH.dtmContractDate
		,strVendor = VEN.strName
		,strPINCO = PFT.strFreightTerm + ', ' + PLOC.strCity
		,intItemId = I.intItemId
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,strItemOrigin = OG.strDescription
		,strItemOriginDefaultPort = ODP.strOriginDefaultPort
		,dblPBasis = ISNULL(PCD.dblBasis, 0)
		,dblMBasis = ISNULL(MB.dblBasisOrDiscount, 0)
		,dblPaymentTermAdjustmentRate = ISNULL(dbo.fnCalculateCostBetweenUOM(PTADJ.intItemUOMId, FMUOM.intItemUOMId, PTADJ.dblRate), 0)
		,dblPackingAdjustmentRate = ISNULL(dbo.fnCalculateCostBetweenUOM(PKADJ.intItemUOMId, FMUOM.intItemUOMId, PKADJ.dblRate), 0)
		,dblPINCOAdjustmentRate = ISNULL(dbo.fnCalculateCostBetweenUOM(FTADJ.intItemUOMId, FMUOM.intItemUOMId, FTADJ.dblTotalCostPerContainer), 0) / ISNULL(FTADJ.dblNetWeight, 1)
		,dblCertificationAdjustmentRate = ISNULL(dbo.fnCalculateCostBetweenUOM(CFADJ.intItemUOMId, FMUOM.intItemUOMId, CFADJ.dblRate), 0)
		,dblPBasisAmt = CASE WHEN ISNULL(PBUOM.dblUnitQty, 0) = 0 OR ISNULL(FMUOM.dblUnitQty, 0) = 0 THEN NULL 	
						ELSE dbo.fnCalculateCostBetweenUOM(PCD.intBasisUOMId, FMUOM.intItemUOMId, ISNULL(PCD.dblBasis, 0)) / ISNULL(PCUR.intCent, 1) END
		,dblMBasisAmt = CASE WHEN ISNULL(MB.dblBasisOrDiscount, 0) = 0 OR ISNULL(FMUOM.dblUnitQty, 0) = 0 THEN NULL 	
						ELSE dbo.fnCalculateCostBetweenUOM(MB.intItemUOMId, FMUOM.intItemUOMId, ISNULL(MB.dblBasisOrDiscount, 0)) / ISNULL(MB.intCent, 1) END
		,dblPaymentTermAdjustmentRateAmt = dbo.fnCalculateCostBetweenUOM(PTADJ.intItemUOMId, FMUOM.intItemUOMId, ISNULL(PTADJ.dblRate, 0)) / ISNULL(FMCUR.intCent, 1)
		,dblPackingAdjustmentRateAmt = dbo.fnCalculateCostBetweenUOM(PKADJ.intItemUOMId, FMUOM.intItemUOMId, ISNULL(PKADJ.dblRate, 0)) / ISNULL(FMCUR.intCent, 1)
		,dblPINCOAdjustmentRateAmt = dbo.fnCalculateCostBetweenUOM(FTADJ.intItemUOMId, FMUOM.intItemUOMId, ISNULL(FTADJ.dblTotalCostPerContainer, 0) / ISNULL(FTADJ.dblNetWeight, 1)) / ISNULL(FMCUR.intCent, 1)
		,dblCertificationAdjustmentRateAmt = dbo.fnCalculateCostBetweenUOM(CFADJ.intItemUOMId, FMUOM.intItemUOMId, ISNULL(CFADJ.dblRate, 0)) / ISNULL(FMCUR.intCent, 1)
		,strSContractNumber = SCH.strContractNumber + '/' + CAST(SCD.intContractSeq AS NVARCHAR(10))
		,dtmSContractDate = SCH.dtmContractDate
		,strCustomer = CUS.strName
		,dblQty = dbo.fnCalculateQtyBetweenUOM(SCD.intItemUOMId, ItemUOM.intItemUOMId, SCD.dblQuantity)
		,dblQtyInFMUOM = dbo.fnCalculateQtyBetweenUOM(SCD.intItemUOMId, FMUOM.intItemUOMId, SCD.dblQuantity)
		,dblUnitQty = CASE WHEN ISNULL(SUOM.dblUnitQty, 0) = 0 OR ISNULL(ItemUOM.dblUnitQty, 0) = 0 THEN NULL 	
						ELSE dbo.fnCalculateQtyBetweenUOM(SCD.intItemUOMId, ItemUOM.intItemUOMId, 1) END
		,strUOM = UM.strUnitMeasure
		,intDays = DATEDIFF(DD, PCH.dtmContractDate, SCH.dtmContractDate)
		,dblSBasis = ISNULL(SCD.dblBasis, 0)
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
		LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = PCD.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth PFM ON PFM.intFutureMonthId = PCD.intFutureMonthId
		LEFT JOIN tblRKFuturesMonth SFM ON SFM.intFutureMonthId = SCD.intFutureMonthId
		LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = PCH.intEntityId
		LEFT JOIN tblEMEntity CUS ON CUS.intEntityId = SCH.intEntityId
		LEFT JOIN tblSMFreightTerms PFT ON PFT.intFreightTermId = PCH.intFreightTermId
		LEFT JOIN tblSMFreightTerms SFT ON SFT.intFreightTermId = SCH.intFreightTermId
		LEFT JOIN tblSMTerm SPT ON SPT.intTermID = PCH.intTermId
		LEFT JOIN tblSMCity PLOC ON PCH.intINCOLocationTypeId = PLOC.intCityId
		LEFT JOIN tblSMCity SLOC ON SCH.intINCOLocationTypeId = SLOC.intCityId
		LEFT JOIN tblICItem I ON I.intItemId = PCD.intItemId
		LEFT JOIN tblICCommodityAttribute OG ON OG.intCommodityAttributeId = I.intOriginId
		LEFT JOIN tblICCommodityUnitMeasure CM ON CM.intCommodityUnitMeasureId = SCH.intCommodityUOMId
		LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CM.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure FMUM ON FMUM.intUnitMeasureId = FM.intUnitMeasureId
		LEFT JOIN tblICItemUOM PUOM ON PUOM.intItemUOMId = PCD.intItemUOMId
		LEFT JOIN tblICItemUOM SUOM ON SUOM.intItemUOMId = SCD.intItemUOMId
		LEFT JOIN tblICItemUOM PBUOM ON PBUOM.intItemUOMId = PCD.intBasisUOMId
		LEFT JOIN tblICItemUOM SBUOM ON SBUOM.intItemUOMId = SCD.intBasisUOMId
		LEFT JOIN tblICItemUOM WUOM ON WUOM.intItemUOMId = SCD.intNetWeightUOMId
		LEFT JOIN tblSMCurrency PCUR ON PCUR.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblSMCurrency SCUR ON SCUR.intCurrencyID = SCD.intBasisCurrencyId
		LEFT JOIN tblSMCurrency SMCUR ON SMCUR.intCurrencyID = SCUR.intMainCurrencyId
		LEFT JOIN tblSMCurrency FMCUR ON FMCUR.intCurrencyID = FM.intCurrencyId
		LEFT JOIN tblICUnitMeasure PUM ON PUM.intUnitMeasureId = PUOM.intUnitMeasureId
		LEFT JOIN tblCTContractDetail FSCD ON FSCD.intContractHeaderId = SCH.intContractHeaderId AND FSCD.intContractSeq = 1
		/* Origin Default Port */
		OUTER APPLY (SELECT TOP 1 strOriginDefaultPort = OGCDP.strCity 
					 FROM tblSMCountry OGC 
						INNER JOIN tblSMCity OGCDP ON OGCDP.intCountryId = OGC.intCountryID
					 WHERE OGC.strCountry = OG.strDescription AND ysnPort = 1 AND ysnDefault = 1) ODP
		/* Market Basis */
		OUTER APPLY (SELECT TOP 1 MTMBD.dblBasisOrDiscount, MTMBD.intCurrencyId, MBUOM.intItemUOMId, MBCU.intCent
					 FROM tblRKM2MBasisDetail MTMBD
						INNER JOIN tblRKM2MBasis MTMB ON MTMB.intM2MBasisId = MTMBD.intM2MBasisId
						LEFT JOIN tblICItemUOM MBUOM ON MBUOM.intItemId = MTMBD.intItemId AND MBUOM.intUnitMeasureId = MTMBD.intUnitMeasureId
						LEFT JOIN tblSMCurrency MBCU ON MBCU.intCurrencyID = MTMBD.intCurrencyId
					 WHERE SCH.intCommodityId = MTMBD.intCommodityId
						AND SCD.intItemId = MTMBD.intItemId
						AND SCD.intFutureMarketId = MTMBD.intFutureMarketId
						AND (MTMBD.intContractTypeId IS NULL OR MTMBD.intContractTypeId = 2)
						AND MTMB.strPricingType = 'Mark to Market'
						AND DATEADD(DD, -60, FSCD.dtmStartDate) >= MTMB.dtmM2MBasisDate
					 ORDER BY 
						ABS(DATEDIFF(HH, DATEADD(DD, -60, FSCD.dtmStartDate), MTMB.dtmM2MBasisDate)) ASC
					 ) MB
		/* Payment Terms Adjustment Basis */
		OUTER APPLY (SELECT TOP 1 PTSA.strMasterRecord, PTSA.intCurrencyId, PTUOM.intItemUOMId,
						dblRate = PTSA.dblRate 
							* CASE WHEN (PTCU.intCurrencyID = FMCUR.intMainCurrencyId) THEN FMCUR.intCent
								   WHEN (PTCU.intMainCurrencyId = FMCUR.intCurrencyID) THEN (1 / PTCU.intCent) ELSE 1 END
					 FROM tblLGStandardAdjustment PTSA
						LEFT JOIN tblICItemUOM PTUOM ON PTUOM.intItemId = I.intItemId AND PTUOM.intUnitMeasureId = PTSA.intUnitMeasureId
						LEFT JOIN tblSMCurrency PTCU ON PTCU.intCurrencyID = PTSA.intCurrencyId
					 WHERE PTSA.intAdjustmentType = 1 
						AND PTSA.strMasterRecord IN (SPT.strTerm, SPT.strTermCode)
						AND SCH.dtmContractDate BETWEEN PTSA.dtmValidFrom AND PTSA.dtmValidTo
					 ORDER BY PTSA.intStandardAdjustmentId DESC
					 ) PTADJ 
		/* Packaging Adjustment Basis */
		OUTER APPLY (SELECT TOP 1 PKSA.strMasterRecord, PKSA.intCurrencyId, PKUOM.intItemUOMId,
						dblRate = PKSA.dblRate 
							* CASE WHEN (PKCU.intCurrencyID = FMCUR.intMainCurrencyId) THEN FMCUR.intCent
								   WHEN (PKCU.intMainCurrencyId = FMCUR.intCurrencyID) THEN (1 / PKCU.intCent) ELSE 1 END
					 FROM tblLGStandardAdjustment PKSA
						LEFT JOIN tblICItemUOM PKUOM ON PKUOM.intItemId = I.intItemId AND PKUOM.intUnitMeasureId = PKSA.intUnitMeasureId
						LEFT JOIN tblSMCurrency PKCU ON PKCU.intCurrencyID = PKSA.intCurrencyId
					 WHERE PKSA.intAdjustmentType = 2 
						AND PKSA.strMasterRecord IN (PUM.strUnitMeasure)
						AND SCH.dtmContractDate BETWEEN PKSA.dtmValidFrom AND PKSA.dtmValidTo
					 ORDER BY PKSA.intStandardAdjustmentId DESC
					 ) PKADJ
		/* Certification Adjustment Basis */
		OUTER APPLY (SELECT TOP 1 CFSA.strMasterRecord, CFSA.intCurrencyId, CFUOM.intItemUOMId,
						dblRate = CFSA.dblRate
							* CASE WHEN (CFCU.intCurrencyID = FMCUR.intMainCurrencyId) THEN FMCUR.intCent 
								   WHEN (CFCU.intMainCurrencyId = FMCUR.intCurrencyID) THEN (1 / CFCU.intCent) ELSE 1 END
					 FROM tblLGStandardAdjustment CFSA
						LEFT JOIN tblICItemUOM CFUOM ON CFUOM.intItemId = I.intItemId AND CFUOM.intUnitMeasureId = CFSA.intUnitMeasureId
						LEFT JOIN tblSMCurrency CFCU ON CFCU.intCurrencyID = CFSA.intCurrencyId
					 WHERE CFSA.intAdjustmentType = 3 
					 	AND CFSA.strMasterRecord IN (SELECT C.strCertificationName FROM tblCTContractCertification 
							CC JOIN tblICCertification C ON C.intCertificationId = CC.intCertificationId WHERE CC.intContractDetailId = PCD.intContractDetailId)
					 AND SCH.dtmContractDate BETWEEN CFSA.dtmValidFrom AND CFSA.dtmValidTo
					 ORDER BY CFSA.intStandardAdjustmentId DESC
					 ) CFADJ 
		/* INCO Term Adjustment Basis */
		OUTER APPLY (SELECT TOP 1 FRMX.intCurrencyId, CTUOM.intItemUOMId, CON.dblNetWeight,
						dblTotalCostPerContainer = FRMX.dblTotalCostPerContainer 
							* CASE WHEN (FRMCU.intCurrencyID = FMCUR.intMainCurrencyId) THEN FMCUR.intCent 
								   WHEN (FRMCU.intMainCurrencyId = FMCUR.intCurrencyID) THEN (1 / FRMCU.intCent) ELSE 1 END
					 FROM tblLGFreightRateMatrix FRMX
						LEFT JOIN tblSMCurrency FRMCU ON FRMCU.intCurrencyID = FRMX.intCurrencyId
						LEFT JOIN tblLGContainerType CON ON CON.intContainerTypeId = FRMX.intContainerTypeId
						LEFT JOIN tblICItemUOM CTUOM ON CTUOM.intItemId = I.intItemId AND CTUOM.intUnitMeasureId = CON.intWeightUnitMeasureId
					 WHERE FRMX.intType = 1
						AND FRMX.strOriginPort = ODP.strOriginDefaultPort
						AND FRMX.strDestinationCity = PLOC.strCity
						AND PCD.dtmStartDate BETWEEN FRMX.dtmValidFrom AND FRMX.dtmValidTo
						AND PCH.intPositionId IN (SELECT intPositionId FROM tblCTPosition P WHERE P.strPositionType = 'Spot')
					 ORDER BY FRMX.dblTotalCostPerContainer ASC
					 ) FTADJ 
		OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	tblICItemUOM WHERE intItemId = I.intItemId AND intUnitMeasureId = FM.intUnitMeasureId) FMUOM
		OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	tblICItemUOM WHERE intItemId = I.intItemId AND intUnitMeasureId = @intUnitMeasureId) ItemUOM
	WHERE 
		DATEDIFF(DD, PCH.dtmContractDate, SCH.dtmContractDate) > 30
		AND @intCommodityId = PCH.intCommodityId
		AND (@intLocationId IS NULL OR @intLocationId = SCD.intCompanyLocationId)
		AND (@dtmStartDate IS NULL OR SCH.dtmContractDate >= @dtmStartDate) 
		AND (@dtmEndDate IS NULL OR SCH.dtmContractDate <= @dtmEndDate)
	) CVMD
	ORDER BY dtmFutureMonthsDate, dtmSContractDate DESC

END

GO
