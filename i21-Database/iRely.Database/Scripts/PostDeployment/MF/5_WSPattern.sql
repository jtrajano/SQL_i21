DECLARE @strPatternString NVARCHAR(50)
DECLARE @strPatternName NVARCHAR(50)
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

SELECT @intSubPatternTypeId0 = 4

SELECT @strSubPatternName0 = 'Part1'

SELECT @strSubPatternTypeDetail0 = 'tblICCategory.strCategoryCode'


--SELECT @intSubPatternTypeId = 3

--SELECT @strSubPatternName = 'Part1'

--SELECT @strSubPatternTypeDetail = 'YY'

--SELECT @intSubPatternTypeId2 = 3

--SELECT @strSubPatternName2 = 'Part2'

--SELECT @strSubPatternTypeDetail2 = 'Julian Date'

--SELECT @intSubPatternTypeId3 = 1

--SELECT @strSubPatternName3 = 'Part3'

--SELECT @strSubPatternTypeDetail3 = 'HU'

--SELECT @intSubPatternTypeId4 = 4

--SELECT @strSubPatternName4 = 'Part4'

--SELECT @strSubPatternTypeDetail4 = 'tblMFShift.strShiftName'

SELECT @strPatternName = N'Lot Number'
	,@strDescription = N'Lot Number'
	,@intPatternCode = 24

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
	,strSubPatternName = @strSubPatternName0
	,intSubPatternTypeId = @intSubPatternTypeId0
	,intSubPatternSize = 1
	,strSubPatternTypeDetail = @strSubPatternTypeDetail0
	,strSubPatternFormat = 'Left(<?>,1)'
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = @strSubPatternName0
		)


--INSERT dbo.tblMFPatternDetail (
--	intPatternId
--	,strSubPatternName
--	,intSubPatternTypeId
--	,intSubPatternSize
--	,strSubPatternTypeDetail
--	,strSubPatternFormat
--	,intOrdinalPosition
--	)
--SELECT intPatternId = @intPatternId
--	,strSubPatternName = @strSubPatternName
--	,intSubPatternTypeId = @intSubPatternTypeId
--	,intSubPatternSize = 1
--	,strSubPatternTypeDetail = @strSubPatternTypeDetail
--	,strSubPatternFormat = ''
--	,intOrdinalPosition = 1
--WHERE NOT EXISTS (
--		SELECT *
--		FROM dbo.tblMFPatternDetail
--		WHERE intPatternId = @intPatternId
--			AND strSubPatternName = @strSubPatternName
--		)

--INSERT dbo.tblMFPatternDetail (
--	intPatternId
--	,strSubPatternName
--	,intSubPatternTypeId
--	,intSubPatternSize
--	,strSubPatternTypeDetail
--	,strSubPatternFormat
--	,intOrdinalPosition
--	)
--SELECT intPatternId = @intPatternId
--	,strSubPatternName = @strSubPatternName2
--	,intSubPatternTypeId = @intSubPatternTypeId2
--	,intSubPatternSize = 5
--	,strSubPatternTypeDetail = @strSubPatternTypeDetail2
--	,strSubPatternFormat = ''
--	,intOrdinalPosition = 2
--WHERE NOT EXISTS (
--		SELECT *
--		FROM dbo.tblMFPatternDetail
--		WHERE intPatternId = @intPatternId
--			AND strSubPatternName = @strSubPatternName2
--		)

--INSERT dbo.tblMFPatternDetail (
--	intPatternId
--	,strSubPatternName
--	,intSubPatternTypeId
--	,intSubPatternSize
--	,strSubPatternTypeDetail
--	,strSubPatternFormat
--	,intOrdinalPosition
--	)
--SELECT intPatternId = @intPatternId
--	,strSubPatternName = @strSubPatternName3
--	,intSubPatternTypeId = @intSubPatternTypeId3
--	,intSubPatternSize = 2
--	,strSubPatternTypeDetail = @strSubPatternTypeDetail3
--	,strSubPatternFormat = ''
--	,intOrdinalPosition = 3
--WHERE NOT EXISTS (
--		SELECT *
--		FROM dbo.tblMFPatternDetail
--		WHERE intPatternId = @intPatternId
--			AND strSubPatternName = @strSubPatternName3
--		)

