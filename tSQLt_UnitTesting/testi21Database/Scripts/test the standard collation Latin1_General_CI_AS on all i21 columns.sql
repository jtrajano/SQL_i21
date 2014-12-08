CREATE PROCEDURE [testi21Database].[test the standard collation (Latin1_General_CI_AS) on all i21 columns]
AS
BEGIN		
	SELECT	TABLE_NAME, COLUMN_NAME, COLLATION_NAME, DATA_TYPE 
	INTO	dbo.listOfOutOfStandardUseOfCollation
	FROM	INFORMATION_SCHEMA.COLUMNS
	WHERE	DATA_TYPE like '%char%'
			AND NOT COLLATION_NAME = 'Latin1_General_CI_AS'
			AND TABLE_NAME NOT IN (
				'tblGLIjemst'
				, 'tblCMAptrxmstArchive'
				, 'tblCMApchkmstArchive'
				, 'tblCMApeglmstArchive'
				, 'tblTMCOBOLWRITE'
				, 'tblTMCOBOLREADSiteLink'
				, 'tblTMCOBOLREADSite'
				, 'tblTMCOBOLLeaseBilling'
			)
			AND COLUMN_NAME NOT IN ('strPassword')
			AND TABLE_NAME LIKE 'tbl%'

	EXEC tSQLt.AssertEmptyTable 'listOfOutOfStandardUseOfCollation';
		
	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('listOfOutOfStandardUseOfCollation') IS NOT NULL 
		DROP TABLE listOfOutOfStandardUseOfCollation
END
GO