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
		CASE WHEN APBD.intWeightUOMId > 0 THEN ISNULL(APBD.dblNetWeight,0) ELSE dblQtyReceived END  as dblNetUnits,
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
		APB.dblAmountDue
	) commodityHeader 
	GROUP BY strCommodityCode
GO