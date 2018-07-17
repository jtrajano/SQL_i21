GO
	PRINT 'START OF CREATING [uspTMRecreateLocationUsedBySiteView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateLocationUsedBySiteView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateLocationUsedBySiteView
GO

CREATE PROCEDURE uspTMRecreateLocationUsedBySiteView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMLocationUsedBySite')
	BEGIN
		DROP VIEW vyuTMLocationUsedBySite
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1  
	)
	BEGIN

		EXEC ('
				CREATE VIEW [dbo].[vyuTMLocationUsedBySite]  
				AS 
				SELECT DISTINCT
					strLocationName = vwloc_loc_no
					,intLocationId = A.A4GLIdentity
					,intConcurrencyId = 0
				FROM vwlocmst A
				INNER JOIN tblTMSite B
					ON A.A4GLIdentity = B.intLocationId
				
			')

	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vyuTMLocationUsedBySite]  
			AS 

			SELECT DISTINCT
				A.strLocationName
				,intLocationId = A.intCompanyLocationId
				,intConcurrencyId = 0
			FROM tblSMCompanyLocation A
			INNER JOIN tblTMSite B
				ON A.intCompanyLocationId = B.intLocationId
			
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateLocationUsedBySiteView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateLocationUsedBySiteView'
GO 
	EXEC ('uspTMRecreateLocationUsedBySiteView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateLocationUsedBySiteView'
GO