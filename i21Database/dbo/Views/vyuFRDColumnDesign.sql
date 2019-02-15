CREATE VIEW [dbo].[vyuFRDColumnDesign]
AS

select 

intColumnDetailId
,B.intColumnId
,B.strColumnName
,B.strDescription as strHeaderDescription
,intRefNo
,'C' + CAST(intRefNo as NVARCHAR(10)) as strRefNo
,ysnReverseSignforExpense
,strSegmentUsed
,strColumnHeader
,strColumnCaption
,A.strColumnType
,strColumnCode
,strFilterType
,strStartOffset
,strEndOffset
,dtmStartDate
,dtmEndDate
,strJustification
,strFormatMask
,strColumnFormula
,ysnHiddenColumn
,dblWidth
,intBudgetCode
,intSegmentFilterGroupId
,intPercentageId
,intSort

from tblFRColumnDesign A
inner join tblFRColumn B
on A.intColumnId = B.intColumnId
