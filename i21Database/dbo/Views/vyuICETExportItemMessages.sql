CREATE VIEW [dbo].[vyuICETExportItemMessages]
	AS SELECT 	 imsgno = strItemNo
				,imsg1 = SUBSTRING(strInvoiceComments,1,60)
				,imsg2 = ''
				,imsg3 = ''
				,iamsgno = 0
	FROM tblICItem
