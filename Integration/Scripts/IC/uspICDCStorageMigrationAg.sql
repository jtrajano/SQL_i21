IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCStorageMigrationAg]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCStorageMigrationAg]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCStorageMigrationAg]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Use this script to import bins
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--create sublocation for each location. i21 requires a sublocation to be created if there are storage locations
--origin does not have sublocations
--do not import if it already exists. 
INSERT INTO tblSMCompanyLocationSubLocation(
	intCompanyLocationId
	, strSubLocationName
	, strSubLocationDescription
	, strClassification
	, intConcurrencyId
)
SELECT DISTINCT 
	L.intCompanyLocationId
	, L.strLocationName
	, L.strLocationName strDescription
	, 'Inventory' strClassification
	, 1 Concurrencyid
FROM 
	tblSMCompanyLocation L LEFT JOIN agitmmst os 
		ON os.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
	LEFT JOIN tblSMCompanyLocationSubLocation sub
		ON sub.intCompanyLocationId = L.intCompanyLocationId
		AND sub.strSubLocationName = L.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS
		AND sub.strClassification = 'Inventory'
WHERE 
	os.agitm_binloc IS NOT NULL
	AND sub.intCompanyLocationSubLocationId IS NULL 

----====================================STEP 1=============================================
--import storage locations from origin and update the sub location required for i21 
MERGE tblICStorageLocation as [Target]
USING
(
	SELECT 
		os.agitm_binloc
		, os.agitm_binloc
		, L.intCompanyLocationId
		, SL.intCompanyLocationSubLocationId
		, 1 concurrencyid
	FROM (
		SELECT 
			agitm_loc_no
			, agitm_binloc 
		FROM 
			agitmmst 
		WHERE 
			agitm_binloc is not null 
		GROUP BY agitm_loc_no, agitm_binloc
	) os 
	JOIN tblSMCompanyLocation L 
		ON os.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
	JOIN tblSMCompanyLocationSubLocation SL 
		ON L.intCompanyLocationId = SL.intCompanyLocationId
) 
AS [Source] (
	strName
	, strDescription
	, intLocationId
	, intSubLocationId
	, intConcurrencyId
)
ON 
	[Target].strName = [Source].strName COLLATE SQL_Latin1_General_CP1_CS_AS
	AND [Target].intLocationId = [Source].intLocationId
	AND [Target].intSubLocationId = [Source].intSubLocationId

WHEN NOT MATCHED THEN
	INSERT (
		strName
		, strDescription
		, intLocationId
		, intSubLocationId
		, intConcurrencyId
	)
	VALUES (
		[Source].strName
		, [Source].strDescription
		, [Source].intLocationId
		, [Source].intSubLocationId
		, [Source].intConcurrencyId
	);