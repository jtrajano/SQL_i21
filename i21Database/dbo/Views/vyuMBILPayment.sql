CREATE VIEW [dbo].[vyuMBILPayment]
	AS
	
SELECT Payment.intPaymentId
	, Payment.strPaymentNo
	, Payment.intEntityCustomerId
	, strCustomerNo = Customer.strEntityNo
	, strCustomerName = Customer.strName
	, Payment.intLocationId
	, Location.strLocationName
	, Payment.intEntityDriverId
	, Driver.strDriverNo
	, Driver.strDriverName
	, Payment.intShiftId
	, Shift.intShiftNumber
	, Payment.dtmDatePaid
	, Payment.strMethod
	, Payment.strCheckNumber
	, Payment.dblPayment
	, Payment.strComments
	, Payment.strVoidComments
	--, Payment.ysnPosted
	, ysnPosted = cast(case when i21Payment.intPaymentId is null then 0 else 1 end as bit)
	, Payment.ysnVoided
	, Payment.dtmPostedDate
	, Payment.dtmVoidedDate
	--, Payment.inti21PaymentId
	, inti21PaymentId = i21Payment.intPaymentId
	, Payment.intConcurrencyId
FROM tblMBILPayment Payment
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = Payment.intEntityCustomerId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Payment.intLocationId
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = Payment.intEntityDriverId
LEFT JOIN tblMBILShift Shift ON Shift.intShiftId = Payment.intShiftId
LEFT JOIN tblARPayment i21Payment ON Payment.inti21PaymentId = i21Payment.intPaymentId