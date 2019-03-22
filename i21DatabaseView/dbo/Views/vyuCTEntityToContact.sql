CREATE VIEW [dbo].[vyuCTEntityToContact]

AS 

	SELECT	EC.intEntityContactId, 
			EY.intEntityId, 
			CY.strName, 
			CY.strEmail, 
			EL.strLocationName, 
			CY.strPhone, 
			CY.strTimezone, 
			CY.strTitle,
			CY.strEmailDistributionOption,
			EC.ysnPortalAccess,
			CY.ysnActive,
			CY.ysnReceiveEmail,
			EC.ysnDefaultContact 
	FROM	dbo.tblEMEntity			AS EY 
	JOIN	dbo.[tblEMEntityToContact]	AS EC ON EY.intEntityId			=	EC.intEntityId 
	JOIN	dbo.tblEMEntity			AS CY ON EC.intEntityContactId	=	CY.intEntityId			LEFT  
	JOIN	dbo.[tblEMEntityLocation]	AS EL ON EC.intEntityLocationId =	EL.intEntityLocationId
