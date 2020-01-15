CREATE FUNCTION [dbo].[fnCTGetVoucherDetail]
(
	@type NVARCHAR(10),
	@Id INT
)
RETURNS @table TABLE
(
	[strBillId]		NVARCHAR(MAX),
	[ysnPaid]		BIT
)
AS
BEGIN
		
	DECLARE @List NVARCHAR(MAX)

	IF @type = 'price' --Price Contract
	BEGIN
		INSERT INTO @table
		(
			[strBillId],
			[ysnPaid]		
		)
		SELECT TOP 1 (COALESCE(@List + ',', '') + e.strBillId) AS strBillId, e.ysnPaid
		FROM tblCTPriceContract a
		INNER JOIN tblCTPriceFixation b ON a.intPriceContractId = b.intPriceContractId
		INNER JOIN tblCTPriceFixationDetail c ON b.intPriceFixationId = c.intPriceFixationId
		INNER JOIN tblCTPriceFixationDetailAPAR d ON c.intPriceFixationDetailId = d.intPriceFixationDetailId
		INNER JOIN tblAPBill e ON d.intBillId = e.intBillId
		WHERE a.intPriceContractId = @Id
	END
	ELSE -- Price Fixation
	BEGIN
		INSERT INTO @table
		(
			[strBillId],
			[ysnPaid]		
		)
		SELECT TOP 1 (COALESCE(@List + ',', '') + c.strBillId) AS strBillId, c.ysnPaid
		FROM tblCTPriceFixationDetail a
		INNER JOIN tblCTPriceFixationDetailAPAR b ON a.intPriceFixationDetailId = b.intPriceFixationDetailId
		INNER JOIN tblAPBill c ON b.intBillId = c.intBillId
		WHERE a.intPriceFixationDetailId = @Id
	END

	RETURN
END