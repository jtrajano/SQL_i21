CREATE VIEW [dbo].[vyuICETExportItemMessages]
	AS SELECT 	 imsgno = strItemNo
				,imsg1 = strInvoiceComments
				,imsg2 = ''
				,imsg3 = ''
				,iamsgno = 0
	FROM tblICItem
