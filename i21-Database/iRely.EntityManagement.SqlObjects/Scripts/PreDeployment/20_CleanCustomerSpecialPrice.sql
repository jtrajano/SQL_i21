GO
PRINT 'Start Checking Customer Special Price'

IF OBJECT_ID('FK_tblARCustomerSpecialPrice_tblARCustomer') IS NULL
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerSpecialPrice' and [COLUMN_NAME] = 'intEntityCustomerId')
	 AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' and [COLUMN_NAME] = 'intEntityCustomerId')
	
	BEGIN
		PRINT 'CLEAN CUSTOMER SPECIAL PRICE'
		

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblTRQuoteDetail' and [COLUMN_NAME] = 'intSpecialPriceId')
		BEGIN
			
			IF object_id('tblTRQuoteDetail_162_163_special_price_orphan_cleanup') IS NOT NULL 
			BEGIN
				PRINT 'DROPING TABLE tblTRQuoteDetail_162_163_special_price_orphan_cleanup'
				EXEC('DROP TABLE tblTRQuoteDetail_162_163_special_price_orphan_cleanup')
			END


			PRINT 'ADDING QUOTE'
				EXEC('SELECT * INTO tblTRQuoteDetail_162_163_special_price_orphan_cleanup FROM tblTRQuoteDetail where intSpecialPriceId in (select intSpecialPriceId from tblARCustomerSpecialPrice where intEntityCustomerId not in (select intEntityCustomerId from tblARCustomer))')



			EXEC('DELETE FROM tblTRQuoteDetail where intSpecialPriceId in (select intSpecialPriceId from tblARCustomerSpecialPrice where intEntityCustomerId not in (select intEntityCustomerId from tblARCustomer))')
		END

		EXEC('DELETE tblARCustomerSpecialPrice where intEntityCustomerId not in (select intEntityCustomerId from tblARCustomer)')

	END

	
END

PRINT 'End Checking Customer Special Price'
GO