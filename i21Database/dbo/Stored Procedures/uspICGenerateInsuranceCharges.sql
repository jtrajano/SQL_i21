CREATE PROCEDURE [dbo].[uspICGenerateInsuranceCharges]
	@strStorageLocationIds AS NVARCHAR(MAX)
	,@intCommodity AS INT
	,@dtmChargeDateUTC AS DATETIME
	,@intM2MHeaderId AS INT
AS




SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON


--DECLARE @intSubLocationId AS INT = 6
--DECLARE @intCommodity AS INT = 1
--DECLARE @dtmChargeDateUTC AS DATETIME = '2022-04-19 16:00:00.000'
--DECLARE @intM2MHeaderId AS INT = 0


DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @dtmChargeDate AS DATETIME 
DECLARE @LocalToUTCDiff AS INT
DECLARE @UTCToLocalDiff AS INT

SET @LocalToUTCDiff = (DATEDIFF(HOUR,GETDATE(),GETUTCDATE()))
SET @UTCToLocalDiff = (DATEDIFF(HOUR,GETUTCDATE(),GETDATE()))

SELECT @dtmChargeDate = DATEADD(HOUR,@UTCToLocalDiff,@dtmChargeDateUTC)


BEGIN TRY
	
	-----GEt Storage Location Ids
	IF OBJECT_ID('tempdb..#tmpStorageLocationIds') IS NOT NULL  					
		DROP TABLE #tmpStorageLocationIds	
	SELECT											
 		intStorageLocationId = AA.Item
	INTO #tmpStorageLocationIds
 	FROM dbo.fnSplitString (ISNULL(@strStorageLocationIds,''),',') AA

	-------------Get the insurance rates
	IF OBJECT_ID('tempdb..#tmpInsuranceRate') IS NOT NULL  					
		DROP TABLE #tmpInsuranceRate	
	SELECT 
		B.intInsurerId
		,B.intInsuranceRateId
		,A.strRateType
		,A.strAppliedTo
		,A.dblRate
		,A.intUnitMeasureId
		,B.dtmStartDateUTC
		,B.dtmEndDateUTC
		,A.intStorageLocationId
		,strInsurerName = C.strName
		,A.intCurrencyId
		,strCurrency = D.strCurrency
		,B.intItemId
		,B.strPolicyNumber
		,A.intInsuranceRateDetailId
	INTO #tmpInsuranceRate
	FROM tblICInsuranceRateDetail A
	INNER JOIN tblICInsuranceRate B
		ON A.intInsuranceRateId = B.intInsuranceRateId
	LEFT JOIN tblEMEntity C
		ON B.intInsurerId = C.intEntityId
	LEFT JOIN tblSMCurrency D
		ON A.intCurrencyId = D.intCurrencyID
	WHERE B.dtmStartDateUTC <= @dtmChargeDateUTC
		AND B.dtmEndDateUTC >= @dtmChargeDateUTC
		AND A.intStorageLocationId IN	(
											SELECT											
 												intStorageLocationId
 											FROM #tmpStorageLocationIds AA
										)

	
	------Get Lot IR transaction 
	IF OBJECT_ID('tempdb..#tmpLotTransactions') IS NOT NULL  					
		DROP TABLE #tmpLotTransactions	

	SELECT 
		dblQuantity = A.dblQuantity
		,intItemUOMId = A.intItemUnitMeasureId
		,A.dblGrossWeight
		,A.dblTareWeight
		,B.intWeightUOMId
		,dblCost = D.dblLastCost
		,C.dtmLastCargoInsuranceDate
		,intStorageLocationId = B.intSubLocationId
		,B.intContractDetailId
		,A.intInventoryReceiptItemLotId
		,D.intLotId
		,strContractNumber = F.strContractNumber
		,intContractSeq = E.intContractSeq
		,strReceiptNumber = C.strReceiptNumber
		,D.strLotNumber
	INTO #tmpLotTransactions
	FROM tblICInventoryReceiptItemLot A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt C
		ON B.intInventoryReceiptId = C.intInventoryReceiptId
	INNER JOIN tblICLot D
		ON A.intLotId = D.intLotId
	LEFT JOIN tblCTContractDetail E
		ON D.intContractDetailId = E.intContractDetailId
	LEFT JOIN tblCTContractHeader F
		ON E.intContractHeaderId = F.intContractHeaderId
	WHERE C.dtmLastCargoInsuranceDate <= @dtmChargeDate
		AND B.intSubLocationId IN	(
										SELECT											
 											intStorageLocationId
 										FROM #tmpStorageLocationIds AA
									)
		AND A.intInventoryReceiptItemLotId NOT IN (SELECT A.intInventoryReceiptItemLotId 
													FROM tblICInsuranceChargeDetail A
													INNER JOIN tblICInsuranceCharge B
														ON A.intInsuranceChargeId = B.intInsuranceChargeId
													WHERE B.ysnPosted = 1)
		AND D.dblQty > 0
		AND ISNULL(D.strCondition,'') NOT IN ('Missing','Skimmed','Swept')
	


	----Generate charge items
	SELECT 
		strCompanyLocation = D.strLocationName
		,strStorageLocation = C.strSubLocationName
		,B.dblQuantity
		,strQuantityUOM = F.strUnitMeasure
		,intQuantityUOMId = B.intItemUOMId
		,dblWeight = ISNULL(dblGrossWeight,0.0) - ISNULL(dblTareWeight,0.0)
		,strWeightUOM = H.strUnitMeasure
		,intWeightUOMId = B.intWeightUOMId
		,dblInventoryValue = B.dblCost
		,dblM2MValue = K.dblMarketPrice
		,dtmLastCargoInsuranceDate
		,A.strInsurerName
		,A.intInsurerId
		,A.dblRate
		,A.intCurrencyId
		,A.strCurrency
		,strRateUOM = I.strUnitMeasure
		,intRateUOMId = L.intItemUOMId
		,dblAmount = ROUND ((CASE	WHEN A.strRateType = 'Unit' THEN B.dblQuantity * A.dblRate
							WHEN A.strRateType = 'Percent' THEN (CASE WHEN A.strAppliedTo = 'Inventory Value' THEN ISNULL(((B.dblCost * B.dblQuantity * dblRate) /100),0.0)
																		 WHEN A.strAppliedTo = 'M2M' THEN ISNULL(((ISNULL(K.dblMarketPrice,0.0) * B.dblQuantity * dblRate) /100),0.0)
																	ELSE 0.0 END)
							ELSE 0.0 END),2)
		,B.intInventoryReceiptItemLotId
		,A.strRateType
		,A.strPolicyNumber
		,intStorageLocationId = A.intStorageLocationId
		,A.intInsuranceRateDetailId
		,intChargeItemId = A.intItemId
		,intLotId = B.intLotId
		,B.strContractNumber
		,B.intContractSeq
		,B.strReceiptNumber
		,B.strLotNumber
		,A.strAppliedTo
	FROM #tmpInsuranceRate A
	INNER JOIN #tmpLotTransactions B
		ON A.intStorageLocationId = B.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation C
		ON A.intStorageLocationId = C.intCompanyLocationSubLocationId
	LEFT JOIN tblSMCompanyLocation D
		ON C.intCompanyLocationId = D.intCompanyLocationId
	LEFT JOIN tblICItemUOM E
		ON B.intItemUOMId = E.intItemUOMId
	LEFT JOIN tblICUnitMeasure F
		ON E.intUnitMeasureId = F.intUnitMeasureId
	LEFT JOIN tblICItemUOM G
		ON B.intWeightUOMId = G.intItemUOMId
	LEFT JOIN tblICUnitMeasure H
		ON G.intUnitMeasureId = H.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure I
		ON A.intUnitMeasureId = I.intUnitMeasureId
	LEFT JOIN tblRKM2MHeader J
		ON J.intM2MHeaderId = @intM2MHeaderId
	LEFT JOIN tblRKM2MTransaction K
		ON J.intM2MHeaderId = K.intM2MHeaderId
			AND B.intContractDetailId = K.intContractDetailId
			AND K.strContractOrInventoryType = 'Inventory (P)'
	LEFT JOIN tblICItemUOM L
		ON L.intItemId = A.intItemId
			AND L.intUnitMeasureId = A.intUnitMeasureId




	
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);

END CATCH
GO