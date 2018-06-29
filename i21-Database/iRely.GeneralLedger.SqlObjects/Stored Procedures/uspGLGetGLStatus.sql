﻿CREATE PROCEDURE [dbo].[uspGLGetGLStatus]
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @HasPrimarySegmentBuilt BIT = 0
	DECLARE @HasLocationSegmentBuilt BIT = 0
	DECLARE @HasUOMBuilt BIT = 0
	DECLARE @HasImportedReallocation BIT = 0
	DECLARE @HasAccountBuilt BIT = 0
	DECLARE @HasStructureBuilt BIT = 0
	DECLARE @HasImportedHistorical BIT = 0
	DECLARE @HasImportedFiscalYear BIT = 0
	
	SELECT TOP 1 @HasStructureBuilt =1 FROM tblGLAccountStructure
	SELECT TOP 1 @HasAccountBuilt=1 FROM tblGLAccount
	select TOP 1 @HasPrimarySegmentBuilt = 1 FROM tblGLAccountStructure a INNER JOIN tblGLAccountSegment b on a.intAccountStructureId = b.intAccountStructureId where a.strType = 'Primary'
	select TOP 1 @HasLocationSegmentBuilt = 1 FROM tblGLAccountStructure a INNER JOIN tblGLAccountSegment b on a.intAccountStructureId = b.intAccountStructureId where a.strType = 'Segment'
	SELECT TOP 1 @HasUOMBuilt = 1 FROM tblGLAccountUnit
	SELECT TOP 1 @HasImportedReallocation = 1 FROM dbo.tblSMPreferences ts WHERE ts.strPreference = 'isReallocationImported' AND strValue = 'true'
	SELECT TOP 1 @HasImportedHistorical = ysnHistoricalJournalImported FROM tblGLCompanyPreferenceOption
	SELECT TOP 1 @HasImportedFiscalYear = 1 FROM tblGLFiscalYear
	SELECT
		ISNULL(@HasStructureBuilt,0) AS HasStructureBuilt,
		ISNULL(@HasAccountBuilt,0) AS HasAccountBuilt,
		ISNULL(@HasPrimarySegmentBuilt,0) AS HasPrimarySegmentBuilt,
		ISNULL(@HasLocationSegmentBuilt,0) AS HasLocationSegmentBuilt,
		ISNULL(@HasUOMBuilt,0) AS HasUOMBuilt,
		ISNULL(@HasImportedReallocation,0) AS HasImportedReallocation,
		ISNULL(@HasImportedHistorical,0) AS HasImportedHistorical,
		ISNULL(@HasStructureBuilt,0) AS HasStructureBuilt,
		ISNULL(@HasImportedFiscalYear,0) AS HasImportedFiscalYear
END