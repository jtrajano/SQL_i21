CREATE VIEW [dbo].[vyuTMLeaseSearch]
AS  
	SELECT
			A.intLeaseId
			,A.strLeaseNumber
			,A.dtmStartDate
			,strLeaseCode = B.strLeaseCode
			,strBillToCustomerNumber = C.strEntityNo
			,strBillToCustomerName = C.strName
			,A.strRentalStatus
			,A.strLeaseStatus
			,A.strBillingFrequency
			,A.intBillingMonth
			,A.strBillingType
			,ysnLeaseToOwn = CAST(ISNULL(A.ysnLeaseToOwn,0) AS BIT)
			,A.dtmDontBillAfter
			,A.intConcurrencyId 
			,strSiteCustomerNumber = L.strEntityNo
			,strSiteCustomerName = L.strName
			,intSiteNumber = F.intSiteNumber
			,strSiteDescription = F.strDescription
			,F.strSiteAddress 
			,H.strDeviceType
			,G.strSerialNumber
			,dblLeaseAmount = J.dblAmount
			,ysnLeaseTaxable = J.ysnTaxable
			,dblTotalUsage = ISNULL((SELECT 
								SUM(ISNULL(dblQuantityDelivered,0.0)) 
							  FROM tblTMDeliveryHistory 
							  WHERE intSiteID = F.intSiteID 
								AND dtmInvoiceDate >= ISNULL(HH.dtmStartDate, DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))
								AND dtmInvoiceDate <= ISNULL(HH.dtmStartDate, DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))), 0.0)
			,dblLeaseBillingMinimum = (SELECT TOP 1 dblMinimumUsage 
												FROM tblTMLeaseMinimumUse 
												WHERE dblSiteCapacity >= ISNULL(F.dblTotalCapacity,0) 
												ORDER BY tblTMLeaseMinimumUse.dblSiteCapacity ASC)
			,dtmLastLeaseBillingDate = A.dtmLastLeaseBillingDate
			,intCntId = CAST((ROW_NUMBER()OVER (ORDER BY A.intLeaseId)) AS INT)
			,strSiteNumber = RIGHT('000'+ CAST(F.intSiteNumber AS VARCHAR(4)),4)
			,strAgreementLetter = M.strName
			,A.ysnPrintDeviceValueInAgreement
			,A.strEvaluationMethod
			,strSiteLocation = N.strLocationName
		FROM tblTMLease A
		LEFT JOIN tblTMLeaseCode B
			ON A.intLeaseCodeId = B.intLeaseCodeId
		LEFT JOIN tblEMEntity C
			ON A.intBillToCustomerId = C.intEntityId 
		LEFT JOIN tblTMLeaseDevice D
			ON A.intLeaseId = D.intLeaseId 
		LEFT JOIN (
			SELECT DISTINCT 
				S.intSiteID
				,LD.intLeaseId
			FROM tblTMLeaseDevice LD
			INNER JOIN tblTMDevice Dev
				ON LD.intDeviceId = Dev.intDeviceId
			INNER JOIN tblTMSiteDevice SD
				ON SD.intDeviceId = Dev.intDeviceId
			INNER JOIN tblTMSite S 
				ON SD.intSiteID = S.intSiteID
		) E
			ON D.intLeaseId = E.intLeaseId
		LEFT JOIN tblTMSite F
			ON E.intSiteID = F.intSiteID
		LEFT JOIN tblTMDevice G
			ON G.intDeviceId = D.intDeviceId
		LEFT JOIN tblTMDeviceType H
			ON G.intDeviceTypeId = H.intDeviceTypeId
		LEFT JOIN tblTMLeaseCode J
			ON A.intLeaseCodeId = J.intLeaseCodeId
		LEFT JOIN tblTMCustomer K
			ON F.intCustomerID = K.intCustomerID 
		LEFT JOIN tblEMEntity L
			ON K.intCustomerNumber = L.intEntityId
		LEFT JOIN (
				SELECT dtmStartDate = MAX(dtmDate)
					,intClockID 
				FROM tblTMDegreeDayReading
				WHERE ysnSeasonStart = 1
				GROUP BY intClockID
		) HH
			ON F.intClockID = HH.intClockID
		LEFT JOIN tblSMLetter M
			ON A.intLetterId = M.intLetterId
		LEFt JOIN tblSMCompanyLocation N
			ON F.intLocationId = N.intCompanyLocationId   
GO