DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)
	,@strSubPatternName NVARCHAR(50)
	,@intSubPatternTypeId INT

SELECT @intSubPatternTypeId = 4 -->Table column 		

SELECT @strSubPatternName = 'Demand'

SELECT @strSubPatternTypeDetail = 'tblMFBlendRequirement.strDemandNo'

SELECT @strPatternName = N'Blend Sheet Number'
	,@strDescription = N'Blend Sheet Number'
	,@intPatternCode = 93

INSERT dbo.tblMFPattern (
	strPatternName
	,strDescription
	,intPatternCode
	)
SELECT strPatternName = @strPatternName
	,strDescription = @strDescription
	,strPatternCode = @intPatternCode
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPattern
		WHERE intPatternCode = @intPatternCode
		)

SELECT @intPatternId = intPatternId
FROM dbo.tblMFPattern
WHERE intPatternCode = @intPatternCode

INSERT dbo.tblMFPatternDetail (
	intPatternId
	,strSubPatternName
	,intSubPatternTypeId
	,intSubPatternSize
	,strSubPatternTypeDetail
	,strSubPatternFormat
	,intOrdinalPosition
	)
SELECT intPatternId = @intPatternId
	,strSubPatternName = @strSubPatternName
	,intSubPatternTypeId = @intSubPatternTypeId
	,intSubPatternSize = 6
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = '<?>'
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
		)

INSERT dbo.tblMFPatternDetail (
	intPatternId
	,strSubPatternName
	,intSubPatternTypeId
	,intSubPatternSize
	,strSubPatternTypeDetail
	,strSubPatternFormat
	,intOrdinalPosition
	)
SELECT intPatternId = @intPatternId
	,strSubPatternName = 'Sequence'
	,intSubPatternTypeId = 6
	,intSubPatternSize = 2
	,strSubPatternTypeDetail = ''
	,strSubPatternFormat = ''
	,intOrdinalPosition = 2
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Sequence'
		)

INSERT dbo.tblMFPatternSequence (
	intPatternId
	,strPatternSequence
	,intSequenceNo
	,intMaximumSequence
	)
SELECT intPatternId = @intPatternId
	,strPatternSequence = Left(strWorkOrderNo, Len(strWorkOrderNo) - 2)
	,intSequenceNo = Max(Cast(right(strWorkOrderNo, 2) AS INT))
	,intMaximumSequence = 99999999
FROM tblMFWorkOrder W
WHERE strWorkOrderNo LIKE 'DN%'

	AND NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = Left(W.strWorkOrderNo, Len(W.strWorkOrderNo) - 2)
		)
Group by strWorkOrderNo