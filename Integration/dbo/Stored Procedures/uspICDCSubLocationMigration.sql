Create PROCEDURE [dbo].[uspICDCSubLocationMigration]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Use this script to import sub location
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----=======================================STEP 1=======================================
--create sublocation for each location. i21 requires a sublocation to be created if there are storage locations
--origin does not have sublocations
insert into tblSMCompanyLocationSubLocation
(intCompanyLocationId, strSubLocationName, strSubLocationDescription, strClassification, intConcurrencyId)
select intCompanyLocationId, strLocationName, strLocationName strDescription, 'Inventory' strClassification, 1 Concurrencyid
from tblSMCompanyLocation


GO

