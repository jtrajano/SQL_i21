CREATE PROCEDURE [dbo].[uspPRProcessTimecardToPayGroup]        
 @strDepartmentIds NVARCHAR(MAX) = ''        
 ,@dtmBeginDate  DATETIME        
 ,@dtmEndDate  DATETIME        
 ,@intUserId   INT = NULL        
AS        
BEGIN   
  
DECLARE @dtmBegin DATETIME        
    ,@dtmEnd DATETIME        
    ,@dtmPay DATETIME        
    ,@xmlDepartments XML        
        
/* Localize Parameters for Optimal Performance */        
SELECT @dtmBegin = @dtmBeginDate        
   ,@dtmEnd  = @dtmEndDate        
   ,@xmlDepartments  = CAST('<A>'+ REPLACE(@strDepartmentIds, ',', '</A><A>')+ '</A>' AS XML)        
        
--Parse the Departments Parameter to Temporary Table        
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intDepartmentId        
INTO #tmpDepartments        
FROM @xmlDepartments.nodes('/A') AS X(T)         
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0        
        
--Clean-up Routine for Timecards with zero hours        
UPDATE tblPRTimecard SET        
dblHours = ROUND(ISNULL(DATEDIFF(MI, dtmTimeIn, dtmTimeOut) / 60.000000, 0), 2)        
WHERE ysnApproved = 1        
 AND intPaycheckId IS NULL        
 AND intPayGroupDetailId IS NULL        
 AND dblHours = 0        
 AND ROUND(ISNULL(DATEDIFF(MI, dtmTimeIn, dtmTimeOut) / 60.000000, 0), 2) > 0        
 AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)        
 AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmDate) AS FLOAT)) AS DATETIME)        
 AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmDate) AS FLOAT)) AS DATETIME)        
      
 DECLARE @intDateFirst int      
 SELECT @intDateFirst  = ISNULL(intFirstDayOfWorkWeek,@@DATEFIRST) FROM tblPRCompanyPreference      
 SET DATEFIRST @intDateFirst        

 DECLARE @strOvertimeCalculation NVARCHAR(50)
 DECLARE @dblRegularHoursThreshold NUMERIC(5, 2)
 
 SELECT @strOvertimeCalculation  = ISNULL(strOvertimeCalculation,'Weekly') FROM tblPRCompanyPreference      
 SELECT @dblRegularHoursThreshold  = ISNULL(dblRegularHoursThreshold, CASE WHEN (@strOvertimeCalculation = 'Weekly') THEN 40 ELSE 0 END) FROM tblPRCompanyPreference
 
  
        
/* Insert Timecards to Temp Table for iteration */        
SELECT         
 T.intEntityEmployeeId        
 ,T.intEmployeeEarningId        
 ,T.intEmployeeDepartmentId        
 ,T.intWorkersCompensationId      
 ,dblRegularHours =  CASE WHEN (SUM(T.dblHours) > @dblRegularHoursThreshold)        
       THEN @dblRegularHoursThreshold      
      ELSE         
       SUM(T.dblHours)        
      END        
 ,dblOvertimeHours = CASE WHEN (SUM(T.dblHours) > @dblRegularHoursThreshold)        
       THEN SUM(T.dblHours) - @dblRegularHoursThreshold      
      ELSE         
       0        
      END          
 ,E.dblDefaultHours        
 ,ysnProcessed = 0      
INTO #tmpTimecard        
FROM tblPRTimecard T LEFT JOIN tblPREmployeeEarning E         
 ON T.intEmployeeEarningId = E.intEmployeeEarningId         
 AND T.intEntityEmployeeId = E.intEntityEmployeeId        
WHERE T.ysnApproved = 1        
 AND T.intPaycheckId IS NULL        
 AND T.intPayGroupDetailId IS NULL        
 AND T.dblHours > 0        
 AND T.intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)        
 AND CAST(FLOOR(CAST(T.dtmDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,T.dtmDate) AS FLOAT)) AS DATETIME)        
 AND CAST(FLOOR(CAST(T.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,T.dtmDate) AS FLOAT)) AS DATETIME)        
