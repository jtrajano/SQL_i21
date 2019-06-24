
PRINT 'Started refreshing GL Segments'
GO
	IF EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE strStructureName = 'LOB')
	BEGIN
		WITH actualGL as (
		SELECT
		strAccountId
		,SUBSTRING(strAccountId, 1, Pstruc.intLength) [Primary]
		,SUBSTRING(strAccountId, Pstruc.intLength +2, LOCstruc.intLength)[Location]
		,SUBSTRING(strAccountId, Pstruc.intLength + LOCstruc.intLength + 3, LOBstruc.intLength) LOB
		FROM tblGLAccount
		OUTER APPLY(
			SELECT top 1 intLength   FROM
			tblGLAccountStructure B 
			WHERE strType =  'Primary'
		)Pstruc
		OUTER APPLY
		(
		SELECT top 1 intLength  FROM
		tblGLAccountStructure B 
		WHERE strStructureName =  'Location'

		)LOCstruc
		OUTER APPLY
		(
		SELECT top 1 intLength  FROM
		tblGLAccountStructure B 
		WHERE strStructureName =  'LOB'
		)LOBstruc

		)
		UPDATE B
		SET B.[Primary Account] = A.[Primary], B.Location = A.Location, B.LOB = A.LOB
		FROM actualGL 
		A JOIN tblGLTempCOASegment B
		ON A.strAccountId = B.strAccountId

		--insert missing segment
		;WITH missingPrimarySegment as(
		SELECT DISTINCT A.[Primary Account]  strCode, B.intAccountSegmentId, St.intAccountStructureId 
		FROM tblGLTempCOASegment A LEFT JOIN  tblGLAccountSegment B ON A.[Primary Account] =B.strCode
		OUTER APPLY
		(
			SELECT * FROM tblGLAccountStructure WHERE strType='Primary'
		) St
		WHERE B.strCode IS NULL 

		)
		INSERT INTO tblGLAccountSegment (strCode, intAccountStructureId, intAccountCategoryId)
		SELECT strCode, intAccountStructureId, 47 FROM missingPrimarySegment

		;WITH missingLocationSegment as(
		SELECT DISTINCT A.Location  strCode, B.intAccountSegmentId, St.intAccountStructureId 
		FROM tblGLTempCOASegment A LEFT JOIN  tblGLAccountSegment B ON A.Location =B.strCode
		OUTER APPLY
		(
			SELECT * FROM tblGLAccountStructure WHERE strStructureName='Location'
		) St
		WHERE B.strCode IS NULL 

		)
		INSERT INTO tblGLAccountSegment (strCode, intAccountStructureId)
		SELECT strCode, intAccountStructureId FROM missingLocationSegment

		;WITH missingLOBSegment as(
		SELECT DISTINCT A.LOB  strCode, B.intAccountSegmentId, St.intAccountStructureId 
		FROM tblGLTempCOASegment A LEFT JOIN  tblGLAccountSegment B ON A.LOB =B.strCode
		OUTER APPLY
		(
			SELECT * FROM tblGLAccountStructure WHERE strStructureName='LOB'
		) St
		WHERE B.strCode IS NULL 

		)
		INSERT INTO tblGLAccountSegment (strCode, intAccountStructureId)
		SELECT strCode, intAccountStructureId FROM missingLOBSegment



		;WITH SM AS (
			SELECT GL.intAccountId, GL.strAccountId , St.intAccountStructureId, Se.intAccountSegmentId
			FROM tblGLAccount GL JOIN
			tblGLTempCOASegment COA on COA.strAccountId = GL.strAccountId
			JOIN tblGLAccountSegment Se on Se.strCode = COA.[Primary Account]
			JOIN tblGLAccountStructure St on St.intAccountStructureId = Se.intAccountStructureId
			WHERE St.strType = 'Primary'  AND GL.intAccountId = 1
			UNION
			SELECT GL.intAccountId, GL.strAccountId , St.intAccountStructureId, Se.intAccountSegmentId
			FROM tblGLAccount GL JOIN
			tblGLTempCOASegment COA on COA.strAccountId = GL.strAccountId
			JOIN tblGLAccountSegment Se on Se.strCode = COA.Location
			JOIN tblGLAccountStructure St on St.intAccountStructureId = Se.intAccountStructureId
			WHERE St.strStructureName = 'Location'  AND GL.intAccountId = 1
			UNION
			SELECT GL.intAccountId, GL.strAccountId , St.intAccountStructureId, Se.intAccountSegmentId
			FROM tblGLAccount GL JOIN
			tblGLTempCOASegment COA on COA.strAccountId = GL.strAccountId
			JOIN tblGLAccountSegment Se on Se.strCode = COA.LOB
			JOIN tblGLAccountStructure St on St.intAccountStructureId = Se.intAccountStructureId
			WHERE St.strStructureName = 'LOB' AND GL.intAccountId = 1
		)

		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId,intConcurrencyId)
		SELECT A.intAccountId, A.intAccountSegmentId,1 FROM  SM A LEFT JOIN
		tblGLAccountSegmentMapping B on A.intAccountId = B.intAccountId AND A.intAccountSegmentId = B.intAccountSegmentId
		WHERE B.intAccountId IS NULL

	END
	ELSE
	BEGIN
		WITH actualGL AS (
		SELECT strAccountId
			,SUBSTRING(strAccountId, 1, Pstruc.intLength) [Primary]
			,SUBSTRING(strAccountId, Pstruc.intLength +2, LOCstruc.intLength)[Location]
			FROM tblGLAccount
		OUTER APPLY(
			SELECT TOP 1 intLength   FROM
			tblGLAccountStructure B 
			WHERE strType =  'Primary'
		)Pstruc
		OUTER APPLY
		(
			SELECT TOP 1 intLength  FROM
			tblGLAccountStructure B 
			WHERE strStructureName =  'Location'
		)LOCstruc
		)
		UPDATE B
		SET B.[Primary Account] = A.[Primary], B.Location = A.Location
		FROM actualGL 
		A JOIN tblGLTempCOASegment B
		ON A.strAccountId = B.strAccountId

		;WITH missingPrimarySegment as(
		SELECT DISTINCT A.[Primary Account]  strCode, B.intAccountSegmentId, St.intAccountStructureId 
		FROM tblGLTempCOASegment A LEFT JOIN  tblGLAccountSegment B ON A.[Primary Account] =B.strCode
		OUTER APPLY
		(
			SELECT * FROM tblGLAccountStructure WHERE strType='Primary'
		) St
		WHERE B.strCode IS NULL 

		)
		INSERT INTO tblGLAccountSegment (strCode, intAccountStructureId, intAccountCategoryId)
		SELECT strCode, intAccountStructureId, 47 FROM missingPrimarySegment

		;WITH missingLocationSegment as(
		SELECT DISTINCT A.Location  strCode, B.intAccountSegmentId, St.intAccountStructureId 
		FROM tblGLTempCOASegment A LEFT JOIN  tblGLAccountSegment B ON A.Location =B.strCode
		OUTER APPLY
		(
			SELECT * FROM tblGLAccountStructure WHERE strStructureName='Location'
		) St
		WHERE B.strCode IS NULL 

		)
		INSERT INTO tblGLAccountSegment (strCode, intAccountStructureId)
		SELECT strCode, intAccountStructureId FROM missingLocationSegment


		;WITH SM AS (
			SELECT GL.intAccountId, GL.strAccountId , St.intAccountStructureId, Se.intAccountSegmentId
			FROM tblGLAccount GL JOIN tblGLTempCOASegment COA on COA.strAccountId = GL.strAccountId
			JOIN tblGLAccountSegment Se on Se.strCode = COA.[Primary Account]
			JOIN tblGLAccountStructure St on St.intAccountStructureId = Se.intAccountStructureId
			WHERE St.strType = 'Primary'  AND GL.intAccountId = 1
			UNION 
			SELECT GL.intAccountId, GL.strAccountId , St.intAccountStructureId, Se.intAccountSegmentId
			FROM tblGLAccount GL JOIN tblGLTempCOASegment COA on COA.strAccountId = GL.strAccountId
			JOIN tblGLAccountSegment Se on Se.strCode = COA.Location
			JOIN tblGLAccountStructure St on St.intAccountStructureId = Se.intAccountStructureId
			WHERE St.strStructureName = 'Location'  AND GL.intAccountId = 1
		)
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId,intConcurrencyId)
		SELECT A.intAccountId, A.intAccountSegmentId,1 FROM  SM A 
		LEFT JOIN tblGLAccountSegmentMapping B on A.intAccountId = B.intAccountId AND A.intAccountSegmentId = B.intAccountSegmentId
		WHERE B.intAccountId IS NULL
	END
GO
PRINT 'Finished refreshing GL Segments'