print('/*******************  BEGIN Updating Customer Rack Quote Header *******************/')
GO

	Update
		tblARCustomerRackQuoteHeader  
	set
		strShowTaxFeeDetail = (CASE WHEN ysnShowFeightDetail = convert(bit,1) and ysnShowTaxDetail = convert(bit,1) THEN 'Itemize' else 'Roll-up' END) 
	where
		strShowTaxFeeDetail is null

GO
print('/*******************  END Updating Customer Rack Quote Header *******************/')