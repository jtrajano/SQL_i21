GO
	PRINT 'START OF CREATING [uspTMRecreateSiteOrderView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateSiteOrderView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateSiteOrderView
GO


CREATE PROCEDURE uspTMRecreateSiteOrderView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMSiteOrder')
	BEGIN
		DROP VIEW vyuTMSiteOrder
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF (EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwitmmst') AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst')
			AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwslsmst'))
		BEGIN
			EXEC('
			CREATE VIEW [dbo].[vyuTMSiteOrder]  
			AS
	  
			SELECT
				A.intSiteID 
				,C.vwcus_key AS strCustomerNumber
				,(	CASE WHEN C.vwcus_co_per_ind_cp = ''C''   
					THEN    RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init) + RTRIM(C.vwcus_name_suffix)   
					ELSE    
						CASE WHEN C.vwcus_first_name IS NULL OR RTRIM(C.vwcus_first_name) = ''''  
							THEN     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix)    
						ELSE     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix) + '', '' + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init)    
						END   
					END
					)COLLATE Latin1_General_CI_AS AS strCustomerName
				,RIGHT(''000''+ CAST(A.intSiteNumber AS NVARCHAR(4)),4) AS strSiteNumber
				,(A.strSiteAddress + CHAR(10) + A.strCity + '', '' + A.strState +  '' '' +  A.strZipCode) AS strSiteAddress
				,A.strLocation
				,E.vwsls_name AS strDriverName
				,F.vwitm_no AS strItemNo
				,CAST(ISNULL(A.dblEstimatedPercentLeft,0) AS DECIMAL(18,2)) AS dblEstimatedPercentLeft
				,CAST(ROUND((ISNULL(A.dblTotalCapacity,0.0) * (((CASE WHEN ISNULL(F.vwitm_deflt_percnt,0) = 0 THEN 100 ELSE F.vwitm_deflt_percnt END) - ISNULL(A.dblEstimatedPercentLeft,0.0))/100)),0) AS INT) AS intCalculatedQuantity
				,CAST(ISNULL(A.dblTotalCapacity,0.0) AS DECIMAL(18,2)) AS dblTotalCapacity
				,ISNULL(D.strRouteId,'''') AS strRouteId
				,A.intConcurrencyId
				,A.intFillMethodId
				,A.intRouteId
				,A.intDriverID AS intDriverId
				,ISNULL(A.intNextDeliveryDegreeDay,0) AS intNextDegreeDay
				,ISNULL(A.ysnActive,0) AS ysnActive
				,ISNULL(A.ysnOnHold,0) AS ysnOnHold
				,DATEADD(dd, DATEDIFF(dd, 0, A.dtmNextDeliveryDate), 0) AS dtmNextJulianDate
				,CAST((CASE WHEN G.intDispatchID IS NULL THEN 0 ELSE 1 END) AS BIT) AS ysnPending
				,intDispatchID AS intDispatchId
				,F.vwitm_class AS strItemClass
				,A.intProduct AS intProductId
				,A.intDeliveryTermID
				,ISNULL(G.ysnDispatched,0) AS ysnDispatched
				,A.intTaxStateID
				,ISNULL(G.strWillCallStatus,'''') AS strWillCallStatus
				,ISNULL(A.ysnTaxable,0) AS ysnTaxable
				,RTRIM(ISNULL(F.vwitm_desc,'''')) AS strProductDescription
				,dblPriceAdjustment = ISNULL(A.dblPriceAdjustment,0.0)
				,intCustomerNumber = B.intCustomerNumber
				,intClockLocation = A.intClockID
				,ysnPastDue = CAST((CASE WHEN ISNULL(C.vwcus_high_past_due,0.0) > 0 THEN 1 ELSE 0 END) AS BIT)
				,ysnOverCreditLimit = CAST((CASE WHEN ISNULL(C.vwcus_balance,0.0) <= C.vwcus_cred_limit  THEN 0 ELSE 1 END)  AS BIT)
				,ysnBudgetCustomers = CAST((CASE WHEN ISNULL(C.vwcus_budget_amt_due,0.0) > 0 THEN 1 ELSE 0 END) AS BIT)
				,dblARBalance = ISNULL(C.vwcus_balance,0.0)
				,dblPastDue = ISNULL(C.vwcus_high_past_due,0.0)
				,dblBudgetAmount = ISNULL(C.vwcus_budget_amt_due,0.0)
				,dblCreditLimit = ISNULL(C.vwcus_cred_limit,0.0)
				,intLocationId = A.intLocationId
				,A.intCustomerID
				,intSitePriceLevel = CAST(NULL AS INT)
				,strSiteDescription = ISNULL(A.strDescription,'''')
				,dtmLastDelivery = A.dtmLastDeliveryDate
				,intOpenWorkOrder = ISNULL(M.intOpenCount,0)
			FROM tblTMSite A
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN vwcusmst C
				ON B.intCustomerNumber = C.A4GLIdentity
			LEFT JOIN tblTMRoute D
				ON A.intRouteId = D.intRouteId	
			LEFT JOIN vwslsmst E
				ON A.intDriverID = E.A4GLIdentity	
			LEFT JOIN (SELECT DISTINCT 
					vwitm_no
					,vwitm_deflt_percnt
					,vwitm_class
					,vwitm_desc
					,A4GLIdentity
				FROM vwitmmst) F
				ON A.intProduct = F.A4GLIdentity
			LEFT JOIN tblTMDispatch G
				ON A.intSiteID = G.intSiteID
			LEFT JOIN (
						SELECT intSiteId = intSiteID
							,intOpenCount = COUNT(intSiteID)
						FROM tblTMWorkOrder 
						WHERE intWorkStatusTypeID = (SELECT TOP 1 intWorkStatusID 
													 FROM tblTMWorkStatusType 
													 WHERE strWorkStatus = ''Open'' 
														AND ysnDefault = 1)
						GROUP BY intSiteID
					) M
				ON A.intSiteID = M.intSiteId
			WHERE A.ysnActive = 1 AND A.dblTotalCapacity > 0
			')	
		END	

	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMSiteOrder]  
			AS  
			SELECT
				A.intSiteID 
				,C.strEntityNo AS strCustomerNumber
				,C.strName AS strCustomerName
				,RIGHT(''000''+ CAST(A.intSiteNumber AS NVARCHAR(4)),4) AS strSiteNumber
				,(A.strSiteAddress + CHAR(10) + A.strCity + '', '' + A.strState +  '' '' +  A.strZipCode) AS strSiteAddress
				,A.strLocation
				,E.strEntityNo AS strDriverName
				,D.strItemNo AS strItemNo
				,CAST(ISNULL(A.dblEstimatedPercentLeft,0) AS DECIMAL(18,2)) AS dblEstimatedPercentLeft
				,CAST(ROUND((ISNULL(A.dblTotalCapacity,0.0) * (((CASE WHEN ISNULL(D.dblDefaultFull,0) = 0 THEN 100 ELSE D.dblDefaultFull END) - ISNULL(A.dblEstimatedPercentLeft,0.0))/100)),0) AS INT) AS intCalculatedQuantity
				,CAST(ISNULL(A.dblTotalCapacity,0.0) AS DECIMAL(18,2)) AS dblTotalCapacity
				,ISNULL(F.strRouteId,'''') AS strRouteId
				,A.intConcurrencyId
				,A.intFillMethodId
				,A.intRouteId
				,A.intDriverID AS intDriverId
				,ISNULL(A.intNextDeliveryDegreeDay,0) AS intNextDegreeDay
				,ISNULL(A.ysnActive,0) AS ysnActive
				,ISNULL(A.ysnOnHold,0) AS ysnOnHold
				,DATEADD(dd, DATEDIFF(dd, 0, A.dtmNextDeliveryDate), 0) AS dtmNextJulianDate
				,CAST((CASE WHEN G.intDispatchID IS NULL THEN 0 ELSE 1 END) AS BIT) AS ysnPending
				,intDispatchID AS intDispatchId
				,H.strCategoryCode AS strItemClass
				,A.intProduct AS intProductId
				,A.intDeliveryTermID
				,ISNULL(G.ysnDispatched,0) AS ysnDispatched
				,A.intTaxStateID
				,ISNULL(G.strWillCallStatus,'''') AS strWillCallStatus
				,ISNULL(A.ysnTaxable,0) AS ysnTaxable
				,D.strDescription AS strProductDescription
				,dblPriceAdjustment = ISNULL(A.dblPriceAdjustment,0.0)
				,intCustomerNumber = B.intCustomerNumber
				,ysnPastDue = CAST((CASE WHEN ISNULL(I.dblHighPastDue,0.0) > 0 THEN 1 ELSE 0 END) AS BIT)
				,ysnOverCreditLimit = CAST((CASE WHEN ISNULL(I.dblBalance,0.0) <= I.dblCreditLimit  THEN 0 ELSE 1 END)  AS BIT)
				,ysnBudgetCustomers = CAST((CASE WHEN ISNULL(I.dblBudgetAmount,0.0) > 0 THEN 1 ELSE 0 END) AS BIT)
				,dblARBalance = ISNULL(I.dblBalance,0.0)
				,dblPastDue = ISNULL(I.dblHighPastDue,0.0)
				,dblBudgetAmount = ISNULL(I.dblBudgetAmount,0.0)
				,dblCreditLimit = ISNULL(I.dblCreditLimit,0.0)
				,intLocationId = A.intLocationId
				,A.intCustomerID
				,intClockLocation = A.intClockID
				,intSitePriceLevel = A.intCompanyLocationPricingLevelId
				,strSiteDescription = ISNULL(A.strDescription,'''')
				,dtmLastDelivery = A.dtmLastDeliveryDate
				,intOpenWorkOrder = ISNULL(M.intOpenCount,0)
			FROM tblTMSite A
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN tblEMEntity C
				ON B.intCustomerNumber = C.intEntityId
			LEFT JOIN (
				SELECT 
					A.intEntityId
					,A.strEntityNo
				FROM tblEMEntity A
				INNER JOIN [tblEMEntityType] C
					ON A.intEntityId = C.intEntityId
				WHERE strType = ''Salesperson''
				) E
				ON A.intDriverID = E.intEntityId
			LEFT JOIN tblICItem D
				ON A.intProduct = D.intItemId
			LEFT JOIN tblTMRoute F
				ON A.intRouteId = F.intRouteId	
			LEFT JOIN tblTMDispatch G
				ON A.intSiteID = G.intSiteID
			LEFT JOIN tblICCategory H
				ON D.intCategoryId = H.intCategoryId	
			INNER JOIN (
				SELECT 
					Ent.intEntityId
					,dblHighPastDue = ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0)
					,dblBalance = ISNULL(CI.dblTotalDue,0.0)
					,dblBudgetAmount = ISNULL(CI.dblBudgetAmount,0.0)
					,dblCreditLimit = ISNULL(CI.dblCreditLimit,0.0)
				FROM tblEMEntity Ent
				INNER JOIN tblARCustomer Cus 
					ON Ent.intEntityId = Cus.intEntityId
				LEFT JOIN [vyuARCustomerInquiryReport] CI
					ON Ent.intEntityId = CI.intEntityCustomerId) I
				ON B.intCustomerNumber = I.intEntityId
			LEFT JOIN (
						SELECT intSiteId = intSiteID
							,intOpenCount = COUNT(intSiteID)
						FROM tblTMWorkOrder 
						WHERE intWorkStatusTypeID = (SELECT TOP 1 intWorkStatusID 
													 FROM tblTMWorkStatusType 
													 WHERE strWorkStatus = ''Open'' 
														AND ysnDefault = 1)
						GROUP BY intSiteID
					) M
				ON A.intSiteID = M.intSiteId
			WHERE A.ysnActive = 1 AND A.dblTotalCapacity > 0
			
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateSiteOrderView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateSiteOrderView] SP'
GO
	EXEC ('uspTMRecreateSiteOrderView')
GO
	PRINT 'END OF Execute [uspTMRecreateSiteOrderView] SP'
GO