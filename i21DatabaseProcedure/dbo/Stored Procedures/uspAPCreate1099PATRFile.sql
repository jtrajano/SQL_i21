﻿CREATE PROCEDURE [dbo].[uspAPCreate1099PATRFile]
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
DECLARE @endOfPATR AS TABLE(strEndOfPATR NVARCHAR(1500), intTotalB INT)
DECLARE @endOfTransmitter AS TABLE(strEndOfTransmitter NVARCHAR(1500))
DECLARE @totalB INT;
DECLARE @totalPayee NVARCHAR(16)


INSERT INTO @transmitter
SELECT dbo.[fnAP1099EFileTransmitter](@year,@test)

INSERT INTO @payer
SELECT dbo.[fnAP1099EFilePayer](@year, 4, @vendorFrom, @vendorTo)

INSERT INTO @payee
SELECT * FROM dbo.fnAP1099EFilePATRPayee(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

INSERT INTO @endOfPATR
SELECT * FROM dbo.fnAP1099EFileEndOfPATR(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

SET @totalB = (SELECT intTotalB FROM @endOfPATR)

INSERT INTO @endOfTransmitter
SELECT [dbo].[fnAP1099EFileEndOfTransmitter](@totalB)

SET @totalPayee = REPLICATE('0', 8 - LEN(CAST(@totalB AS NVARCHAR(100)))) + CAST(@totalB AS NVARCHAR(100))

UPDATE A
	SET A.strTransmitter = STUFF(A.strTransmitter, 296, 8, @totalPayee)
FROM @transmitter A

SELECT * FROM @transmitter
UNION ALL
SELECT * FROM @payer
UNION ALL
SELECT * FROM @payee
UNION ALL
SELECT strEndOfPATR FROM @endOfPATR
UNION ALL 
SELECT * FROM @endOfTransmitter