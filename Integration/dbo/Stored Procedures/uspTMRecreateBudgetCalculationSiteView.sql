GO
	PRINT 'START OF CREATING [uspTMRecreateBudgetCalculationSiteView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateBudgetCalculationSiteView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateBudgetCalculationSiteView
GO

CREATE PROCEDURE uspTMRecreateBudgetCalculationSiteView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMBudgetCalculationSite')
	BEGIN
		DROP VIEW vyuTMBudgetCalculationSite
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1 
	)
	BEGIN
		EXEC ('
				
				CREATE VIEW [dbo].[vyuTMBudgetCalculationSite]  
				AS 

				SELECT 
					strCustomerNumber = C.vwcus_key COLLATE Latin1_General_CI_AS
					,strCustomerName = C.strFullName COLLATE Latin1_General_CI_AS
					,strLocation = D.vwloc_loc_no COLLATE Latin1_General_CI_AS
					,intSiteNumber = A.intSiteNumber
					,strSiteDescription  = A.strDescription
					,strSiteAddress = A.strSiteAddress
					,dblYTDGalsThisSeason = ISNULL(H.dblTotalGallons,0.0)
					,dblYTDGalsLastSeason = ISNULL(I.dblTotalGallons,0.0)
					,dblYTDGals2SeasonsAgo = ISNULL(J.dblTotalGallons,0.0)
					,dblSiteBurnRate = A.dblBurnRate
					,dblSiteEstimatedGallonsLeft = A.dblEstimatedGallonsLeft
					,dblCurrentARBalance = CAST((ISNULL(C.vwcus_ar_per1,0.0) + ISNULL(C.vwcus_ar_per2,0.0) + ISNULL(C.vwcus_ar_per3,0.0) + ISNULL(C.vwcus_ar_per4,0.0) + ISNULL(C.vwcus_ar_per5,0.0) + ISNULL(C.vwcus_ar_future,0.0)) AS NUMERIC(18,6))
					,dblDailyUse = (CASE WHEN MONTH(GETDATE()) >= G.intBeginSummerMonth AND  MONTH(GETDATE()) < G.intBeginWinterMonth THEN ISNULL(A.dblSummerDailyUse,0.0) ELSE ISNULL(A.dblWinterDailyUse,0) END)
					,strSiteNumber = RIGHT(''0000'' + CAST(ISNULL(A.intSiteNumber,0)AS NVARCHAR(4)),4) 
					,dblUnappliedCredits = ISNULL(C.vwcus_cred_reg,0.0) + ISNULL(C.vwcus_cred_ppd,0.0)
					,E.*
				FROM tblTMSite A
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				INNER JOIN vwcusmst C
					ON B.intCustomerNumber = C.A4GLIdentity
				LEFT JOIN vwlocmst D
					ON A.intLocationId = D.A4GLIdentity
				INNER JOIN tblTMBudgetCalculationSite E
					ON A.intSiteID = E.intSiteId
				LEFT JOIN tblTMClock G
					ON A.intClockID = G.intClockID
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND intCurrentSeasonYear = intSeasonYear
				)H
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND (intCurrentSeasonYear - 1) = intSeasonYear
				)I
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND (intCurrentSeasonYear - 2) = intSeasonYear
				)J
			
		')
	END
	ELSE
	BEGIN
		EXEC ('
				CREATE VIEW [dbo].[vyuTMBudgetCalculationSite]  
				AS 

				SELECT 
					strCustomerNumber = C.strEntityNo
					,strCustomerName = C.strName
					,strLocation = D.strLocationName 
					,intSiteNumber = A.intSiteNumber
					,strSiteDescription  = A.strDescription
					,strSiteAddress = A.strSiteAddress
					,dblYTDGalsThisSeason = ISNULL(H.dblTotalGallons,0.0)
					,dblYTDGalsLastSeason = ISNULL(I.dblTotalGallons,0.0)
					,dblYTDGals2SeasonsAgo = ISNULL(J.dblTotalGallons,0.0)
					,dblSiteBurnRate = A.dblBurnRate
					,dblSiteEstimatedGallonsLeft = A.dblEstimatedGallonsLeft
					,dblCurrentARBalance = CAST(ISNULL(F.dbl0Days,0.0) + (ISNULL(F.dbl10Days,0.0) + ISNULL(F.dbl30Days,0.0) + ISNULL(F.dbl60Days,0.0)+ ISNULL(F.dbl90Days,0.0) + ISNULL(F.dbl91Days,0.0) + ISNULL(F.dblFuture,0.0)) AS NUMERIC(18,6))
					,dblDailyUse = (CASE WHEN MONTH(GETDATE()) >= G.intBeginSummerMonth AND  MONTH(GETDATE()) < G.intBeginWinterMonth THEN ISNULL(A.dblSummerDailyUse,0.0) ELSE ISNULL(A.dblWinterDailyUse,0) END)
					,strSiteNumber = RIGHT(''0000'' + CAST(ISNULL(A.intSiteNumber,0)AS NVARCHAR(4)),4) 
					,dblUnappliedCredits = ISNULL(F.dblUnappliedCredits,0.0) + ISNULL(F.dblPrepaids,0.0)
					,E.*
				FROM tblTMSite A
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				INNER JOIN tblEMEntity C
					ON B.intCustomerNumber = C.intEntityId
				LEFT JOIN tblSMCompanyLocation D
					ON A.intLocationId = D.intCompanyLocationId
				INNER JOIN tblTMBudgetCalculationSite E
					ON A.intSiteID = E.intSiteId
				LEFT JOIN vyuARCustomerInquiryReport F
					ON C.intEntityId = F.intEntityCustomerId
				LEFT JOIN tblTMClock G
					ON A.intClockID = G.intClockID
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND intCurrentSeasonYear = intSeasonYear
				)H
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND (intCurrentSeasonYear - 1) = intSeasonYear
				)I
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND (intCurrentSeasonYear - 2) = intSeasonYear
				)J
		
		

		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateBudgetCalculationSiteView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateBudgetCalculationSiteView'
GO 
	EXEC ('uspTMRecreateBudgetCalculationSiteView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateBudgetCalculationSiteView'
GO
