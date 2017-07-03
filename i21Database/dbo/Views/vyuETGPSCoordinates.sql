CREATE VIEW [dbo].[vyuETGPSCoordinates]
AS
WITH cte AS
(
   SELECT *,ROW_NUMBER() OVER (PARTITION BY strTruckId ORDER BY dtmRecordDate DESC) AS rn
   FROM tblETGPSCoordinates
)
SELECT intGPSCoordinatesId
	, strTruckId COLLATE Latin1_General_CI_AS AS strTruckId 
	, strDriverId COLLATE Latin1_General_CI_AS AS strDriverId  
	, dblLatitude
	, dblLongitude
	, dtmRecordDate
	, ISNULL(intConcurrencyId,0) as intConcurrencyId
FROM cte
WHERE rn = 1
