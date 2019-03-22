CREATE VIEW [dbo].[vyuAPRptCashRequirementsByCommodity]

AS
	SELECT
		 CAST ( SUM(dblTotal) + SUM(dblTax) AS DECIMAL (18,2)) AS dblCommodityTotal, --SUM THE LINE ITEM OF THE BILL PER COMMODITY
		 CAST (SUM(dblNetUnits) AS DECIMAL (18,2)) AS dblNetUnits,
		 ISNULL(strCommodityCode, 'Non - Commodity') as strCommodityCode,
		 strCompanyName = (SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup),
		  strCompanyAddress = (SELECT TOP 1 
				   ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strZip),'') + ' ' + ISNULL(RTRIM(strCity), '') + ' ' + ISNULL(RTRIM(strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strPhone)+ CHAR(13) + char(10), '') FROM tblSMCompanySetup)
	FROM
	(
	SELECT
		 APB.intBillId,
		C.strCommodityCode,
		CASE WHEN IE.strType = 'Other Charge' THEN 0 ELSE
		( CASE 
				WHEN APBD.intWeightUOMId > 0 
				THEN dbo.fnCalculateQtyBetweenUOM(APBD.intWeightUOMId, CUM.intUnitMeasureId,  ISNULL(APBD.dblNetWeight,0)) --NET 
				ELSE dbo.fnCalculateQtyBetweenUOM(APBD.intUnitOfMeasureId, CUM.intUnitMeasureId,  ISNULL(APBD.dblQtyReceived,0)) END --STOCK
		) END AS dblNetUnits,
		APBD.dblTotal,
		APBD.dblTax,
		APB.dblAmountDue
	FROM tblAPBill APB
	INNER JOIN tblAPBillDetail APBD
		ON APB.intBillId = APBD.intBillId
	INNER JOIN dbo.tblICItem IE 
		ON IE.intItemId = APBD.intItemId 
	LEFT JOIN dbo.tblICCommodity C 
		ON C.intCommodityId = IE.intCommodityId
	INNER JOIN tblICCommodityUnitMeasure CUM
		ON CUM.intCommodityId = C.intCommodityId AND ysnStockUnit = 1
	WHERE APBD.intItemId IS NOT NULL 
		  AND APBD.intContractHeaderId IS NOT NULL --WILL SHOW ALL CONTRACT RELATED TRANSACTIONS 
		  AND APB.intBillId NOT IN ( --WILL SHOW NOT PAID TRANSACTIONS ONLY
			SELECT A.intBillId FROM [vyuAPBillPayment] A
		  )
		GROUP BY strCommodityCode, 
		APBD.dblUnitQty,
		APBD.dblTotal,
		APBD.dblTax,
		APBD.dblQtyReceived , 
		APBD.dblNetWeight,
		APB.intBillId,
		APBD.intWeightUOMId,
		APB.dblAmountDue,
		IE.strType,
		CUM.intUnitMeasureId,
		APBD.intUnitOfMeasureId
	) commodityHeader 
	GROUP BY strCommodityCode
GO