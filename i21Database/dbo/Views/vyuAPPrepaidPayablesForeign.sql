CREATE VIEW [dbo].[vyuAPPrepaidPayablesForeign]
AS

SELECT * FROM vyuAPPrepaidPayablesForeignPartial
UNION ALL  
  
SELECT B.dtmDate, B.intBillId, B.strBillId, PF.dblDiscrepancy, 0, 0, 0, 0, 0, 0, V.strVendorId, ISNULL(V.strVendorId, '') + ' - ' + ISNULL(E.strName, ''), B.dtmDueDate, B.ysnPosted, B.ysnPaid, A.intAccountId, A.strAccountId, EC.strClass, B.intCurrencyId  
FROM (  
 SELECT PF.strBillId, (PF.dblCalculatedDue - PF.dblAmountDue) dblDiscrepancy  
 FROM (  
  SELECT strBillId, SUM(dblTotal + dblInterest - dblAmountPaid - dblDiscount) dblCalculatedDue, SUM(dblAmountDue) dblAmountDue  
  FROM vyuAPPrepaidPayablesForeignPartial  
  GROUP BY strBillId  
 ) PF  
 INNER JOIN tblAPBill B ON B.strBillId = PF.strBillId  
 WHERE PF.dblCalculatedDue <> PF.dblAmountDue  
) PF  
INNER JOIN tblAPBill B ON B.strBillId = PF.strBillId  
LEFT JOIN (tblAPVendor V INNER JOIN tblEMEntity E ON E.intEntityId = V.intEntityId) ON V.intEntityId = B.intEntityVendorId  
LEFT JOIN tblEMEntityClass EC ON EC.intEntityClassId = E.intEntityClassId  
LEFT JOIN tblGLAccount A ON A.intAccountId = B.intAccountId  
WHERE PF.dblDiscrepancy > -1 AND PF.dblDiscrepancy < 1


GO