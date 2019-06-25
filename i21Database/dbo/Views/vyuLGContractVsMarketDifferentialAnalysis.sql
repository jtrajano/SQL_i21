CREATE VIEW [dbo].[vyuLGContractVsMarketDifferentialAnalysis]
AS
SELECT
	strMonthYr = SFM.strFutureMonth
	,strPContractNumber = PCH.strContractNumber
	,dtmPContractNumber = PCH.dtmContractDate
	,strVendor = VEN.strName
	,strPBasis = PCD.dblBasis
	,strPINCO = FT.strFreightTerm
	,strItemNo = I.strItemNo
	,strItemDescription = I.strDescription
	,strItemOrigin = OG.strDescription
	,dblMBasis = MB.dblBasisOrDiscount
	,strPaymentTermAdjustment = ISNULL(PTADJ.strMasterRecord, '')
	,strPackingAdjustment = ISNULL(PKADJ.strMasterRecord, '')
	,strPINCOAdjustment = ISNULL(FTADJ.strMasterRecord, '')
	,strCertificationAdjustment = ISNULL(CFADJ.strMasterRecord, '')
	,dblNetBasis = ISNULL(PCD.dblBasis, 0) + ISNULL(MB.dblBasisOrDiscount, 0)
				 + ISNULL(PTADJ.dblRate, 0) + ISNULL(PKADJ.dblRate, 0)  
				 + ISNULL(FTADJ.dblRate, 0) + ISNULL(CFADJ.dblRate, 0)
	,strSContractNumber = SCH.strContractNumber
	,strCustomer = CUS.strName
	,dblQty = SCH.dblQuantity
	,strUOM = UM.strUnitMeasure
	,intDays = DATEDIFF(DD, PCH.dtmContractDate, SCH.dtmContractDate)
	,dblSBasis = SCD.dblBasis
	,strSBasisUOM = BUM.strUnitMeasure
	,intUnitMeasureId = UM.intUnitMeasureId
	,intCompanyLocationId = PCD.intCompanyLocationId
	,intCommodityId = PCH.intCommodityId
FROM
	tblLGAllocationDetail ALD
	INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = ALD.intPContractDetailId
	INNER JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
	INNER JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
	INNER JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblRKFuturesMonth PFM ON PFM.intFutureMonthId = PCD.intFutureMonthId
	LEFT JOIN tblRKFuturesMonth SFM ON SFM.intFutureMonthId = SCD.intFutureMonthId
	LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = PCH.intEntityId
	LEFT JOIN tblEMEntity CUS ON CUS.intEntityId = SCH.intEntityId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = PCH.intFreightTermId
	LEFT JOIN tblICItem I ON I.intItemId = PCD.intItemId
	LEFT JOIN tblICCommodityAttribute OG ON OG.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblICCommodityUnitMeasure CM ON CM.intCommodityUnitMeasureId = SCH.intCommodityUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CM.intUnitMeasureId 
	LEFT JOIN tblICItemUOM BUOM ON BUOM.intItemUOMId = SCD.intBasisUOMId
	LEFT JOIN tblICUnitMeasure BUM ON BUM.intUnitMeasureId = BUOM.intUnitMeasureId
	OUTER APPLY (SELECT TOP 1 dblBasisOrDiscount FROM tblRKM2MBasisDetail MTMBD
					INNER JOIN tblRKM2MBasis MTMB ON MTMB.intM2MBasisId = MTMBD.intM2MBasisId
				 WHERE PCH.intCommodityId = MTMBD.intCommodityId
					AND PCD.intItemId = MTMBD.intItemId
					AND PCD.intFutureMarketId = MTMBD.intFutureMarketId
					AND PCD.intFutureMonthId = MTMBD.intFutureMonthId
					AND PFM.strFutureMonth = MTMBD.strPeriodTo
				 ORDER BY MTMB.dtmM2MBasisDate DESC
				 ) MB
	OUTER APPLY (SELECT TOP 1 strMasterRecord, dblRate FROM tblLGStandardAdjustment
				 WHERE intAdjustmentType = 1 AND SCH.dtmContractDate BETWEEN dtmValidFrom AND dtmValidTo
				 ORDER BY intStandardAdjustmentId DESC
				 ) PTADJ
	OUTER APPLY (SELECT TOP 1 strMasterRecord, dblRate FROM tblLGStandardAdjustment
				 WHERE intAdjustmentType = 2 AND SCH.dtmContractDate BETWEEN dtmValidFrom AND dtmValidTo
				 ORDER BY intStandardAdjustmentId DESC
				 ) PKADJ
	OUTER APPLY (SELECT TOP 1 strMasterRecord, dblRate FROM tblLGStandardAdjustment
				 WHERE intAdjustmentType = 3 AND SCH.dtmContractDate BETWEEN dtmValidFrom AND dtmValidTo
				 ORDER BY intStandardAdjustmentId DESC
				 ) FTADJ
	OUTER APPLY (SELECT TOP 1 strMasterRecord, dblRate FROM tblLGStandardAdjustment
				 WHERE intAdjustmentType = 4 AND SCH.dtmContractDate BETWEEN dtmValidFrom AND dtmValidTo
				 ORDER BY intStandardAdjustmentId DESC
				 ) CFADJ
WHERE DATEDIFF(DD, PCH.dtmContractDate, SCH.dtmContractDate) > 30

GO
