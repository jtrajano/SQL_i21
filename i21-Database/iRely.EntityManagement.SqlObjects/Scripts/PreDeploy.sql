:r .\PreDeployment\17_DropDependencies_RenameTable.sql

:r .\PreDeployment\01_EntitySchemaUpdate.sql
:r .\PreDeployment\02_UpdateGroupIdFromNonExistence.sql
:r .\PreDeployment\03_EntityCustomerFarmRename_DataFix.sql
:r .\PreDeployment\04_EntityLocationTaxCodeUpdate.sql
:r .\PreDeployment\05_EntitySplitSchemaUpdate.sql
:r .\PreDeployment\07_EntityFarmSchemaUpdate.sql
:r .\PreDeployment\08_EntityShipViaSchemaUpdate.sql
:r .\PreDeployment\UpdateShipVia.sql
:r .\PreDeployment\09_UpdateEntityLocationShipVia.sql
:r .\PreDeployment\10_CheckAndFixSpecialPricingRackLocation.sql
:r .\PreDeployment\11_AvoidCustomerTransportSupplierIdConflict.sql
:r .\PreDeployment\13_EntityUserSecuritySchemaUpdate.sql
:r .\PreDeployment\14_EntityUserSecuritySchemaUpdateForTM01.sql -- this should always be under entity security schema change 
:r .\PreDeployment\14_EntityUserSecuritySchemaUpdateForTM02.sql -- this should always be under entity security schema change 
:r .\PreDeployment\14_EntityUserSecuritySchemaUpdateForTM03.sql -- this should always be under entity security schema change 
:r .\PreDeployment\14_EntityUserSecuritySchemaUpdateForTM04.sql -- this should always be under entity security schema change 
:r .\PreDeployment\14_EntityUserSecuritySchemaUpdateForTM05.sql -- this should always be under entity security schema change 
:r .\PreDeployment\14_EntityUserSecuritySchemaUpdateForTM06.sql -- this should always be under entity security schema change 
:r .\PreDeployment\HDGroupUserConfigDataEntryFix.sql -- this will update the security id at tblHDGroupUserConfig table (one time update)
:r .\PreDeployment\12_EntityEmployeeSchemaUpdate.sql
:r .\PreDeployment\12_UpdateCustomerFreightNullLocation.sql
:r .\PreDeployment\15_DropSMUserSecurityTrigger.sql
:r .\PreDeployment\18_FixDuplicateLocationEntry.sql
:r .\PreDeployment\19_CleanEntityPhoneNumber.sql

:r .\PreDeployment\16_CleanCustomerProductVersion.sql
:r .\PreDeployment\20_CleanCustomerSpecialPrice.sql
:r .\PreDeployment\21_CleanAPBillMissingContact.sql

:r .\PreDeployment\16_Drop_tblEntity_related_constraints.sql -- THIS IS ON THE OUTSKIRT OF SCRIPT DUE TO ITS SENSITIVITY