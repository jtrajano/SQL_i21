CREATE PROCEDURE [dbo].[uspAPUpdateBill1099Status]
	@vendorFrom INT,
	@vendorTo INT,
	@year INT,
	@form1099 INT
AS

UPDATE A
	SET A.ysn1099Printed = Status1099.ysnPrinted
FROM tblAPBillDetail A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
CROSS APPLY (
	SELECT
		*
	FROM tblAP1099History C
	WHERE C.intEntityVendorId = B.intEntityVendorId
	AND YEAR(B.dtmDate) = @year
) Status1099
WHERE B.intEntityVendorId BETWEEN (CASE WHEN @vendorTo < @vendorFrom THEN @vendorTo ELSE @vendorFrom END) 
					AND (CASE WHEN @vendorTo < @vendorFrom THEN @vendorFrom ELSE @vendorTo END)
			AND YEAR(B.dtmDate) = @year
			AND A.int1099Form = @form1099
			AND B.ysnPosted = 1 AND B.dblPayment > 0


