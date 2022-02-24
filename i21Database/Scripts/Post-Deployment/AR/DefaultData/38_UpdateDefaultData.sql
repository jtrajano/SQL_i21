print('/*******************  BEGIN Update tblARCompanyPreference *******************/')
GO

UPDATE tblARCompanyPreference SET intPageLimit = 1000 WHERE intPageLimit IS NULL

GO
print('/*******************  BEGIN Update tblARCompanyPreference  *******************/')

print('/*******************  BEGIN Update tblARInvoice *******************/')
GO

UPDATE tblARInvoice SET dblInvoiceTotal = 0 WHERE dblInvoiceTotal IS NULL
UPDATE tblARInvoice SET dblAmountDue = 0 WHERE dblAmountDue IS NULL
UPDATE tblARInvoice SET dblDiscount = 0 WHERE dblDiscount IS NULL
UPDATE tblARInvoice SET dblInterest = 0 WHERE dblInterest IS NULL
UPDATE tblARInvoice SET dtmDate = CAST(dtmDate AS DATE) WHERE CAST(dtmDate AS TIME) <> '00:00:00.0000000'
UPDATE tblARInvoice SET dtmPostDate = CAST(dtmPostDate AS DATE) WHERE CAST(dtmPostDate AS TIME) <> '00:00:00.0000000'

GO
print('/*******************  BEGIN Update tblARInvoice  *******************/')

print('/*******************  BEGIN Update tblARPayment *******************/')
GO

ALTER TABLE tblARPayment DISABLE TRIGGER trg_tblARPaymentUpdate
ALTER TABLE tblARPaymentDetail DISABLE TRIGGER trg_tblARPaymentDetailUpdate

UPDATE tblARPayment SET dblAmountPaid = 0 WHERE dblAmountPaid IS NULL
UPDATE tblARPayment SET dtmDatePaid = CAST(dtmDatePaid AS DATE) WHERE CAST(dtmDatePaid AS TIME) <> '00:00:00.0000000'

GO
print('/*******************  BEGIN Update tblARPayment  *******************/')

print('/*******************  BEGIN Update tblARPaymentDetail *******************/')
GO

UPDATE tblARPaymentDetail SET dblPayment = 0 WHERE dblPayment IS NULL
UPDATE tblARPaymentDetail SET dblAmountDue = 0 WHERE dblAmountDue IS NULL
UPDATE tblARPaymentDetail SET dblDiscount = 0 WHERE dblDiscount IS NULL
UPDATE tblARPaymentDetail SET dblInterest = 0 WHERE dblInterest IS NULL
UPDATE tblARPaymentDetail SET dblWriteOffAmount = 0 WHERE dblWriteOffAmount IS NULL

ALTER TABLE tblARPayment ENABLE TRIGGER trg_tblARPaymentUpdate
ALTER TABLE tblARPaymentDetail ENABLE TRIGGER trg_tblARPaymentDetailUpdate

GO
print('/*******************  BEGIN Update tblARPaymentDetail  *******************/')