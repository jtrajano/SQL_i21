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

    ,1 AS intBillDetailId
    ,BV.intTransactionType
    ,BV.strTransactionType
    ,BV.strBillId
    ,BV.strVendorOrderNumber
    ,BV.dtmDate
    ,BV.dtmDateCreated
    ,BV.ysnPosted
    ,BV.ysnPaid
    ,ISNULL(VP.ysnClr,0) AS ysnClr
    ,BV.strName
    ,CL.strLocationName
    ,BV.intEntityVendorId
FROM [20.1Dev].[dbo].[tblAPAppliedPrepaidAndDebit] PD
INNER JOIN dbo.vyuAPBill BV 
	ON PD.intBillId = BV.intBillId
INNER JOIN dbo.tblAPBill BT
	ON BV.intBillId = BT.intBillId
LEFT JOIN dbo.vyuAPVouchersPaymentInfo VP
	ON VP.intBillId = BT.intBillId
INNER JOIN dbo.tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = BT.intShipToId
