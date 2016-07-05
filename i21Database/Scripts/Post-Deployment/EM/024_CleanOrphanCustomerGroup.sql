PRINT '*** Start Clean up customer group orphan***'

DELETE FROM tblARCustomerGroupDetail where intCustomerGroupId not in (select intCustomerGroupId from tblARCustomerGroup)


PRINT '*** End Clean up customer group orphan***'