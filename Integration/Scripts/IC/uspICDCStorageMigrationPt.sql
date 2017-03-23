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

insert into tblICStorageLocation 
(strName, strDescription, intLocationId, intSubLocationId, intConcurrencyId)
select os.ptitm_binloc, os.ptitm_binloc, L.intCompanyLocationId, SL.intCompanyLocationSubLocationId, 1 concurrencyid
from 
(select ptitm_loc_no, ptitm_binloc from ptitmmst where ptitm_binloc is not null group by ptitm_loc_no, ptitm_binloc) os 
join tblSMCompanyLocation L on os.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
join tblSMCompanyLocationSubLocation SL on L.intCompanyLocationId = SL.intCompanyLocationId

