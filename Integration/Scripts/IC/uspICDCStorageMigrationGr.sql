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

insert into tblICStorageLocation 
(strName, strDescription, intLocationId, intSubLocationId, intCommodityId, dblPackFactor, dblEffectiveDepth,
dblUnitPerFoot, dblResidualUnit, intConcurrencyId)
select os.gaphy_bin_no, os.gaphy_desc, SL.intCompanyLocationId, SL.intCompanyLocationSubLocationId, C.intCommodityId, 
os.gaphy_pack_factor, os.gaphy_eff_depth, os.gaphy_un_per_ft, os.gaphy_residual_un, 1 concurrencyid
from gaphymst os 
join tblSMCompanyLocation L on os.gaphy_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = L.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
join tblSMCompanyLocationSubLocation SL on L.intCompanyLocationId = SL.intCompanyLocationId
left join tblICCommodity C on os.gaphy_com_cd COLLATE SQL_Latin1_General_CP1_CS_AS = C.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS



GO

