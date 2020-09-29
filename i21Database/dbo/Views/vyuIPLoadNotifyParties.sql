CREATE VIEW vyuIPLoadNotifyParties
AS
SELECT NP.intLoadNotifyPartyId
	,NP.intLoadId
	,NP.strNotifyOrConsignee
	,NP.strText
	,NP.strType
	,strParty = CASE 
		WHEN strType IN (
				'Vendor'
				,'Customer'
				,'Forwarding Agent'
				,'Shipping Line'
				,'Terminal'
				)
			THEN E.strName
		WHEN strType = 'Bank'
			THEN B.strBankName
		ELSE C.strCompanyName
		END
	,strPartyLocation = CASE 
		WHEN strType IN (
				'Vendor'
				,'Customer'
				,'Forwarding Agent'
				,'Shipping Line'
				,'Terminal'
				)
			THEN EL.strLocationName
		WHEN strType = 'Bank'
			THEN B.strBankName
		ELSE CL.strLocationName
		END
FROM tblLGLoadNotifyParties NP
LEFT JOIN tblEMEntity E ON E.intEntityId = NP.intEntityId
LEFT JOIN tblCMBank B ON B.intBankId = NP.intEntityId
LEFT JOIN tblSMCompanySetup C ON C.intCompanySetupID = NP.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = NP.intEntityLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = NP.intEntityLocationId

