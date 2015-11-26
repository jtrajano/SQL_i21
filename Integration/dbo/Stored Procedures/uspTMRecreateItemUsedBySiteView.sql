GO
	PRINT 'START OF CREATING [uspTMRecreateItemUsedBySiteView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateItemUsedBySiteView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateItemUsedBySiteView
GO

CREATE PROCEDURE uspTMRecreateItemUsedBySiteView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMItemUsedBySite')
	BEGIN
		DROP VIEW vyuTMItemUsedBySite
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1  
	)
	BEGIN
		EXEC ('
				CREATE VIEW [dbo].[vyuTMItemUsedBySite]  
				AS 
				SELECT DISTINCT
					strItemNo = A.vwitm_no
					,intItemId = A.A4GLIdentity
					,strDescription = A.vwitm_desc
					,intConcurrencyId = 0
				FROM vwitmmst A
				INNER JOIN tblTMSite B
					ON A.A4GLIdentity = B.intProduct
				
			')

	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vyuTMItemUsedBySite]  
			AS 

			SELECT DISTINCT
				A.strItemNo
				,A.intItemId
				,A.strDescription
				,intConcurrencyId = 0
			FROM tblICItem A
			INNER JOIN tblTMSite B
				ON A.intItemId = B.intProduct
		
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateItemUsedBySiteView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateItemUsedBySiteView'
GO 
	EXEC ('uspTMRecreateItemUsedBySiteView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateItemUsedBySiteView'
GO