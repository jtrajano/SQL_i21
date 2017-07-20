IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCStorageMigrationPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCStorageMigrationPt]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCStorageMigrationPt]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Use this script to import bins
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


----====================================STEP 1=============================================
--import storage locations from origin and update the sub location required for i21 
MERGE tblICStorageLocation AS [Target]
USING
(
	SELECT
		  strName				= os.ptitm_binloc COLLATE Latin1_General_CI_AS
		, strDescription		= os.ptitm_binloc COLLATE Latin1_General_CI_AS
		, intLocationId			= L.intCompanyLocationId
		, intSubLocationId		= SL.intCompanyLocationSubLocationId
		, intConcurrencyId		= 1
	FROM 
	(
		SELECT ptitm_loc_no, ptitm_binloc
		FROM ptitmmst 
		WHERE ptitm_binloc is not null 
		GROUP BY ptitm_loc_no, ptitm_binloc
	) os 
	JOIN tblSMCompanyLocation L on os.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
	JOIN tblSMCompanyLocationSubLocation SL on L.intCompanyLocationId = SL.intCompanyLocationId
) AS [Source] (strName, strDescription, intLocationId, intSubLocationId, intConcurrencyId)
ON [Target].strName = [Source].strName
	AND [Target].intLocationId = [Source].intLocationId
	AND [Target].intSubLocationId = [Source].intSubLocationId
WHEN NOT MATCHED THEN
INSERT (strName, strDescription, intLocationId, intSubLocationId, intConcurrencyId)
VALUES ([Source].strName, [Source].strDescription, [Source].intLocationId, [Source].intSubLocationId, [Source].intConcurrencyId);