CREATE VIEW [dbo].[vyuARPOSEndOfDay]
	AS 
	SELECT
		 intPOSEndOfDayId				=	EOD.intPOSEndOfDayId
		 ,intPOSLogId					=	POSLOG.intPOSLogId
		,strEODNo						=	EOD.strEODNo
		,dblOpeningBalance				=	EOD.dblOpeningBalance
		,dblExpectedEndingBalance		=	(EOD.dblOpeningBalance + EOD.dblExpectedEndingBalance)
		,dblFinalEndingBalance			=	EOD.dblFinalEndingBalance
		,intCompanyLocationPOSDrawerId	=	EOD.intCompanyLocationPOSDrawerId
		,intCompanyLocationId			=	DRAWER.intCompanyLocationId
		,intStoreId						=	EOD.intStoreId
		,intEntityId					=	POSLOG.intEntityId
		,strUsername					=	CRED.strUserName
		,strName						=	EM.strName
		,strEmail						=	EM.strEmail
		,strPOSDrawerName				=	DRAWER.strPOSDrawerName
		,strLocationName				=	LOC.strLocationName
		,ysnClosed						=	EOD.ysnClosed
		,ysnAllowMultipleUser			=	DRAWER.ysnAllowMultipleUser
		
	FROM tblARPOSEndOfDay EOD
	INNER JOIN tblSMCompanyLocationPOSDrawer DRAWER ON  EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
	INNER JOIN (
		SELECT
			intCompanyLocationId
			,strLocationName
			,strAddress
			,strZipPostalCode
			,strCity
			,strStateProvince
			,strCountry
		FROM tblSMCompanyLocation
	) LOC ON DRAWER.intCompanyLocationId = LOC.intCompanyLocationId
	INNER JOIN (
		SELECT 
			intPOSLogId
			, intEntityId
			, intPOSEndOfDayId
		FROM tblARPOSLog
	) POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
	INNER JOIN (
		SELECT 
			intEntityId
			,strName
			,strEmail
		 FROM tblEMEntity
	) EM ON POSLOG.intEntityId = EM.intEntityId
	INNER JOIN (
		SELECT
			intEntityCredentialId
			,intEntityId
			,strUserName
		FROM tblEMEntityCredential

	) CRED ON EM.intEntityId = CRED.intEntityId