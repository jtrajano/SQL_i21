CREATE VIEW [dbo].[vyuTMCompanySiteEvent]
AS  
	SELECT E.intEventID
		, E.dtmDate
		, E.intEventTypeID
		, ET.strEventType
		--, ET.strDescription strEventTypeDescription
		, E.intPerformerID
        , ESP.strName strPerformerName
		, E.intUserID
		, S.strUserName
		, E.intDeviceId
		, D.strSerialNumber
		, D.strDescription strDeviceDescription
		, D.strOwnership
		, D.intDeviceTypeId
		, DT.strDeviceType
		, E.strDescription
		, E.intCompanyConsumptionSiteId
		, CS.intSiteNumber
		, E.strLevel
        , E.intConcurrencyId
		--intSiteId = A.intSiteID
		--,intCustomerId = A.intCustomerID
		--,strSiteNumber = RIGHT('000'+ CAST(A.intSiteNumber AS VARCHAR(4)),4) COLLATE Latin1_General_CI_AS
		--,strBillingBy = A.strBillingBy
		--,strCustomerKey = C.vwcus_key
		--,strCustomerName = C.strFullCustomerName
		--,strSiteAddress = A.strSiteAddress
		--,strDescription = A.strDescription
		--,strPhone = C.vwcus_phone
		--,intParentSiteId = A.intParentSiteID
		--,intConcurrencyId = A.intConcurrencyId
	FROM tblTMEvent E 
	INNER JOIN tblTMCompanyConsumptionSite CS ON CS.intCompanyConsumptionSiteId = E.intCompanyConsumptionSiteId
	INNER JOIN tblTMEventType ET ON ET.intEventTypeID = E.intEventTypeID
	INNER JOIN tblSMUserSecurity S ON S.intEntityId = E.intUserID
	LEFT JOIN tblARSalesperson SP ON SP.intEntityId = E.intPerformerID
        LEFT JOIN tblEMEntity ESP ON ESP.intEntityId = SP.intEntityId
	LEFT JOIN tblTMDevice D ON D.intDeviceId = E.intDeviceId
	LEFT JOIN tblTMDeviceType DT ON DT.intDeviceTypeId = D.intDeviceTypeId