GROUP BY        
 T.intEntityEmployeeId        
 ,T.intEmployeeEarningId        
 ,T.intEmployeeDepartmentId        
 ,T.intWorkersCompensationId      
 ,E.dblDefaultHours      
 ,CASE WHEN (@strOvertimeCalculation = 'Weekly') THEN  DATEADD(DD, 7 - DATEPART(dw, dtmDate), dtmDate)    ELSE dtmDate END
        
DECLARE @intEmployeeEarningId INT        
DECLARE @intEmployeeDepartmentId INT        
DECLARE @intWorkersCompensationId INT      
DECLARE @intEntityEmployeeId INT        
DECLARE @intPayGroupDetailId INT        
DECLARE @dblLongestTotalHours NUMERIC(18, 6)      
DECLARE @intDefaultWorkersCompensationId INT      
      
DECLARE @TimecardOvertime TABLE      
(      
 intPayGroupId INT      
 ,intEntityEmployeeId INT      
 ,intEmployeeEarningId INT      
 ,intTypeEarningId INT      
 ,intDepartmentId INT      
 ,intWorkersCompensationId INT      
 ,strCalculationType NVARCHAR(50)      
 ,dblDefaultHours NUMERIC(18, 6)      
 ,dblHoursToProcess NUMERIC(18, 6)      
 ,dblAmount NUMERIC(18, 6)      
 ,dblTotal NUMERIC(18, 6)      
 ,dtmDateFrom DATETIME      
 ,dtmDateTo DATETIME      
 ,intSource INT      
 ,intSort INT      
)      
        
