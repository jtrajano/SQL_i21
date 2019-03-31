CREATE VIEW [dbo].[vyuAPVoucherInfo]
AS 

WITH 
lastVoucher
(
	dblLastVoucherTotal,
	dblLastVoucherDate
)
AS
(
	SELECT TOP 1
		dblLastVoucherTotal		=	A.dblTotal,
		dblLastVoucherDate		=	A.dtmDate
	FROM tblAPBill A
	ORDER BY intBillId DESC
),
lastYearVoucherTotal(dblLastYearVoucherTotal)
AS
(
	SELECT dbo.[fnAPGetLYVoucher]()
),
ytdVouchers(dblYTDVoucherTotal)
AS
(
	SELECT dbo.[fnAPGetYTDPurchases]()
)

SELECT 
	CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INT) AS intVoucherInfoId,
	* 
FROM lastVoucher, lastYearVoucherTotal, ytdVouchers;
