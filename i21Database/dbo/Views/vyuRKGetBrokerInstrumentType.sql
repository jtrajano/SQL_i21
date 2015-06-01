CREATE VIEW [dbo].[vyuRKGetBrokerInstrumentType]	
AS  
SELECT intBrokerageAccountId
 ,intEntityId
 ,intInstrumentTypeId
 ,CASE 
  WHEN intInstrumentTypeId = 1
   THEN 'Futures'
  WHEN intInstrumentTypeId = 2
   THEN 'Options'
  ELSE 'Futures & Options'
  END AS strInstrumentType
FROM tblRKBrokerageAccount
WHERE intInstrumentTypeId <> 3

UNION

SELECT intBrokerageAccountId
 ,intEntityId
 ,2
 ,'Options' AS strInstrumentType
FROM tblRKBrokerageAccount
WHERE intInstrumentTypeId = 3

UNION

SELECT intBrokerageAccountId
 ,intEntityId
 ,1
 ,'Futures' AS strInstrumentType
FROM tblRKBrokerageAccount
WHERE intInstrumentTypeId = 3
