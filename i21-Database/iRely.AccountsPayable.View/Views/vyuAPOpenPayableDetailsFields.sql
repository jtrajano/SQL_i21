CREATE VIEW [dbo].[vyuAPOpenPayableDetailsFields]
AS
SELECT *
FROM (
	SELECT A.dtmDate
		,A.dtmDueDate
		,B.strVendorId
		,B.[intEntityId]
		,A.intBillId
		,A.strBillId
		,A.strVendorOrderNumber
		,T.strTerm
		,(
			SELECT TOP 1 strCompanyName
			FROM dbo.tblSMCompanySetup
			) AS strCompanyName
		,A.intAccountId
		,D.strAccountId
		,tmpAgingSummaryTotal.dblTotal
		,tmpAgingSummaryTotal.dblAmountPaid
		,tmpAgingSummaryTotal.dblDiscount
		,tmpAgingSummaryTotal.dblInterest
		,tmpAgingSummaryTotal.dblAmountDue
		,ISNULL(B.strVendorId, '') + ' - ' + isnull(C.strName, '') AS strVendorIdName
		,NULL AS strReceiptNumber 
		,NULL AS strTicketNumber
		,NULL AS strShipmentNumber
		,NULL AS strContractNumber
		,NULL AS strLoadNumber
		,EC.strClass
		,E.strCommodityCode
	FROM (
		SELECT intBillId
			,SUM(tmpAPPayables.dblTotal) AS dblTotal
			,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
			,SUM(tmpAPPayables.dblDiscount) AS dblDiscount
			,SUM(tmpAPPayables.dblInterest) AS dblInterest
			,(SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS dblAmountDue
		FROM (
			SELECT intBillId
				,dblTotal
				,dblAmountDue
				,dblAmountPaid
				,dblDiscount
				,dblInterest
				,dtmDate
			FROM dbo.vyuAPPayables
			) tmpAPPayables
		GROUP BY intBillId
		UNION ALL
		SELECT 
			intBillId
			,SUM(tmpAPPrepaidPayables.dblTotal) AS dblTotal
			,0 --SUM(tmpAPPrepaidPayables.dblAmountPaid) AS dblAmountPaid
			,SUM(tmpAPPrepaidPayables.dblDiscount)AS dblDiscount
			,SUM(tmpAPPrepaidPayables.dblInterest) AS dblInterest
			,CAST((SUM(tmpAPPrepaidPayables.dblTotal) + SUM(tmpAPPrepaidPayables.dblInterest) - SUM(tmpAPPrepaidPayables.dblAmountPaid) - SUM(tmpAPPrepaidPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM (SELECT --DISTINCT 
				intBillId
				,dblTotal
				,dblAmountDue
				,dblAmountPaid
				,dblDiscount
				,dblInterest
				,dtmDate
				,intPrepaidRowType
			FROM dbo.vyuAPPrepaidPayables) tmpAPPrepaidPayables 
		GROUP BY intBillId, intPrepaidRowType
		) AS tmpAgingSummaryTotal
	LEFT JOIN dbo.tblAPBill A ON A.intBillId = tmpAgingSummaryTotal.intBillId
	LEFT JOIN (
		dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId
		) ON B.[intEntityId] = A.[intEntityVendorId]
	LEFT JOIN dbo.tblGLAccount D ON A.intAccountId = D.intAccountId
	LEFT JOIN dbo.tblSMTerm T ON A.intTermsId = T.intTermID
	LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C.intEntityClassId
	LEFT JOIN vyuAPVoucherCommodity E ON E.intBillId = tmpAgingSummaryTotal.intBillId
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
	) MainQuery

	UNION ALL
  
	SELECT *
	   FROM (
		SELECT DISTINCT
			 NULL AS dtmDate
			,NULL AS dtmDueDate
			,NULL AS strVendorId
			,NULL AS intEntityId
			,NULL AS intBillId
			,APB.strBillId AS strBillId
			,NULL AS strVendorOrderNumber
			,NULL AS strTerm
			,NULL AS strCompanyName
			,NULL AS intAccountId
			,NULL AS strAccountId
			,NULL AS dblTotal
			,NULL AS dblAmountPaid
			,NULL AS dblDiscount
			,NULL AS dblInterest
			,NULL AS dblAmountDue
			,NULL AS strVendorIdName
			,IR.strReceiptNumber 
			,SC.strTicketNumber
			,ICS.strShipmentNumber
			,CH.strContractNumber
			,LG.strLoadNumber
			,NULL AS strClass
			,E.strCommodityCode
		FROM (
			SELECT intBillId
				,(SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS dblAmountDue
			FROM (
				SELECT intBillId
					,dblTotal
					,dblAmountDue
					,dblAmountPaid
					,dblDiscount
					,dblInterest
				FROM dbo.vyuAPPayables
				) tmpAPPayables
			GROUP BY intBillId
			) AS tmpAgingSummaryTotal
		INNER JOIN dbo.tblAPBill APB ON APB.intBillId = tmpAgingSummaryTotal.intBillId
		INNER JOIN dbo.tblAPBillDetail APD ON APB.intBillId = APD.intBillId
		LEFT JOIN dbo.tblICInventoryReceiptItem IRE ON APD.intInventoryReceiptItemId = IRE.intInventoryReceiptItemId
		LEFT JOIN dbo.tblICInventoryReceipt IR ON IRE.intInventoryReceiptId = IR.intInventoryReceiptId 
		LEFT JOIN dbo.tblICInventoryShipment ICS ON ICS.intInventoryShipmentId = APD.intInventoryShipmentChargeId
		LEFT JOIN dbo.tblSCTicket SC ON IRE.intSourceId = SC.intTicketId
		LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = IRE.intOrderId
		LEFT JOIN dbo.tblLGLoad LG ON LG.intLoadId = APD.intLoadId
		LEFT JOIN vyuAPVoucherCommodity E ON E.intBillId = tmpAgingSummaryTotal.intBillId
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
		) MainQuery    

GO


