
PRINT ('Reporting Component Cleanup')
GO

DELETE FROM tblTFReportingComponent WHERE intMasterId = 0 
--AND intReportingComponentId NOT IN (SELECT DISTINCT intReportingComponentId FROM tblTFTransaction)
GO

PRINT ('TAX FORMS - Deployment - END')
GO
