GO
	PRINT 'START OF CREATING [uspTMRecreateDriverUsedBySiteView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateDriverUsedBySiteView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateDriverUsedBySiteView
GO

CREATE PROCEDURE uspTMRecreateDriverUsedBySiteView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDriverUsedBySite')
	BEGIN
		DROP VIEW vyuTMDriverUsedBySite
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1  
	)
	BEGIN

		EXEC ('
				CREATE VIEW [dbo].[vyuTMDriverUsedBySite]  
				AS 
				SELECT DISTINCT
					strEntityNo = A.vwsls_slsmn_id
					,intEntityId = A.A4GLIdentity
					,strName = A.vwsls_name
					,intConcurrencyId = 0
				FROM vwslsmst A
				INNER JOIN tblTMSite B
					ON A.A4GLIdentity = B.intDriverID
				
			')

	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vyuTMDriverUsedBySite]  
			AS 

			SELECT DISTINCT
				A.strEntityNo
				,A.intEntityId
				,strName = A.strName
				,intConcurrencyId = 0
			FROM tblEMEntity A
			INNER JOIN tblEMEntityType B
				ON A.intEntityId = B.intEntityId
			INNER JOIN tblTMSite C
				ON A.intEntityId = C.intDriverID
			WHERE B.strType = ''Salesperson''
			
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateDriverUsedBySiteView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateDriverUsedBySiteView'
GO 
	EXEC ('uspTMRecreateDriverUsedBySiteView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateDriverUsedBySiteView'
GO