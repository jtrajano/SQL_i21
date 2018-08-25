CREATE VIEW [dbo].[vyuSTStoreAppRegistered]
AS
SELECT ST.intStoreId 
, ST.strStoreAppMacAddress
, ST.strStoreAppWebUrl
, ST.intStoreNo
, ST.guidStoreAppConnectionId
, ST.dtmStoreAppLastDateLog
, CASE
	WHEN ISNULL(CU.strContextId, '') = ''
		THEN CAST(0 AS BIT)
	ELSE CAST(1 AS BIT)
	END AS ysnStoreAppOnline
FROM tblSTStore ST
LEFT JOIN tblSMConnectedUser CU 
	ON ST.guidStoreAppConnectionId = CU.strContextId