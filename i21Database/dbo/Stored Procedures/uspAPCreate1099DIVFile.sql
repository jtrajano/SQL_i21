﻿CREATE PROCEDURE [dbo].[uspAPCreate1099DIVFile]
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
DECLARE @endOfDIV AS TABLE(strEndOfDIV NVARCHAR(1500), intTotalDIV INT)
DECLARE @endOfTransmitter AS TABLE(strEndOfTransmitter NVARCHAR(1500))
DECLARE @totalPayee NVARCHAR(16)
DECLARE @totalDIV INT;


INSERT INTO @transmitter
SELECT dbo.[fnAP1099EFileTransmitter](@year,@test)

INSERT INTO @payer
SELECT dbo.[fnAP1099EFilePayer](@year, 2, @vendorFrom, @vendorTo)

INSERT INTO @payee
SELECT * FROM dbo.[fnAP1099EFileDIVPayee](@year, @reprint, @corrected, @vendorFrom, @vendorTo)

INSERT INTO @endOfDIV
SELECT * FROM dbo.fnAP1099EFileEndOfDIV(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

SET @totalDIV = (SELECT intTotalDIV FROM @endOfDIV)

INSERT INTO @endOfTransmitter
SELECT [dbo].[fnAP1099EFileEndOfTransmitter](@totalDIV)

-- SET @totalPayee = REPLICATE('0', 8 - LEN(CAST((SELECT COUNT(*) FROM @payee) AS NVARCHAR(100)))) + CAST((SELECT COUNT(*) FROM @payee) AS NVARCHAR(100))
SET @totalPayee = REPLICATE('0', 8 - LEN(CAST(@totalDIV AS NVARCHAR(100)))) + CAST(@totalDIV AS NVARCHAR(100))

UPDATE A
	SET A.strTransmitter = STUFF(A.strTransmitter, 296, 8, @totalPayee)
FROM @transmitter A

SELECT * FROM @transmitter
UNION ALL
SELECT * FROM @payer
UNION ALL
SELECT * FROM @payee
UNION ALL
SELECT strEndOfDIV FROM @endOfDIV
UNION ALL 
SELECT * FROM @endOfTransmitter