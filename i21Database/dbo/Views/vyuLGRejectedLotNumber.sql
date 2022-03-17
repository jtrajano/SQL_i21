

CREATE VIEW [dbo].[vyuLGRejectedLotNumber]
AS
	SELECT 
		A.intLotId
		,C.strCustomerRejected
	FROM tblICLot A
	INNER JOIN tblQMSample B WITH(NOLOCK)
		ON A.intLotId = B.intProductValueId and B.intProductTypeId = 6
	OUTER APPLY (
		SELECT strCustomerRejected = LEFT(strName, LEN(strName) - 1) COLLATE Latin1_General_CI_AS
		FROM (
			SELECT CC.strName + ', '  
			FROM (
				SELECT DISTINCT strName
				FROM tblQMSample AA
				INNER JOIN tblEMEntity BB
					ON AA.intEntityId = BB.intEntityId
				WHERE AA.intProductValueId = B.intProductValueId
					AND BB.strName IS NOT NULL
					AND BB.strName <> ''
			) CC
			FOR XML PATH ('')

		) DD(strName)
	) C
	WHERE B.intSampleStatusId = 4 --Rejected status
	GROUP BY A.intLotId,C.strCustomerRejected
GO
