CREATE PROCEDURE [dbo].[uspPATGetPostedRefundFromAPBill]
	@intRefundId					INT
AS
BEGIN
	SELECT intBillId FROM tblAPBill WHERE strVendorOrderNumber LIKE CONCAT('PAT-',@intRefundId,'-%') AND ysnPosted = 1
END
GO