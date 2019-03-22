CREATE VIEW vyuLGLoadNotifyPartiesNotMapped
AS
SELECT 
	NP.intLoadNotifyPartyId
	,NP.intBankId
	,NP.intCompanyLocationId
	,NP.intCompanySetupID
	,NP.intEntityId
	,NP.intEntityLocationId
	,NP.intLoadId
	,NP.strNotifyOrConsignee
	,NP.strText
	,NP.strType
	,strParty = CASE WHEN IsNull(NPE.intEntityId, 0) = 0 THEN
						CASE WHEN IsNull(NPB.intEntityId, 0) = 0 THEN
							CASE WHEN IsNULL(NPC.intEntityId, 0) = 0 THEN
								''
							ELSE
								NPC.strName
							END
						ELSE
							NPB.strName
						END
					ELSE
						NPE.strName
					END
	,strPartyLocation = CASE WHEN IsNull(NPAE.intEntityLocationId, 0) = 0 THEN
							CASE WHEN IsNull(NPAB.intEntityLocationId, 0) = 0 THEN
								CASE WHEN IsNULL(NPAC.intEntityLocationId, 0) = 0 THEN
									''
								ELSE
									NPAC.strLocationName
								END
							ELSE
								NPAB.strLocationName
							END
						ELSE
							NPAE.strLocationName
						END
					
	,strAddress  = CASE WHEN IsNull(NPAE.intEntityLocationId, 0) = 0 THEN
							CASE WHEN IsNull(NPAB.intEntityLocationId, 0) = 0 THEN
								CASE WHEN IsNULL(NPAC.intEntityLocationId, 0) = 0 THEN
									''
								ELSE
									NPAC.strAddress
								END
							ELSE
								NPAB.strAddress
							END
						ELSE
							NPAE.strAddress
						END
	,strCity  = CASE WHEN IsNull(NPAE.intEntityLocationId, 0) = 0 THEN
							CASE WHEN IsNull(NPAB.intEntityLocationId, 0) = 0 THEN
								CASE WHEN IsNULL(NPAC.intEntityLocationId, 0) = 0 THEN
									''
								ELSE
									NPAC.strCity
								END
							ELSE
								NPAB.strCity
							END
						ELSE
							NPAE.strCity
						END
	,strState   = CASE WHEN IsNull(NPAE.intEntityLocationId, 0) = 0 THEN
							CASE WHEN IsNull(NPAB.intEntityLocationId, 0) = 0 THEN
								CASE WHEN IsNULL(NPAC.intEntityLocationId, 0) = 0 THEN
									''
								ELSE
									NPAC.strState
								END
							ELSE
								NPAB.strState
							END
						ELSE
							NPAE.strState
						END
	,strCountry  = CASE WHEN IsNull(NPAE.intEntityLocationId, 0) = 0 THEN
							CASE WHEN IsNull(NPAB.intEntityLocationId, 0) = 0 THEN
								CASE WHEN IsNULL(NPAC.intEntityLocationId, 0) = 0 THEN
									''
								ELSE
									NPAC.strCountry
								END
							ELSE
								NPAB.strCountry
							END
						ELSE
							NPAE.strCountry
						END
	
FROM tblLGLoadNotifyParties NP
LEFT JOIN vyuLGNotifyParties NPE ON NPE.intEntityId = NP.intEntityId AND NPE.strEntity = NP.strType
LEFT JOIN vyuLGNotifyParties NPB ON NPB.intEntityId = NP.intBankId  AND NPB.strEntity = NP.strType
LEFT JOIN vyuLGNotifyParties NPC ON NPC.intEntityId = NP.intCompanySetupID  AND NPC.strEntity = NP.strType
LEFT JOIN vyuLGNotifyPartiesAddresses NPAE ON NPAE.intEntityLocationId = NP.intEntityLocationId AND NPAE.strType = NP.strType
LEFT JOIN vyuLGNotifyPartiesAddresses NPAB ON NPAB.intEntityLocationId = -1 AND NPAB.intEntityId = NP.intBankId AND NPAB.strType = NP.strType
LEFT JOIN vyuLGNotifyPartiesAddresses NPAC ON NPAC.intEntityLocationId = NP.intCompanyLocationId AND NPAC.strType = NP.strType

