CREATE VIEW [dbo].[vyuRKGetBrokerInstrumentType]	
AS  
SELECT intBrokerageAccountId,intEntityId as intBrokerId,intInstrumentTypeId, 
CASE WHEN intInstrumentTypeId = 1 Then 'Futures' 
	 WHEN intInstrumentTypeId = 2 THEN 'Options'
ELSE 'Futures & Options' end as strInstrumentType
FROM tblRKBrokerageAccount f
