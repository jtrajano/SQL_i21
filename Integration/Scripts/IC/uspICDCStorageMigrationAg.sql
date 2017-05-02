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


----====================================STEP 1=============================================
--import storage locations from origin and update the sub location required for i21 

insert into tblICStorageLocation 
(strName, strDescription, intLocationId, intSubLocationId, intConcurrencyId)
select os.agitm_binloc, os.agitm_binloc, L.intCompanyLocationId, SL.intCompanyLocationSubLocationId, 1 concurrencyid
from 
(select agitm_loc_no, agitm_binloc from agitmmst where agitm_binloc is not null group by agitm_loc_no, agitm_binloc) os 
join tblSMCompanyLocation L on os.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
join tblSMCompanyLocationSubLocation SL on L.intCompanyLocationId = SL.intCompanyLocationId


