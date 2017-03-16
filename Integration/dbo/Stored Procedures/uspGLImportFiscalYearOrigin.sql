EXEC('IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLImportFiscalYearOrigin'' and type = ''P'')
	DROP PROCEDURE [dbo].[uspGLImportFiscalYearOrigin];')

EXEC(
'CREATE PROCEDURE [dbo].[uspGLImportFiscalYearOrigin]
AS
BEGIN
IF OBJECT_ID(''tempOriginFY'') IS NOT NULL DROP TABLE tempOriginFY
select * into tempOriginFY from glfypmst
IF OBJECT_ID(''tempFiscalYear'') IS NOT NULL DROP TABLE tempFiscalYear
CREATE TABLE [dbo].[tempFiscalYear](
    [intFiscalYearId] [int] IDENTITY(1,1) NOT NULL,
    [strFiscalYear] [nvarchar](50) NOT NULL,
    [intRetainAccount] [int] NULL,
    [dtmDateFrom] [datetime] NULL,
    [dtmDateTo] [datetime] NULL,
    [ysnStatus] [bit] NOT NULL,
    [intConcurrencyId] [int] NOT NULL,
    )
insert into tempFiscalYear
(
strFiscalYear
,intRetainAccount
,dtmDateFrom
,dtmDateTo
,ysnStatus
,intConcurrencyId
)
select
glfyp_yr
,(select  A.intAccountId
    from tblGLAccount A
    inner join tblGLCOACrossReference B
    on A.intAccountId = B.inti21Id
  
    inner join glactmst C
    on C.A4GLIdentity  = B.intLegacyReferenceId
    inner join glctlmst D
    ON  D.glctl_ret_earn_main = C.glact_acct1_8
    where D.glctl_ret_earn_sub = C.glact_acct9_16
)
, ((substring(convert(varchar(10),glfyp_beg_date_1),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_1),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_1),1,4)))
, ((substring(convert(varchar(10),glfyp_end_date_12),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_12),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_12),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
from glfypmst
IF OBJECT_ID(''tempFiscalyearDetail'') IS NOT NULL DROP TABLE tempFiscalyearDetail
CREATE TABLE [dbo].[tempFiscalyearDetail](
    [intGLFiscalYearPeriodId] [int] IDENTITY(1,1) NOT NULL,
    [intFiscalYearId] [int] NOT NULL,
    [strPeriod] [nvarchar](30) NULL,
    [dtmStartDate] [datetime] NOT NULL,
    [dtmEndDate] [datetime] NOT NULL,
    [ysnOpen] [bit] NOT NULL,
    [intConcurrencyId] [int] NOT NULL,
    )
-- Period 1
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_1),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_1),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_1),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_1),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_1),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_1),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_1),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_1),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_1),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 2
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_2),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_2),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_2),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_2),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_2),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_2),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_2),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_2),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_2),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 3
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_3),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_3),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_3),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_3),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_3),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_3),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_3),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_3),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_3),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 4
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_4),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_4),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_4),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_4),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_4),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_4),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_4),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_4),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_4),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 5
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_5),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_5),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_5),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_5),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_5),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_5),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_5),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_5),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_5),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 6
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_6),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_6),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_6),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_6),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_6),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_6),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_6),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_6),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_6),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 7
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_7),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_7),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_7),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_7),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_7),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_7),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_7),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_7),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_7),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 8
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_8),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_8),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_8),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_8),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_8),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_8),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_8),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_8),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_8),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 9
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_9),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_9),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_9),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_9),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_9),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_9),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_9),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_9),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_9),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 10
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_10),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_10),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_10),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_10),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_10),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_10),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_10),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_10),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_10),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 11
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_11),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_11),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_11),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_11),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_11),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_11),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_11),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_11),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_11),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear
-- Period 12
insert into tempFiscalyearDetail (
intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId)
select
B.intFiscalYearId
, (select datename(month,dateadd(month, MONTH ((((substring(convert(varchar(10),A.glfyp_beg_date_12),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_12),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_12),1,4))) )) -1 , 0)) as MonthName) + '' '' + (select  CONVERT(varchar, YEAR(B.dtmDateFrom)))
  
,((substring(convert(varchar(10),glfyp_beg_date_12),5,2) 
+''/''+substring(convert(varchar(10),glfyp_beg_date_12),7,2)
+''/''+substring(convert(varchar(10),glfyp_beg_date_12),1,4)))
,((substring(convert(varchar(10),glfyp_end_date_12),5,2) 
+''/''+substring(convert(varchar(10),glfyp_end_date_12),7,2)
+''/''+substring(convert(varchar(10),glfyp_end_date_12),1,4)))
,(CASE WHEN glfyp_closed_yn =''N'' THEN 1 ELSE 0 END)
,1
 from
glfypmst A
inner join tempFiscalYear B
on A.glfyp_yr = B.strFiscalYear

delete from tblGLFiscalYearPeriod
delete from tblGLBudget
delete from tblGLFiscalYear
SET IDENTITY_INSERT tblGLFiscalYear ON
insert into tblGLFiscalYear
(
intFiscalYearId
,strFiscalYear
,intRetainAccount
,dtmDateFrom
,dtmDateTo
,ysnStatus
,intConcurrencyId
)
select
intFiscalYearId
,strFiscalYear
,intRetainAccount
,dtmDateFrom
,dtmDateTo
,ysnStatus
,intConcurrencyId
from tempFiscalYear
SET IDENTITY_INSERT tblGLFiscalYear OFF
SET IDENTITY_INSERT tblGLFiscalYearPeriod ON
insert into tblGLFiscalYearPeriod(
intGLFiscalYearPeriodId
,intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId
)
select
intGLFiscalYearPeriodId
,intFiscalYearId
,strPeriod
,dtmStartDate
,dtmEndDate
,ysnOpen
,intConcurrencyId
from tempFiscalyearDetail

update tblGLFiscalYearPeriod
set ysnAPOpen = 0
,ysnAROpen  = 0
,ysnINVOpen  = 0
,ysnCMOpen = 0 
,ysnPROpen = 0
,ysnCTOpen=0
where intFiscalYearId in (select intFiscalYearId from tblGLFiscalYear where  ysnStatus = 0 )

SET IDENTITY_INSERT tblGLFiscalYearPeriod OFF
END')
