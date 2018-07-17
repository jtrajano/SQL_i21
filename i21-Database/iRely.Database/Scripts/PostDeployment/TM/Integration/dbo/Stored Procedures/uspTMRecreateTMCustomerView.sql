GO
	PRINT 'START OF CREATING [uspTMRecreateTMCustomerView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateTMCustomerView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateTMCustomerView
GO

CREATE PROCEDURE uspTMRecreateTMCustomerView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMCustomer')
	BEGIN
		DROP VIEW vyuTMCustomer
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
	)
	BEGIN
		EXEC ('
				
				CREATE VIEW [dbo].[vyuTMCustomer]
				AS  
					SELECT 
						A.intCustomerID
						,strName  = C.strFullName
						,strEntityNo = C.vwcus_key
						,intSiteCount = COUNT(A.intCustomerID)
						,B.intConcurrencyId
					FROM tblTMSite A
					INNER JOIN tblTMCustomer B
						ON A.intCustomerID = B.intCustomerID
					INNER JOIN vwcusmst C
						ON B.intCustomerNumber = C.A4GLIdentity
					GROUP BY A.intCustomerID,C.strFullName,C.vwcus_key,B.intConcurrencyId
				
			
		')
	END
	ELSE
	BEGIN
		EXEC ('
				CREATE VIEW [dbo].[vyuTMCustomer]
				AS  
					SELECT 
						A.intCustomerID
						,C.strName
						,C.strEntityNo
						,intSiteCount = COUNT(A.intCustomerID)
						,B.intConcurrencyId
					FROM tblTMSite A
					INNER JOIN tblTMCustomer B
						ON A.intCustomerID = B.intCustomerID
					INNER JOIN tblEMEntity C
						ON B.intCustomerNumber = C.intEntityId
					GROUP BY A.intCustomerID,C.strName,C.strEntityNo,B.intConcurrencyId
				

		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateTMCustomerView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateTMCustomerView'
GO 
	EXEC ('uspTMRecreateTMCustomerView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateTMCustomerView'
GO
