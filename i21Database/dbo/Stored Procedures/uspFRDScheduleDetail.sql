CREATE PROCEDURE  [dbo].[uspFRDScheduleDetail]
    @intHierarchyScheduleId INT  
           
AS          
BEGIN          
          
SET QUOTED_IDENTIFIER OFF          
SET ANSI_NULLS ON          
SET NOCOUNT ON           
        
 --MAIN DATA SOURCE          
 DELETE tblFRReportHierarchyScheduleDetails WHERE intHierarchyScheduleId = @intHierarchyScheduleId  
 ----------------------------------------------------------------------------------------------------------------------------------------          
 INSERT INTO tblFRReportHierarchyScheduleDetails (intReportId,intHierarchyScheduleId,intReportHierarchyId,intReportHierarchyDetailId,dtmAsOfDate,dtmSchedDate)           
 SELECT intReportId,intHierarchyScheduleId,T0.intReportHierarchyId,T0.intReportHierarchyDetailId,dtmAsOfDate,dtmScheduleDate FROM tblFRReportHierarchyDetail T0  
 INNER JOIN  tblFRReportHierarchySchedule T1  
 ON T0.intReportHierarchyId = T1.intReportHierarchyId  
 WHERE T1.intHierarchyScheduleId = @intHierarchyScheduleId  
        
 SELECT @@ROWCOUNT        
 END      