--INSERT dbo.tblMFPatternDetail (
--	intPatternId
--	,strSubPatternName
--	,intSubPatternTypeId
--	,intSubPatternSize
--	,strSubPatternTypeDetail
--	,strSubPatternFormat
--	,intOrdinalPosition
--	)
--SELECT intPatternId = @intPatternId
--	,strSubPatternName = @strSubPatternName4
--	,intSubPatternTypeId = @intSubPatternTypeId4
--	,intSubPatternSize = 1
--	,strSubPatternTypeDetail = @strSubPatternTypeDetail4
--	,strSubPatternFormat = 'Right(<?>,1)'
--	,intOrdinalPosition = 4
--WHERE NOT EXISTS (
--		SELECT *
--		FROM dbo.tblMFPatternDetail
--		WHERE intPatternId = @intPatternId
--			AND strSubPatternName = @strSubPatternName4
--		)

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
	,intSubPatternSize = 9
	,strSubPatternTypeDetail = ''
	,strSubPatternFormat = ''
	,intOrdinalPosition = 2
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Sequence'
		)
GO

DECLARE @strPatternString NVARCHAR(50)
DECLARE @strPatternName NVARCHAR(50)
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

--	SELECT @intSubPatternTypeId0 = 4

--SELECT @strSubPatternName0 = 'Part0'

--SELECT @strSubPatternTypeDetail0 = 'tblICCategory.strCategoryCode'

SELECT @intSubPatternTypeId = 3

SELECT @strSubPatternName = 'Part1'

SELECT @strSubPatternTypeDetail = 'YY'

SELECT @intSubPatternTypeId2 = 3

SELECT @strSubPatternName2 = 'Part2'

SELECT @strSubPatternTypeDetail2 = 'Julian Date'

SELECT @intSubPatternTypeId3 = 1

SELECT @strSubPatternName3 = 'Part3'

SELECT @strSubPatternTypeDetail3 = 'HU'

SELECT @intSubPatternTypeId4 = 4

SELECT @strSubPatternName4 = 'Part4'

SELECT @strSubPatternTypeDetail4 = 'tblMFShift.strShiftName'

SELECT @strPatternName = N'Parent Lot Number'
	,@strDescription = N'Parent Lot Number'
	,@intPatternCode = 78

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

--INSERT dbo.tblMFPatternDetail (
--	intPatternId
--	,strSubPatternName
--	,intSubPatternTypeId
--	,intSubPatternSize
--	,strSubPatternTypeDetail
--	,strSubPatternFormat
--	,intOrdinalPosition
--	)
--SELECT intPatternId = @intPatternId
--	,strSubPatternName = @strSubPatternName0
--	,intSubPatternTypeId = @intSubPatternTypeId0
--	,intSubPatternSize = 1
--	,strSubPatternTypeDetail = @strSubPatternTypeDetail0
--	,strSubPatternFormat = 'Left(<?>,1)'
--	,intOrdinalPosition = 0
--WHERE NOT EXISTS (
--		SELECT *
--		FROM dbo.tblMFPatternDetail
--		WHERE intPatternId = @intPatternId
--			AND strSubPatternName = @strSubPatternName0
--		)



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
	,intSubPatternSize = 5
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
	,intSubPatternSize = 2
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
	)
SELECT intPatternId = @intPatternId
	,strSubPatternName = @strSubPatternName4
	,intSubPatternTypeId = @intSubPatternTypeId4
	,intSubPatternSize = 1
	,strSubPatternTypeDetail = @strSubPatternTypeDetail4
	,strSubPatternFormat = 'Right(<?>,1)'
	,intOrdinalPosition = 4
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = @strSubPatternName4
		)
