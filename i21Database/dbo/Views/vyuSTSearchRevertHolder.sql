CREATE VIEW [dbo].[vyuSTSearchRevertHolder]
AS
SELECT 
	RH.*
	, E.strName
	, CONVERT(DATETIME, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, dtmDateTimeModifiedFrom), DATENAME(TzOffset, SYSDATETIMEOFFSET()))) AS dtmLocalDateTimeModifiedFrom  -- CAST(dtmDateTimeModifiedFrom AS DATE)
	, CONVERT(DATETIME, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, dtmDateTimeModifiedTo), DATENAME(TzOffset, SYSDATETIMEOFFSET()))) AS dtmLocalDateTimeModifiedTo -- CAST(dtmDateTimeModifiedFrom AS TIME)
FROM tblSTRevertHolder RH
INNER JOIN tblEMEntity E
	ON RH.intEntityId = E.intEntityId
	   