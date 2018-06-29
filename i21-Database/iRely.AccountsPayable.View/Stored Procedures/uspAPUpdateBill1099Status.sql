CREATE PROCEDURE [dbo].[uspAPUpdateBill1099Status]
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL,
	@year INT,
	@form1099 INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE A
	SET A.ysn1099Printed = Status1099.ysnPrinted
FROM tblAPBillDetail A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
INNER JOIN tblAPVendor C ON B.intEntityVendorId = C.[intEntityId]
CROSS APPLY (
	SELECT
		TOP 1 *
	FROM tblAP1099History C
	WHERE C.intEntityVendorId = B.intEntityVendorId
	AND YEAR(B.dtmDate) = @year
	AND A.int1099Form = C.int1099Form
	ORDER BY C.dtmDatePrinted DESC
) Status1099
WHERE 
1 = (CASE WHEN ISNULL(@vendorFrom,'') = '' THEN 1
				WHEN ISNULL(@vendorFrom,'') <> '' AND C.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
AND YEAR(B.dtmDate) = @year
AND A.int1099Form = @form1099
AND 1 = (CASE WHEN B.intTransactionType = 9 THEN 1 
			WHEN B.intTransactionType != 9 AND B.ysnPosted = 1 THEN 1
			ELSE 0 END)
AND 1 = (CASE WHEN B.intTransactionType = 9 THEN 1
			WHEN B.intTransactionType != 9 AND B.dblPayment > 0 THEN 1 ELSE 0 END)


