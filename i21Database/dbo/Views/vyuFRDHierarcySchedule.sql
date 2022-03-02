CREATE VIEW [dbo].[vyuFRDHierarcySchedule]  
AS  
  
SELECT T0.intHierarchyScheduleId,T0.intReportId,T3.strReportName,T3.strDescription,
T0.intReportHierarchyId,T2.strReportHierarchyName,T0.dtmAsOfDate,T0.dtmScheduleDate,
SUM(CASE WHEN ISNULL(T1.intReportHierarchyId,0) <> 0 THEN 1 ELSE 0 END)intTotalReport,
CASE WHEN ysnReportIsSuccess = 0 THEN 'Pending' ELSE 'Completed' END strStatus 
FROM tblFRReportHierarchySchedule T0
INNER JOIN tblFRReportHierarchyDetail T1 
ON T0.intReportHierarchyId  = T1.intReportHierarchyId
INNER JOIN tblFRReportHierarchy T2
ON T0.intReportHierarchyId  = T2.intReportHierarchyId
INNER  JOIN tblFRReport T3   
ON T0.intReportId = T3.intReportId  
GROUP BY T0.intHierarchyScheduleId,T0.intReportId,T3.strReportName,T3.strDescription,
T0.intReportHierarchyId,T2.strReportHierarchyName,T0.dtmAsOfDate,T0.dtmScheduleDate
