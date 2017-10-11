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
insert into tblSMCompanyLocationSubLocation
(intCompanyLocationId, strSubLocationName, strSubLocationDescription, strClassification, intConcurrencyId)
select distinct intCompanyLocationId, strLocationName, strLocationName strDescription, 'Inventory' strClassification, 1 Concurrencyid
from tblSMCompanyLocation L 
join agitmmst os on os.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
where agitm_binloc is not null


----====================================STEP 1=============================================
--import storage locations from origin and update the sub location required for i21 


Merge tblICStorageLocation as [Target]
using
(select os.agitm_binloc, os.agitm_binloc, L.intCompanyLocationId, SL.intCompanyLocationSubLocationId, 1 concurrencyid
from 
(select agitm_loc_no, agitm_binloc from agitmmst where agitm_binloc is not null group by agitm_loc_no, agitm_binloc) os 
join tblSMCompanyLocation L on os.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
join tblSMCompanyLocationSubLocation SL on L.intCompanyLocationId = SL.intCompanyLocationId
) as [Source] (strName, strDescription, intLocationId, intSubLocationId, intConcurrencyId)
ON [Target].strName = [Source].strName COLLATE SQL_Latin1_General_CP1_CS_AS
and [Target].intLocationId = [Source].intLocationId
and [Target].intSubLocationId = [Source].intSubLocationId
When Not Matched then
Insert (strName, strDescription, intLocationId, intSubLocationId, intConcurrencyId)
values ([Source].strName, [Source].strDescription, [Source].intLocationId, [Source].intSubLocationId, [Source].intConcurrencyId);


