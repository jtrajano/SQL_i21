--liquibase formatted sql

-- changeset Von:fnCTCheckIfPaid.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTCheckIfPaid]
(
	@intPriceContractId INT
)
RETURNS BIT
AS
BEGIN

	DECLARE @ysnPaid BIT = 0

	IF EXISTS
	(
		SELECT TOP 1 1
		FROM tblAPPaymentDetail BP
		INNER JOIN tblCTPriceFixationDetailAPAR APAR ON BP.intBillId = APAR.intBillId
		INNER JOIN tblCTPriceFixationDetail PFD ON PFD.intPriceFixationDetailId = APAR.intPriceFixationDetailId
		INNER JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = PFD.intPriceFixationId
		WHERE PF.intPriceContractId = @intPriceContractId
		GROUP BY PFD.intPriceFixationDetailId
	)
	BEGIN
		SET @ysnPaid = 1
	END

	RETURN @ysnPaid

END



