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
	FROM	dbo.tblEntity			AS EY 
	JOIN	dbo.tblEntityToContact	AS EC ON EY.intEntityId			=	EC.intEntityId 
	JOIN	dbo.tblEntity			AS CY ON EC.intEntityContactId	=	CY.intEntityId			LEFT  
	JOIN	dbo.tblEntityLocation	AS EL ON EC.intEntityLocationId =	EL.intEntityLocationId
