CREATE VIEW [dbo].[vyuMBILPayment]
	AS
	
SELECT Payment.intPaymentId
	, Payment.strPaymentNo
	, Payment.intEntityCustomerId
	, strCustomerNo = Customer.strEntityNo
	, strCustomerName = Customer.strName
	, intLocationId = Payment.intCompanyLocationId
	, Location.strLocationName
	, Payment.intEntityDriverId
	, Driver.strDriverNo
	, Driver.strDriverName
	, Payment.intShiftId
	, Shift.intShiftNumber
	, dtmDatePaid
	, Payment.strMethod
	, Payment.strCheckNumber
	, Payment.dblPayment
	, Payment.strComments
	, Payment.intConcurrencyId
FROM tblMBILPayment Payment
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = Payment.intEntityCustomerId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Payment.intCompanyLocationId
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = Payment.intEntityDriverId
LEFT JOIN tblMBILShift Shift ON Shift.intShiftId = Payment.intShiftId