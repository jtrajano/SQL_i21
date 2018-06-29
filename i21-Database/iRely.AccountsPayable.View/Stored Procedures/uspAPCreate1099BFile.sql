CREATE PROCEDURE [dbo].[uspAPCreate1099BFile]
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
DECLARE @endOfB AS TABLE(strEndOfB NVARCHAR(1500))
DECLARE @endOfTransmitter AS TABLE(strEndOfTransmitter NVARCHAR(1500))
DECLARE @totalPayee NVARCHAR(16)


INSERT INTO @transmitter
SELECT dbo.[fnAP1099EFileTransmitter](@year,@test)

INSERT INTO @payer
SELECT dbo.[fnAP1099EFilePayer](@year, 3, @vendorFrom, @vendorTo)

INSERT INTO @payee
SELECT * FROM dbo.fnAP1099EFileBPayee(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

INSERT INTO @endOfB
SELECT dbo.fnAP1099EFileEndOfB(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

INSERT INTO @endOfTransmitter
SELECT [dbo].[fnAP1099EFileEndOfTransmitter](1)

SET @totalPayee = REPLICATE('0', 8 - LEN(CAST((SELECT COUNT(*) FROM @payee) AS NVARCHAR(100)))) + CAST((SELECT COUNT(*) FROM @payee) AS NVARCHAR(100))

UPDATE A
	SET A.strTransmitter = STUFF(A.strTransmitter, 296, 8, @totalPayee)
FROM @transmitter A

SELECT * FROM @transmitter
UNION ALL
SELECT * FROM @payer
UNION ALL
SELECT * FROM @payee
UNION ALL
SELECT * FROM @endOfB
UNION ALL 
SELECT * FROM @endOfTransmitter