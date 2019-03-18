print 'Start Update Credit Card Processing from Vantiv to WorldPay'

if exists( select top 1 1 from tblSMCompanyPreference where strCreditCardProcessingType = 'Vantiv')
begin
	print 'execute'
	update tblSMCompanyPreference set strCreditCardProcessingType  = 'Worldpay' where strCreditCardProcessingType = 'Vantiv'

end

print 'End Update Credit Card Processing from Vantiv to WorldPay'