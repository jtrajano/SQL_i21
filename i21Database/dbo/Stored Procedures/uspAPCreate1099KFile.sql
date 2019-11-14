﻿CREATE PROCEDURE [dbo].[uspAPCreate1099KFile]
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
DECLARE @endOfK AS TABLE(strEndOfK NVARCHAR(1500), intTotalK INT)
DECLARE @endOfTransmitter AS TABLE(strEndOfTransmitter NVARCHAR(1500))
DECLARE @totalK INT;
DECLARE @totalPayee NVARCHAR(16)
DECLARE @recordCSequence NVARCHAR(16)
DECLARE @recordFSequence NVARCHAR(16)

INSERT INTO @transmitter
SELECT dbo.[fnAP1099EFileTransmitter](@year,@test)

INSERT INTO @payer
SELECT dbo.[fnAP1099EFilePayer](@year, 6, @vendorFrom, @vendorTo)

INSERT INTO @payee
SELECT * FROM dbo.fnAP1099EFileKPayee(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

INSERT INTO @endOfK
SELECT * FROM dbo.fnAP1099EFileEndOfK(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

SET @totalK = (SELECT intTotalK FROM @endOfK)

INSERT INTO @endOfTransmitter
SELECT [dbo].[fnAP1099EFileEndOfTransmitter](@totalK)

--UPDATE LINE 296 OF 'A' RECORD
SET @totalPayee = REPLICATE('0', 8 - LEN(CAST(@totalK AS NVARCHAR(100)))) + CAST(@totalK AS NVARCHAR(100))

UPDATE A
	SET A.strTransmitter = STUFF(A.strTransmitter, 296, 8, @totalPayee)
FROM @transmitter A

-- --UPDATE LINE 500 OF 'C' RECORD
-- SET @recordCSequence = REPLICATE('0', 8 - LEN(CAST((SELECT COUNT(*)+3 FROM @payee) AS NVARCHAR(100)))) + CAST((SELECT COUNT(*)+3 FROM @payee) AS NVARCHAR(100))
-- UPDATE A
-- 	SET A.strEndOfK = STUFF(A.strEndOfK, 500, 8, @recordCSequence)
-- FROM @endOfK A

-- --UPDATE LINE 500 OF 'F' RECORD
-- SET @recordFSequence = REPLICATE('0', 8 - LEN(CAST((SELECT COUNT(*)+4 FROM @payee) AS NVARCHAR(100)))) + CAST((SELECT COUNT(*)+4 FROM @payee) AS NVARCHAR(100))
-- UPDATE A
-- 	SET A.strEndOfTransmitter = STUFF(A.strEndOfTransmitter, 500, 8, @recordFSequence)
-- FROM @endOfTransmitter A

SELECT * FROM @transmitter
UNION ALL
SELECT * FROM @payer
UNION ALL
SELECT * FROM @payee
UNION ALL
SELECT strEndOfK FROM @endOfK
UNION ALL 
SELECT * FROM @endOfTransmitter
