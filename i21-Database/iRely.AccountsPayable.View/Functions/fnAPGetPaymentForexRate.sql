CREATE FUNCTION [dbo].[fnAPGetPaymentForexRate]()
RETURNS @table TABLE(intBillId INT PRIMARY KEY, dblExchangeRate DECIMAL(18,6))
AS
BEGIN
	--GET THE AVERAGE OF FOREX PER PAYMENT
	--GET THE FOREX RATE OF VOUCHER IF IT HAS A CONTRACT, IF NOT USE THE CURRENCY EXCHANGE RATE SETUP
	INSERT INTO @table
	SELECT
		intBillId
		,SUM(ISNULL(NULLIF(paymentRate.dblRate,0), 1)) / COUNT(*)
	FROM (
		SELECT
			voucher.intBillId
			,CASE WHEN voucherDetail.intContractDetailId > 0 AND ISNULL(voucherDetail.dblRate,1) != 1 
					THEN voucherDetail.dblRate ELSE ISNULL(payment.dblExchangeRate,1) END dblRate
		FROM tblAPPayment payment
		INNER JOIN tblAPPaymentDetail paymentDetail ON payment.intPaymentId = paymentDetail.intPaymentId
		INNER JOIN tblAPBill voucher ON ISNULL(paymentDetail.intBillId, paymentDetail.intOrigBillId) = voucher.intBillId
		INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
		OUTER APPLY (
			SELECT TOP 1
				dblRate
			FROM tblSMCurrencyExchangeRate exchangeRate
			INNER JOIN tblSMCurrencyExchangeRateDetail exchangeRateDetail ON exchangeRate.intCurrencyExchangeRateId = exchangeRateDetail.intCurrencyExchangeRateId
			WHERE exchangeRateDetail.intRateTypeId = (SELECT intAccountsPayableRateTypeId FROM tblSMMultiCurrency)
			AND exchangeRate.intFromCurrencyId = payment.intCurrencyId 
			AND exchangeRate.intToCurrencyId =  (SELECT intDefaultCurrencyId FROM tblSMCompanyPreference)
			AND exchangeRateDetail.dtmValidFromDate <= payment.dtmDatePaid
			ORDER BY exchangeRateDetail.dtmValidFromDate DESC
		) forexRate
		WHERE paymentDetail.dblPayment != 0
	) paymentRate
	GROUP BY intBillId

	RETURN;
END
