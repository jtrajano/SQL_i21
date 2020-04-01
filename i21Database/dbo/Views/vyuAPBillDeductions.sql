CREATE VIEW [dbo].[vyuAPBillDeductions]
--WITH SCHEMABINDING
AS

SELECT
    PD.intId
    ,PD.intBillId
    ,PD.intLineApplied
    ,PD.strTransactionNumber
    ,PD.strItemNo
    ,PD.strItemDescription
    ,PD.strContractNumber
    ,PD.intPrepayType
    ,PD.dblTotal
    ,PD.dblBillAmount
    ,PD.dblBalance
    ,PD.dblAmountApplied

    ,BD.intBillDetailId
    ,BD.intTransactionType
    ,BD.strTransactionType
    ,BD.strBillId
    ,BD.strVendorOrderNumber
    ,BD.dtmDate
    ,BD.dtmDateCreated
    ,BD.ysnPosted
    ,BD.ysnPaid
    ,BD.ysnClr
    ,BD.strName
    ,BD.strLocationName
    ,BD.intEntityVendorId
FROM [20.1Dev].[dbo].[tblAPAppliedPrepaidAndDebit] PD
INNER JOIN dbo.vyuAPBillDetail BD ON PD.intBillId = BD.intBillId
