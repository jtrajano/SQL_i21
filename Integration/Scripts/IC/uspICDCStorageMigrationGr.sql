IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCStorageMigrationGr]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCStorageMigrationGr]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCStorageMigrationGr]

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
insert into tblSMCompanyLocationSubLocation
(intCompanyLocationId, strSubLocationName, strSubLocationDescription, strClassification, intConcurrencyId)
select distinct intCompanyLocationId, strLocationName, strLocationName strDescription, 'Inventory' strClassification, 1 Concurrencyid
from tblSMCompanyLocation L 
join gaphymst os on os.gaphy_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
where gaphy_bin_no is not null

----====================================STEP 1=============================================
--import storage locations from origin and update the sub location required for i21 
MERGE tblICStorageLocation as [Target]
USING
(SELECT os.gaphy_bin_no, os.gaphy_desc, L.intCompanyLocationId, SL.intCompanyLocationSubLocationId, 1 concurrencyid
FROM 
	(SELECT gaphy_loc_no, gaphy_bin_no, gaphy_desc FROM gaphymst WHERE gaphy_loc_no IS NOT NULL GROUP BY gaphy_loc_no, gaphy_bin_no, gaphy_desc) os 
	join tblSMCompanyLocation L on os.gaphy_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
	join tblSMCompanyLocationSubLocation SL on L.intCompanyLocationId = SL.intCompanyLocationId
) AS [Source] (strName, strDescription, intLocationId, intSubLocationId, intConcurrencyId)

ON [Target].strName = [Source].strName COLLATE SQL_Latin1_General_CP1_CS_AS
and [Target].intLocationId = [Source].intLocationId
and [Target].intSubLocationId = [Source].intSubLocationId

WHEN NOT MATCHED THEN
INSERT (strName, strDescription, intLocationId, intSubLocationId, intConcurrencyId)
VALUES ([Source].strName, [Source].strDescription, [Source].intLocationId, [Source].intSubLocationId, [Source].intConcurrencyId);


GO

