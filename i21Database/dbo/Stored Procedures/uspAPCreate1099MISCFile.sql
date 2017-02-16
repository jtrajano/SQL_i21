CREATE PROCEDURE [dbo].[uspAPCreate1099MISCFile]
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL,
	@year INT,
	@reprint BIT = 0,
	@corrected BIT = 0,
	@test BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF;

DECLARE @transmitter AS TABLE(strTransmitter NVARCHAR(1500))
DECLARE @payer AS TABLE(strPayer NVARCHAR(1500))
DECLARE @payee AS TABLE(strPayee NVARCHAR(MAX))
DECLARE @endOfMISC AS TABLE(strEndOfMISC NVARCHAR(1500))
DECLARE @endOfTransmitter AS TABLE(strEndOfTransmitter NVARCHAR(1500))
DECLARE @totalPayee NVARCHAR(16)
DECLARE @recordCSequence NVARCHAR(16)
DECLARE @recordFSequence NVARCHAR(16)

INSERT INTO @transmitter
SELECT dbo.[fnAP1099EFileTransmitter](@year,@test)

INSERT INTO @payer
SELECT dbo.[fnAP1099EFilePayer](@year, 1, @vendorFrom, @vendorTo)

INSERT INTO @payee
SELECT * FROM dbo.fnAP1099EFileMISCPayee(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

INSERT INTO @endOfMISC
SELECT dbo.fnAP1099EFileEndOfMISC(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

INSERT INTO @endOfTransmitter
SELECT [dbo].[fnAP1099EFileEndOfTransmitter](1)

--UPDATE LINE 296 OF 'A' RECORD
SET @totalPayee = REPLICATE('0', 8 - LEN(CAST((SELECT COUNT(*) FROM @payee) AS NVARCHAR(100)))) + CAST((SELECT COUNT(*) FROM @payee) AS NVARCHAR(100))
UPDATE A
	SET A.strTransmitter = STUFF(A.strTransmitter, 296, 8, @totalPayee)
FROM @transmitter A

--UPDATE LINE 500 OF 'C' RECORD
SET @recordCSequence = REPLICATE('0', 8 - LEN(CAST((SELECT COUNT(*)+3 FROM @payee) AS NVARCHAR(100)))) + CAST((SELECT COUNT(*)+3 FROM @payee) AS NVARCHAR(100))
UPDATE A
	SET A.strEndOfMISC = STUFF(A.strEndOfMISC, 500, 8, @recordCSequence)
FROM @endOfMISC A

--UPDATE LINE 500 OF 'F' RECORD
SET @recordFSequence = REPLICATE('0', 8 - LEN(CAST((SELECT COUNT(*)+4 FROM @payee) AS NVARCHAR(100)))) + CAST((SELECT COUNT(*)+4 FROM @payee) AS NVARCHAR(100))
UPDATE A
	SET A.strEndOfTransmitter = STUFF(A.strEndOfTransmitter, 500, 8, @recordFSequence)
FROM @endOfTransmitter A

SELECT * FROM @transmitter
UNION ALL
SELECT * FROM @payer
UNION ALL
SELECT * FROM @payee
UNION ALL
SELECT * FROM @endOfMISC
UNION ALL 
SELECT * FROM @endOfTransmitter