/* Add Timecards to Pay Group Detail */        
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTimecard WHERE ysnProcessed = 0)      
 BEGIN         
  /* Select Timecard to Add */        
  SELECT TOP 1         
   @intEmployeeEarningId   = intEmployeeEarningId        
   ,@intEmployeeDepartmentId = intEmployeeDepartmentId      
   ,@intWorkersCompensationId = intWorkersCompensationId      
   ,@intEntityEmployeeId = intEntityEmployeeId        
  FROM #tmpTimecard      
  WHERE ysnProcessed = 0      
        
  /* Delete any Generated Hours that occupies this Period */        
  DELETE FROM tblPRPayGroupDetail        
  WHERE (intEmployeeEarningId = @intEmployeeEarningId OR strCalculationType IN ('Overtime', 'Shift Differential'))        
   AND intDepartmentId = @intEmployeeDepartmentId        
   AND intWorkersCompensationId = @intWorkersCompensationId      
   AND intEntityEmployeeId = @intEntityEmployeeId        
   AND dtmDateFrom >= CAST(FLOOR(CAST(@dtmBegin AS FLOAT)) AS DATETIME)         
   AND dtmDateFrom <= CAST(FLOOR(CAST(@dtmEnd AS FLOAT)) AS DATETIME)        
   AND intSource = 0        
        
  /* Insert Regular Hours To Pay Group Detail */        
  INSERT INTO tblPRPayGroupDetail        
   (intPayGroupId        
   ,intEntityEmployeeId        
   ,intEmployeeEarningId        
   ,intTypeEarningId        
   ,intDepartmentId        
   ,intWorkersCompensationId        
   ,strCalculationType        
   ,dblDefaultHours        
   ,dblHoursToProcess        
   ,dblAmount        
   ,dblTotal        
   ,dtmDateFrom        
   ,dtmDateTo        
   ,intSource        
   ,intSort        
   ,intConcurrencyId)        
  SELECT        
   EE.intPayGroupId        
   ,TC.intEntityEmployeeId        
   ,TC.intEmployeeEarningId        
   ,EE.intTypeEarningId        
   ,TC.intEmployeeDepartmentId        
   ,CASE WHEN (EE.strCalculationType IN ('Hourly Rate', 'Overtime', 'Salary')) THEN TC.intWorkersCompensationId ELSE NULL END      
   ,EE.strCalculationType        
   ,TC.dblRegularHours        
   ,TC.dblRegularHours        
   ,EE.dblRateAmount        
   ,CASE WHEN (EE.strCalculationType IN ('Fixed Amount', 'Salary')) THEN EE.dblRateAmount ELSE ROUND(TC.dblRegularHours * EE.dblRateAmount, 2) END        
   ,CAST(FLOOR(CAST(@dtmBegin AS FLOAT)) AS DATETIME)        
   ,CAST(FLOOR(CAST(@dtmEnd AS FLOAT)) AS DATETIME)        
   ,3        
   ,1        
   ,1        
  FROM (SELECT intEntityEmployeeId,intEmployeeEarningId,intEmployeeDepartmentId,SUM(dblRegularHours) dblRegularHours       
   ,intWorkersCompensationId    
  FROM #tmpTimecard       
  GROUP BY intEntityEmployeeId ,intEmployeeEarningId,intEmployeeDepartmentId , intWorkersCompensationId) TC         
   INNER JOIN tblPREmployeeEarning EE         
    ON TC.intEmployeeEarningId = EE.intEmployeeEarningId        
   INNER JOIN tblPREmployee EMP        
    ON EMP.[intEntityId] = EE.intEntityEmployeeId        
   LEFT JOIN tblPREmployeeEarning EL        
    ON EE.intEmployeeEarningLinkId = EL.intTypeEarningId        
    AND EE.intEntityEmployeeId = EL.intEntityEmployeeId        
  WHERE TC.intEmployeeEarningId = @intEmployeeEarningId        
    AND TC.intEmployeeDepartmentId = @intEmployeeDepartmentId      
    AND TC.intWorkersCompensationId = @intWorkersCompensationId      
    AND TC.intEntityEmployeeId = @intEntityEmployeeId        
    AND EE.strCalculationType IN ('Hourly Rate', 'Fixed Amount', 'Salary')        
        
  /* Get the Created Pay Group Detail Id*/        
  SELECT @intPayGroupDetailId = @@IDENTITY        
        
 /* Check if Employee has multiple WC code in their time card within Paygroup period */      
 IF(SELECT COUNT(DISTINCT intWorkersCompensationId)FROM #tmpTimecard WHERE intEntityEmployeeId = @intEntityEmployeeId) > 1      
 BEGIN      
  /* Get the longest amount of hours rendered by Employee within Paygroup period*/      
  SELECT @dblLongestTotalHours = MAX(TH.dblTotalHours)      
  FROM (      
   SELECT intEntityEmployeeId      
    ,intWorkersCompensationId      
    ,dblTotalHours = SUM(dblRegularHours + dblOvertimeHours)      
   FROM #tmpTimecard      
   WHERE intEntityEmployeeId = @intEntityEmployeeId      
   GROUP BY intEntityEmployeeId      
    ,intWorkersCompensationId      
  )TH      
      
  /* Check if the longest total hours rendered has more than one WC Code within Paygroup period      
     If true, get the default WC Code on Employee level */      
  IF(SELECT COUNT(intWorkersCompensationId) FROM (SELECT intEntityEmployeeId      
    ,intWorkersCompensationId      
    ,dblTotalHours = SUM(dblRegularHours + dblOvertimeHours)      
   FROM #tmpTimecard      
   WHERE intEntityEmployeeId = @intEntityEmployeeId      
   GROUP BY intEntityEmployeeId      
    ,intWorkersCompensationId) TH      
   WHERE TH.dblTotalHours = @dblLongestTotalHours) > 1      
  BEGIN      
   SELECT @intDefaultWorkersCompensationId = intWorkersCompensationId      
   FROM tblPREmployee WHERE intEntityId = @intEntityEmployeeId      
  END      
  ELSE      
  BEGIN      
   SELECT @intDefaultWorkersCompensationId = intWorkersCompensationId      
   FROM (SELECT intEntityEmployeeId      
    ,intWorkersCompensationId      
    ,dblTotalHours = SUM(dblRegularHours + dblOvertimeHours)      
   FROM #tmpTimecard      
   WHERE intEntityEmployeeId = @intEntityEmployeeId      
   GROUP BY intEntityEmployeeId      
    ,intWorkersCompensationId) TH      
   WHERE TH.dblTotalHours = @dblLongestTotalHours      
  END      
 END      
 ELSE       
 BEGIN      
  SET @intDefaultWorkersCompensationId = @intWorkersCompensationId      
 END      
      
 /* Insert Overtime Hours To Timecard Overtime Temp table*/      
 INSERT INTO @TimecardOvertime      
   (intPayGroupId        
   ,intEntityEmployeeId        
   ,intEmployeeEarningId        
   ,intTypeEarningId        
   ,intDepartmentId        
  ,intWorkersCompensationId      
   ,strCalculationType        
   ,dblDefaultHours        
   ,dblHoursToProcess        
   ,dblAmount        
   ,dblTotal        
   ,dtmDateFrom        
   ,dtmDateTo        
   ,intSource        
  ,intSort)      
  SELECT        
  TCE.intPayGroupId      
   ,TCE.intEntityEmployeeId        
   ,EL.intEmployeeEarningId        
   ,EL.intTypeEarningId        
   ,TCE.intEmployeeDepartmentId        
  ,@intDefaultWorkersCompensationId      
   ,EL.strCalculationType        
   ,TCE.dblOvertimeHours        
   ,TCE.dblOvertimeHours        
   ,EL.dblRateAmount         
   ,ROUND(TCE.dblOvertimeHours * EL.dblRateAmount, 2)        
   ,CAST(FLOOR(CAST(@dtmBegin AS FLOAT)) AS DATETIME)        
   ,CAST(FLOOR(CAST(@dtmEnd AS FLOAT)) AS DATETIME)        
   ,3        
   ,1        
  FROM tblPREmployeeEarning EL         
  INNER JOIN (SELECT   
  EE.intTypeEarningId       
      ,EE.intEntityEmployeeId      
      ,EE.intEmployeeEarningId      
      ,intEmployeeDepartmentId      
      ,SUM(dblOvertimeHours) dblOvertimeHours --SELECT EE.*, TC.dblRegularHours, TC.dblOvertimeHours, TC.intEmployeeDepartmentId         
            ,TC.intWorkersCompensationId      
   ,EE.intPayGroupId  
            FROM #tmpTimecard TC INNER JOIN tblPREmployeeEarning EE         
            ON TC.intEmployeeEarningId = EE.intEmployeeEarningId      
            GROUP BY EE.intTypeEarningId       
          ,EE.intEntityEmployeeId      
          ,EE.intEmployeeEarningId      
          ,intEmployeeDepartmentId      
                ,TC.intWorkersCompensationId      
    ,EE.intPayGroupId  
    ) TCE        
   ON EL.intEmployeeEarningLinkId = TCE.intTypeEarningId        
    AND EL.intEntityEmployeeId = TCE.intEntityEmployeeId         
  WHERE TCE.intEmployeeDepartmentId = @intEmployeeDepartmentId        
    AND TCE.dblOvertimeHours > 0        
    AND TCE.intEntityEmployeeId = @intEntityEmployeeId        
  AND TCE.intWorkersCompensationId = @intWorkersCompensationId      
    AND EL.strCalculationType IN ('Overtime')        
        
  /* Insert Shift Differential Hours To Pay Group Detail */        
  INSERT INTO tblPRPayGroupDetail        
   (intPayGroupId     
   ,intEntityEmployeeId        
   ,intEmployeeEarningId        
   ,intTypeEarningId        
   ,intDepartmentId        
  ,intWorkersCompensationId      
   ,strCalculationType        
   ,dblDefaultHours        
   ,dblHoursToProcess        
   ,dblAmount        
   ,dblTotal        
   ,dtmDateFrom        
   ,dtmDateTo        
   ,intSort        
   ,intConcurrencyId)        
  SELECT        
   EL.intPayGroupId        
   ,EL.intEntityEmployeeId        
   ,EL.intEmployeeEarningId        
   ,EL.intTypeEarningId        
   ,SD.intEmployeeDepartmentId        
  ,SD.intWorkersCompensationId      
   ,EL.strCalculationType        
   ,0        
   ,0        
   ,SUM(SD.dblTotal)        
   ,SUM(SD.dblTotal)        
   ,CAST(FLOOR(CAST(@dtmBegin AS FLOAT)) AS DATETIME)        
   ,CAST(FLOOR(CAST(@dtmEnd AS FLOAT)) AS DATETIME)        
   ,1        
   ,1        
  FROM        
   (SELECT TCSH.*,         
    dblTotal = CONVERT(NUMERIC(18, 2), dblHours * CASE WHEN (strDifferentialPay = 'Shift') THEN dblMaxRate ELSE dblRate END)        
   FROM         
    (SELECT         
     SHIFTHOURS.*,        
     MAXRATE.dblMaxRate        
    FROM        
    (SELECT TCS.*        
      ,dblHours = CONVERT(NUMERIC(18, 2),        
       CASE WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftStart AND dtmTimeOut < dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmShiftStart, dtmTimeOut) AS NUMERIC(18, 6)) / 60       
        WHEN (dtmTimeIn > dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut > dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmTimeIn, dtmShiftEnd) AS NUMERIC(18, 6)) / 60        
        WHEN (dtmTimeIn >= dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut <= dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmTimeIn, dtmTimeOut) AS NUMERIC(18, 6)) / 60        
        WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmShiftStart, dtmShiftEnd) AS NUMERIC(18, 6)) / 60        
        ELSE 0        
      END)        
     FROM        
     (SELECT        
      TC.intTimecardId, TC.dtmDate, TC.intEntityEmployeeId, TC.intEmployeeEarningId, EE.intTypeEarningId,        
     TC.intEmployeeDepartmentId, TC.intWorkersCompensationId, DS.intShiftNo, TC.dtmTimeIn, TC.dtmTimeOut, D.strDifferentialPay      
      ,dtmShiftStart = DATEADD(HH, DATEPART(HH, dtmStart), DATEADD(MI, DATEPART(MI, dtmStart), DATEADD(SS, DATEPART(SS, dtmStart), DATEADD(MS, DATEPART(MS, dtmStart), dtmDate))))        
      ,dtmShiftEnd = CASE WHEN (dtmStart > dtmEnd) THEN        
            DATEADD(HH, DATEPART(HH, dtmEnd), DATEADD(MI, DATEPART(MI, dtmEnd), DATEADD(SS, DATEPART(SS, dtmEnd), DATEADD(MS, DATEPART(MS, dtmEnd), DATEADD(DD, 1, dtmDate)))))        
           ELSE        
            DATEADD(HH, DATEPART(HH, dtmEnd), DATEADD(MI, DATEPART(MI, dtmEnd), DATEADD(SS, DATEPART(SS, dtmEnd), DATEADD(MS, DATEPART(MS, dtmEnd), dtmDate))))        
           END        
      ,dblRate = CONVERT(NUMERIC(18, 6),        
         CASE WHEN (strRateType = 'Per Hour') THEN        
           DS.dblRate        
          ELSE         
           ISNULL((SELECT TOP 1 dblRateAmount FROM tblPREmployeeEarning         
              WHERE intEmployeeEarningId = TC.intEmployeeEarningId         
              AND intEntityEmployeeId = TC.intEntityEmployeeId), 0)         
           * DS.dblRate        
          END)        
     FROM         
     (SELECT intTimecardId, intEntityEmployeeId, intEmployeeEarningId, intEmployeeDepartmentId, intWorkersCompensationId, dtmDate      
       ,dtmTimeIn = DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), dtmTimeIn)        
       ,dtmTimeOut = DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), dtmTimeOut)         
      FROM tblPRTimecard        
      WHERE ysnApproved = 1 AND intPaycheckId IS NULL AND intPayGroupDetailId IS NULL AND dblHours > 0        
       AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)        
       AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmDate) AS FLOAT)) AS DATETIME)        
       AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmDate) AS FLOAT)) AS DATETIME)) TC        
      INNER JOIN tblPREmployeeEarning EE        
       ON TC.intEmployeeEarningId = EE.intEmployeeEarningId        
       AND TC.intEntityEmployeeId = EE.intEntityEmployeeId        
      LEFT JOIN tblPRDepartmentShift DS         
       ON TC.intEmployeeDepartmentId = DS.intDepartmentId        
      INNER JOIN tblPRDepartment D        
       ON D.intDepartmentId = DS.intDepartmentId        
     ) TCS        
     WHERE         
      CONVERT(NUMERIC(18, 2),        
       CASE WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftStart AND dtmTimeOut < dtmShiftEnd) THEN     
         CAST(DATEDIFF(MI, dtmShiftStart, dtmTimeOut) AS NUMERIC(18, 6)) / 60        
        WHEN (dtmTimeIn > dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut > dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmTimeIn, dtmShiftEnd) AS NUMERIC(18, 6)) / 60        
        WHEN (dtmTimeIn >= dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut <= dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmTimeIn, dtmTimeOut) AS NUMERIC(18, 6)) / 60        
        WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmShiftStart, dtmShiftEnd) AS NUMERIC(18, 6)) / 60        
        ELSE 0        
      END) > 0        
     ) SHIFTHOURS        
     INNER JOIN         
     (SELECT intTimecardId        
       ,dblMaxRate = MAX(dblRate)        
      FROM        
      (SELECT        
       TC.intTimecardId, TC.dtmDate, TC.intEntityEmployeeId, TC.intEmployeeEarningId, EE.intTypeEarningId,        
      TC.intEmployeeDepartmentId, TC.intWorkersCompensationId, DS.intShiftNo, TC.dtmTimeIn, TC.dtmTimeOut, D.strDifferentialPay      
       ,dtmShiftStart = DATEADD(HH, DATEPART(HH, dtmStart), DATEADD(MI, DATEPART(MI, dtmStart), DATEADD(SS, DATEPART(SS, dtmStart), DATEADD(MS, DATEPART(MS, dtmStart), dtmDate))))        
       ,dtmShiftEnd = CASE WHEN (dtmStart > dtmEnd) THEN        
            DATEADD(HH, DATEPART(HH, dtmEnd), DATEADD(MI, DATEPART(MI, dtmEnd), DATEADD(SS, DATEPART(SS, dtmEnd), DATEADD(MS, DATEPART(MS, dtmEnd), DATEADD(DD, 1, dtmDate)))))        
           ELSE        
            DATEADD(HH, DATEPART(HH, dtmEnd), DATEADD(MI, DATEPART(MI, dtmEnd), DATEADD(SS, DATEPART(SS, dtmEnd), DATEADD(MS, DATEPART(MS, dtmEnd), dtmDate))))        
           END        
       ,dblRate = CONVERT(NUMERIC(18, 6),        
          CASE WHEN (strRateType = 'Per Hour') THEN        
            DS.dblRate        
           ELSE         
            ISNULL((SELECT TOP 1 dblRateAmount FROM tblPREmployeeEarning         
               WHERE intEmployeeEarningId = TC.intEmployeeEarningId         
               AND intEntityEmployeeId = TC.intEntityEmployeeId), 0)         
            * DS.dblRate        
           END)        
      FROM         
      (SELECT intTimecardId, intEntityEmployeeId, intEmployeeEarningId, intEmployeeDepartmentId, intWorkersCompensationId, dtmDate      
        ,dtmTimeIn = DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), dtmTimeIn)        
        ,dtmTimeOut = DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), dtmTimeOut)         
       FROM tblPRTimecard        
       WHERE ysnApproved = 1 AND intPaycheckId IS NULL AND intPayGroupDetailId IS NULL AND dblHours > 0        
        AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)        
        AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmDate) AS FLOAT)) AS DATETIME)        
        AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmDate) AS FLOAT)) AS DATETIME)) TC        
       INNER JOIN tblPREmployeeEarning EE        
        ON TC.intEmployeeEarningId = EE.intEmployeeEarningId        
        AND TC.intEntityEmployeeId = EE.intEntityEmployeeId        
       LEFT JOIN tblPRDepartmentShift DS         
        ON TC.intEmployeeDepartmentId = DS.intDepartmentId        
       INNER JOIN tblPRDepartment D        
        ON D.intDepartmentId = DS.intDepartmentId        
      ) TCS        
      WHERE         
       CONVERT(NUMERIC(18, 2),        
        CASE WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftStart AND dtmTimeOut < dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmShiftStart, dtmTimeOut) AS NUMERIC(18, 6)) / 60        
        WHEN (dtmTimeIn > dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut > dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmTimeIn, dtmShiftEnd) AS NUMERIC(18, 6)) / 60        
        WHEN (dtmTimeIn >= dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut <= dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmTimeIn, dtmTimeOut) AS NUMERIC(18, 6)) / 60        
        WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftEnd) THEN        
         CAST(DATEDIFF(MI, dtmShiftStart, dtmShiftEnd) AS NUMERIC(18, 6)) / 60        
        ELSE 0        
       END) > 0        
      GROUP BY intTimecardId        
     ) MAXRATE        
     ON SHIFTHOURS.intTimecardId = MAXRATE.intTimecardId        
    ) TCSH        
   ) SD        
   LEFT JOIN tblPREmployeeEarning EL        
   ON SD.intTypeEarningId = EL.intEmployeeEarningLinkId        
   AND SD.intEntityEmployeeId = EL.intEntityEmployeeId        
     WHERE SD.intEmployeeDepartmentId = @intEmployeeDepartmentId        
      AND SD.dblTotal > 0        
      AND SD.intEntityEmployeeId = @intEntityEmployeeId        
      AND EL.strCalculationType IN ('Shift Differential')        
   GROUP BY        
    EL.intPayGroupId        
    ,EL.intEntityEmployeeId        
    ,EL.intEmployeeEarningId        
    ,EL.intTypeEarningId        
    ,SD.intEmployeeDepartmentId        
   ,SD.intWorkersCompensationId      
    ,EL.strCalculationType        
        
  /* Update Processed Timecards */        
  UPDATE tblPRTimecard        
  SET 
   -- dblRegularHours = Y.dblRegularHours        
   --,dblOvertimeHours = Y.dblOvertimeHours        
    intPayGroupDetailId = @intPayGroupDetailId        
   ,intProcessedUserId = @intUserId        
   ,dtmProcessed = GETDATE()        
  FROM        
  (SELECT        
   intTimecardId        
   ,dblRegularHours = CASE WHEN (X.dblDefaultHours > 0) THEN        
        CASE WHEN (X.dblDefaultHours > X.dblRunningHours) THEN X.dblHours         
         ELSE CASE WHEN (X.dblHours < (X.dblRunningHours - X.dblDefaultHours)) THEN 0        
           ELSE X.dblHours - (X.dblRunningHours - X.dblDefaultHours) END        
         END        
        ELSE X.dblHours END        
     ,dblOvertimeHours = CASE WHEN (X.dblDefaultHours > 0) THEN        
        CASE WHEN (X.dblDefaultHours > X.dblRunningHours) THEN 0         
         ELSE CASE WHEN (X.dblHours < (X.dblRunningHours - X.dblDefaultHours)) THEN X.dblHours         
         ELSE (X.dblRunningHours - X.dblDefaultHours) END        
         END        
        ELSE 0 END        
  FROM        
   (SELECT         
    TC.intTimecardId        
    ,TC.intEntityEmployeeId        
    ,TC.dtmDate        
    ,TC.intEmployeeEarningId        
    ,TC.intEmployeeDepartmentId        
   ,TC.intWorkersCompensationId      
    ,TC.dtmTimeIn        
    ,TC.dtmTimeOut        
    ,TC.ysnApproved        
    ,TC.dblHours        
    ,EE.dblDefaultHours        
    ,dblRunningHours = (SELECT        
          SUM (TCR.dblHours)         
         FROM        
          tblPRTimecard TCR        
         WHERE         
          TCR.dtmTimeOut <= TC.dtmTimeOut         
          AND TCR.intEntityEmployeeId = TC.intEntityEmployeeId        
          AND TCR.intEmployeeEarningId = TC.intEmployeeEarningId        
          AND TCR.intEmployeeDepartmentId = TC.intEmployeeDepartmentId        
         AND TCR.intWorkersCompensationId = TC.intWorkersCompensationId      
          AND CAST(FLOOR(CAST(TCR.dtmDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,TCR.dtmDate) AS FLOAT)) AS DATETIME)        
          AND CAST(FLOOR(CAST(TCR.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,TCR.dtmDate) AS FLOAT)) AS DATETIME))        
   FROM        
    tblPRTimecard TC LEFT JOIN tblPREmployeeEarning EE        
    ON TC.intEmployeeEarningId = EE.intEmployeeEarningId        
   WHERE        
    TC.ysnApproved = 1        
    AND TC.dblHours > 0        
    AND TC.intEmployeeEarningId = @intEmployeeEarningId        
    AND TC.intEmployeeDepartmentId = @intEmployeeDepartmentId        
   AND TC.intWorkersCompensationId = @intWorkersCompensationId      
    AND CAST(FLOOR(CAST(TC.dtmDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,TC.dtmDate) AS FLOAT)) AS DATETIME)        
    AND CAST(FLOOR(CAST(TC.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,TC.dtmDate) AS FLOAT)) AS DATETIME)        
   GROUP BY         
    TC.intTimecardId        
    ,TC.intEntityEmployeeId        
    ,TC.dtmDate        
    ,TC.intEmployeeEarningId        
    ,TC.intEmployeeDepartmentId        
   ,TC.intWorkersCompensationId      
    ,TC.dblHours        
    ,TC.dtmTimeIn        
    ,TC.dtmTimeOut        
    ,TC.ysnApproved        
    ,EE.dblDefaultHours) X        
   ) Y        
  WHERE tblPRTimecard.intTimecardId = Y.intTimecardId        
        
  /* Loop Control */        
 UPDATE #tmpTimecard       
 SET ysnProcessed = 1      
  WHERE intEmployeeEarningId = @intEmployeeEarningId        
   AND intEmployeeDepartmentId = @intEmployeeDepartmentId         
   AND intEntityEmployeeId = @intEntityEmployeeId        
  AND intWorkersCompensationId = @intWorkersCompensationId      
  AND ysnProcessed = 0      
 END        
        
