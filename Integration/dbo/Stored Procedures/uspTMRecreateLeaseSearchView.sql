GO
	PRINT 'START OF CREATING [uspTMRecreateLeaseSearchView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateLeaseSearchView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateLeaseSearchView
GO

CREATE PROCEDURE uspTMRecreateLeaseSearchView 
AS
BEGIN
	IF OBJECT_ID('tempdb..#tblTMOriginMod') IS NOT NULL DROP TABLE #tblTMOriginMod

	CREATE TABLE #tblTMOriginMod
	(
		 intModId INT IDENTITY(1,1)
		, strDBName nvarchar(50) NOT NULL 
		, strPrefix NVARCHAR(5) NOT NULL UNIQUE
		, strName NVARCHAR(30) NOT NULL UNIQUE
		, ysnUsed BIT NOT NULL 
	)

	-- AG ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ag')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	-- PETRO ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMLeaseSearch') 
	BEGIN
		DROP VIEW vyuTMLeaseSearch
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMLeaseSearch]
				AS
				SELECT
					A.intLeaseId
					,A.strLeaseNumber
					,A.dtmStartDate
					,strLeaseCode = B.strLeaseCode
					,strBillToCustomerNumber = D.vwcus_key COLLATE Latin1_General_CI_AS 	
					,strBillToCustomerName = (CASE WHEN D.vwcus_co_per_ind_cp = ''D''   
													THEN  ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_first_name),'''') + ISNULL(RTRIM(D.vwcus_mid_init),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''')   
													ELSE    
														CASE WHEN D.vwcus_first_name IS NULL OR RTRIM(D.vwcus_first_name) = ''''  
															THEN     ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''')    
															ELSE     ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(D.vwcus_first_name),'''') + ISNULL(RTRIM(D.vwcus_mid_init),'''')    
														END   
												END) COLLATE Latin1_General_CI_AS 
					,A.strRentalStatus
					,A.strLeaseStatus
					,A.strBillingFrequency
					,A.intBillingMonth
					,A.strBillingType
					,ysnLeaseToOwn = CAST(ISNULL(A.ysnLeaseToOwn,0) AS BIT)
					,A.dtmDontBillAfter
					,A.intConcurrencyId 
					,strSiteCustomerNumber = H.vwcus_key COLLATE Latin1_General_CI_AS 	
					,strSiteCustomerName = (CASE WHEN H.vwcus_co_per_ind_cp = ''D''   
													THEN  ISNULL(RTRIM(H.vwcus_last_name),'''') + ISNULL(RTRIM(H.vwcus_first_name),'''') + ISNULL(RTRIM(H.vwcus_mid_init),'''') + ISNULL(RTRIM(H.vwcus_name_suffix),'''')   
													ELSE    
														CASE WHEN H.vwcus_first_name IS NULL OR RTRIM(H.vwcus_first_name) = ''''  
															THEN     ISNULL(RTRIM(H.vwcus_last_name),'''') + ISNULL(RTRIM(H.vwcus_name_suffix),'''')    
															ELSE     ISNULL(RTRIM(H.vwcus_last_name),'''') + ISNULL(RTRIM(H.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(H.vwcus_first_name),'''') + ISNULL(RTRIM(H.vwcus_mid_init),'''')    
														END   
												END) COLLATE Latin1_General_CI_AS 
					,intSiteNumber = F.intSiteNumber
					,strSiteDescription = F.strDescription
					,F.strSiteAddress 
					,I.strDeviceType
					,C.strSerialNumber
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
					,strSiteNumber = RIGHT(''000''+ CAST(F.intSiteNumber AS VARCHAR(4)),4)
					,strAgreementLetter = M.strName
					,A.ysnPrintDeviceValueInAgreement
					,A.strEvaluationMethod
					,strSiteLocation = N.vwloc_name
				FROM tblTMLease A
				LEFT JOIN tblTMLeaseDevice K
					ON A.intLeaseId = K.intLeaseId
				LEFT JOIN tblTMDevice C
					ON K.intDeviceId = C.intDeviceId
				LEFT JOIN(
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
				)E
					ON A.intLeaseId = E.intLeaseId
				LEFT JOIN tblTMSite F
					ON F.intSiteID = E.intSiteID
				LEFT JOIN tblTMCustomer G
					ON F.intCustomerID = G.intCustomerID
				LEFT JOIN vwcusmst H
					ON G.intCustomerNumber = H.A4GLIdentity
				LEFT JOIN tblTMDeviceType I
					ON C.intDeviceTypeId = I.intDeviceTypeId
				LEFT JOIN tblTMLeaseCode B
					ON A.intLeaseCodeId = B.intLeaseCodeId
				LEFT JOIN vwcusmst D
					ON A.intBillToCustomerId = D.A4GLIdentity
				LEFT JOIN tblTMLeaseCode J
					ON A.intLeaseCodeId = J.intLeaseCodeId
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
				LEFt JOIN vwlocmst N
					ON F.intLocationId = N.A4GLIdentity 
				')
		END
		ELSE
		BEGIN
			GOTO TMNoOrigin
		END
	END
	ELSE
	BEGIN
		TMNoOrigin:
		EXEC ('
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
						,strSiteNumber = RIGHT(''000''+ CAST(F.intSiteNumber AS VARCHAR(4)),4)
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
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateLeaseSearchView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateLeaseSearchView'
GO 
	EXEC ('uspTMRecreateLeaseSearchView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateLeaseSearchView'
GO