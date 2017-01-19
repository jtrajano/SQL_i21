CREATE VIEW [dbo].[vyuFRDRowDesign]
AS

select 

intRowDetailId
,B.intRowId
,B.strRowName
,B.strDescription as strHeaderDescription
,intRefNo
,'R' + CAST(intRefNo as NVARCHAR(10)) as strRefNo
,A.strDescription
,strRowType
,strBalanceSide
,strSource
,strRelatedRows
,strAccountsUsed
,strAccountsType
,ysnShowCredit
,ysnShowDebit
,ysnShowOthers
,ysnLinktoGL
,ysnPrintEach
,ysnPercentage
,ysnHidden
,dblHeight
,strFontName
,strFontStyle
,strFontColor
,intFontSize
,strOverrideFormatMask
,ysnForceReversedExpense
,ysnOverrideFormula
,ysnOverrideColumnFormula
,intSort

from tblFRRowDesign A
inner join tblFRRow B
on A.intRowId = B.intRowId

