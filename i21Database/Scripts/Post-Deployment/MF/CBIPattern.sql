﻿DECLARE @strPatternString NVARCHAR(50)
, @strPatternName NVARCHAR(50)
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
	,@intPatternCode INT

SELECT @intSubPatternTypeId = 3

SELECT @strSubPatternName = 'Part1'

SELECT @strSubPatternTypeDetail = 'YY'

SELECT @intSubPatternTypeId2 = 3

SELECT @strSubPatternName2 = 'Part2'

SELECT @strSubPatternTypeDetail2 = 'Julian Date'

SELECT @intSubPatternTypeId3 = 8

SELECT @strSubPatternName3 = 'Alphabetical Sequence'

SELECT @strSubPatternTypeDetail3 = ''

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
	,ysnPaddingZero
	)
SELECT intPatternId = @intPatternId
	,strSubPatternName = @strSubPatternName3
	,intSubPatternTypeId = @intSubPatternTypeId3
	,intSubPatternSize = 3
	,strSubPatternTypeDetail = @strSubPatternTypeDetail3
	,strSubPatternFormat = ''
	,intOrdinalPosition = 3
	,ysnPaddingZero=0
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = @strSubPatternName3
		)
Go
DECLARE @strPatternString NVARCHAR(50)
, @strPatternName NVARCHAR(50)
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
	,@intPatternCode INT

SELECT @intSubPatternTypeId =1

SELECT @strSubPatternName = 'Part1'

SELECT @strSubPatternTypeDetail = '@strParentLotNumber'

SELECT @intSubPatternTypeId2 = 6

SELECT @strSubPatternName2 = 'Sequence'

SELECT @strSubPatternTypeDetail2 = ''

SELECT @intSubPatternTypeId3 = 1

SELECT @strSubPatternName3 = 'Part2'

SELECT @strSubPatternTypeDetail3 = '-'

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
	,strSubPatternName = @strSubPatternName3
	,intSubPatternTypeId = @intSubPatternTypeId3
	,intSubPatternSize = 1
	,strSubPatternTypeDetail = @strSubPatternTypeDetail3
	,strSubPatternFormat = ''
	,intOrdinalPosition = 2
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
	)
SELECT intPatternId = @intPatternId
	,strSubPatternName = @strSubPatternName2
	,intSubPatternTypeId = @intSubPatternTypeId2
	,intSubPatternSize = 9
	,strSubPatternTypeDetail = @strSubPatternTypeDetail2
	,strSubPatternFormat = ''
	,intOrdinalPosition = 3
	,ysnPaddingZero=0
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = @strSubPatternName2
		)


