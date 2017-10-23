
PRINT ('Reporting Component Cleanup')

DELETE FROM tblTFReportingComponent WHERE intMasterId = 0 
--AND intReportingComponentId NOT IN (SELECT DISTINCT intReportingComponentId FROM tblTFTransaction)

GO