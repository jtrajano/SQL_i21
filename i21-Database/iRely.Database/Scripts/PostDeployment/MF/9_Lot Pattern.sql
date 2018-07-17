DECLARE @strPatternString NVARCHAR(50)
	,@strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternId INT
	,@strSubPatternTypeDetail0 NVARCHAR(50)
	,@strSubPatternName0 NVARCHAR(50)
	,@intSubPatternTypeId0 INT
	,@strSubPatternTypeDetail NVARCHAR(50)
	,@strSubPatternName NVARCHAR(50)
	,@intSubPatternTypeId INT
	,@strSubPatternTypeDetail2 NVARCHAR(50)
	,@strSubPatternName2 NVARCHAR(50)
	,@intSubPatternTypeId2 INT
	,@strSubPatternTypeDetail3 NVARCHAR(50)
	,@strSubPatternName3 NVARCHAR(50)
	,@intSubPatternTypeId3 INT
	,@strSubPatternTypeDetail4 NVARCHAR(50)
	,@strSubPatternName4 NVARCHAR(50)
	,@intSubPatternTypeId4 INT
	,@intPatternCode INT
	,@intCompanyLocationId INT

SELECT @intSubPatternTypeId = 3

SELECT @strSubPatternName = 'Part1'

SELECT @strSubPatternTypeDetail = 'YY'

SELECT @intSubPatternTypeId2 = 3

SELECT @strSubPatternName2 = 'Part2'

SELECT @strSubPatternTypeDetail2 = 'Julian Date'

SELECT @intSubPatternTypeId3 = 1

SELECT @strSubPatternName3 = 'Part3'

SELECT @strSubPatternTypeDetail3 = '-'

SELECT @intSubPatternTypeId4 = 6

SELECT @strSubPatternName4 = 'Sequence'

SELECT @strSubPatternTypeDetail4 = ''

SELECT @strPatternName = N'Lot Number'
	,@strDescription = N'Lot Number'
	,@intPatternCode = 24

SELECT @intCompanyLocationId = MIN(intCompanyLocationId)
FROM tblSMCompanyLocation

WHILE @intCompanyLocationId IS NOT NULL
BEGIN
	INSERT dbo.tblMFPattern (
		strPatternName
		,strDescription
		,intPatternCode
		,intLocationId
		)
	SELECT strPatternName = @strPatternName
		,strDescription = @strDescription
		,strPatternCode = @intPatternCode
		,intLocationId = @intCompanyLocationId
	WHERE NOT EXISTS (
			SELECT *
			FROM dbo.tblMFPattern
			WHERE intPatternCode = @intPatternCode
				AND intLocationId = @intCompanyLocationId
			)

	SELECT @intPatternId = intPatternId
	FROM dbo.tblMFPattern
	WHERE intPatternCode = @intPatternCode
		AND intLocationId = @intCompanyLocationId

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
		,intSubPatternSize = 1
		,strSubPatternTypeDetail = @strSubPatternTypeDetail
		,strSubPatternFormat = ''
		,intOrdinalPosition = 1
	WHERE NOT EXISTS (
			SELECT *
			FROM dbo.tblMFPatternDetail
			WHERE intPatternId = @intPatternId
				AND strSubPatternName = @strSubPatternName
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
		,strSubPatternName = @strSubPatternName2
		,intSubPatternTypeId = @intSubPatternTypeId2
		,intSubPatternSize = 3
		,strSubPatternTypeDetail = @strSubPatternTypeDetail2
		,strSubPatternFormat = ''
		,intOrdinalPosition = 2
	WHERE NOT EXISTS (
			SELECT *
			FROM dbo.tblMFPatternDetail
			WHERE intPatternId = @intPatternId
				AND strSubPatternName = @strSubPatternName2
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
		,strSubPatternName = @strSubPatternName3
		,intSubPatternTypeId = @intSubPatternTypeId3
		,intSubPatternSize = 1
		,strSubPatternTypeDetail = @strSubPatternTypeDetail3
		,strSubPatternFormat = ''
		,intOrdinalPosition = 3
	WHERE NOT EXISTS (
			SELECT *
			FROM dbo.tblMFPatternDetail
			WHERE intPatternId = @intPatternId
				AND strSubPatternName = @strSubPatternName3
			)

	INSERT dbo.tblMFPatternDetail (
		intPatternId
		,strSubPatternName
		,intSubPatternTypeId
		,intSubPatternSize
		,strSubPatternTypeDetail
		,strSubPatternFormat
		,intOrdinalPosition
		,ysnPaddingZero
		,ysnMaxSize
		)
	SELECT intPatternId = @intPatternId
		,strSubPatternName = @strSubPatternName4
		,intSubPatternTypeId = @intSubPatternTypeId4
		,intSubPatternSize = 3
		,strSubPatternTypeDetail = @strSubPatternTypeDetail4
		,strSubPatternFormat = ''
		,intOrdinalPosition = 4
		,ysnPaddingZero = 1
		,ysnMaxSize = 1
	WHERE NOT EXISTS (
			SELECT *
			FROM dbo.tblMFPatternDetail
			WHERE intPatternId = @intPatternId
				AND strSubPatternName = @strSubPatternName4
			)

	SELECT @intCompanyLocationId = MIN(intCompanyLocationId)
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId > @intCompanyLocationId
END


