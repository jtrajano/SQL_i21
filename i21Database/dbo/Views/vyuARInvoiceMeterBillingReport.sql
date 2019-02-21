CREATE VIEW [dbo].[vyuARInvoiceMeterBillingReport]
AS
SELECT intInvoiceId				= I.intInvoiceId
	 , intInvoiceDetailId		= ID.intInvoiceDetailId
	 , intMeterReadingId		= MRD.intMeterReadingId
	 , strMeterKey				= MAD.strMeterKey
	 , dblLastReading			= MRD.dblLastReading
	 , dblCurrentReading		= MRD.dblCurrentReading
	 , dblQtyShipped			= ID.dblQtyShipped
FROM tblARInvoice I 
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN tblMBMeterReading MR ON I.intMeterReadingId = MR.intMeterReadingId AND I.intInvoiceId = MR.intInvoiceId
INNER JOIN tblMBMeterReadingDetail MRD ON MR.intMeterReadingId = MRD.intMeterReadingId
INNER JOIN tblMBMeterAccountDetail MAD ON MRD.intMeterAccountDetailId = MAD.intMeterAccountDetailId AND ID.intItemId = MAD.intItemId
WHERE I.strType = 'Meter Billing'