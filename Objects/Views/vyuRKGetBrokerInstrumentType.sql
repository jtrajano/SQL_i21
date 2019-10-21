CREATE VIEW [dbo].[vyuRKGetBrokerInstrumentType]	

AS

SELECT intBrokerageAccountId
	, intEntityId
	, intInstrumentTypeId
	, CASE WHEN intInstrumentTypeId = 1 THEN 'Futures'
			WHEN intInstrumentTypeId = 2 THEN 'Options'
			ELSE 'Futures & Options' END COLLATE Latin1_General_CI_AS AS strInstrumentType
FROM tblRKBrokerageAccount
WHERE intInstrumentTypeId <> 3

UNION ALL SELECT intBrokerageAccountId
	, intEntityId
	, 2
	, 'Options' COLLATE Latin1_General_CI_AS AS strInstrumentType
FROM tblRKBrokerageAccount
WHERE intInstrumentTypeId = 3

UNION ALL SELECT intBrokerageAccountId
	, intEntityId
	, 1
	, 'Futures' COLLATE Latin1_General_CI_AS AS strInstrumentType
FROM tblRKBrokerageAccount
WHERE intInstrumentTypeId = 3