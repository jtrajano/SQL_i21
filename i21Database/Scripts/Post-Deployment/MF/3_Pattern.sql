DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Lot Number'
	,@strDescription = N'Lot Number'
	,@intPatternCode = 24
	,@strSubPatternTypeDetail = 'LOT-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = Len(@strSubPatternTypeDetail)
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Batch Production'
	,@strDescription = N'Batch Production'
	,@intPatternCode = 33
	,@strSubPatternTypeDetail = ''

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
	,strSubPatternName = 'Sequence'
	,intSubPatternTypeId = 6
	,intSubPatternSize = 8
	,strSubPatternTypeDetail = ''
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
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
	,strPatternSequence = ''
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = ''
		)
GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Work Order'
	,@strDescription = N'Work Order'
	,@intPatternCode = 34
	,@strSubPatternTypeDetail = 'WO-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = 3
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Demand Number'
	,@strDescription = N'Demand Number'
	,@intPatternCode = 46
	,@strSubPatternTypeDetail = 'DN-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = 3
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Stage Lot Number'
	,@strDescription = N'Stage Lot Number'
	,@intPatternCode = 55
	,@strSubPatternTypeDetail = 'STG-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = Len(@strSubPatternTypeDetail)
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Bag Off Order'
	,@strDescription = N'Bag Off Order'
	,@intPatternCode = 59
	,@strSubPatternTypeDetail = 'BO-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = Len(@strSubPatternTypeDetail)
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO


GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Schedule Number'
	,@strDescription = N'Schedule Number'
	,@intPatternCode = 63
	,@strSubPatternTypeDetail = 'WS-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = Len(@strSubPatternTypeDetail)
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Pick List Number'
	,@strDescription = N'Pick List Number'
	,@intPatternCode = 68
	,@strSubPatternTypeDetail = 'PK-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = Len(@strSubPatternTypeDetail)
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Sanitization Order Number'
	,@strDescription = N'Sanitization Order Number'
	,@intPatternCode = 70
	,@strSubPatternTypeDetail = 'S-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = Len(@strSubPatternTypeDetail)
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO

DECLARE @strPatternName NVARCHAR(50)
	,@strDescription NVARCHAR(100)
	,@intPatternCode INT
	,@intPatternId INT
	,@strSubPatternTypeDetail NVARCHAR(50)

SELECT @strPatternName = N'Parent Lot Number'
	,@strDescription = N'Parent Lot Number'
	,@intPatternCode = 78
	,@strSubPatternTypeDetail = 'PLOT-'

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
	,strSubPatternName = 'Prefix'
	,intSubPatternTypeId = 1
	,intSubPatternSize = Len(@strSubPatternTypeDetail)
	,strSubPatternTypeDetail = @strSubPatternTypeDetail
	,strSubPatternFormat = ''
	,intOrdinalPosition = 1
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternDetail
		WHERE intPatternId = @intPatternId
			AND strSubPatternName = 'Prefix'
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
	,intSubPatternSize = 8
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
	,strPatternSequence = @strSubPatternTypeDetail
	,intSequenceNo = (
		SELECT MAX(intNumber)
		FROM dbo.tblSMStartingNumber
		WHERE strTransactionType = @strPatternName
		)
	,intMaximumSequence = 99999999
WHERE NOT EXISTS (
		SELECT *
		FROM dbo.tblMFPatternSequence
		WHERE intPatternId = @intPatternId
			AND strPatternSequence = @strSubPatternTypeDetail
		)
GO


