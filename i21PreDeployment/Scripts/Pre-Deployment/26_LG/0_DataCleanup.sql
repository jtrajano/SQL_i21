
/*
* Container Types 
* 1. Append (n) to duplicate Container Types
* 2..
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblLGContainerType'))
BEGIN

EXEC('
	UPDATE CT
	SET strContainerType = CT.strContainerType + ''('' + CAST(CT_Ranked.intRank AS nvarchar(10)) + '')''
	FROM tblLGContainerType CT
	INNER JOIN (
		SELECT intContainerTypeId, strContainerType, 
		DENSE_RANK() OVER(PARTITION BY strContainerType ORDER BY intContainerTypeId) intRank 
			FROM tblLGContainerType) CT_Ranked ON CT.intContainerTypeId = CT_Ranked.intContainerTypeId
	WHERE CT_Ranked.intRank > 1
')

END