/* Insert Overtime Hours To Pay Group Detail */      
INSERT INTO tblPRPayGroupDetail      
 (intPayGroupId      
 ,intEntityEmployeeId      
 ,intEmployeeEarningId      
 ,intTypeEarningId      
 ,intDepartmentId      
 ,intWorkersCompensationId      
 ,strCalculationType      
 ,dblDefaultHours      
 ,dblHoursToProcess      
 ,dblAmount      
 ,dblTotal      
 ,dtmDateFrom      
 ,dtmDateTo      
 ,intSource      
 ,intSort      
 ,intConcurrencyId)      
SELECT DISTINCT       
 intPayGroupId      
 ,intEntityEmployeeId      
 ,intEmployeeEarningId      
 ,intTypeEarningId      
 ,intDepartmentId      
 ,intWorkersCompensationId      
 ,strCalculationType      
 ,dblDefaultHours = SUM(ISNULL(dblDefaultHours,0))      
 ,dblHoursToProcess = SUM(ISNULL(dblHoursToProcess,0))      
 ,dblAmount = SUM(ISNULL(dblAmount,0))      
 ,dblTotal = SUM(ISNULL(dblTotal,0))      
 ,dtmDateFrom      
 ,dtmDateTo      
 ,intSource      
 ,intSort      
 ,1      
FROM @TimecardOvertime      
GROUP BY intPayGroupId      
 ,intEntityEmployeeId      
 ,intEmployeeEarningId      
 ,intTypeEarningId      
 ,intDepartmentId      
 ,intWorkersCompensationId      
 ,strCalculationType      
 ,dtmDateFrom      
 ,dtmDateTo      
 ,intSource      
 ,intSort      
      
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTimecard')) DROP TABLE #tmpTimecard        
        
END