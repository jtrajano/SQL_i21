CREATE VIEW [dbo].[vyuGRGetPurchaseSaleDetail]
AS
SELECT
	 SUM(ISNULL(a.dblOriginalBalance,0)) dblOriginalBalance 
	,SUM(ISNULL(SH.dblUnits,0)*-1) dblUnits
FROM tblGRCustomerStorage a
LEFT JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId=a.intCustomerStorageId
Where ISNULL(SH.strType,'')='TakeOut' AND ISNULL(a.strStorageType,'') <> 'ITR'
