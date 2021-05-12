/*
    For checking Asset on a closed period when closing a fiscal period
*/
CREATE VIEW [dbo].[vyuFAClosedPeriodAsset]
AS
WITH FA as(
select 
A.strAssetId,
A.intAssetId,
CASE WHEN BD.intBookId = 1 THEN 'GAAP' ELSE 'Tax' END Book,
A.dtmDateInService,
DATEADD( MONTH, (DM.intServiceYear  * 12) + ISNULL( DM.intMonth, 0) , A.dtmDateInService) LastDateOfService
from vyuFAFixedAsset A join
tblFABookDepreciation BD on A.intAssetId = BD.intAssetId join
tblFADepreciationMethod DM on DM.intDepreciationMethodId = BD.intDepreciationMethodId
WHERE ISNULL(ysnDisposed,0) = 0 and ISNULL(ysnAcquired,0) = 1
AND A.ysnFullyDepreciated = 0
),
DateRange as(
select FA.strAssetId,LB.dtmStartDate,
 UB.dtmEndDate
from FA 
outer apply(
select  dtmStartDate, dtmEndDate from
tblGLFiscalYearPeriod
where dtmDateInService between dtmStartDate and dtmEndDate
) LB
outer apply(
select dtmStartDate, dtmEndDate from
tblGLFiscalYearPeriod
where LastDateOfService between dtmStartDate and dtmEndDate
) UB
)
select strAssetId, intGLFiscalYearPeriodId, strPeriod, intFiscalYearId from DateRange DR
cross apply (
	select intGLFiscalYearPeriodId, strPeriod, intFiscalYearId 
	from tblGLFiscalYearPeriod where dtmStartDate between DR.dtmStartDate and DR.dtmEndDate
	and (isnull(ysnOpen,0) | isnull(ysnFAOpen,0)) = 0
)FP




GO

