CREATE PROCEDURE [dbo].[uspAPImportVoucherLassus]
	@file NVARCHAR(500)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @sql NVARCHAR(MAX);
DECLARE @path NVARCHAR(500);
DECLARE @errorFile NVARCHAR(500);
DECLARE @lastIndex INT;

-- SET @lastIndex = (LEN(@file)) -  CHARINDEX('/', REVERSE(@file)) 
-- SET @path = SUBSTRING(@file, 0, @lastindex + 1)
SET @errorFile = REPLACE(@file, 'csv', 'txt');

DELETE FROM tblAPImportVoucherLassus

SET @sql = 'BULK INSERT tblAPImportVoucherLassus FROM ''' + @file + ''' WITH
        (
        FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		ROWS_PER_BATCH = 10000, 
		FIRSTROW = 1,
		TABLOCK,
		ERRORFILE = ''' + @errorFile + '''
        )'

EXEC(@sql)
-- SET @sql = 'BULK INSERT tblAPImportVoucherLassus FROM ''' + @file + ''' WITH
--     (
--     FIRSTROW = 2,
--     FIELDTERMINATOR = ',',  --CSV field delimiter
--     ROWTERMINATOR = '\n',   --Use to shift the control to next row
--     ERRORFILE = 'C:\CSVDATA\SchoolsErrorRows.csv',
--     TABLOCK
--     )
